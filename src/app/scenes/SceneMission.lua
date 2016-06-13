local SceneMission = class("SceneMission",  _G.GAME_BASE.cSceneBaseClass )

local GRAVITY         = 0
local COIN_MASS       = 100
local COIN_RADIUS     = 46
local COIN_FRICTION   = 0.95
local COIN_ELASTICITY = 0.95
local WALL_THICKNESS  = 64
local WALL_FRICTION   = 1.0
local WALL_ELASTICITY = 0.5
local _angle_r2a = 180 / math.pi

function SceneMission:OnCreate( nMissionId )
    self.m_nMissionId = nMissionId
end

function SceneMission:PreLoadRes()
end

function SceneMission:OnLoadOver()
end

function SceneMission:OnEnter()
    local oGameApp = self:GetGameApp()
    if oGameApp == nil then
        return
    end
    local oRaceLogicManager = oGameApp:GetRaceLogicManager()
    if oRaceLogicManager == nil then
        return
    end
    local uiManager = _G.GAME_APP:GetUIManager()
    if uiManager == nil then
        return
    end
    function showUICallback()
        self.m_oRaceLogicManager = oRaceLogicManager
        oRaceLogicManager:StartRace( self.m_nMissionId )
    end
    uiManager:ShowUI( "UIGameMission", true, showUICallback,nil, true )
end

function SceneMission:OnExit()
    if self.m_oRaceLogicManager ~= nil then
        self.m_oRaceLogicManager:OnDestory()
    end
end

function SceneMission:OnTouch( event )
    if self.m_oRaceLogicManager ~= nil then
        self.m_oRaceLogicManager:OnTouch( event )
    end
end

function SceneMission:Update(dt)
    local oSceneRoot = self:GetSceneRoot()
    local oGameLayer = self:GetGameLayer()
    if oSceneRoot == nil or oGameLayer == nil then
        return
    end
    if self.m_oRaceLogicManager ~= nil then
        self.m_oRaceLogicManager:Update( dt )
    end
end

return SceneMission