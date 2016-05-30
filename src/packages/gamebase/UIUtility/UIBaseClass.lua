local UIBaseClass = class("UIBaseClass" )

function UIBaseClass:ctor()
	self.m_sJsonFilePath = ""
	self.m_tDynItemCacheLoadTable = {}
	self.m_oUIRootNode = nil
	self.m_oUIManager = nil
	self.m_oGameApp = nil
	self.m_bTouchSwallowEnabled = true
	self.m_bTouchEnabled = true
	self.m_nTouchMode = cc.TOUCH_MODE_ONE_BY_ONE
	self.m_closeCallback = nil
	self.m_bScaleOpenAction = false
	self.m_bIsScaling	= false
	self.m_tItemSlotMap = {}
	self.m_tDynamicItemCache = {}
	self.m_tUnusedDynItemIdx = {}
	self.m_tDynamicItemCacheInited = {}
	self.m_tButtonGroupInfo = {}
end

function UIBaseClass:RegisterEventsHandlers( name, eventName, handler )
	assert( self.m_oUIManager ~= nil )
	self.m_oUIManager:RegisterEventsHandlers( name, eventName, handler, self )
end

function UIBaseClass:SetUIRootNode( oUIRoot )
	assert( oUIRoot ~= nil )
	oUIRoot:retain()
	self.m_oUIRootNode = oUIRoot
end

function UIBaseClass:SetUIManager( uiManager )
	self.m_oUIManager = uiManager
end

function UIBaseClass:SetGameApp( oGameApp )
	self.m_oGameApp = oGameApp
end

function UIBaseClass:GetGameApp()
	return self.m_oGameApp
end

function UIBaseClass:SetCloseCallback( closeCallback )
	self.m_closeCallback = closeCallback
end

function UIBaseClass:GetUIManager()
	return self.m_oUIManager
end

function UIBaseClass:GetUIRootNode()
	return self.m_oUIRootNode
end

function UIBaseClass:SeekNodeByPath( childNodePath )
	if childNodePath == nil or childNodePath == "" then
		return
	end
	return ccuiloader_seekNodeEx( self.m_oUIRootNode, childNodePath )
end

function UIBaseClass:AddDynamicItemCache( json, num )
	local uiManager = self:getUIManager()
	if uiManager == nil then
		return
	end
	if self.m_tDynamicItemCache[json] == nil then
		local tItemCaches = {}
		local tUnusedDynItemIdx = {}
		for i = 1, num do
			local listItemRootNode, width, height = uiManager:loadUIFromFilePath( json )
			local listItem = ccuiloader_seekNodeEx(listItemRootNode, "ref")
			if listItem then
		        listItem:retain()
		        listItem:setVisible(true)
		        listItem:removeFromParentAndCleanup(false)
		    end
		    listItem.nIndex = i
			table.insert( tItemCaches, listItem )
			table.insert( tUnusedDynItemIdx, i )
			self.m_tDynamicItemCache[json] = tItemCaches
			self.m_tUnusedDynItemIdx[json] = tUnusedDynItemIdx
		end
	end
end

function UIBaseClass:AddDynamicItemCacheByName( json, uiNode )
	if json == nil or uiNode == nil then
		return
	end
	local uiManager = self:getUIManager()
	if uiManager == nil then
		return
	end
	local tItemCaches = self.m_tDynamicItemCache[json] or {}
	local tUnusedDynItemIdx = self.m_tUnusedDynItemIdx[json] or {}
	if self.m_tDynamicItemCache[json] == nil then
		self.m_tDynamicItemCache[json] = {}
		self.m_tUnusedDynItemIdx[json] = {}
	end
	local listItem = ccuiloader_seekNodeEx(uiNode, "ref")
	if listItem ~= nil then
		listItem:retain()
        listItem:setVisible(true)
        listItem:removeFromParentAndCleanup(true)
		local nIdx = #tItemCaches + 1
		listItem.nIdx = nIdx
		table.insert( self.m_tDynamicItemCache[json], listItem )
		table.insert( tUnusedDynItemIdx, nIdx )
	end
end

function UIBaseClass:FinishInitDynItemCache( json )
	self.m_tDynamicItemCacheInited[json] = true
end

function UIBaseClass:IsDynamicItemCacheInited( json )
	return ( self.m_tDynamicItemCacheInited[json] == true)
