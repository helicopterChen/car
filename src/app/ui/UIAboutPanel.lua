local UIAboutPanel = class("UIAboutPanel", _G.GAME_BASE.UIBaseClass )
---------------------------------------------------------------------------------------------------------
function UIAboutPanel:InitConfig()
	self.m_sJsonFilePath = "ui/aboutPanel.json"
	self.m_bScaleOpenAction = true
end

function UIAboutPanel:OnInitEventsHandler()
	self:RegisterEventsHandlers( "ref/closeBtn", 	  				"OnClicked", 	self.OnClickedCloseBtn  )
end

function UIAboutPanel:InitData()
end

function UIAboutPanel:OnShowUI()
end

function UIAboutPanel:OnCloseUI()
end
---------------------------------------------------------------------------------------------------------
function UIAboutPanel:OnUpdateUI() 
end

function UIAboutPanel:OnClickedCloseBtn()
	self:Close()
end

return UIAboutPanel