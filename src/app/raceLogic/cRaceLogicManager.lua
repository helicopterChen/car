local cRaceLogicManager = class("cRaceLogicManager")

function cRaceLogicManager:ctor()
	self.m_bPauseUpdate = false
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
	self.m_bPauseUpdate = false
	local tMissionConf = oDataManager:GetDataByNameAndId( "MissionsConf", nMissionId )
	if tMissionConf ~= nil then
		if self.m_oCurRaceLogic ~= nil then
			self:RecordOldRaceData()
		end
		local oObjectManager = oGameApp:GetObjectManager()
		if oObjectManager ~= nil then
			oObjectManager:SetPauseUpdate(false)
		end
		local oRaceLogic = self:CreateNewRaceByType( tMissionConf.type )
		if oRaceLogic ~= nil then
			oRaceLogic:SetGameApp( self.m_oGameApp )
			self.m_oCurRaceLogic = oRaceLogic
			oRaceLogic:InitRaceWithConf( tMissionConf )
			oCurScene:SetPause(false)
			oRaceLogic:OnStart()
		end
	end
end

function cRaceLogicManager:RealStartRace()
	if self.m_oCurRaceLogic ~= nil then
		self.m_oCurRaceLogic:RealStartRace()
	end
end

function cRaceLogicManager:SetPauseRace(bPause)
	local oGameApp = self:GetGameApp()
	if oGameApp == nil then
		return
	end
	local oCurScene = oGameApp:GetCurScene()
	if oCurScene == nil then
		return
	end
	self.m_bPauseUpdate = bPause
	oCurScene:SetPause(bPause)
	if self.m_oCurRaceLogic ~= nil then
		self.m_oCurRaceLogic:OnPause()
		local oGameApp = self:GetGameApp()
		if oGameApp ~= nil then
			local oObjectManager = oGameApp:GetObjectManager()
			if oObjectManager ~= nil then
				oObjectManager:SetPauseUpdate(bPause)
			end
		end
	end
end

function cRaceLogicManager:IsPauseUpdate()
	return self.m_bPauseUpdate
end

function cRaceLogicManager:CreateNewRaceByType( sType )
	local sRaceClassPath = string.format("app.raceLogic.cRaceMode%s", sType)
	local cRackModeClass = require (sRaceClassPath)
	if cRackModeClass ~= nil then
		return cRackModeClass:new()
	end
end

function cRaceLogicManager:OnTouch( event )
	if self.m_oCurRaceLogic ~= nil then
		self.m_oCurRaceLogic:OnTouch( event )
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
	if oCurRaceLogic == nil then
		return
	end
	if oCurRaceLogic.m_bPauseUpdate == true then
		return
	end
	if oCurRaceLogic.OnDefaultUpdate ~= nil then
		oCurRaceLogic:OnDefaultUpdate( dt )
	end
	if oCurRaceLogic.OnUpdate ~= nil then
		oCurRaceLogic:OnUpdate( dt )
	end
end

function cRaceLogicManager:GetCurRaceLogic()
	return self.m_oCurRaceLogic
end

return cRaceLogicManager