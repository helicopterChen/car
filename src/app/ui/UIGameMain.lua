local UIGameMain = class("UIGameMain", _G.GAME_BASE.UIBaseClass )
---------------------------------------------------------------------------------------------------------
function UIGameMain:InitConfig()
	self.m_sJsonFilePath = "ui/gameMain.json"
end

function UIGameMain:OnInitEventsHandler()
	self:RegisterEventsHandlers( "ref/menuLayer/missionModeBtn", 	  		"OnClicked", 	self.OnClickedMissionModeBtn )
	--self:RegisterEventsHandlers( "ref/menuLayer/freeModeBtn", 	  			"OnClicked", 	self.OnClickedFreeModeBtn )
	--self:RegisterEventsHandlers( "ref/menuLayer/netBattleModeBtn", 	  		"OnClicked", 	self.OnClickedNetBattleModeBtn )
end

function UIGameMain:InitData()
end

function UIGameMain:OnShowUI()
end

function UIGameMain:OnCloseUI()
end
---------------------------------------------------------------------------------------------------------
function UIGameMain:OnClickedMissionModeBtn()
	local oUIManager = self:GetUIManager()
	if oUIManager ~= nil then
		oUIManager:ShowUI( "UIMissionChoice", true )
	end
	self:Close()
end

function UIGameMain:OnClickedFreeModeBtn()
end

function UIGameMain:OnClickedNetBattleModeBtn()
end

return UIGameMain