end

function UIBaseClass:GetUnusedDynamicItemCache( json )
	local uiManager = self:getUIManager()
	if uiManager == nil then
		return
	end
	local tDynItemCache = self.m_tDynamicItemCache[json]
	if tDynItemCache == nil then
		self:addDynamicItemCache( json, 10 )
	end
	tDynItemCache = self.m_tDynamicItemCache[json]
	local listItemCacheCount = #tDynItemCache
	local tUnusedDynItemIdx = self.m_tUnusedDynItemIdx[json]
	if #tUnusedDynItemIdx == 0 then
		for i = 1, 10 do
			local listItemRootNode, width, height = uiManager:loadUIFromFilePath( json )
			local listItem = ccuiloader_seekNodeEx(listItemRootNode, "ref")
			if listItem then
		        listItem:retain()
		        listItem:setVisible(true)
		        listItem:removeFromParentAndCleanup(false)
		    end
		    listItem.nIndex = listItemCacheCount + i
			table.insert( tDynItemCache, listItem )
			table.insert( tUnusedDynItemIdx, listItem.nIndex )
		end 
	end
	local dynListItem = tDynItemCache[tUnusedDynItemIdx[1]]
	table.remove( tUnusedDynItemIdx, 1 )
	return dynListItem
end

function UIBaseClass:ClearDynmicItemUseMark( json )
	local tDynItemCache = self.m_tDynamicItemCache[json]
	local tUnusedDynItemIdx = self.m_tUnusedDynItemIdx[json]
	if tDynItemCache ~= nil then
		self.m_tUnusedDynItemIdx[json] = {}
		for i, v in ipairs( tDynItemCache ) do
			if v.removeAllEventListeners ~= nil then
				v:removeAllEventListeners()
			end
			if v.removeAllNodeEventListeners ~= nil then
				v:removeAllNodeEventListeners()
			end
			v:removeFromParentAndCleanup(false)
			self:ResetChildCtrlVisible( v, v.options )
			self.m_tUnusedDynItemIdx[json][i] = i
		end
	end
end

function UIBaseClass:ResetChildCtrlVisible( uiNode, options )
	if options ~= nil then
		uiNode:setVisible( options.visible )
		local jsonNode = uiNode.jsonNode
		if jsonNode ~= nil and jsonNode.children ~= nil then
			for i, v in ipairs( jsonNode.children ) do
				local childNode = ccuiloader_seekNodeEx( uiNode, v.options.name )
				if childNode ~= nil then
					self:ResetChildCtrlVisible( childNode, v.options )
				end
			end
		end
	end
end

function UIBaseClass:Close()
	self:ClearButtonGroups()	
	local uiManager = self:GetUIManager()
	if uiManager ~= nil then
		uiManager:CloseUI( self.uiName )
		if self.m_closeCallback ~= nil then
			self:closeCallback()
		end
	end
end

function UIBaseClass:DefauleDestory()
	self.m_tItemSlotMap = {}
	for _, tCache in pairs( self.m_tDynamicItemCache  ) do
		for i, v in ipairs(tCache) do
			v:release()
		end
	end
	self.m_tDynamicItemCache = {}
	self.m_tUnusedDynItemIdx = {}
end

function UIBaseClass:DoUIOpenNodeScaleAction( nodePath, callback, callbackData )
	nodePath = nodePath or "ref"
	local scaleNode = self:SeekNodeByPath( nodePath )
	if self.m_bIsScaling == true then
		return
	end
	self.m_bIsScaling = true
	if scaleNode ~= nil then
		local originX, originY = scaleNode:getPosition()
		local contentSize = scaleNode:getContentSize()
		scaleNode:setAnchorPoint( cc.p( 0.5, 0.5 ) )
		scaleNode:setPosition( cc.p( originX + contentSize.width / 2, originY + contentSize.height / 2) )
		scaleNode:setScale(0.01)
		scaleNode:setVisible(true)
		local array = CCArray:create()
        local scaleTo1 = CCScaleTo:create( 0.15, 1.15, 1.15 )
        local scaleTo2 = CCScaleTo:create( 0.1, 0.95, 0.95 )
        local scaleTo3 = CCScaleTo:create( 0.08, 1, 1 )
        local endedCallback = CCCallFunc:create(function()
        											scaleNode:setAnchorPoint( cc.p( 0, 0 ) ) 
        									    	scaleNode:setPosition( cc.p( originX, originY ) )
        									    	self.m_bIsScaling = false
        									    	if callback ~= nil then
        									    		callback( callbackData )
        									    	end
        									    end)
        array:addObject(scaleTo1)
        array:addObject(scaleTo2)
        array:addObject(scaleTo3)
        array:addObject(endedCallback)
        local sequence = CCSequence:create( array )
		scaleNode:runAction( sequence )
	end
