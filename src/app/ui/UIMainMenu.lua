local UIMainMenu = class("UIMainMenu", _G.GAME_BASE.UIBaseClass )
---------------------------------------------------------------------------------------------------------
function UIMainMenu:InitConfig()
	self.m_sJsonFilePath = "ui/mainMenu.json"
end

function UIMainMenu:OnInitEventsHandler()
	self:RegisterEventsHandlers( "menuLayer/missionModeBtn", 	  			"OnClicked", 	self.OnClickedMissionModeBtn )
	--self:RegisterEventsHandlers( "ref/menuLayer/freeModeBtn", 	  			"OnClicked", 	self.OnClickedFreeModeBtn )
	--self:RegisterEventsHandlers( "ref/menuLayer/netBattleModeBtn", 	  		"OnClicked", 	self.OnClickedNetBattleModeBtn )
	self:RegisterEventsHandlers( "topLayer/rankBtn", 						"OnClicked", 	self.OnClickedRankBtn )
	self:RegisterEventsHandlers( "topLayer/rankBtn", 						"OnClicked", 	self.OnClickedRankBtn )
	self:RegisterEventsHandlers( "topLayer/helpBtn", 						"OnClicked", 	self.OnClickedHelpBtn )
	self:RegisterEventsHandlers( "topLayer/settingBtn", 					"OnClicked", 	self.OnClickedSettingBtn )
	self:RegisterEventsHandlers( "topLayer/moreBtn", 						"OnClicked", 	self.OnClickedMoreBtn )
	self:RegisterEventsHandlers( "topLayer/headBgFrame", 					"OnClicked", 	self.OnClickedHeadBgFrameBtn )
end

function UIMainMenu:InitData()
end

function UIMainMenu:OnShowUI()
end

function UIMainMenu:OnCloseUI()
end
---------------------------------------------------------------------------------------------------------
function UIMainMenu:OnClickedMissionModeBtn()
	local oUIManager = self:GetUIManager()
	if oUIManager ~= nil then
		oUIManager:ShowUI( "UIMissionChoice", true )
	end
	self:Close()
end

function UIMainMenu:OnClickedFreeModeBtn()
end

function UIMainMenu:OnClickedNetBattleModeBtn()
end

function UIMainMenu:OnClickedRankBtn()
	self.m_oUIManager:ShowUI( "UIRankPanel", true )
end

function UIMainMenu:OnClickedHelpBtn()
	self.m_oUIManager:ShowUI( "UIHelperPanel", true )
end

function UIMainMenu:OnClickedSettingBtn()
	self.m_oUIManager:ShowUI( "UISettingPanel", true )
end

function UIMainMenu:OnClickedMoreBtn()
	return
end

function UIMainMenu:OnClickedHeadBgFrameBtn()
	self.m_oUIManager:ShowUI( "UICharInfoPanel", true )
end

return UIMainMenu