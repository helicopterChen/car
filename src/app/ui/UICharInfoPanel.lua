local UICharInfoPanel = class("UICharInfoPanel", _G.GAME_BASE.UIBaseClass )
---------------------------------------------------------------------------------------------------------
function UICharInfoPanel:InitConfig()
	self.m_sJsonFilePath = "ui/charInfoPanel.json"
	self.m_bScaleOpenAction = true
end

function UICharInfoPanel:OnInitEventsHandler()
	self:RegisterEventsHandlers( "ref/closeBtn", 	  				"OnClicked", 	self.OnClickedCloseBtn  )
end

function UICharInfoPanel:InitData()
end

function UICharInfoPanel:OnShowUI()
	local titleLabel = self:SeekNodeByPath( "ref/titleLabel" )
	if titleLabel ~= nil then
		titleLabel:enableOutline(cc.c4b(254,241,217,255),3)	
	end
end

function UICharInfoPanel:OnCloseUI()
end
---------------------------------------------------------------------------------------------------------
function UICharInfoPanel:OnUpdateUI() 
end

function UICharInfoPanel:OnClickedCloseBtn()
	self:Close()
end

return UICharInfoPanel