end

function UIBaseClass:ShowSystemTips( sTips )
	local uiManager = self:getUIManager()
	if uiManager ~= nil then
		uiManager:ShowSystemTips( sTips )
	end
end

function UIBaseClass:CreateButtonGroup( sGroupName, sNormal, sHighLight, selectChangedHandler )
	if self.m_tButtonGroupInfo[sGroupName] == nil then
		self.m_tButtonGroupInfo[sGroupName] = { NORMAL = sNormal, SELECTED = sHighLight, Buttons = {}, SelectedName = "", ChangeHandler = selectChangedHandler }
	end
end

function UIBaseClass:ClearButtonGroups()
	self.m_tButtonGroupInfo = {}
end

function UIBaseClass:addButtonToGroup( sGroupName, sButtonName )
	local tGroupInfo = self.m_tButtonGroupInfo[sGroupName]
	if tGroupInfo ~= nil then
		local nIdx = self:__getButtonIdxByName( sGroupName, sButtonName )
		if nIdx == -1 then
			local oButton = self:SeekNodeByPath( sButtonName )
			if oButton ~= nil then
				oButton.GroupName = sGroupName
				oButton.ButtonName = sButtonName
				table.insert( tGroupInfo.Buttons, {sButtonName, oButton } )
				self:RegisterEventsHandlers( sButtonName, "OnClicked", self.onClickedDefaultGroupBtn )	
				if #tGroupInfo.Buttons == 1 then
					self:onSelectButtonByName( sGroupName, sButtonName )
				else
					oButton:setButtonImage( "normal",  tGroupInfo.NORMAL )
 					oButton:setButtonImage( "pressed", tGroupInfo.SELECTED )
				end
			end
		end
	end
end

function UIBaseClass:onClickedDefaultGroupBtn( oControl )
	local sGroupName = oControl.GroupName
	local sButtonName= oControl.ButtonName
	if sGroupName ~= nil and sButtonName ~= nil then
		self:onSelectButtonByName( sGroupName, sButtonName )
	end
end

function UIBaseClass:onSelectButtonByName( sGroupName, sButtonName )
	local tGroupInfo = self.m_tButtonGroupInfo[sGroupName]
	if tGroupInfo.SelectedName == sButtonName then
		return
	end
	if tGroupInfo ~= nil then
		for i, v in ipairs( tGroupInfo.Buttons ) do
			local oButton = v[2]
			if oButton ~= nil then
				if v[1] == sButtonName then
					tGroupInfo.SelectedName = v[1]
					oButton:setButtonImage( "normal",  tGroupInfo.SELECTED )
 					oButton:setButtonImage( "pressed", tGroupInfo.SELECTED )
				else
					oButton:setButtonImage( "normal",  tGroupInfo.NORMAL )
 					oButton:setButtonImage( "pressed", tGroupInfo.SELECTED )
				end
			end
		end
		if tGroupInfo.ChangeHandler ~= nil then
			tGroupInfo.ChangeHandler( self, sGroupName )
		end
	end
end

function UIBaseClass:onSelectButton( sGroupName, oControl )
	local tGroupInfo = self.m_tButtonGroupInfo[sGroupName]
	if tGroupInfo ~= nil then
		for i, v in ipairs( tGroupInfo.Buttons ) do
			local oButton = v[2]
			if oButton ~= nil then
				if v[2] == oControl then
					tGroupInfo.SelectedName = v[1]
					oButton:setButtonImage( "normal",  tGroupInfo.SELECTED )
 					oButton:setButtonImage( "pressed", tGroupInfo.SELECTED )
				else
					oButton:setButtonImage( "normal",  tGroupInfo.NORMAL )
 					oButton:setButtonImage( "pressed", tGroupInfo.NORMAL )
				end
			end
		end
	end
