local cRaceLogicManager = class("cRaceLogicManager")

function cRaceLogicManager:ctor()
end

function cRaceLogicManager:GetInstance()
	if _G.__oRaceLogicManager == nil then
		_G.__oRaceLogicManager = cRaceLogicManager:new()
	end
	return _G.__oRaceLogicManager
end

function cRaceLogicManager:SetGameApp( oGameApp )
	self.m_oGameApp = oGameApp
end

function cRaceLogicManager:GetGameApp()
	return self.m_oGameApp
end

function cRaceLogicManager:StartRace( nMissionId )
	local oGameApp = self:GetGameApp()
	if oGameApp == nil then
		return
	end
	local oCurScene = oGameApp:GetCurScene()
	if oCurScene == nil then
		return
	end
	local oGameLayer = oCurScene:GetGameLayer()
	local oDataManager = oGameApp:GetDataManager()
	if oDataManager == nil or oGameLayer == nil then
		return
	end
	local tMissionConf = oDataManager:GetDataByNameAndId( "MissionsConf", nMissionId )
	if tMissionConf ~= nil then
		if self.m_oCurRaceLogic ~= nil then
			self:RecordOldRaceData()
		end
		local oRaceLogic = self:CreateNewRaceByType( tMissionConf.type )
		if oRaceLogic ~= nil then
			oRaceLogic:SetGameApp( self.m_oGameApp )
			self.m_oCurRaceLogic = oRaceLogic
			oRaceLogic:InitRaceWithConf( tMissionConf )
			oRaceLogic:OnStart()
		end
	end
end

function cRaceLogicManager:PauseRace()
	if self.m_oCurRaceLogic ~= nil then
		self.m_oCurRaceLogic:Pause()
	end
end

function cRaceLogicManager:CreateNewRaceByType( sType )
	local sRaceClassPath = string.format("app.raceLogic.cRaceMode%s", sType)
	local cRackModeClass = require (sRaceClassPath)
	if cRackModeClass ~= nil then
		return cRackModeClass:new()
	end
end

function cRaceLogicManager:RecordOldRaceData()
	if self.m_oCurRaceLogic ~= nil then
	end
end

function cRaceLogicManager:EndRace()
end

function cRaceLogicManager:OnDestory()
	local oGameApp = self:GetGameApp()
	if oGameApp == nil then
		return
	end
	local oCurScene = oGameApp:GetCurScene()
	if oCurScene == nil then
		return
	end
	local oGameLayer = oCurScene:GetGameLayer()
	local oDataManager = oGameApp:GetDataManager()
	if oDataManager == nil or oGameLayer == nil then
		return
	end
	if self.m_oCurRaceLogic ~= nil then
		self.m_oCurRaceLogic:OnDestory()
	end
end

function cRaceLogicManager:RecordResult()
end

function cRaceLogicManager:Update( dt )
	local oCurRaceLogic = self.m_oCurRaceLogic
	if oCurRaceLogic ~= nil then
		if oCurRaceLogic.OnDefaultUpdate ~= nil then
			oCurRaceLogic:OnDefaultUpdate( dt )
		end
		if oCurRaceLogic.OnUpdate ~= nil then
			oCurRaceLogic:OnUpdate( dt )
		end
	end
end

return cRaceLogicManager