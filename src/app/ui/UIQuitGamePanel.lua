local UIQuitGamePanel = class("UIQuitGamePanel", _G.GAME_BASE.UIBaseClass )
---------------------------------------------------------------------------------------------------------
function UIQuitGamePanel:InitConfig()
	self.m_sJsonFilePath = "ui/quitGamePanel.json"
	self.m_bScaleOpenAction = true
end

function UIQuitGamePanel:OnInitEventsHandler()
	self:RegisterEventsHandlers( "ref/closeBtn", 	  				"OnClicked", 	self.OnClickedCloseBtn  )
	self:RegisterEventsHandlers( "ref/cancelBtn", 	  				"OnClicked", 	self.OnClickedCancelBtn  )
	self:RegisterEventsHandlers( "ref/okBtn", 	  					"OnClicked", 	self.OnClickedOkBtn  )
end

function UIQuitGamePanel:InitData()
end

function UIQuitGamePanel:OnShowUI()
end

function UIQuitGamePanel:OnCloseUI()
end
---------------------------------------------------------------------------------------------------------
function UIQuitGamePanel:OnUpdateUI() 
end

function UIQuitGamePanel:OnClickedCloseBtn()
	self:Close()
end

function UIQuitGamePanel:OnClickedCancelBtn()
end

function UIQuitGamePanel:OnClickedOkBtn()
end

return UIQuitGamePanel