end

function UIBaseClass:getButtonGroupSelectedIdx( sGroupName )
	local tGroupInfo = self.m_tButtonGroupInfo[sGroupName]
	if tGroupInfo ~= nil then
		return self:__getButtonIdxByName( sGroupName, tGroupInfo.SelectedName )
	end
end

function UIBaseClass:__getButtonIdxByName( sGroupName, sButtonName )
	local nIdx = -1
	local tGroupInfo = self.m_tButtonGroupInfo[sGroupName]
	if tGroupInfo ~= nil then
		for i, v in ipairs( tGroupInfo.Buttons ) do
			if v[1] == sButtonName then
				nIdx = i
				break
			end
		end
	end
	return nIdx
end

function UIBaseClass:__getButtonByName( sGroupName, sButtonName )
	local nIdx = -1
	local tGroupInfo = self.m_tButtonGroupInfo[sGroupName]
	if tGroupInfo ~= nil then
		for i, v in ipairs( tGroupInfo.Buttons ) do
			if v[1] == sButtonName then
				nIdx = i
				break
			end
		end
	end
	return nIdx
end

function UIBaseClass:ShowSystemTips( sStrId )
	local uiManager = self:getUIManager()
	if uiManager ~= nil then
		uiManager:ShowSystemTips( app:GET_STR( sStrId ) )
	end
end

function UIBaseClass:RegisterItemSlot( sItemSlotName, sItemBtn, sItemIconName, sNumLabelName,showPanel, clickedHandler )
	assert(self.m_oUIManager)
	local tItemSlotInfo = self.m_tItemSlotMap[ sItemSlotName ]
	if tItemSlotInfo ~= nil and tItemSlotInfo.EffectNode ~= nil then
		tItemSlotInfo.EffectNode:removeFromParentAndCleanup()
		self.m_tItemSlotMap[sItemSlotName] = nil
	end
	self.m_tItemSlotMap[ sItemSlotName ] = { BtnName = sItemBtn, SpriteName = sItemIconName, NumLabelName = sNumLabelName }
	self.m_oUIManager:registerItemSlotClickedHandler( sItemSlotName, showPanel, clickedHandler, self )
	self:updateSlotView( sItemSlotName )
end

function UIBaseClass:RegisterDynamicItemSlot( sItemSlotName, slotBtn, slotIcon, slotNumLabel, showPanel, clickedHandler )
	assert(self.m_oUIManager)
	self.m_tItemSlotMap[ sItemSlotName ] = { SlotBtn = slotBtn, SlotSprite = slotIcon, SlotNumLabel = slotNumLabel }
	self.m_oUIManager:registerDynamicItemSlotClickedHandler( sItemSlotName, showPanel, clickedHandler, self )
	self:updateSlotView( sItemSlotName )
end

function UIBaseClass:GetItemSlotInfoByName( sItemSlotName )
	return self.m_tItemSlotMap[ sItemSlotName ]
end

function UIBaseClass:AddAnimToNodeByPath( sNodePath, nId, nAnimId, nZOrder, nOX, nOY, nScale )
	local uiManager = self:getUIManager()
	local oNode = self:SeekNodeByPath( sNodePath )
	if uiManager ~= nil and oNode ~= nil then
		uiManager:AddAnimToNode( oNode, nId, nAnimId, nZOrder, nOX, nOY, nScale )
	end
end

function UIBaseClass:AddAnimToNode( oNode, nId, nAnimId, nZOrder, nOX, nOY, nScale )
	local uiManager = self:getUIManager()
	if uiManager ~= nil and oNode ~= nil then
		uiManager:AddAnimToNode( oNode, nId, nAnimId, nZOrder, nOX, nOY, nScale )
	end
end

function UIBaseClass:RemoveAnimFromNodeByPath( sNodePath, nId )
	local uiManager = self:getUIManager()
	local oNode = self:SeekNodeByPath( sNodePath )
	if uiManager ~= nil and oNode ~= nil then
		uiManager:RemoveAnimByIdFromNode( oNode, nId )
	end
end

function UIBaseClass:RemoveAnimFromNode( oNode, nId )
	local uiManager = self:getUIManager()
	if uiManager ~= nil and oNode ~= nil then
		uiManager:RemoveAnimByIdFromNode( oNode, nId )
	end
