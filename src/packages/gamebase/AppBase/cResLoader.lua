local cDataQueue = import("..CommonUtility.cDataQueue")
local cFakeGameResLoader = import(".cFakeGameResLoader")
local cResLoader = class("cResLoader")
--[[
	加载资源调用异步加载接口，一次性加载一个资源
	图片资源加载成功之后，再进行加载其他的资源
--]]
local oDirector = cc.Director:getInstance()
local oFileUtils = cc.FileUtils:getInstance()
assert( oDirector ~= nil and oFileUtils ~= nil )
local oTextureCache = oDirector:getTextureCache()
local oSpriteFrameCache = cc.SpriteFrameCache:getInstance()
local oArmatureDataManager = ccs.ArmatureDataManager:getInstance()
assert( oTextureCache ~= nil and oArmatureDataManager ~= nil and oSpriteFrameCache ~= nil )

function oFileUtils:getFileSize( sFilePath )
	local fileData = cc.HelperFunc:getFileData( "res/" .. sFilePath ) or ""
	return string.len( fileData )
end

cResLoader.TLoadWorkConf = 
{--  类型				文件扩展名长度      合法扩展名
	["UI"] 			= { ExtLength = 5, Exts={'.json',} },
	["TEXTURE"] 	= { ExtLength = 4, Exts={'.jpg', '.png',} },
	["SPRITEFRAME"] = { ExtLength = 6, Exts={'.plist', } },
	["ARMATURE"] 	= { ExtLength = 11,Exts={'.exportjson',} },
	["JSON_DATA"] 	= { ExtLength = 5, Exts={'.json',} },
	["CFG_DATA"] 	= { ExtLength = 5, Exts={'.json',} },
	["UI_NODE_PRE_CREATE"]= { ExtLength = 5, Exts={'.json'} },
	["DYN_ITEM_CACHE_CREATE"]= { ExtLength = 5, Exts={'.json'}, },
}

function cResLoader:ctor( sName, nId )
	self.m_oResManager = nil
	self.m_sName = sName
	self.m_nId = nId
	self.m_tLoadWorkList = {}
	self.m_tFileLoadedList = {}
	self.m_tTotalLoadSize = {}
	self.m_tWorkLoadedSize = {}
	self.m_tLoadedOkList = {}
	self.m_tFileLoadQueue = {}
	self.m_tCurLoadingFileConf = nil
	for i, v in pairs( cResLoader.TLoadWorkConf ) do
		self.m_tLoadWorkList[i] = {}
		self.m_tFileLoadedList[i] = {}
		self.m_tWorkLoadedSize[i] = 0
		self.m_tTotalLoadSize[i] = 0
		self.m_tLoadedOkList[i] = false
		self.m_tFileLoadQueue[i] = cDataQueue:new()
	end
	self.m_pLoadOverCallback = nil
	self.m_tLoadOverCallbackData = nil
	self.m_pLoadOverCallbackCalled = false
	self.m_oOwnerScene = nil
end

function cResLoader:Init()
end

function cResLoader:SetGameApp( oGameApp )
	self.m_oGameApp = oGameApp
end

function cResLoader:GetGameApp()
	return self.m_oGameApp
end

function cResLoader:SetResManager( manager )
	self.m_oResManager = manager
end

function cResLoader:GetResManager()
	return self.m_oResManager
end

function cResLoader:SetOwnerScene( ownerScene )
	self.m_oOwnerScene = ownerScene
end

function cResLoader:GetOwnerScene()
	return self.m_oOwnerScene
end

function cResLoader:SetLoadOverDestory( bLoadOverDestroy )
	self.m_bLoadOverDestory = bLoadOverDestroy
end

function cResLoader:GetName()
	return self.m_sName
end

function cResLoader:IsLoadOverDestory()
	return self.m_bLoadOverDestory
end

