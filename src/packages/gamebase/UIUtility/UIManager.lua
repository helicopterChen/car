local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance()
local cDataTableEx = import("..CommonUtility.cDataTableEx")
local cDataQueue = import("..CommonUtility.cDataQueue")
local UIManager = class("UIManager")

function UIManager:ctor()
	self.m_tUILoaded = {}
	self.m_tUIOpened = {}
	self.m_tIngoreNavigationUIList = 
	{
		["UIDebugInfoPanel"] = true,
		["UICoverLayer"] = true,
		["UINavigation"] = true,
		["UIItemInfoPanel"] = true,
		["UIExitDialog"] = true,
		["UIFakeSDKExit"] = true,
	}
	self.m_tControlStrMap = {}
	self.m_tPreCreatedUINode = {}
	self.m_tUILoadingData = {}
	self.m_nNextCreateUIId = 100000000
	self.m_tCreatedCtrlMap = {}
	self.m_sCurLoadingUIJsonPath = ""
	self.m_tNeedShowUIQueue = cDataQueue:new()
	self.m_tRealShowUIQueue = cDataQueue:new()
	self.m_tDynUICreateData = {}
	self.m_sCurCreateDynUIJsonPath = ""
	self.m_loadUIOkCallback = nil
	self.m_loadUIOkCallbackData = nil
	self.m_nTotalUpdateTime = 0
	self.m_nLastUpdateTime = 0
end

function UIManager:Init()
end

function UIManager:GetInstance()
	if _G.__oUIManager == nil then
		_G.__oUIManager = UIManager:new()
	end
	return _G.__oUIManager
end

function UIManager:SetGameApp( oGameApp )
	self.m_oGameApp = oGameApp
end

function UIManager:GetGameApp()
	return self.m_oGameApp
end
function UIManager:ShowUI( uiName, resetData, callback, callbackData, bMainUI )
	if uiName ~= "UISmallLoading" and uiName ~= "UILoading" and uiName ~= "UIDebugInfoPanel" and bMainUI ~= true then
		self:RealShowUI( "UISmallLoading", true )
	end
	if #self.m_tNeedShowUIQueue > 0 then
		if uiName == "UIConfirmBuyPanel" or uiName == "UIAskBuyItemPanel" then
			return
		end
	end
	if uiName == "UIAskBuyItemPanel" and self:IsShowUI( "UINavigation" ) == true then
		return
	end
	self.m_tNeedShowUIQueue:InQueue( { uiName, resetData, callback, callbackData, bMainUI } )
end

function UIManager:AddRealShowUI( uiName, resetData, callback, callbackData, bMainUI )
	self.m_tRealShowUIQueue:InQueue( { uiName, resetData, callback, callbackData, bMainUI } )
end

function UIManager:SetLoadUIOkCallback( pCallback, tCallbackData )
	self.m_loadUIOkCallback = pCallback
	self.m_loadUIOkCallbackData = tCallbackData
end


function UIManager:RealShowUI( uiName, resetData, callback, callbackData, bMainUI )
	if uiName ~= "UISmallLoading" then
		if self:IsShowUI( "UISmallLoading" ) == true then
			self:CloseUI( "UISmallLoading" )
		end
	end
	resetData = resetData or true
	assert( _G.GAME_APP ~= nil )
	local curScene = _G.GAME_APP:GetSceneManager():GetCurScene()
	assert(curScene ~= nil )
	local sceneUILayer = curScene:GetUILayer()
	assert(sceneUILayer ~= nil )
	local uiModule = self:GetUIByName( uiName )
	if uiModule == nil then
		return
	end
	if self:IsShowUI( uiName ) == true then
		uiModule.m_tUIViewData = cDataTableEx:create()
		if resetData == true then
			uiModule:InitData()
		end
		if uiModule.OnShowUI ~= nil then
			uiModule:OnShowUI()
		end
		local uiRootNode = uiModule:GetUIRootNode()
		if uiRootNode ~= nil then
			uiRootNode:setTouchSwallowEnabled(uiModule.m_bTouchSwallowEnabled)
    		uiRootNode:setTouchEnabled(uiModule.m_bTouchEnabled)
    		uiRootNode:setTouchMode(uiModule.m_nTouchMode)
			if uiRootNode:getParent() == nil then
				if uiModule.OnInitEventsHandler ~= nil then
					uiModule:OnInitEventsHandler()
				end
				sceneUILayer:addChild( uiRootNode )
			end
			if uiRootNode:isVisible() == false then
				uiRootNode:setVisible( true )
			end
		end
		self.m_tUIOpened[uiName] = uiModule
		if callback ~= nil then
			callback( callbackData )
		end
		if uiModule.m_bScaleOpenAction == true then
			uiModule:DoUIOpenNodeScaleAction( nil )
		end
		if bMainUI == true then
			if self:IsShowUI( "UILoading" ) == true then
				local uiLoading = self:GetUIByName( "UILoading" )
				if uiLoading ~= nil then
					uiLoading:SetCanClose()
				end
			end
		end
		return
	end
	local uiRootNode = uiModule:GetUIRootNode()
	if uiRootNode ~= nil then
		uiRootNode:setTouchSwallowEnabled(uiModule.m_bTouchSwallowEnabled)
		uiRootNode:setTouchEnabled(uiModule.m_bTouchEnabled)
		uiRootNode:setTouchMode(uiModule.m_nTouchMode)
		uiRootNode:setVisible( true )
		if uiRootNode:getParent() == nil then
			if uiModule.OnInitEventsHandler ~= nil then
				uiModule:OnInitEventsHandler()
			end
			sceneUILayer:addChild( uiRootNode )
		end
	end
	uiModule.m_tUIViewData = cDataTableEx:create()
	if resetData == true then
		uiModule:InitData()
	end
	if uiModule.OnShowUI ~= nil then
		uiModule:OnShowUI()
	end
	self.m_tUIOpened[uiName] = uiModule
	if callback ~= nil then
		callback( callbackData )
	end
	if uiModule.m_bScaleOpenAction == true then
		uiModule:DoUIOpenNodeScaleAction( nil )
	end
	if bMainUI == true then
		local uiLoading = self:GetUIByName( "UILoading" )
		if uiLoading ~= nil then
			uiLoading:SetCanClose()
		end
	end
