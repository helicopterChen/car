local cResLoader = import(".cResLoader")
local cDataQueue = import("..CommonUtility.cDataQueue")
local cFakeGameResLoader = import(".cFakeGameResLoader")
local cResManager = class("cResManager")
local _tinsert = table.insert
local CONVERT_CFGDATA_EVERY_STEP_NUM = 33

local oDirector = cc.Director:getInstance()
local oFileUtils = cc.FileUtils:getInstance()
assert( oDirector ~= nil and oFileUtils ~= nil )
local oTextureCache = oDirector:getTextureCache()
local oSpriteFrameCache = cc.SpriteFrameCache:getInstance()
local oArmatureDataManager = ccs.ArmatureDataManager:getInstance()
assert( oTextureCache ~= nil and oArmatureDataManager ~= nil and oSpriteFrameCache ~= nil )

function cResManager:ctor()
	self.m_tSearchDirs = {}
	self.m_tUIJsonFileData = {}
	self.m_tCfgTypeAndFieldsDefData = {}
	self.m_tCfgConvertedDataMap = {}
	self.m_tCfgDataConvertedMark = {}
	self.m_tResAsyncLoaders = {}
	self.m_tResNameAsyncLoaderMap = {}
	self.m_tLoadedArmatureFileInfo = {}
	self.m_oNeedRunAsyncLoaderQueue = cDataQueue:new()
	self.m_oResAsyncLoaderOkQueue = cDataQueue:new()
	self.m_oNeedLoadUIResDataQueue = cDataQueue:new()
	self.m_oCfgConvertDataQueue = cDataQueue:new()
	self.m_oCfgConvertWorkStepQueue = cDataQueue:new()
	self.m_oUINodePreCreateQueue = cDataQueue:new()
	self.m_oCurRunLoader = nil
	self.m_nNextLoaderId = 1000000000
	--暂时不使用C++中的GameResLoader
	if false then
		self.m_oGameResLoader = GameResLoader:Instance()
	else
		self.m_oGameResLoader = cFakeGameResLoader:GetInstance()
	end
end

function cResManager:GetInstance()
	if _G.__oResManager == nil then
		_G.__oResManager = cResManager:new()
	end
	return _G.__oResManager
end

function cResManager:ClearResData()
	self.m_tResAsyncLoaders = {}
	self.m_tResNameAsyncLoaderMap = {}
	for i, v in pairs( self.m_tLoadedArmatureFileInfo ) do
		oArmatureDataManager:removeArmatureFileInfo( i )
	end
	oSpriteFrameCache:removeSpriteFrames()
	oTextureCache:removeAllTextures()
	self.m_nNextLoaderId = 1000000000
end

function cResManager:GetResAsyncLoaders()
	return self.m_tResAsyncLoaders
end

function cResManager:GetAsyncLoaderByName( sLoaderName )
	return self.m_tResNameAsyncLoaderMap[ sLoaderName ]
end

function cResManager:CreateNewResLoader( sLoaderName )
	local sName = sLoaderName or string.format( "WORK_ID_%d", self.m_nNextLoaderId )
	if sName ~= nil then
		local oAsyncLoader = cResLoader.new( sName, self.m_nNextLoaderId )
		if oAsyncLoader ~= nil then
			table.insert( self.m_tResAsyncLoaders, oAsyncLoader )
			self.m_tResNameAsyncLoaderMap[ sName ] = oAsyncLoader
			self.m_nNextLoaderId = self.m_nNextLoaderId + 1
			oAsyncLoader:Init()
			oAsyncLoader:SetGameApp( self.m_oGameApp )
			oAsyncLoader:SetResManager( self )
			return oAsyncLoader
		end
	end
end

function cResManager:DestoryResLoader( sLoaderName )
	local oAsyncLoader = self:GetAsyncLoaderByName( sLoaderName )
	if oAsyncLoader == nil then
		return
	end
	for i, v in ipairs( self.m_tResAsyncLoaders ) do
		if v == oAsyncLoader then
			table.remove( self.m_tResAsyncLoaders, i )
			break
		end
	end
	self.m_tResNameAsyncLoaderMap[ sLoaderName ] = nil
end

function cResManager:RunAsyncLoader( sLoaderName, pCallback, tCallbackData )
	local oAsyncLoader = self:GetAsyncLoaderByName( sLoaderName )
	if oAsyncLoader == nil then
		assert( false )
	end
	self.m_oNeedRunAsyncLoaderQueue:InQueue( {sLoaderName, pCallback, tCallbackData } )
end