end

function UIBaseClass:ClearAllAnimFromNodeByPath( sNodePath )
	local uiManager = self:getUIManager()
	local oNode = self:SeekNodeByPath( sNodePath )
	if uiManager ~= nil and oNode ~= nil then
	end
	uiManager:ClearAllAnimFromNode( oNode )
end

function UIBaseClass:ClearAllAnimFromNode( oNode )
	local uiManager = self:getUIManager()
	if uiManager ~= nil and oNode ~= nil then
		uiManager:ClearAllAnimFromNode( oNode )
	end
end

function UIBaseClass:clearItemSlotInfo()
	self.m_tItemSlotMap = {}
end

function UIBaseClass:setItemSlotInfo( sItemSlotName, itemInfo, coverViewId, coverViewScale, coverViewPause )
	if self.m_tItemSlotMap[ sItemSlotName ] ~= nil then
		self.m_tItemSlotMap[ sItemSlotName ].ItemInfo = itemInfo
		self.m_tItemSlotMap[ sItemSlotName ].CoverViewId = coverViewId
		self.m_tItemSlotMap[ sItemSlotName ].CoverViewScale = coverViewScale
		self.m_tItemSlotMap[ sItemSlotName ].CoverViewPause = coverViewPause
	end
	self:updateSlotView( sItemSlotName )
end

function UIBaseClass:setItemSlotVisible( sItemSlotName, visible )
	local tItemSlotInfo = self.m_tItemSlotMap[ sItemSlotName ]
	if tItemSlotInfo ~= nil then
		local slotBtn = nil
		local slotSprite = nil
		local itemNumLabel = nil
		if tItemSlotInfo.BtnName ~= nil then
			slotBtn = self:SeekNodeByPath( tItemSlotInfo.BtnName )
			slotSprite = self:SeekNodeByPath( tItemSlotInfo.SpriteName )
			itemNumLabel = self:SeekNodeByPath( tItemSlotInfo.NumLabelName )
		else
			slotBtn = tItemSlotInfo.SlotBtn
			slotSprite = tItemSlotInfo.SlotSprite
			itemNumLabel = tItemSlotInfo.SlotNumLabel
		end
		if slotBtn ~= nil then
			slotBtn:setVisible( visible )
		end
		if slotSprite ~= nil then
			slotSprite:setVisible( visible )
		end
		if itemNumLabel ~= nil then
			itemNumLabel:setVisible( visible )
		end
	end
end

function UIBaseClass:setItemSlotEffect( sItemSlotName, nEffectId, nZOrder, nScale )
	local tItemSlotInfo = self.m_tItemSlotMap[ sItemSlotName ]
	if tItemSlotInfo ~= nil then
		local slotBtn = nil
		if tItemSlotInfo.BtnName ~= nil then
			if tItemSlotInfo.EffectNode ~= nil then
				tItemSlotInfo.EffectNode:removeFromParentAndCleanup()
				tItemSlotInfo.EffectNode = nil
			end
			slotBtn = self:SeekNodeByPath( tItemSlotInfo.BtnName )
			local effectNode = Factory.createAnim( nEffectId, false, false )
			if effectNode ~= nil then
				slotBtn:addChild( effectNode )
				tItemSlotInfo.EffectNode = effectNode
				if nScale ~= nil then
					effectNode:setScale( nScale )
					effectNode:setZOrder( nZOrder or 10)
				end
			end
		end
	end
end

function UIBaseClass:setItemSlotOutAction( sItemSlotName )
	local tItemSlotInfo = self.m_tItemSlotMap[ sItemSlotName ]
	if tItemSlotInfo ~= nil then
		local slotBtn = nil
		local slotSprite = nil
		local itemNumLabel = nil

		slotBtn = self:SeekNodeByPath( tItemSlotInfo.BtnName )
		slotSprite = self:SeekNodeByPath( tItemSlotInfo.SpriteName )
		itemNumLabel = self:SeekNodeByPath( tItemSlotInfo.NumLabelName )

		if slotBtn ~= nil then
			slotBtn:setVisible( false )
		end
		if slotSprite ~= nil then
			local action = cc.FadeOut:create(1)
			slotSprite:runAction( action )
		end
		if itemNumLabel ~= nil then
			itemNumLabel:setVisible( false )
		end
	end