end

function UIManager:IsShowUI( uiName )
	return (self.m_tUIOpened[uiName] ~= nil)
end

function UIManager:CloseUI( uiName )
	if self.m_tUIOpened[uiName] == nil then
		return
	end
	assert( _G.GAME_APP ~= nil )
	local oSceneManager = _G.GAME_APP:GetSceneManager()
	assert( oSceneManager ~= nil )
	local oCurScene = oSceneManager:GetCurScene()
	assert(oCurScene ~= nil )
	local oUILayer = oCurScene:GetUILayer()
	assert(oUILayer ~= nil )
	local uiModule = self:GetUIByName( uiName )
	assert(uiModule ~= nil )
	uiModule.m_tUIViewData = nil
	local uiRootNode = uiModule:GetUIRootNode()
	if uiRootNode ~= nil then
		uiRootNode:setVisible(false)
		uiRootNode:removeFromParent(false)
	end
	if uiModule.OnCloseUI ~= nil then
		uiModule:OnCloseUI()
	end
	self.m_tUIOpened[uiName] = nil
end

function UIManager:SetNodeJsonAndOptions( uiNode, jsonNode )
	uiNode.jsonNode = jsonNode
	uiNode.options = jsonNode.options
	if jsonNode.classname == "Label" then
		uiNode:setSystemFontName( CONFIG_DEFAULT_TTF or "" )
	end
	for i, v in ipairs( jsonNode.children ) do
		local childNode = ccuiloader_seekNodeEx( uiNode, v.options.name )
		if childNode ~= nil then
			self:SetNodeJsonAndOptions( childNode, v )
		end
	end
end

function UIManager:PreLoadUI( uiName )
	local uiModule = self:GetUIByName( uiName )
	if uiModule ~= nil then
		uiModule:InitData()
	end
end

function UIManager:WillShowUI( uiName )
	if self:IsShowUI( uiName ) == true then
		return true
	end
	local tAllUINeedToShow = self.m_tNeedShowUIQueue:GetDataInQueue()
	for i, v in ipairs( tAllUINeedToShow ) do
		if v[1] == uiName then
			return true
		end
	end
end

function UIManager:GetUIByName( uiName )
	if self.m_tUILoaded[uiName] == nil then
		local UIClass = import(string.format("app/ui/%s", uiName))
		if UIClass == nil then
			return
		end
		local uiModule = UIClass:new()
		assert( uiModule ~= nil )
		uiModule:SetUIManager(self)
		uiModule:SetGameApp(self.m_oGameApp)
		uiModule:InitConfig()
		assert(uiModule.m_sJsonFilePath ~= nil and uiModule.m_sJsonFilePath ~= "")
		local uiRootNode, nWidth, nHeight = self:GetUIFromFilePath( uiModule.m_sJsonFilePath )
		if uiRootNode ~= nil and nWidth ~= nil and nHeight ~= nil then
			uiModule.uiName = uiName
			uiRootNode:setContentSize( cc.size( nWidth, nHeight ) )
			uiModule:SetUIRootNode( uiRootNode )
		end
		self.m_tUILoaded[uiName] = uiModule
	end
	return self.m_tUILoaded[uiName]
end

function UIManager:CreateUIByNameAsync( uiName, resetData, callback, callbackData, bMainUI )
	local uiModule = self:GetUIByName( uiName )
	if uiModule ~= nil then
		local function loadUIFromFilePathAsyncCallback( tCallbackData )
			local oUIModule = tCallbackData[1]
			if oUIModule ~= nil then
				local uiRootNode, width, height = self:GetUIFromFilePath( uiModule.m_sJsonFilePath )
				if uiRootNode ~= nil and width ~= nil and height ~= nil then
					uiModule.uiName = uiName
					uiRootNode:setContentSize( cc.size( width, height ) )
					uiModule:SetUIRootNode( uiRootNode )
					self:AddRealShowUI( uiName, resetData, callback, callbackData, bMainUI )
				end
			end
		end
		if uiModule.m_tDynItemCacheLoadTable ~= nil then
			for i, v in ipairs(uiModule.m_tDynItemCacheLoadTable) do
				if uiModule:IsDynamicItemCacheInited( v[1] ) ~= true then
					self:addDynamicItemCacheAsync( v[1], v[2], uiModule )
				end
			end
		end
		local uiRootNode, width, height = self:GetUIFromFilePath( uiModule.m_sJsonFilePath )
		if uiRootNode == nil then
			self:LoadUIFromFilePathAsync( uiModule.m_sJsonFilePath, loadUIFromFilePathAsyncCallback, { uiModule } )
		else
			self:AddRealShowUI( uiName, resetData, callback, callbackData, bMainUI )
		end
	end
end

function UIManager:AddDynamicItemCacheAsync( jsonName, num, uiModule, callback, callbackData )
	if self.m_tDynUICreateData[jsonName] == nil then
		self.m_tDynUICreateData[jsonName] = { Queue = cDataQueue:new(), FilePath = jsonName, UIModule = uiModule, Callback = callback, CallbackData = callbackData }
	end
	if self.m_sCurCreateDynUIJsonPath == ""  then
		self.m_sCurCreateDynUIJsonPath = jsonName
	end
	local tCreateQueue = self.m_tDynUICreateData[self.m_sCurCreateDynUIJsonPath].Queue
	if tCreateQueue ~= nil then
		for i = 1, num do
			tCreateQueue:InQueue( {jsonName} )
		end
	end
end

function UIManager:InitControlStrMap()
	self.m_tControlStrMap = {}
	local controlStrMap = CfgData.getCfgTable(CFG_CONTROL_STRING)
	if controlStrMap ~= nil then
		for i, uiControlMap in pairs( controlStrMap ) do
			local sName = string.format( "ui/%s", i )
			if self.m_tControlStrMap[sName] == nil then
				self.m_tControlStrMap[sName] = {}
			end
			local tempMap = self.m_tControlStrMap[sName]
			for idx, val in ipairs( uiControlMap ) do
				tempMap[ val.controlName ] = val.strID
			end
		end
	end
end