function cResManager:OnAsyncLoaderLoadOk( sLoaderName )
	local oAsyncLoader = self:GetAsyncLoaderByName( sLoaderName )
	if oAsyncLoader == nil then
		return
	end
	self.m_oResAsyncLoaderOkQueue:InQueue( oAsyncLoader )
end

function cResManager:GetLoadedSize()
	local nLoadedSize = 0
	for i, v in ipairs( self.m_tResAsyncLoaders ) do
		nLoadedSize = nLoadedSize + v:GetLoadedSize()
	end
	return nLoadedSize
end

function cResManager:GetTotalLoadSize()
	local nLoadedSize = 0
	for i, v in ipairs( self.m_tResAsyncLoaders ) do
		nLoadedSize = nLoadedSize + v:GetTotalLoadSize()
	end
	return nLoadedSize
end

function cResManager:AddSpriteFramesWithFileAsync( plistPath, textureName, funcCallback )
    if self.m_oGameResLoader ~= nil then
        if plistPath == nil or plistPath == "" then
            return
        end
        local fileUtil = cc.FileUtils:getInstance()
        local fullPath = string.gsub( fileUtil:fullPathForFilename(plistPath), "\\", "/" )
        self:addSearchPathIf(io.pathinfo(fullPath).dirname, fileUtil)
        local bAddOk = self.m_oGameResLoader:addSpriteFramesWithFileAsync( plistPath, textureName, funcCallback )
    	if bAddOk ~= true then
	    	funcCallback()
    	end
    end
end

function cResManager:AddJsonFileDecodeAsync( jsonFilePath, funcCallback )
    if self.m_oGameResLoader ~= nil then
        if jsonFilePath == nil or jsonFilePath == "" then
            return
        end
        local fileUtil = cc.FileUtils:getInstance()
        local fullPath = string.gsub( fileUtil:fullPathForFilename(jsonFilePath), "\\", "/" )
        self:addSearchPathIf(io.pathinfo(fullPath).dirname, fileUtil)
        if self.m_oGameResLoader.m_bIsFake == true then
        	self.m_oGameResLoader:addJsonFileDecodeAsync( jsonFilePath, funcCallback )
        else
	        local bAddOk = self.m_oGameResLoader:addJsonFileDecodeAsync( jsonFilePath, funcCallback )
	    	if bAddOk ~= true then
	    		if funcCallback ~= nil then
		    		funcCallback()
		    	end
	    	end
	    end
	end
end

function cResManager:AddUINodePreCreateAsync( uiJsonFilePath, funcCallback )
	self.m_oUINodePreCreateQueue:InQueue( {uiJsonFilePath, funcCallback} )
end

function cResManager:AddConvertCfgDataAsync( jsonFilePath, tCfgDef, funcCallback )
	local bLoaded = self:isJsonCfgDataLoaded(jsonFilePath)
	if bLoaded == true then
		self.m_oCfgConvertDataQueue:InQueue( {jsonFilePath, tCfgDef, funcCallback} )
	end
end

function cResManager:AddUIJsonFileDecodeDataAsync( uiJsonFilePath, funcCallback )
	local bIsUIDataLoaded = self:IsUIJsonFileDecodeDataLoaded(uiJsonFilePath)
	if bIsUIDataLoaded == true then
		if funcCallback ~= nil then
			funcCallback()
		end
		return
	end
	self.m_oNeedLoadUIResDataQueue:InQueue( {uiJsonFilePath, funcCallback} )
end

function cResManager:AddUIJsonFileDecodeData( uiJsonFilePath, funcCallback )
	local jsonNode, jsonVal = cc.uiloader:loadAndParseFile( uiJsonFilePath )
	if jsonNode ~= nil and jsonVal ~= nil  then
		self.m_tUIJsonFileData[uiJsonFilePath] = { jsonNode, jsonVal }
		if funcCallback ~= nil then
			funcCallback()
		end
		return jsonNode, jsonVal
	end
end

function cResManager:ConverJsonCfgData( jsonDataFilePath, tCfgDef, funcCallback )
	if self.m_oGameResLoader.isFake == true then
		CfgData.loadCfgTable( tCfgDef[1] )
		self.m_tCfgDataConvertedMark[jsonDataFilePath] = true
		if funcCallback ~= nil then
			funcCallback()
		end
	else
		if self.m_tCfgDataConvertedMark[jsonDataFilePath] == true then
			if funcCallback ~= nil then
				funcCallback()
			end
		else
			local tJsonData = self:getJsonCfgDataByName(jsonDataFilePath)
			if tJsonData ~= nil then
				local vaules = tJsonData.values
				local nCount = vaules:count()
				local nColCount = 0
				if nCount ~= nil then
					local needLoadStep = math.ceil( nCount / CONVERT_CFGDATA_EVERY_STEP_NUM )
					for i = 1, needLoadStep do
						if i == needLoadStep then
							self:addJsonCfgDataLoadStep( jsonDataFilePath, i-1, tCfgDef, funcCallback, true, nCount )
						else
							self:addJsonCfgDataLoadStep( jsonDataFilePath, i-1, tCfgDef, funcCallback, false, nCount )
						end
					end
				end
				self.m_tCfgDataConvertedMark[jsonDataFilePath] = false
			end
		end
	end
