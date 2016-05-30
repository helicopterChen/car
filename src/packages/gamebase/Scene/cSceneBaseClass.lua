
local cSceneBaseClass = class( "cSceneBaseClass" )

function cSceneBaseClass:ctor()
	self.m_bPaused = false
	self.m_oSceneRoot = nil
	self.m_oUILayer = nil
	self.m_oGameLayer = nil
	self.m_sName = name
	self.m_oResLoader = nil
	self.m_nTimePast = 0
	self.m_tPreLoadData = 
	{
		Textures = {},
		SpriteFrame = {},
		Armatures = {},
		LoadUI = {},
		JsonData = {},
	}
end

function cSceneBaseClass:SetSceneRoot( oSceneRoot, bUsePhysics )
	self.m_oSceneRoot = oSceneRoot
  	-- 启动帧侦听
    self:scheduleUpdate()  
    self:removeAllNodeEventListeners()
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function( dt ) self:DefaultUpdate(dt) end)    
    oSceneRoot.onEnter = 
    function( ... )
    end
    oSceneRoot.onExit = 
    function( ... )
    	self:OnExit( ... )
    	self:unscheduleUpdate()
    end
    oSceneRoot.onEnterTransitionDidFinish =
    function( ... )
    	self:onEnterTransitionDidFinish( ... )
    end
    if bUsePhysics == true then
        self.m_oPhysicalWorld = oSceneRoot:getPhysicsWorld()
        self.m_oPhysicalWorld:setAutoStep(false)
        self.m_oPhysicalWorld:setGravity(cc.p(0, 0))
        self.m_oPhysicalWorld:setDebugDrawMask(0)
    end
    local uiLayer = cc.Layer:create()
   	if uiLayer ~= nil then
	   	self.m_oUILayer = uiLayer
	   	oSceneRoot:addChild( uiLayer, 200 )
	   	uiLayer:setLocalZOrder( 200 )
	   	uiLayer:setKeypadEnabled(true)
	   	if self.m_sName ~= "SceneSplash" and self.m_sName ~= "SceneLoadSplash" then
		   	uiLayer:addNodeEventListener(cc.KEYPAD_EVENT,
	   		function(event)
	   			local uiManager = app.uiManager
	   			local sdkAdapter = app.sdkAdapter
	   			if uiManager == nil or sdkAdapter == nil then
	   				return
	   			end
	   			if self.m_sName == "SceneLoadSplash" or uiManager:IsShowUI( "UILoading" ) == true  then
	   				return
	   			end
	   			if event.key == "back" then
	   				local function choiceCancelCallback()
	   					local curScene = app.sceneManager:GetCurScene()
		   				if curScene ~= nil and curScene.pauseGame ~= nil then
		   					if curScene.originPauseState ~= true then
		   						curScene:pauseGame( false )
		   					end
		   				end
	   				end
	   				local function sdkExitCallback( result )
		            	if tonumber( result ) == 0 then
		   					app:saveAllData()
		   					app:onExitGame()
			                CCDirector:sharedDirector():endToLua()		            		
		            	else
		            		choiceCancelCallback()
		            	end
		            end
	   				local function choiceOkCallback()
		                sdkAdapter:showExit( sdkExitCallback )
	   				end
	   				local curScene = app.sceneManager:GetCurScene()
	   				if curScene ~= nil and curScene.pauseGame ~= nil then
	   					curScene.originPauseState = curScene.m_bPaused
	   					curScene:pauseGame( true )
	   				end
	   				local tData = 
					{ 
						Title = app:GET_STR( "STR_EXIT_GAME" ),
						Desc = app:GET_STR( "STR_IS_EXIT_GAME" ),
						Btn1Label = app:GET_STR( "STR_SHORT_YES" ),
						Btn1Callback = choiceOkCallback,
						Btn2Label = app:GET_STR( "STR_SHORT_NO" ), 
						Btn2Callback = choiceCancelCallback,
						Btn2CallbackData = nil,
						CloseCallback = choiceCancelCallback,
						CloseCallbackData = nil,
					}
					uiManager:showExitDialog( tData )
	   			end 
	   		end)
		end
	end
	local oGameLayer = cc.Layer:create()
	if oGameLayer ~= nil then
	   	oSceneRoot:addChild( oGameLayer, 0 )
	   	self.m_oGameLayer = oGameLayer
	end
end

function cSceneBaseClass:SetGameApp( oGameApp )
	self.m_oGameApp = oGameApp
end

function cSceneBaseClass:GetGameApp()
	return self.m_oGameApp
end

function cSceneBaseClass:PreLoadRes()
end