function UIManager:ReplaceUIControlStr( sFilePath, uiRootNode )
	local tStrMap = self.m_tControlStrMap[ sFilePath ]
	if tStrMap ~= nil then
		for i, v in pairs( tStrMap ) do
			local childNode = ccuiloader_seekNodeEx( uiRootNode, i )
			if childNode ~= nil and childNode.setString ~= nil then
				childNode:setString( app:GET_STR(v or "") or "")
			end
		end
	end
end

function UIManager:LoadUIFromFilePath( sFilePath )
	local oResManager = _G.GAME_APP:GetResManager()
	if oResManager == nil then
		return
	end
	local jsonNode, jsonVal = cc.uiloader:loadAndParseFile( sFilePath )
	local uiRootNode, width, height = cc.uiloader:loadFromJson( jsonVal )
	if uiRootNode ~= nil and jsonNode ~= nil then
		for i, v in ipairs( jsonNode.children ) do
			self:SetNodeJsonAndOptions( uiRootNode, jsonNode )
			if v.classname == "Panel" and v.options ~= nil and v.options.name ~= nil then
				local childNode = ccuiloader_seekNodeEx( uiRootNode, v.options.name )
				if childNode ~= nil then
					childNode:autoAdaptSize( uiRootNode:getContentSize() )
				end
			end
		end
		self:ReplaceUIControlStr( sFilePath, uiRootNode )
	end
	return uiRootNode, width, height
end

function UIManager:GetUIFromFilePath( sFilePath )
	if self.m_tPreCreatedUINode[sFilePath] ~= nil then
		return unpack(self.m_tPreCreatedUINode[sFilePath])
	end
end

function UIManager:LoadUIFromFilePathAsync( sFilePath, callback, callbackData )
	local oResManager = _G.GAME_APP:GetResManager()
	if oResManager == nil then
		return
	end
	local jsonNode, jsonVal = oResManager:GetUIJsonFileDecodeData( sFilePath )
	if jsonNode == nil or jsonVal == nil then
		if callback ~= nil then
			callback( callbackData )
		end
		return
	end
	cc.uiloader:prettyJson(jsonNode)
	self:LoadUIFromJsonAsync( sFilePath, jsonNode, callback, callbackData )
end

function UIManager:GetNextCreateUIId()
	self.m_nNextCreateUIId = self.m_nNextCreateUIId + 1
	return self.m_nNextCreateUIId
end

function UIManager:LoadUIFromJsonAsync( sFilePath, jsonNode, callback, callbackData )
	if self.m_tPreCreatedUINode[sFilePath] ~= nil then
		callback( callbackData )
		return
	end
	if self.m_sCurLoadingUIJsonPath == ""  then
		self.m_sCurLoadingUIJsonPath = sFilePath
	end
	if self.m_tUILoadingData[sFilePath] ~= nil then
		return
	end
	self.m_tUILoadingData[sFilePath] = { Queue = cDataQueue:new(), FilePath = sFilePath, Callback = callback, CallbackData = callbackData }
	local tLoadingQueue = self.m_tUILoadingData[sFilePath].Queue
	if tLoadingQueue ~= nil then
		self:AddNodeToLoadingQueue( tLoadingQueue, jsonNode, self:GetNextCreateUIId(), 0 )
	end
end

function UIManager:DoAfterAllLoaded( sFilePath )
	local oRootNode = nil
	local tScrollView = {}
	local tRootJsonNode = nil
	for i, v in pairs( self.m_tCreatedCtrlMap ) do
		local oNode = v[1]
		local jsonNode = v[2]
		if oNode.PARENT_ID == 0 then
			oRootNode = oNode
			tRootJsonNode = jsonNode
		end
		local tParentNodeData = self.m_tCreatedCtrlMap[oNode.PARENT_ID]
		if tParentNodeData ~= nil and oNode:getParent() == nil then
			local oParentNode = tParentNodeData[1]
			if oParentNode ~= nil then
				if oParentNode.classname == "ScrollView" then
					oParentNode.emptyNode:addChild(oNode)
				else
					oParentNode:addChild(oNode)
				end
				oNode:setLocalZOrder(oNode.ZOrder or 0)
			end
		end
		if oNode.classname == "ScrollView" then
			table.insert( tScrollView, oNode )
		end
	end
	for i, v in ipairs(tScrollView) do
		v:resetPosition()
	end
	if tRootJsonNode ~= nil then
		local rootOptions = tRootJsonNode.options
		if rootOptions.adaptScreen == true then
			self.m_tPreCreatedUINode[sFilePath] = { oRootNode, display.width, display.height }
		else
			self.m_tPreCreatedUINode[sFilePath] = { oRootNode, display.sizeInPixels.width, display.sizeInPixels.height }
		end
		if oRootNode ~= nil and tRootJsonNode ~= nil then
			for i, v in ipairs( tRootJsonNode.children ) do
				self:SetNodeJsonAndOptions( oRootNode, tRootJsonNode )
				if v.classname == "Panel" and v.options ~= nil and v.options.name ~= nil then
					local childNode = ccuiloader_seekNodeEx( oRootNode, v.options.name )
					if childNode ~= nil then
						childNode:autoAdaptSize( oRootNode:getContentSize() )
					end
				end
			end
			self:ReplaceUIControlStr( sFilePath, oRootNode )
		end
	end
	for i, v in pairs( self.m_tCreatedCtrlMap) do
		local oNode = v[1]
		if oNode ~= nil then
			if oNode.PARENT_ID ~= 0 then
				oNode:release()
			end
		end
	end
	self.m_tCreatedCtrlMap = {}
end

function UIManager:CreateOneNodeByData( jsonNode, loadCtrlID, parentId )
	local transX, transY
	local parent
	if parentId ~= nil and parentId ~= 0 then
		local parentData = self.m_tCreatedCtrlMap[parentId]
		if parentData ~= nil then
			parent = parentData[1]
			transX = parent.PosTrans.x 
			transY = parent.PosTrans.y
		end
	end
	local oNode = cc.uiloader:createOneFromJson(jsonNode,transX,transY,parent)
	if oNode ~= nil then
		oNode.LOAD_ID = loadCtrlID
		oNode.PARENT_ID = parentId
		oNode:retain()
		self.m_tCreatedCtrlMap[loadCtrlID] = { oNode, jsonNode }
	end