--[[
	sWorkType: 异步加载工作类型,类型种类 SCENE UI ARMATURE TEXTURE
	sFilePath: 需要被异步加载的文件路径
	sLoadType: 加载类型: 直接加载，还是间接加载(可能UI中引用了某个图片) 类型: DIRECT REF_UI REF_SCENE REF_ARMATURE
	tParams: 额外参数,辅助判定是进行的什么类型的加载
--]]
function cResLoader:AddAsyncLoadWork( sWorkType, sLoadType, sFilePath, tParams )
		sLoadType = sLoadType or "DIRECT"
	assert( sWorkType == "TEXTURE" or sWorkType == "ARMATURE" or sWorkType == "UI" or sWorkType == "SPRITEFRAME" or 
			sWorkType == "JSON_DATA" or sWorkType == "CFG_DATA" or sWorkType == "UI_NODE_PRE_CREATE" or sWorkType == "DYN_ITEM_CACHE_CREATE" )
	--检查文件扩展名
	local tLoadWorkConf = cResLoader.TLoadWorkConf[ sWorkType ]
	if tLoadWorkConf == nil then
		return false, string.format( "AddAsyncLoadWork Err: invalid work type %s", sWorkType )
	end
	local sExtensions = string.sub( sFilePath, -tonumber(tLoadWorkConf.ExtLength),-1 )
	if sExtensions == nil then
		return false, "AddAsyncLoadWork Err: invalid file extension name."
	end
	local bExtValid = false
	for i, v in ipairs( tLoadWorkConf.Exts ) do
		if string.lower( sExtensions ) == string.lower( v ) then
			bExtValid = true
			break
		end
	end
	if bExtValid == false then
		return false, "AddAsyncLoadWork Err: invalid file extension name" --扩展名不合法
	end
	--检查文件是否已经在列表中准备加载(避免重复加载的情况)
	local tLoadWorkList = self.m_tLoadWorkList[ sWorkType ]
	if tLoadWorkList == nil then
		return false, "AddAsyncLoadWork Err: can't find work list."
	end
	local bFound = false
	for i, v in pairs( tLoadWorkList ) do
		if v.FilePath == sFilePath then
			bFound = true
			return false, "AddAsyncLoadWork Err: exist in work list"
		end
	end
	local bFileExist = oFileUtils:isFileExist( "res/" .. sFilePath )
	local nFileSize = oFileUtils:getFileSize( sFilePath )
	if bFileExist == true and nFileSize ~= nil then
		tLoadWorkList[#tLoadWorkList+1] = { FilePath = sFilePath, Size = nFileSize, Type = sWorkType, LoadType = sLoadType, Params = tParams }
		self.m_tTotalLoadSize[sWorkType] = self.m_tTotalLoadSize[sWorkType] + nFileSize
		return true
	end
end

function cResLoader:StartRun( pCallback, tCallbackData )
	self.m_pLoadOverCallback = pCallback
	self.m_tLoadOverCallbackData = tCallbackData
	self.m_pLoadOverCallbackCalled = false
	local oUILoadQueue = self.m_tFileLoadQueue["UI"]
	if oUILoadQueue ~= nil then
		for i, v in pairs( self.m_tLoadWorkList["UI"] ) do
			oUILoadQueue:InQueue( v )
		end
	end
	if next(self.m_tLoadWorkList["UI"]) == nil then
		self.m_tLoadedOkList["UI"] = true
	end
	local oJsonDataLoadQueue = self.m_tFileLoadQueue["JSON_DATA"]
	if oJsonDataLoadQueue ~= nil then
		for i, v in pairs( self.m_tLoadWorkList["JSON_DATA"] ) do
			oJsonDataLoadQueue:InQueue( v )
		end
	end
	if next(self.m_tLoadWorkList["JSON_DATA"]) == nil then
		self.m_tLoadedOkList["JSON_DATA"] = true
	end
	local oArmatureLoadQueue = self.m_tFileLoadQueue[ "ARMATURE" ]
	if oArmatureLoadQueue ~= nil then
		for i, v in pairs( self.m_tLoadWorkList["ARMATURE"] ) do --这里可能会出现加载不完全的问题.
			oArmatureLoadQueue:InQueue( v )
		end
	end
	if next(self.m_tLoadWorkList["ARMATURE"]) == nil then
		self.m_tLoadedOkList["ARMATURE"] = true
	end
	local tAddTextures = {}
	local oSpriteFrameQueue = self.m_tFileLoadQueue[ "SPRITEFRAME" ]
	if oSpriteFrameQueue ~= nil then
		for i, v in pairs( self.m_tLoadWorkList["SPRITEFRAME"] ) do
			oSpriteFrameQueue:InQueue( v )
			table.insert( tAddTextures, v.Params )
		end
	end
	if next(self.m_tLoadWorkList["SPRITEFRAME"]) == nil then
		self.m_tLoadedOkList["SPRITEFRAME"] = true
	end
	for i, v in ipairs( tAddTextures ) do
		self:AddAsyncLoadWork( "TEXTURE", "DIRECT", v )
	end	
	local oTextureLoadQueue = self.m_tFileLoadQueue[ "TEXTURE" ]
	if oTextureLoadQueue ~= nil then
		for i, v in pairs( self.m_tLoadWorkList["TEXTURE"] ) do
			oTextureLoadQueue:InQueue( v )
		end
	end
	if next(self.m_tLoadWorkList["TEXTURE"]) == nil then
		self.m_tLoadedOkList["TEXTURE"] = true
	end
	local oCfgDataLoadQueue = self.m_tFileLoadQueue[ "CFG_DATA" ]
	if oCfgDataLoadQueue ~= nil then
		for i, v in pairs( self.m_tLoadWorkList["CFG_DATA"] ) do
			oCfgDataLoadQueue:InQueue( v )
		end
	end
	if next(self.m_tLoadWorkList["CFG_DATA"]) == nil then
		self.m_tLoadedOkList["CFG_DATA"] = true
	end
	local oUINodePreCreateQueue = self.m_tFileLoadQueue["UI_NODE_PRE_CREATE"]
	if oUINodePreCreateQueue ~= nil then
		for i, v in pairs( self.m_tLoadWorkList["UI_NODE_PRE_CREATE"] ) do
			oUINodePreCreateQueue:InQueue( v )
		end
	end
	if next(self.m_tLoadWorkList["UI_NODE_PRE_CREATE"]) == nil then
		self.m_tLoadedOkList["UI_NODE_PRE_CREATE"] = true
	end
	local oDynItemPreCreateQueue = self.m_tFileLoadQueue["DYN_ITEM_CACHE_CREATE"]
	if oDynItemPreCreateQueue ~= nil then
		for i, v in pairs( self.m_tLoadWorkList["DYN_ITEM_CACHE_CREATE"] ) do
			oDynItemPreCreateQueue:InQueue( v )
		end
	end
	if next(self.m_tLoadWorkList["DYN_ITEM_CACHE_CREATE"]) == nil then
		self.m_tLoadedOkList["DYN_ITEM_CACHE_CREATE"] = true
	end
	--开始进行加载图片资源
	self:LoadOneJsonData()
	local bAllLoadedOk = true
	for i, v in pairs(self.m_tLoadedOkList) do
		if v == false then
			bAllLoadedOk = false
		end
	end
	if bAllLoadedOk == true then
		self:OnLoadAllResOk()
	end
end

function cResLoader:OnLoadAllResOk()
	local oResManager = self.m_oResManager
	if oResManager == nil then
		return
	end
	oResManager:OnAsyncLoaderLoadOk( self.m_sName )
end

function cResLoader:LoadOneUIData()
	--回调函数，闭包用法，可以方便找到self
	local function LoadUIDataCallback()
		if self.m_tCurLoadingFileConf ~= nil then
			self:PrintLoadInfo( true, self.m_tCurLoadingFileConf )
			self:UpdateAsyncWorkLoadedOk( "UI" )
		end
		self:LoadOneUIData()
	end
	local oLoadQueue = self.m_tFileLoadQueue[ "UI" ]
	if oLoadQueue ~= nil then
		local tLoadWork = oLoadQueue:OutQueue()
		if tLoadWork ~= nil then
			self.m_tCurLoadingFileConf = tLoadWork
			self:PrintLoadInfo( false, self.m_tCurLoadingFileConf )
			self.m_oResManager:AddUIJsonFileDecodeDataAsync( tLoadWork.FilePath, LoadUIDataCallback )
		else
			self.m_tCurLoadingFileConf = nil
			self:LoadOneTexture()
		end
	end
end

function cResLoader:LoadOneTexture()
	--回调函数，闭包用法，可以方便找到self
	local function LoadTextureCallback()
		if self.m_tCurLoadingFileConf ~= nil then
			self:PrintLoadInfo( true, self.m_tCurLoadingFileConf )
			self:UpdateAsyncWorkLoadedOk( "TEXTURE" )
		end
		self:LoadOneTexture()
	end
	local oLoadQueue = self.m_tFileLoadQueue[ "TEXTURE" ]
	if oLoadQueue ~= nil then
		local tLoadWork = oLoadQueue:OutQueue()
		if tLoadWork ~= nil then
			self.m_tCurLoadingFileConf = tLoadWork
			self:PrintLoadInfo( false, self.m_tCurLoadingFileConf )
			oTextureCache:addImageAsync( tLoadWork.FilePath, LoadTextureCallback )
		else
			self.m_tCurLoadingFileConf = nil
			self:LoadOneSpriteFrame()
		end
	end
end

function cResLoader:LoadOneJsonData()
	--回调函数，闭包用法，可以方便找到self
	local function LoadJsonDataCallback()
		if self.m_tCurLoadingFileConf ~= nil then
			self:PrintLoadInfo( true, self.m_tCurLoadingFileConf )
			self:UpdateAsyncWorkLoadedOk( "JSON_DATA" )
		end
		self:LoadOneJsonData()
	end
	local oLoadQueue = self.m_tFileLoadQueue[ "JSON_DATA" ]
	if oLoadQueue ~= nil then
		local tLoadWork = oLoadQueue:OutQueue()
		if tLoadWork ~= nil then
			self.m_tCurLoadingFileConf = tLoadWork
			self:PrintLoadInfo( false, self.m_tCurLoadingFileConf )
			self.m_oResManager:AddJsonFileDecodeAsync( tLoadWork.FilePath, LoadJsonDataCallback )
		else
			self.m_tCurLoadingFileConf = nil
			self:ConvertOneCfgData()
		end
	end
end

function cResLoader:ConvertOneCfgData()
	--回调函数，闭包用法，可以方便找到self
	local function ConvertCfgDataCallback()
		if self.m_tCurLoadingFileConf ~= nil then
			self:PrintLoadInfo( true, self.m_tCurLoadingFileConf )
			self:UpdateAsyncWorkLoadedOk( "CFG_DATA" )
		end
		self:ConvertOneCfgData()
	end
	local oLoadQueue = self.m_tFileLoadQueue[ "CFG_DATA" ]
	if oLoadQueue ~= nil then
		local tLoadWork = oLoadQueue:OutQueue()
		if tLoadWork ~= nil then
			self.m_tCurLoadingFileConf = tLoadWork
			self:PrintLoadInfo( false, self.m_tCurLoadingFileConf )
			self.m_oResManager:addConvertCfgDataAsync( tLoadWork.FilePath, tLoadWork.Params, ConvertCfgDataCallback )
		else
			self.m_tCurLoadingFileConf = nil
			self:LoadOneUIData()
		end
	end
end

function cResLoader:LoadOneArmature()
	local function LoadArmatureCallback()
		if self.m_tCurLoadingFileConf ~= nil then
			self:PrintLoadInfo( true, self.m_tCurLoadingFileConf )
			self:UpdateAsyncWorkLoadedOk( "ARMATURE" )
		end
		self:LoadOneArmature()
	end
	local oLoadQueue = self.m_tFileLoadQueue[ "ARMATURE" ]
	if oLoadQueue ~= nil then
		local tLoadWork = oLoadQueue:OutQueue()
		if tLoadWork ~= nil then
			self.m_tCurLoadingFileConf = tLoadWork
			self:PrintLoadInfo( false, self.m_tCurLoadingFileConf )
			oArmatureDataManager:addArmatureFileInfoAsync( tLoadWork.FilePath, LoadArmatureCallback )
		else
			self.m_tCurLoadingFileConf = nil
			self:PreCreateOneUINode()
		end
	end
end

function cResLoader:PreCreateOneUINode()
	local function PreCreateUINodeCallback()
		if self.m_tCurLoadingFileConf ~= nil then
			self:PrintLoadInfo( true, self.m_tCurLoadingFileConf )
			self:UpdateAsyncWorkLoadedOk( "UI_NODE_PRE_CREATE" )
		end
		self:PreCreateOneUINode()
	end
	local oLoadQueue = self.m_tFileLoadQueue[ "UI_NODE_PRE_CREATE" ]
	if oLoadQueue ~= nil then
		local tLoadWork = oLoadQueue:OutQueue()
		if tLoadWork ~= nil then
			self.m_tCurLoadingFileConf = tLoadWork
			self:PrintLoadInfo( false, self.m_tCurLoadingFileConf )
			self.m_oResManager:AddUINodePreCreateAsync( tLoadWork.FilePath, PreCreateUINodeCallback )
		else
			self.m_tCurLoadingFileConf = nil
		end
	end
end

function cResLoader:LoadOneSpriteFrame()
	local function LoadSpriteFrameCallback()
		if self.m_tCurLoadingFileConf ~= nil then
			self:PrintLoadInfo( true, self.m_tCurLoadingFileConf )
			self:UpdateAsyncWorkLoadedOk( "SPRITEFRAME" )
		end
		self:LoadOneSpriteFrame()
	end
	local oLoadQueue = self.m_tFileLoadQueue["SPRITEFRAME"]
	if oLoadQueue ~= nil then
		local tLoadWork = oLoadQueue:OutQueue()
		if tLoadWork ~= nil then
			self.m_tCurLoadingFileConf = tLoadWork
			self:PrintLoadInfo( false, self.m_tCurLoadingFileConf )
			self.m_oResManager:AddSpriteFramesWithFileAsync( tLoadWork.FilePath, tLoadWork.Params, LoadSpriteFrameCallback )
		else
			self.m_tCurLoadingFileConf = nil
			self:LoadOneArmature()
		end
	end
end

function cResLoader:PrintLoadInfo( bOk, tLoadingFileConf )
	if CONFIG_DEBUG_SHOW_LOAD_RES_INFO ~= true then
		return
	end
	if bOk ~= true then
		print( string.format( "Load [%s]: %s Size:%s Time:%s", tLoadingFileConf.Type, tLoadingFileConf.FilePath, tLoadingFileConf.Size or 0, os.clock() ) )
	else
		print( string.format( "OK [%s]: %s Time:%s", tLoadingFileConf.Type, tLoadingFileConf.FilePath, os.clock() ) )
	end
end

function cResLoader:UpdateAsyncWorkLoadedOk( sWorkType )
	assert( sWorkType == "TEXTURE" or sWorkType == "ARMATURE" or sWorkType == "UI" or sWorkType == "SPRITEFRAME" or sWorkType == "JSON_DATA" or 
			sWorkType == "CFG_DATA" or sWorkType == "UI_NODE_PRE_CREATE" or sWorkType == "DYN_ITEM_CACHE_CREATE" )
	local tLoadedOk = {}
	--检查是否加载完毕了,如果加载完毕，则回调，判定这次的加载OK
	for i, v in ipairs( self.m_tLoadWorkList[sWorkType] ) do
		tLoadedOk[v.FilePath] = false
	end
	--这里需要保证，一次回调函数，只会认为加载了一个文件
	local bHaveLoadedFile = false
	for i, v in ipairs( self.m_tLoadWorkList[sWorkType] ) do
		if self.m_tFileLoadedList[sWorkType][v.FilePath] ~= true then
			if bHaveLoadedFile == false then	--也就是每次回调，这里只判定为加载了一个文件，而不是多个
				local bCheckLoaded = false
				if sWorkType == "TEXTURE" then
					local oTexture = oTextureCache:getTextureForKey( v.FilePath )
					if oTexture ~= nil then
						bCheckLoaded = true
					end
				elseif sWorkType == "ARMATURE" then
					local oArmature = oArmatureDataManager:getArmatureData( v.Params )
					if oArmature ~= nil then
						bCheckLoaded = true
					end
				elseif sWorkType == "SPRITEFRAME" then
					local bIsSpriteFrameLoaded = self.m_oResManager:IsSpriteFrameLoaded( v.FilePath )
					if bIsSpriteFrameLoaded == true then
						bCheckLoaded = true
					end
				elseif sWorkType == "JSON_DATA" then
					local bIsJsonLoaded = self.m_oResManager:IsJsonCfgDataLoaded( v.FilePath )
					if bIsJsonLoaded == true then
						self.m_oResManager:initJsonFieldsAndTypes( v.FilePath, v.Params )
						bCheckLoaded = true
					end
				elseif sWorkType == "UI" then
					local bIsUILoaded = self.m_oResManager:IsUIJsonFileDecodeDataLoaded( v.FilePath )
					if bIsUILoaded == true then
						bCheckLoaded = true
					end
				elseif sWorkType == "CFG_DATA" then
					local bIsCfgDataConverted = self.m_oResManager:IsCfgDataConverted( v.FilePath )
					if bIsCfgDataConverted == true then
						bCheckLoaded = true
					end
				elseif sWorkType == "UI_NODE_PRE_CREATE" then
					local oGameApp = self:GetGameApp()
					if oGameApp ~= nil then
						local oUIManager = oGameApp:GetUIManager()
						if oUIManager ~= nil then
							local oNode = oUIManager:GetUIFromFilePath( v.FilePath )
							if oNode ~= nil then
								bCheckLoaded = true
							end
						end
					end
				elseif sWorkType == "DYN_ITEM_CACHE_CREATE" then
					bCheckLoaded = true
				end
				local nFileSize = v.Size
				if bCheckLoaded == true and nFileSize ~= nil then
					self.m_tWorkLoadedSize[sWorkType] = self.m_tWorkLoadedSize[sWorkType] + nFileSize
					self.m_tFileLoadedList[sWorkType][v.FilePath] = true
					tLoadedOk[v.FilePath] = true
					--如果是armature,则加入到已加载armature列表里面,注册，方便之后进行清理
					if sWorkType == "ARMATURE" then
						local oResManager = self:GetResManager()
						if oResManager ~= nil then
							oResManager:addLoadedArmatureFileInfo( v.FilePath )
						end
					end
					bHaveLoadedFile = true
					--如果这里是加载UI图片资源,则刷新，看是否UI资源更新完成
					if v.LoadType ~= "DIRECT" then
						if v.LoadType == "UI_REF" and v.Params ~= nil and v.Params.LoadWork ~= nil then
							if sWorkType == "TEXTURE" then
								if v.Params.LoadWork.NeedLoadTextures[ v.FilePath ] == false then
									v.Params.LoadWork.NeedLoadTextures[ v.FilePath ] = true
								end
								self:UpdateAsyncWorkLoadedOk( "UI" )
							end
						end
					end
				end
			end
		else
			tLoadedOk[v.FilePath] = true
		end
	end
	local bLoadedOk = true
	for i, v in pairs(tLoadedOk) do
		if v == false then
			bLoadedOk = false
			break
		end
	end
	--加载完毕
	if bLoadedOk == true then
		if self.m_tLoadedOkList[sWorkType] == false then
			self.m_tLoadedOkList[sWorkType] = true
		end
		local bAllLoadedOk = true
		for i, v in pairs(self.m_tLoadedOkList) do
			if v == false then
				bAllLoadedOk = false
			end
		end
		if bAllLoadedOk == true then
			self:OnLoadAllResOk()
		end
	end
end

function cResLoader:OnDoResLoadCallback()
	if self.m_pLoadOverCallback ~= nil then
		if self.m_pLoadOverCallbackCalled == false then
			self.m_pLoadOverCallbackCalled = true
			self.m_bIsLoadOver = true
			self.m_pLoadOverCallback( self.m_sName, self.m_nId, self.m_tLoadOverCallbackData )
		end
	end
end

function cResLoader:GetTotalLoadSize()
	local nTotalLoadedSize = 0
	for i, v in pairs( self.m_tTotalLoadSize ) do
		nTotalLoadedSize = nTotalLoadedSize + v
	end
	return nTotalLoadedSize
end

function cResLoader:GetLoadedSize()
	local nTotalLoadedSize = 0
	for i, v in pairs( self.m_tWorkLoadedSize ) do
		nTotalLoadedSize = nTotalLoadedSize + v
	end
	return nTotalLoadedSize
end

return cResLoader