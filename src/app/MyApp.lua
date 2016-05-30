
require("config")
require("cocos.init")
require("framework.init")
_G.GAME_BASE = cc.load( "gamebase" )
require("app.init")
local cRaceLogicManager = import("app.raceLogic.cRaceLogicManager")

local MyApp = class("MyApp", _G.GAME_BASE.cAppBase )
local ObjectPropertiesConfig = import( ".gameObject.ObjectPropertiesConfig" );

function MyApp:ctor()
    self.super.ctor(self)
    self.m_oRaceLogicManager = cRaceLogicManager:GetInstance()
    self.m_oRaceLogicManager:SetGameApp(self)
end

function MyApp:Run()
    self:GetSceneManager():EnterScene("SceneSplash")
end

function MyApp:LoadDataConfig()
	self.m_oDataManager:LoadJsonData( "config/Towers.json", "TowersConf", true, true );
	self.m_oDataManager:LoadJsonData( "config/Missions.json", "MissionsConf", true );
	self.m_oDataManager:LoadJsonData( "config/Cars.json", "CarConf", true );
end

function MyApp:OnUpdate( nTimeDelta )
end

function MyApp:OnCreate()
	math.randomseed(os.time());
	local oPropertieManager = self:GetPropertiesManager()
	if oPropertieManager ~= nil then
		oPropertieManager:SetPropertieConf( ObjectPropertiesConfig )
	end
end

function MyApp:EnterLoadSplash()
	self:GetSceneManager():EnterScene("SceneLoadSplash") 
end

function MyApp:EnterSceneMainGame()
	self:GetSceneManager():EnterScene("SceneMainGame") 
end

function MyApp:EnterSceneMission( nMissionId, callback, tCallbackData )
	self:GetSceneManager():EnterScene("SceneMission",true, { nMissionId }, callback, tCallbackData ) 
end

function MyApp:GetRaceLogicManager()
	return self.m_oRaceLogicManager
end

return MyApp