end

function UIManager:AddNodeToLoadingQueue( oQueue, jsonNode, loadCtrlID, parentId )
	oQueue:InQueue( { jsonNode, loadCtrlID, parentId } )
	local children = jsonNode.children
	for i, v in ipairs(children) do
		self:AddNodeToLoadingQueue( oQueue, v, self:GetNextCreateUIId(), loadCtrlID )
	end
end

function UIManager:CloseAllUI( tIgnoreList )
	local closedUIList = {}
	tIgnoreList = tIgnoreList or {}
	for i, v in pairs( self.m_tUIOpened ) do
		if tIgnoreList[i] ~= true then
			local uiRootNode = v:GetUIRootNode()
			if uiRootNode ~= nil then
				if v.OnCloseUI ~= nil then
					v:OnCloseUI()
				end
				uiRootNode:removeFromParent()
				closedUIList[#closedUIList+1] = i
			end
		end
	end
	for i, v in ipairs( closedUIList ) do
		self.m_tUIOpened[v] = nil
	end
	self.m_loadUIOkCallback = nil
	self.m_loadUIOkCallbackData = nil
end

function UIManager:DestoryAllUI()
	for i, v in pairs( self.m_tUILoaded ) do
		if i ~= "UILoading" and i ~= "UISmallLoading" then
			if v ~= nil then
				if v.onDestory ~= nil then
					v:onDestory()
				end
				v:DefauleDestory()
				local uiRootNode = v:GetUIRootNode()
				if uiRootNode ~= nil then
					uiRootNode:removeFromParent()
					uiRootNode:release()
				end
				self.m_tUILoaded[ i ] = nil
				self.m_tUIOpened[ i ] = nil	
			end
		end
	end
	for i, v in pairs( self.m_tPreCreatedUINode ) do
		if i ~= "ui/smallLoading.json" and i ~= "ui/loading.json" then
			local oRootNode = v[1]
			if oRootNode ~= nil then
				oRootNode:release()
			end
			self.m_tPreCreatedUINode[i] = nil
			local oResManager = _G.GAME_APP:GetResManager()
			if oResManager ~= nil then
				oResManager:ResetUIJsonFileData(i)
			end
		end
	end
	self.m_tUILoadingData = {}
	self.m_tCreatedCtrlMap = {}
	self.m_sCurLoadingUIJsonPath = ""
	self.m_tNeedShowUIQueue = cDataQueue:new()
	self.m_tRealShowUIQueue = cDataQueue:new()
	self.m_tDynUICreateData = {}
	self.m_sCurCreateDynUIJsonPath = ""
end

function UIManager:Update( dt )
	local tNeedOpenUI = self.m_tNeedShowUIQueue:OutQueue()
	if tNeedOpenUI ~= nil then
		self:CreateUIByNameAsync( unpack(tNeedOpenUI) )
	end
	self.m_nTotalUpdateTime = self.m_nTotalUpdateTime + dt
	local bUpdateSec = (math.floor( self.m_nLastUpdateTime ) < math.floor( self.m_nTotalUpdateTime ))
	for i, v in pairs( self.m_tUIOpened ) do
		if v.OnUpdateUI ~= nil then
			v:OnUpdateUI( dt )
		end
		if bUpdateSec == true and v.OnUpdateSec ~= nil then
			v:OnUpdateSec( dt )
		end
		if v.OnUpdateViewData ~= nil then
			if v.m_tUIViewData ~= nil then
				v:OnUpdateViewData()
			end
		end
		if v.OnUpdateView ~= nil then
			if v.m_tUIViewData ~= nil and v.m_tUIViewData:IsDirty() == true then
				v:OnUpdateView()
				v.m_tUIViewData:ResetDirty()
			end
		end
	end
	if self:UpdateLoadDynUIJson() ~= true then
		return
	end
	if self:UpdateLoadUIJson() ~= true then
		return
	end
	if self.m_tRealShowUIQueue ~= nil then
		local tRealShowData = self.m_tRealShowUIQueue:OutQueue()
		if tRealShowData ~= nil then
			self:RealShowUI( unpack(tRealShowData) )
		end
	end
	if self.m_tRealShowUIQueue:IsEmpty() and self.m_tNeedShowUIQueue:IsEmpty() then
		if self.m_loadUIOkCallback ~= nil then
			self.m_loadUIOkCallback( self.m_loadUIOkCallbackData )
			self.m_loadUIOkCallback = nil
			self.m_loadUIOkCallbackData = nil
		end
	end
	self.m_nLastUpdateTime = self.m_nTotalUpdateTime
end 

function UIManager:UpdateLoadUIJson()
	if self.m_tUILoadingData ~= nil then
		if self.m_sCurLoadingUIJsonPath == "" then
			return true
		end
		local tCurLoadingData = self.m_tUILoadingData[self.m_sCurLoadingUIJsonPath]
		if tCurLoadingData ~= nil then
			local oLoadingQueue = tCurLoadingData.Queue
			local sFilePath = tCurLoadingData.FilePath
			local callback = tCurLoadingData.Callback
			local callbackData = tCurLoadingData.CallbackData
			if oLoadingQueue ~= nil then
				for i = 1, 15 do
					local tData = oLoadingQueue:OutQueue()
					if tData ~= nil then
						self:CreateOneNodeByData( unpack(tData) )
					else
						self:DoAfterAllLoaded( sFilePath )
						if callback ~= nil then
							callback( callbackData )
						end
						local bFound = false
						for idx, v in pairs(self.m_tUILoadingData) do
							if v.Queue:IsEmpty() ~= true then
								bFound = true
								self.m_sCurLoadingUIJsonPath = v.FilePath
								return
							end
						end
						if bFound == false then
							self.m_sCurLoadingUIJsonPath = ""
							return true
						end
						return
					end
				end
			end
		else
			return true
		end
	end
end

function UIManager:UpdateLoadDynUIJson()
	if self.m_tDynUICreateData ~= nil then
		if self.m_sCurCreateDynUIJsonPath == "" then
			return true
		end
		local tCurCreateDynData = self.m_tDynUICreateData[self.m_sCurCreateDynUIJsonPath]
		if tCurCreateDynData ~= nil then
			local oCreateQueue = tCurCreateDynData.Queue
			local sFilePath = tCurCreateDynData.FilePath
			local callback = tCurCreateDynData.Callback
			local callbackData = tCurCreateDynData.CallbackData
			local oUIModule = tCurCreateDynData.UIModule
			if oCreateQueue ~= nil and oUIModule ~= nil then
				local tData = oCreateQueue:OutQueue()
				if tData ~= nil then
					local oNode, width, height = self:loadUIFromFilePath( unpack(tData) )
					if oNode ~= nil and oUIModule ~= nil then
						oUIModule:AddDynamicItemCacheByName( sFilePath, oNode )
					end
				else
					oUIModule:FinishInitDynItemCache( sFilePath )
					if callback ~= nil then
						callback( callbackData )
					end
					local bFound = false
					for idx, v in pairs(self.m_tDynUICreateData) do
						if v.Queue:IsEmpty() ~= true then
							bFound = true
							self.m_sCurCreateDynUIJsonPath = v.FilePath
							return
						end
					end
					if bFound == false then
						self.m_sCurCreateDynUIJsonPath = ""
						return true
					end
					return
				end
			end
		else
			return true
		end
	end
end

function UIManager:ShowSystemTips( sTips )
	local function callbackFuc( tCallbackData )
		local uiSystemTips = self:GetUIByName( "UISystemTips" )
		if uiSystemTips ~= nil then
			uiSystemTips:setTips( tCallbackData or "" )
		end
	end
	self:ShowUI( "UISystemTips", true, callbackFuc, sTips  )
end

--[[
	Type 类型(目前暂时只有一种对话框类型)
	Title 标题
	Desc 显示提示文字
	Btn1Label 按钮1文字
	Btn2Label 按钮2文字
	Btn1Callback 按钮1回调
	Btn1CallbackData 按钮1回调函数
	Btn2Callback 按钮2回调
	Btn2CallbackData 按钮2回调函数
--]]
function UIManager:ShowConfirmDialog( tShowData, tShowCallback )
	if tShowData.Type == "Small" then
		local function callbackFuc( tCallbackData )
			local uiConfirmDialog = self:GetUIByName( "UISmallConfirmDialog" )
			if uiConfirmDialog ~= nil then
				uiConfirmDialog:setDialogData( tCallbackData )
				if tShowCallback ~= nil then
					tShowCallback()
				end
			end
		end
		self:ShowUI( "UISmallConfirmDialog", true, callbackFuc, tShowData )
	elseif tShowData.Type == "Small2" then
		local function callbackFuc( tCallbackData )
			local uiConfirmDialog = self:GetUIByName( "UISmallConfirmDialogEx" )
			if uiConfirmDialog ~= nil then
				uiConfirmDialog:setDialogData( tCallbackData )
				if tShowCallback ~= nil then
					tShowCallback()
				end
			end
		end
		self:ShowUI( "UISmallConfirmDialogEx", true, callbackFuc, tShowData )
	else
		local function callbackFuc( tCallbackData )
			local uiConfirmDialog = self:GetUIByName( "UIConfirmDialog" )
			if uiConfirmDialog ~= nil then
				uiConfirmDialog:setDialogData( tCallbackData )
				if tShowCallback ~= nil then
					tShowCallback()
				end
			end
		end
		self:ShowUI( "UIConfirmDialog", true, callbackFuc, tShowData )
	end
end

function UIManager:ShowExitDialog( tShowData, tShowCallback )
	if self:IsShowUI( "UIExitDialog" ) == true or
	   self:IsShowUI( "UIFakeSDKExit" ) == true then
		return
	end
	local function callbackFuc( tCallbackData )
		local uiExitDialog = self:GetUIByName( "UIExitDialog" )
		if uiExitDialog ~= nil then
			uiExitDialog:setDialogData( tCallbackData )
			if tShowCallback ~= nil then
				tShowCallback()
			end
		end
	end
	self:ShowUI( "UIExitDialog", true, callbackFuc, tShowData )
end

function UIManager:ShowStoreAndGuidToItem( sType, nItemId, tDiscountInfo, nShowCount )
	tDiscountInfo = tDiscountInfo or {}
	nShowCount = nShowCount or 1
	local function showStoreCallback( tDiscountData )
        local uiStore = app.uiManager:GetUIByName( "UIStore" )
        if uiStore ~= nil then
        	uiStore:setItemDiscountInfo( tDiscountData )
        	uiStore:guidToItem( sType, nItemId, nShowCount )
        end
    end
    self:ShowUI("UIStore", true, showStoreCallback, tDiscountInfo )
end

function UIManager:CheckIgnoreNavigation( uiName )
	local navigationMgr = nil
	if navigationMgr ~= nil then
		local curNavInfo = navigationMgr:getCurNavInfo()
		if curNavInfo ~= nil then
			if uiName == curNavInfo.uiName then
				return false
			end
		end
	end
	return self.m_tIngoreNavigationUIList[uiName]
end

function UIManager:CheckPassNavigation( control )
	if self:IsShowUI( "UINavigation" ) == true then
		local uiNavigation = self:GetUIByName( "UINavigation" )
		if uiNavigation ~= nil and uiNavigation.waitScaleOver == true then
			return false
		end
		local navigationMgr = app.navigationMgr
		if navigationMgr ~= nil then
			local curNavInfo = navigationMgr:getCurNavInfo()
			if curNavInfo ~= nil and curNavInfo.autoNextStepTime > 0 then
				return true
			end
		end
		local uiNavigation = self:GetUIByName( "UINavigation" )
		if uiNavigation ~= nil then
			return (control == uiNavigation:getNavigationButton())
		end
	end
	return true
end

function UIManager:OnClickedNavigationBtn( control )
	if self:IsShowUI( "UINavigation" ) == true then
		local uiNavigation = self:GetUIByName( "UINavigation" )
		if uiNavigation ~= nil then
			if control == uiNavigation:getNavigationButton() then
				uiNavigation:OnClickedNavigationBtn()
			end
		end
	end
end

function UIManager:RemoveAllNavigationEffects()
	if self:IsShowUI( "UINavigation" ) == true then
		local uiNavigation = self:GetUIByName( "UINavigation" )
		if uiNavigation ~= nil then
		end
	end
end

function UIManager:RegisterEventsHandlers( controlPath, eventName, handler, uiModule )
	assert( uiModule ~= nil )
	if eventName ~= "OnClicked" and eventName ~= "OnPressed" and eventName ~= "OnReleased" and eventName ~= "TouchEvent" then
		return
	end
	local control = uiModule:SeekNodeByPath( controlPath )
	if control ~= nil then
		if iskindof(control, "UIButton") then	--button才有点击事件的注册
			if eventName == "OnClicked" then
				control:removeEventListenersByEvent("CLICKED_EVENT")
				control:onButtonClicked( 
					function( event )
						if self:CheckIgnoreNavigation( uiModule.uiName ) ~= true and self:CheckPassNavigation( control ) ~= true then
							return
						end
						if uiModule.m_bIsScaling == true then
							return
						end
						--audio.playSound(GAME_SFX.tapButton)
						if control.scaleOnClicked == true then
						    local target = event.target
						    if target ~= nil then
						        local scaleX = target:getScaleX()
						        local scaleY = target:getScaleY()
						        event.target:runAction(CCSequence:createWithTwoActions(CCScaleTo:create(0.15, scaleX * 1.3, scaleY * 1.3 ), CCScaleTo:create(0.2, scaleX, scaleY)))
						    end
						end
						self:RemoveAllNavigationEffects()
						if handler ~= nil then
							handler( uiModule, control, event )
						end
						self:OnClickedNavigationBtn( control )
					end
					)
			elseif eventName == "OnPressed" then
				control:removeEventListenersByEvent("PRESSED_EVENT")
				control:onButtonPressed( 
					function(event) 
						if self:CheckIgnoreNavigation( uiModule.uiName ) ~= true and self:CheckPassNavigation( control ) ~= true then
							return
						end
						handler( uiModule, event ) 
						end )
			elseif eventName == "OnReleased" then
				control:removeEventListenersByEvent("RELEASE_EVENT")
				control:onButtonRelease( 
					function(event) 
						if self:CheckIgnoreNavigation( uiModule.uiName ) ~= true and self:CheckPassNavigation( control ) ~= true then
							return
						end
						handler( uiModule, event ) 
						end )
			end
		elseif iskindof(control, "UIPanel") then --panel控件才会有ontouch这种事件存在
			if eventName == "TouchEvent" then
				control:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)
	    		control:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event) 
	    															return handler( uiModule, event )
	    														  end)
	    	end
		end
	end