function cSceneBaseClass:AddPreLoadResWork()
	local tPreLoadData = self.m_tPreLoadData
	if tPreLoadData == nil then
		return
	end
	tPreLoadData.CfgNeedLoadMap = {}
	for i, v in ipairs(tPreLoadData.JsonData) do
		tPreLoadData.CfgNeedLoadMap[v] = true
	end
	tPreLoadData.CfgNeedLoad = {}
	--[[
	for i, v in ipairs(CfgData.__cfgs__) do
		local jsonPath = string.format( "config/%s", v[2] )
		if tPreLoadData.CfgNeedLoadMap[jsonPath] == true then
			table.insert( tPreLoadData.CfgNeedLoad, {string.format( "config/%s", v[2]), v} )
		end
    end
    --]]
	local oResLoader = self:GetResLoader()
    if oResLoader ~= nil then
        for i, v in ipairs( tPreLoadData.JsonData ) do
             oResLoader:AddAsyncLoadWork( "JSON_DATA", "DIRECT", v )
        end
        for i, v in ipairs( tPreLoadData.Textures ) do
            oResLoader:AddAsyncLoadWork( "TEXTURE", "DIRECT", v )
        end
        for i, v in ipairs( tPreLoadData.SpriteFrame ) do
           oResLoader:AddAsyncLoadWork( "SPRITEFRAME", "DIRECT", v[1], v[2] ) 
        end
        for i, v in ipairs( tPreLoadData.Armatures ) do
            oResLoader:AddAsyncLoadWork( "ARMATURE", "DIRECT", v[1], v[2] )
        end
        for i, v in ipairs( tPreLoadData.LoadUI ) do
            oResLoader:AddAsyncLoadWork( "UI", "DIRECT", v )
        end
        --for i, v in ipairs( tPreLoadData.CfgNeedLoad ) do
        --    oResLoader:AddAsyncLoadWork( "CFG_DATA", "DIRECT", v[1], v[2] )
        --end
        for i, v in ipairs( tPreLoadData.LoadUI ) do
            oResLoader:AddAsyncLoadWork( "UI_NODE_PRE_CREATE", "DIRECT", v )
        end
    end
end

function cSceneBaseClass:DefaultLoadOver()
	self:OnEnter()
end

function cSceneBaseClass:GetSceneRoot()
	return self.m_oSceneRoot
end

function cSceneBaseClass:GetUILayer()
	return self.m_oUILayer
end

function cSceneBaseClass:GetGameLayer()
	return self.m_oGameLayer
end

function cSceneBaseClass:SetCallback( callback, tCallbackData )
	self.m_pCallback = callback
	self.m_tCallbackData = tCallbackData
end

function cSceneBaseClass:SetShowUICallback( pCallback, tCallbackData )
    self.m_pShowUICallback = pCallback
    self.m_tShowUICallbackData = tCallbackData
end

function cSceneBaseClass:SetResLoader( oResLoader )
	self.m_oResLoader = oResLoader
end

function cSceneBaseClass:GetResLoader()
	return self.m_oResLoader
end

function cSceneBaseClass:DefaultUpdate( dt )
	if dt > 0.02 then dt = 0.02 end
	self.m_nTimePast = self.m_nTimePast + dt 
	local oGameApp = _G.GAME_APP
	if oGameApp ~= nil then
		if oGameApp.DefaultUpdate ~= nil then
	   		oGameApp:DefaultUpdate( dt )
	   	end
	    if oGameApp.Update ~= nil then
	    	oGameApp:Update( dt )
	    end
	end
	if self.m_oPhysicalWorld ~= nil then
		self.m_oPhysicalWorld:step(dt)
	end
	if self.Update ~= nil then
		self:Update(dt)
	end
end

function cSceneBaseClass:addChild( node, zorder, tag )
	if self.m_oSceneRoot ~= nil then
		self.m_oSceneRoot:addChild( node, zorder or 1, tostring(tag or -1) )
	end
end

function cSceneBaseClass:scheduleUpdate()
	if self.m_oSceneRoot ~= nil then
		self.m_oSceneRoot:scheduleUpdate()
	end
end

function cSceneBaseClass:unscheduleUpdate()
	if self.m_oSceneRoot ~= nil then
		self.m_oSceneRoot:unscheduleUpdate()
	end
end

function cSceneBaseClass:addNodeEventListener( ... )
	if self.m_oSceneRoot ~= nil then
		self.m_oSceneRoot:addNodeEventListener( ... )
	end
end

function cSceneBaseClass:removeAllNodeEventListeners( ... )
	if self.oSceneRoot ~= nil then
		self.m_oSceneRoot:removeAllNodeEventListeners( ... )
	end
end

function cSceneBaseClass:convertToNodeSpace( ... )
	if self.m_oSceneRoot ~= nil then
		return self.m_oSceneRoot:convertToNodeSpace( ... )
	end
end

function cSceneBaseClass:runAction( ... )
	if self.m_oSceneRoot ~= nil then
		self.m_oSceneRoot:runAction( ... )
	end
end


return cSceneBaseClass