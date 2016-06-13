--自由
local cRaceLogicBase = import( ".cRaceLogicBase" )

local cRaceModeFree = class("cRaceModeFree", cRaceLogicBase)

function cRaceModeFree:OnStart()
	local oGameApp = self:GetGameApp()
	if oGameApp == nil then
		return
	end
	local oUIManager = oGameApp:GetUIManager()
	if oUIManager == nil then
		return
	end
	if oUIManager:IsShowUI( "UIGameMission" ) == true then
		local uiGameMission = oUIManager:GetUIByName( "UIGameMission" )
		if uiGameMission ~= nil then
			uiGameMission:BeginCountDown( 3 )
		end
	end
end

function cRaceModeFree:OnFinish()
end

return cRaceModeFree