end

function UIManager:RegisterItemSlotClickedHandler( sSlotName, showPanel, handler, uiModule )
	assert( uiModule ~= nil )
	local tItemSlotInfo = uiModule:getItemSlotInfoByName( sSlotName )
	if tItemSlotInfo == nil then
		return
	end
	local control = uiModule:SeekNodeByPath( tItemSlotInfo.BtnName )
	if control == nil then
		return
	end
	local function showItemInfoPanelCallback( relativeSlotName )
		local tSlotInfo = uiModule:getItemSlotInfoByName( relativeSlotName )
		if tSlotInfo == nil or tSlotInfo.ItemInfo == nil then
			return
		end
		local function callback( tCallbackData )
			local uiItemInfoPanel = self:GetUIByName( "UIItemInfoPanel" )
			if uiItemInfoPanel ~= nil then
				uiItemInfoPanel:setItemInfo( tSlotInfo.ItemInfo, tSlotInfo.CoverViewId, tSlotInfo.CoverViewScale, tSlotInfo.CoverViewPause )
			end
		end
		self:ShowUI( "UIItemInfoPanel", true, callback, tSlotInfo.ItemInfo )
	end
	control.m_sRelativeSlotName = sSlotName
	control:onButtonClicked(
					function( event ) 
						--audio.playSound(GAME_SFX.tapButton)
						if showPanel == true then
							showItemInfoPanelCallback(event.target.m_sRelativeSlotName)
						end
						if handler ~= nil then
							handler( uiModule, sSlotName, control, event )
						end
					end
				)
