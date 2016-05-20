local cAppBase = class("cAppBase")
local cSceneManager  = import( "..Scene.cSceneManager" )
local cDataManager 	 = import( ".cDataManager" )
local cResManager	 = import( ".cResManager" )
local cObjectManager = import( "..Object.cObjectManager" )
local cServerObjectManager = import( "..Object.cServerObjectManager" )
local UIManager     = import( "..UIUtility.UIManager" )
local cPropertiesManager = import( "..Object.cPropertiesManager" )
local cNetConnectionManager = import( "..Network.cNetConnectionManager" )
local cNetFakeServerManager = import( "..Network.cNetFakeServerManager" )

cAppBase.APP_ENTER_BACKGROUND_EVENT = "APP_ENTER_BACKGROUND_EVENT"
cAppBase.APP_ENTER_FOREGROUND_EVENT = "APP_ENTER_FOREGROUND_EVENT"


function cAppBase:ctor(appName, packageRoot)
	_G.GAME_APP = self
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

	self.name = appName
    self.packageRoot = packageRoot or "app"

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    local customListenerBg = cc.EventListenerCustom:create(cAppBase.APP_ENTER_BACKGROUND_EVENT,
                                handler(self, self.OnEnterBackground))
    eventDispatcher:addEventListenerWithFixedPriority(customListenerBg, 1)
    local customListenerFg = cc.EventListenerCustom:create(cAppBase.APP_ENTER_FOREGROUND_EVENT,
                                handler(self, self.OnEnterForeground))
    eventDispatcher:addEventListenerWithFixedPriority(customListenerFg, 1)

	self.m_oDataManager = cDataManager:GetInstance()
	self.m_oSceneManager = cSceneManager:GetInstance()
	self.m_oObjectManager = cObjectManager:GetInstance()
	self.m_oServerObjectManager = cServerObjectManager:GetInstance()
	self.m_oUIManager	  = UIManager:GetInstance()
	self.m_oNetConnectionManager = cNetConnectionManager:GetInstance()
	self.m_oResManager	= cResManager:GetInstance()
	self.m_oNetFakeServerManager = cNetFakeServerManager:GetInstance()
	self.m_oPropertiesManager = cPropertiesManager:GetInstance()
	self.m_oSceneManager:SetGameApp( self )
	self.m_oDataManager:SetGameApp( self )
	self.m_oUIManager:SetGameApp( self )
	self.m_oResManager:SetGameApp( self )
	self.m_oNetFakeServerManager:SetGameApp( self )
	self.m_oPropertiesManager:SetGameApp( self )
	self:LoadBaseDataConfig()
	self:LoadDataConfig()
	self:DefaultCreate()
	if self.OnCreate ~= nil then
		self:OnCreate()
	end
end

function cAppBase:Run()
end

function cAppBase:OnExit()
end

function cAppBase:Exit()
    cc.Director:getInstance():endToLua()
    if device.platform == "windows" or device.platform == "mac" then
        os.exit()
    end
end

function cAppBase:DefaultExit()
	self.m_oObjectManager:Reset()
	self:OnExit()
end

function cAppBase:Reset()
	self.m_oObjectManager:Reset()
	self.m_oServerObjectManager:Reset()
	self.m_oNetConnectionManager:Reset()
	self.m_oNetFakeServerManager:Reset()
end

function cAppBase:LoadDataConfig()
end

function cAppBase:DefaultCreate()
	self.m_oUIManager:Init()
end

function cAppBase:DefaultUpdate( nTimeDelta )
	if GAME_PAUSE_UPDATE ~= true then
		self.m_oResManager:Update( nTimeDelta )
		self.m_oSceneManager:Update( nTimeDelta )
		self.m_oObjectManager:Update( nTimeDelta )
		self.m_oServerObjectManager:Update( nTimeDelta )
		self.m_oUIManager:Update( nTimeDelta )
		self.m_oNetConnectionManager:Update( nTimeDelta )
		self.m_oNetFakeServerManager:Update( nTimeDelta )
		self:OnUpdate( nTimeDelta )
	end
end

function cAppBase:OnUpdate( nTimeDelta )
	
end

function cAppBase:OnEnterBackground()
    self:dispatchEvent({name = AppBase.APP_ENTER_BACKGROUND_EVENT})
end

function cAppBase:OnEnterForeground()
    self:dispatchEvent({name = AppBase.APP_ENTER_FOREGROUND_EVENT})
end

function cAppBase:EnterScene(sceneName, args, transitionType, time, more)
    local scenePackageName = self.packageRoot .. ".scenes." .. sceneName
    local sceneClass = require(scenePackageName)
    local scene = sceneClass.new(unpack(checktable(args)))
    display.replaceScene(scene, transitionType, time, more)
end

function cAppBase:OnChangeSceneReset()
	if self.m_oAvatarManager ~= nil then
		self.m_oAvatarManager:Reset()
	end
	if self.m_oObjectManager ~= nil then
		self.m_oObjectManager:Reset()
	end
	if self.m_oSceneManager ~= nil then
		self.m_oSceneManager:Reset()
	end
end

function cAppBase:SetResManagerUpdate( bUpdate )
    self.bNeedUpdateResManager = bUpdate
end

function cAppBase:LoadBaseDataConfig()
end

function cAppBase:GetSceneManager()
	return self.m_oSceneManager
end

function cAppBase:GetDataManager()
	return self.m_oDataManager
end

function cAppBase:GetUIManager()
	return self.m_oUIManager
end

function cAppBase:GetNetConnectionManager()
	return self.m_oNetConnectionManager
end

function cAppBase:GetCurScene()
	return self.m_oSceneManager:GetCurScene()
end

function cAppBase:GetResManager()
	return self.m_oResManager
end

function cAppBase:GetNetFakeServerManager()
	return self.m_oNetFakeServerManager
end

function cAppBase:GetPropertiesManager()
	return self.m_oPropertiesManager
end

return cAppBase
