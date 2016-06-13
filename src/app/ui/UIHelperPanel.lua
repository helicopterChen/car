local UIHelperPanel = class("UIHelperPanel", _G.GAME_BASE.UIBaseClass )
---------------------------------------------------------------------------------------------------------
function UIHelperPanel:InitConfig()
	self.m_sJsonFilePath = "ui/helperPanel.json"
	self.m_bScaleOpenAction = true
end

function UIHelperPanel:OnInitEventsHandler()
	self:RegisterEventsHandlers( "ref/closeBtn", 	  				"OnClicked", 	self.OnClickedCloseBtn  )
end

function UIHelperPanel:InitData()
end

function UIHelperPanel:OnShowUI()
end

function UIHelperPanel:OnCloseUI()
end
---------------------------------------------------------------------------------------------------------
function UIHelperPanel:OnUpdateUI() 
end

function UIHelperPanel:OnClickedCloseBtn()
	self:Close()
end

return UIHelperPanel