end

function UIManager:registerDynamicItemSlotClickedHandler( sSlotName, showPanel, clickedHandler, uiModule )
	assert( uiModule ~= nil )
	local tItemSlotInfo = uiModule:getItemSlotInfoByName( sSlotName )
	if tItemSlotInfo == nil then
		return
	end
	local control = tItemSlotInfo.SlotBtn
	if control == nil then
		return
	end
	local function showItemInfoPanelCallback( relativeSlotName )
		local tSlotInfo = uiModule:getItemSlotInfoByName( relativeSlotName )
		if tSlotInfo == nil then
			return
		end
		local function callback( tCallbackData )
			local uiItemInfoPanel = self:GetUIByName( "UIItemInfoPanel" )
			if uiItemInfoPanel ~= nil then
				uiItemInfoPanel:setItemInfo( tSlotInfo.ItemInfo, tSlotInfo.CoverViewId, tSlotInfo.CoverViewScale, tSlotInfo.CoverViewPause )
			end
		end
		self:ShowUI( "UIItemInfoPanel", true, callback, tSlotInfo.ItemInfo )
	end
	control.m_sRelativeSlotName = sSlotName
	control:onButtonClicked(
					function( event ) 
						--audio.playSound(GAME_SFX.tapButton)
						if showPanel == true and event.target ~= nil then
							showItemInfoPanelCallback( event.target.m_sRelativeSlotName )
						end
						if handler ~= nil then
							handler( uiModule, sSlotName, control, event )
						end
					end
				)
end

function UIManager.loadTexture(plist, png)
	if UIManager.isNil(plist) then
		return
	end

	local fileUtil
	fileUtil = cc.FileUtils:getInstance()
	local fullPath = fileUtil:fullPathForFilename(plist)
	UIManager.addSearchPathIf(io.pathinfo(fullPath).dirname, fileUtil)
	local spCache
	spCache = cc.SpriteFrameCache:getInstance()
	if png then
		spCache:addSpriteFrames(plist, png)
	else
		spCache:addSpriteFrames(plist)
	end
end