end

function UIBaseClass:setItemSlotInAction( sItemSlotName )
	local tItemSlotInfo = self.m_tItemSlotMap[ sItemSlotName ]
	if tItemSlotInfo ~= nil then
		local slotSprite = nil
		slotSprite = self:SeekNodeByPath( tItemSlotInfo.SpriteName )
		if slotSprite ~= nil then
			local action = cc.Blink:create(1,5)
			slotSprite:runAction( action )
		end
	end
end

function UIBaseClass:updateSlotView( sItemSlotName )
	local tItemSlotInfo = self.m_tItemSlotMap[ sItemSlotName ]
	if tItemSlotInfo ~= nil then
		local itemIconSprite = nil
		local itemNumLabel = nil
		if tItemSlotInfo.SpriteName ~= nil then
			itemIconSprite = self:SeekNodeByPath( tItemSlotInfo.SpriteName )
			itemNumLabel = self:SeekNodeByPath( tItemSlotInfo.NumLabelName )
		else
			itemIconSprite = tItemSlotInfo.SlotSprite
			itemNumLabel = tItemSlotInfo.SlotNumLabel
		end	
		local itemInfo = tItemSlotInfo.ItemInfo
		if itemInfo ~= nil then
			if itemIconSprite ~= nil then
				itemIconSprite:setVisible( true )
				local slotSprite = self.m_oUIManager:replaceSpriteIcon( itemIconSprite, itemInfo.plistFile, itemInfo.iconName, false )
				if slotSprite ~= nil then
					tItemSlotInfo.SlotSprite = slotSprite
				end
			end
			if itemNumLabel ~= nil then
				itemNumLabel:setVisible( true )
				itemNumLabel:setString( itemInfo.count )
			end
		else
			if itemIconSprite ~= nil then
				itemIconSprite:setVisible( false )
			end
			if itemNumLabel ~= nil then
				itemNumLabel:setVisible( false )
			end
		end
		local coverViewId = tItemSlotInfo.CoverViewId or 0
		local coverViewScale = tItemSlotInfo.CoverViewScale or 1
		local coverPause = tItemSlotInfo.CoverViewPause or false
		if coverViewId ~= nil and coverViewId ~= 0 then
			local slotBtn = nil
			local slotSprite = nil
			local itemNumLabel = nil
			if tItemSlotInfo.BtnName ~= nil then
				slotBtn = self:SeekNodeByPath( tItemSlotInfo.BtnName )
				slotSprite = self:SeekNodeByPath( tItemSlotInfo.SpriteName )
				itemNumLabel = self:SeekNodeByPath( tItemSlotInfo.NumLabelName )
			else
				slotBtn = tItemSlotInfo.SlotBtn
				slotSprite = tItemSlotInfo.SlotSprite
				itemNumLabel = tItemSlotInfo.SlotNumLabel
			end
			if slotBtn ~= nil then
				slotBtn:setVisible( true )
			end
			if slotSprite ~= nil then
				slotSprite:setVisible( false )
			end
			if itemNumLabel ~= nil then
				itemNumLabel:setVisible( false )
			end
			local btnContentSize = slotBtn:getContentSize()
			if slotBtn.animView ~= nil then
				slotBtn.animView:removeFromParentAndCleanup(true)
				slotBtn.animView = nil
			end
			local animView, viewCfg = Factory.createAnim( coverViewId )
			if animView ~= nil and viewCfg ~= nil then
				animView:setPosition( cc.p( btnContentSize.width / 2, btnContentSize.height / 2) )
				animView:setScale( coverViewScale )
				slotBtn:addChild( animView, 100 )
				if viewCfg.type == 3 then
					local animation = animView:getAnimation()
					if animation ~= nil then
						if coverPause == true then
							animation:pause()
						end
					end
				end
				slotBtn.animView = animView
			end
		end
	end
end

function UIBaseClass:GetUIControlByPath( uiName, controlPath )
	local uiManager = self:getUIManager()
	if uiManager == nil then
		return
	end
	local uiModule = uiManager:GetUIByName( uiName )
	if uiModule ~= nil then
		return uiModule:SeekNodeByPath( controlPath )
	end
end

return UIBaseClass