end

function cResManager:DoPreCreateUINodeData( uiJsonFilePath, funcCallback )
	local uiManager = _G.GAME_APP:GetUIManager()
	if uiManager == nil then
		return
	end
	uiManager:LoadUIFromFilePathAsync( uiJsonFilePath, funcCallback )
end

function cResManager:AddJsonCfgDataLoadStep( jsonDataFilePath, idx, tCfgDef, funcCallback, bIsEnd, totalCount )
	self.m_oCfgConvertWorkStepQueue:InQueue( {jsonDataFilePath, idx, tCfgDef, funcCallback, bIsEnd, totalCount } )
end

function cResManager:StepConvertJsonCfgData( jsonDataFilePath, idx, tCfgDef, funcCallback, bIsEnd, totalCount )
	if self.m_oGameResLoader.m_bIsFake ~= true then
		local nBeginIdx = (idx * CONVERT_CFGDATA_EVERY_STEP_NUM)
		local nEndIdx = ((idx + 1)* CONVERT_CFGDATA_EVERY_STEP_NUM) - 1
		if nEndIdx >= (totalCount - 1) then
			nEndIdx = (totalCount - 1)
		end
		local sCfgName = tCfgDef[1]
		local tDataFmt = tCfgDef[3]
		local sKey = tDataFmt[1][2]
		local nFmtLen = #tDataFmt
		local tData = self:getCfgDataByIdx( jsonDataFilePath, nBeginIdx, nEndIdx )
		if tData ~= nil then
			if self.m_tCfgConvertedDataMap[ jsonDataFilePath ] == nil then
				self.m_tCfgConvertedDataMap[ jsonDataFilePath ] = {}
			end
			local tConvertedData = self.m_tCfgConvertedDataMap[ jsonDataFilePath ]
			if tConvertedData ~= nil then
				for i, v in ipairs( tData ) do
					local nKeyVal = tonumber(v[sKey]) or v[sKey]
					if nFmtLen == 1 then
						if tConvertedData[nKeyVal] == nil then
							tConvertedData[nKeyVal] = v
						end
					elseif nFmtLen == 2 then
						if tConvertedData[nKeyVal] == nil then
							tConvertedData[nKeyVal] = {}
						end
						_tinsert( tConvertedData[nKeyVal], v )
					end
				end
			end
		end
		if bIsEnd == true then
			CfgData.initCfgTable( sCfgName, self.m_tCfgConvertedDataMap[ jsonDataFilePath ] or {} )
			self.m_tCfgDataConvertedMark[jsonDataFilePath] = true
			funcCallback()
		end
	end
end

function cResManager:GetCfgDataByIdx( jsonDataFilePath, nBegin, nEnd )
	local tData = {}
	local tJsonData = self:getJsonCfgDataByName(jsonDataFilePath)
	local tTypeAndFieldsDef = self.m_tCfgTypeAndFieldsDefData[jsonDataFilePath]
	if tJsonData ~= nil and tTypeAndFieldsDef ~= nil then
		local types = tTypeAndFieldsDef.Types
		local fields = tTypeAndFieldsDef.Fields
		local values = tJsonData.values
		for i = nBegin, nEnd do
			local tRowData = {}
			local tProps = values:objectAtIndex( i )
			if tProps ~= nil then
				local nColCount = tProps:count()
				for j = 0, ( nColCount - 1 ) do
					tRowData[fields[j]] = JsonParser.Value( types[j], tProps:objectAtIndex( j ):getCString() )
				end
			end
			_tinsert( tData, tRowData )
		end
	end
	return tData
end

function cResManager:IsCfgDataConverted( cfgJsonFilePath )
	return self.m_tCfgDataConvertedMark[cfgJsonFilePath]
end

function cResManager:GetUIJsonFileDecodeData( uiJsonFilePath )
	local tData = self.m_tUIJsonFileData[uiJsonFilePath]
	if tData ~= nil then
		return tData[1], tData[2]
	else
		self:AddUIJsonFileDecodeData( uiJsonFilePath )
		local tData = self.m_tUIJsonFileData[uiJsonFilePath]
		if tData ~= nil then
			return tData[1], tData[2]
		end
	end
end