function UIManager.isNil(str)
	if not str or 0 == string.utf8len(str) then
		return true
	else
		return false
	end
end

function UIManager.addSearchPathIf(dir, fileUtil)
	if not UIManager.searchDirs then
		UIManager.searchDirs = {}
	end

	if not UIManager.isSearchExist(dir) then
		table.insert(UIManager.searchDirs, dir)
		if not fileUtil then
			fileUtil = cc.FileUtils:getInstance()
		end
		fileUtil:addSearchPath(dir)
	end
end

function UIManager.isSearchExist(dir)
	local bExist = false
	for i,v in ipairs(UIManager.searchDirs) do
		if v == dir then
			bExist = true
			break
		end
	end

	return bExist
end

function UIManager:transResName(fileData)
	if not fileData then
		return
	end

	local name = fileData.path
	if not name then
		return name
	end

	UIManager.loadTexture(fileData.plistFile)
	if 1 == fileData.resourceType then
		return "#" .. name
	else
		return name
	end
end

function UIManager:replaceSpriteIcon( sprite, plistFile, filePath, isGray )
	if sprite == nil then
		return
	end
	local options = sprite.options
	local jsonNode = sprite.jsonNode
	if options == nil or  options.fileNameData == nil or jsonNode == nil then
		return
	end
	if isGray ~= true then
		if (plistFile == options.fileNameData.plistFile and filePath == options.fileNameData.path) then
			return
		end
	end
	local parent = sprite:getParent()
	if parent == nil then
		return
	end
	local clsName = jsonNode.classname
	if clsName == nil then
		return
	end
	options.fileNameData.plistFile = plistFile
	options.fileNameData.path = filePath
	options.x = options.x or 0
	options.y = options.y or 0
	if options.originWidth ~= nil then
		options.width = options.originWidth
		options.height = options.originHeight
		options.scaleX = options.originScaleX
		options.scaleY = options.originScaleY
	else
		options.originWidth = options.width
		options.originHeight = options.height
		options.originScaleX = options.scaleX
		options.originScaleY = options.scaleY
	end
	local uiNode = self:createSpriteIcon( options, sprite.jsonNode, isGray )
	if uiNode == nil then
		return
	end
	uiNode.name = options.name or "unknow node"
	sprite:removeFromParentAndCleanup(true)
	parent:addChild(uiNode)

	if options.flipX then
		if uiNode.setFlipX then
			uiNode:setFlipX(options.flipX)
		end
	end
	if options.flipY then
		if uiNode.setFlipY then
			uiNode:setFlipY(options.flipY)
		end
	end
	uiNode:setRotation(options.rotation or 0)
	uiNode:setScaleX((options.scaleX or 1) * uiNode:getScaleX())
	uiNode:setScaleY((options.scaleY or 1) * uiNode:getScaleY())
	uiNode:setVisible(options.visible)
	uiNode:setLocalZOrder(options.ZOrder or 0)
	-- uiNode:setGlobalZOrder(options.ZOrder or 0)
	uiNode:setTag(options.tag or 0)
	return uiNode
end

function UIManager:setSpriteGray( sprite, bIsGray )
	if sprite == nil then
		return
	end
	local options = sprite.options
	local jsonNode = sprite.jsonNode
	if options == nil or  options.fileNameData == nil or jsonNode == nil then
		return
	end
	self:replaceSpriteIcon( sprite, options.fileNameData.plistFile, options.fileNameData.path, bIsGray )
end

function UIManager:replaceSpriteIconByName( sprite, sameFilePngName )
	if sprite == nil then
		return
	end
	local options = sprite.options
	local jsonNode = sprite.jsonNode
	if options == nil or  options.fileNameData == nil or jsonNode == nil then
		return
	end
	self:replaceSpriteIcon( sprite, options.fileNameData.plistFile, sameFilePngName, false )
end

function UIManager:createSpriteIcon( options, jsonNode, isGray )
	local params = {}
	params.scale9 = options.scale9Enable
	if params.scale9 then
		params.capInsets = cc.rect(options.capInsetsX, options.capInsetsY,options.capInsetsWidth, options.capInsetsHeight)
	end
    local sResName = self:transResName(options.fileNameData)
    if sResName == nil then
    	return
    end
    if isGray == true then
    	if string.sub( sResName, 1, 1 ) == '#' then
    		self:createGraySpriteFrame( string.sub( sResName, 2 ) )
    	end
    	if string.find( sResName, ".png" )  ~= nil then
			sResName = string.gsub( sResName, ".png", "___gray.png" )
		end
    end
    local node = cc.ui.UIImage.new(sResName, params)
	if not options.scale9Enable then
		local originSize = node:getContentSize()
		if options.width then
			options.scaleX = (options.scaleX or 1) * options.width/originSize.width
		end
		if options.height then
			options.scaleY = (options.scaleY or 1) * options.height/originSize.height
		end
	end
	if not options.ignoreSize then
		node:setLayoutSize(options.width, options.height)

		-- setLayoutSize have scaled
		options.scaleX = 1
		options.scaleY = 1
	end
	node:setPositionX(options.x or 0)
	node:setPositionY(options.y or 0)
	node:setAnchorPoint(cc.p(options.anchorPointX or 0.5, options.anchorPointY or 0.5))

	if options.touchAble then
		node:setTouchEnabled(true)
		node:setTouchSwallowEnabled(true)
	end
	if options.opacity then
		node:setOpacity(options.opacity)
	end
	node.options = options
	node.jsonNode = jsonNode
	return node
end

