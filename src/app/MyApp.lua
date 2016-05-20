
require("config")
require("cocos.init")
require("framework.init")

_G.GAME_BASE = cc.load( "gamebase" )

local MyApp = class("MyApp", _G.GAME_BASE.cAppBase )

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:Run()
    self:GetSceneManager():EnterScene("SceneSplash")
end

function MyApp:LoadDataConfig()
end

function MyApp:OnUpdate( nTimeDelta )

end

function MyApp:EnterLoadSplash()
	self:GetSceneManager():EnterScene("SceneLoadSplash") 
end

function MyApp:EnterSceneMainGame()
	self:GetSceneManager():EnterScene("SceneMainGame") 
end

function MyApp:EnterSceneMission()
	self:GetSceneManager():EnterScene("SceneMission",true) 
end

return MyApp
