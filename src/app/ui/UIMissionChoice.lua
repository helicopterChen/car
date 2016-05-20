local UIMissionChoice = class("UIMissionChoice", _G.GAME_BASE.UIBaseClass )
---------------------------------------------------------------------------------------------------------
function UIMissionChoice:InitConfig()
	self.m_sJsonFilePath = "ui/missionChoice.json"
end

function UIMissionChoice:OnInitEventsHandler()
	self:RegisterEventsHandlers( "ref/enterMissionBtn", 	  		"OnClicked", 	self.OnClickedEnterMissBtn )
	self:RegisterEventsHandlers( "ref/backBtn", 	  				"OnClicked", 	self.OnClickedBackBtn  )
end

function UIMissionChoice:InitData()
end

function UIMissionChoice:OnShowUI()
end

function UIMissionChoice:OnCloseUI()
end
---------------------------------------------------------------------------------------------------------
function UIMissionChoice:OnUpdateUI()
end

function UIMissionChoice:OnClickedEnterMissBtn()
	_G.GAME_APP:EnterSceneMission()
	self:Close()
end

function UIMissionChoice:OnClickedBackBtn()
	local oUIManager = self:GetUIManager()
	if oUIManager ~= nil then
		oUIManager:ShowUI( "UIGameMain", true )
	end
	self:Close()
end

return UIMissionChoice