function UIManager:createGraySpriteFrame( filename )
	if filename == nil then
		return
	end
	local graySpriteName = filename
	if string.find( filename, ".png" ) ~= nil then
		graySpriteName = string.gsub( filename, ".png", "___gray.png" )
	end
	local grayFrame = sharedSpriteFrameCache:spriteFrameByName(graySpriteName)
	if grayFrame ~= nil then
		return
	end
	local frame = display.newSpriteFrame( filename )
	if frame ~= nil then
		local __graySprite = display.newFilteredSprite( "#" .. filename, "GRAY")
		if __graySprite ~= nil then
			local contentSize = __graySprite:getContentSize()
			local __canva = CCRenderTexture:create( contentSize.width, contentSize.height )
			if __canva ~= nil then
				__graySprite:setLocalZOrder( 10 )
				__graySprite:setFlipY(true)
				__graySprite:setAnchorPoint( cc.p( 0.5, 0.5) )
				__graySprite:setPosition( cc.p(contentSize.width/2,contentSize.height/2) )
				__canva:beginWithClear( 0,0,0,0)
				__graySprite:visit()
				__canva:endToLua()
				__graySprite:runAction(CCDelayTime:create(1.0))
				local spriteFrame = CCSpriteFrame:createWithTexture( __canva:getSprite():getTexture(), cc.rect( 0, 0, contentSize.width, contentSize.height )  )
				if spriteFrame ~= nil then
					sharedSpriteFrameCache:addSpriteFrame( spriteFrame, graySpriteName )
				end
			end
		end
	end
end

function UIManager:createLightSpriteFromNode( oDrawNode, tContentSize )
	if oDrawNode == nil or tContentSize == nil then
		return
	end
	local nOldX, nOldY = oDrawNode:getPosition()
	local tOldAnchorPos = oDrawNode:getAnchorPoint()
	local width = tContentSize.width
	local height= tContentSize.height
	local __canva = CCRenderTexture:create( width, height )
	local __canva2 = CCRenderTexture:create( width, height )
	if __canva ~= nil and __canva2 ~= nil then
		__canva:beginWithClear( 0, 0, 0, 0)
		oDrawNode:setPosition( cc.p(width/2,height/2) )
		oDrawNode:setAnchorPoint( cc.p( 0.5, 0.5 ))
		oDrawNode:visit()
		__canva:endToLua()
		oDrawNode:setPosition( cc.p(nOldX,nOldY) )
		oDrawNode:setAnchorPoint( tOldAnchorPos )
		local spriteFrame = CCSpriteFrame:createWithTexture( __canva:getSprite():getTexture(), cc.rect( 0, 0, width, height )  )
		if spriteFrame ~= nil then
			local sprite = CCSprite:createWithSpriteFrame( spriteFrame )
			if sprite ~= nil then
				local oldBlendFunc = sprite:getBlendFunc()
				local blendFunc = ccBlendFunc()
				blendFunc.src = GL_ONE
				blendFunc.dst = GL_ONE
				__canva2:beginWithClear( 0, 0, 0, 0)
				sprite:setPosition( cc.p(width/2,height/2) )
				sprite:setAnchorPoint( cc.p( 0.5, 0.5 ))
				sprite:setBlendFunc(blendFunc)
				sprite:visit()
				sprite:visit()
				sprite:visit()
				sprite:setBlendFunc(oldBlendFunc)
				__canva2:endToLua()
			end
		end
		local spriteFrame = CCSpriteFrame:createWithTexture( __canva2:getSprite():getTexture(), cc.rect( 0, 0, width, height )  )
		if spriteFrame ~= nil then
			local sprite = CCSprite:createWithSpriteFrame( spriteFrame )
			if sprite ~= nil then
				return sprite
			end
		end
	end
end

function UIManager:addButtonGlowEffect( oNode, tContentSize )
	if oNode == nil then
		return
	end
	local nTag = 808080808
	local childNode = oNode:getChildByTag(nTag)
	if childNode ~= nil then
		childNode:stopAllActions()
		childNode:removeFromParentAndCleanup(true)
	end
	local oDrawNode = self:createLightSpriteFromNode( oNode, tContentSize )
	if oDrawNode == nil then
		return
	end
	local nWidth = tContentSize.width
	local nHeight = tContentSize.height
	--oDrawNode:setAnchorPoint( cc.p(0.5,0.5) )
	--oDrawNode:setPosition( cc.p(nWidth/2,nHeight/2) )
	oNode:addChild( oDrawNode, 10, nTag )
	local array = CCArray:create()
	local nOpacity = 255
	local nScale = 1
	local nDeltaScale = 0.02
	local nDeltaOpacity = 30
	for i = 1, 5 do 
		nScale = nScale + nDeltaScale
		nOpacity= nOpacity- nDeltaOpacity
		local scaleTo = CCScaleTo:create( 0.1, nScale )
		array:addObject(scaleTo)
		local fadeTo = CCFadeTo:create(0, nOpacity )
		array:addObject(fadeTo)
	end
	for i = 1, 5 do 
		nScale = nScale - nDeltaScale
		nOpacity= nOpacity+ nDeltaOpacity
		local scaleTo = CCScaleTo:create( 0.1, nScale )
		array:addObject(scaleTo)
		local fadeTo = CCFadeTo:create(0, nOpacity )
		array:addObject(fadeTo)
	end
	local sequence = CCSequence:create( array )
	local repeatForever = CCRepeatForever:create( sequence )
	oDrawNode:runAction(repeatForever)
end

function UIManager:getAnimByIdFromNode( oNode, nId )
	if oNode == nil or nId == nil then
		return
	end
	local nTag = 900000000 + nId
	return oNode:getChildByTag(nTag)
end

function UIManager:RemoveAnimByIdFromNode( oNode, nId )
	if oNode == nil or nId == nil then
		return
	end
	local armature = self:getAnimByIdFromNode( oNode )
	if armature ~= nil then
		local animation = armature:getAnimation()
		if animation ~= nil then
			animation:stop()
			armature:stopAllActions()
			armature:removeFromParentAndCleanup(true)
		end
	end
end

function UIManager:ClearAllAnimFromNode( oNode )
	local tNeedDelIds = {}
	local tChildren = oNode:getChildren()
	local nChildrenCount = oNode:getChildrenCount()
	for i = 1, nChildrenCount do
		local childNode = tChildren:objectAtIndex(i - 1)
		if childNode ~= nil then
			local nTag = childNode:getTag()
			if nTag > 900000000 then
				tNeedDelIds[nTag] = true
			end
		end
	end
	for i, v in pairs( tNeedDelIds ) do
		local armature = oNode:getChildByTag( i )
		if armature ~= nil then
			local animation = armature:getAnimation()
			if animation ~= nil then
				animation:stop()
				armature:stopAllActions()
				armature:removeFromParentAndCleanup(true)
			end
		end
	end
end

return UIManager