function cResManager:AddLoadedArmatureFileInfo( sFilePath )
	self.m_tLoadedArmatureFileInfo[ sFilePath ] = true
end

function cResManager:IsUIJsonFileDecodeDataLoaded( uiJsonFilePath )
	return (self.m_tUIJsonFileData[uiJsonFilePath] ~= nil)
end

function cResManager:ResetUIJsonFileData(uiJsonFilePath)
	self.m_tUIJsonFileData[uiJsonFilePath] = nil
end

function cResManager:GetJsonCfgDataByName( jsonPathName )
	return self.m_oGameResLoader:getJsonCfgDataByName( jsonPathName )
end

function cResManager:IsSpriteFrameLoaded( spriteFrameFile )
	return self.m_oGameResLoader:isSpriteFrameLoaded(spriteFrameFile)
end

function cResManager:IsJsonCfgDataLoaded( filePath )
	return self.m_oGameResLoader:isJsonCfgDataLoaded(filePath)
end

function cResManager:InitJsonFieldsAndTypes( filePath )
	if self.m_oGameResLoader.m_bIsFake ~= true then
		local tJsonCfgData = self:getJsonCfgDataByName( filePath )
		if tJsonCfgData ~= nil then
			local types = tJsonCfgData.types
			local fields = tJsonCfgData.fields
			local tTypesData = {}
			local tFieldsData = {}
			local nCount = types:count()
			for i = 0, (nCount-1)do
				tTypesData[i] = types:objectAtIndex(i):getCString()
				tFieldsData[i] = fields:objectAtIndex(i):getCString()
			end
			self.m_tCfgTypeAndFieldsDefData[filePath] = { Types = tTypesData, Fields = tFieldsData }
		end
	end
end

function cResManager:Update( nTimeDelta )
	--回调相关
	if self.m_oCurRunLoader == nil then
		local tNeedRunLoaderConf = self.m_oNeedRunAsyncLoaderQueue:OutQueue()
		if tNeedRunLoaderConf ~= nil then
			local oAsyncLoader = self:GetAsyncLoaderByName( tNeedRunLoaderConf[1] )
			if oAsyncLoader ~= nil then
				oAsyncLoader:StartRun( tNeedRunLoaderConf[2], tNeedRunLoaderConf[3] )
				self.m_oCurRunLoader = oAsyncLoader
			end
		end
	end
	local oAsyncLoader = self.m_oResAsyncLoaderOkQueue:OutQueue()
	if oAsyncLoader ~= nil then
		oAsyncLoader:OnDoResLoadCallback()
		if oAsyncLoader:IsLoadOverDestory() == true then
			local sAsyncLoaderName = oAsyncLoader:GetName()
			if sAsyncLoaderName ~= nil then
				self:DestoryResLoader( sAsyncLoaderName )
				self.m_oCurRunLoader = nil
			end
		end
	end
	if self.m_oGameResLoader.m_bIsFake == true then
		self.m_oGameResLoader:Update( nTimeDelta )
	end
	local tLoadWork = self.m_oNeedLoadUIResDataQueue:OutQueue()
	if tLoadWork ~= nil then
		self:AddUIJsonFileDecodeData( unpack(tLoadWork) )
		return
	end
	local tConvertWork = self.m_oCfgConvertDataQueue:OutQueue()
	if tConvertWork ~= nil then
		self:converJsonCfgData( unpack(tConvertWork) )
		return
	end
	local tLoadStep = self.m_oCfgConvertWorkStepQueue:OutQueue()
	if tLoadStep ~= nil then
		self:stepConvertJsonCfgData( unpack( tLoadStep) )
		return
	end
	local tUINodePreCreateWork = self.m_oUINodePreCreateQueue:OutQueue()
	if tUINodePreCreateWork ~= nil then
		self:DoPreCreateUINodeData( unpack(tUINodePreCreateWork) )
		return
	end
end

function cResManager:IsSearchExist(dir)
    local bExist = false
    for i,v in ipairs(self.m_tSearchDirs) do
        if v == dir then
            bExist = true
            break
        end
    end

    return bExist
end

function cResManager:SetGameApp( oGameApp )
	self.m_oGameApp = oGameApp
end

function cResManager:GetGameApp()
	return self.m_oGameApp
end

function cResManager:AddSearchPathIf(dir, fileUtil)
    if not self.m_tSearchDirs then
        self.m_tSearchDirs = {}
    end

    if not self:isSearchExist(dir) then
        table.insert(self.m_tSearchDirs, dir)
        if not fileUtil then
            fileUtil = cc.FileUtils:getInstance()
        end
        fileUtil:addSearchPath(dir)
    end
end

return cResManager