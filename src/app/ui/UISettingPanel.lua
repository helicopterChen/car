local UISettingPanel = class("UISettingPanel", _G.GAME_BASE.UIBaseClass )
---------------------------------------------------------------------------------------------------------
function UISettingPanel:InitConfig()
	self.m_sJsonFilePath = "ui/settingPanel.json"
	self.m_bScaleOpenAction = true
end

function UISettingPanel:OnInitEventsHandler()
	self:RegisterEventsHandlers( "ref/closeBtn", 	  				"OnClicked", 	self.OnClickedCloseBtn  )
end

function UISettingPanel:InitData()
end

function UISettingPanel:OnShowUI()
	local titleLabel = self:SeekNodeByPath( "ref/titleLabel" )
	local musicVolumeSlider = self:SeekNodeByPath( "ref/musicVolumeSlider" )
	local soundVolumeSlider = self:SeekNodeByPath( "ref/soundVolumeSlider" )
	local musicVolumeProgress = self:SeekNodeByPath( "ref/musicVolumeProgress" )
	local soundVolumeProgress = self:SeekNodeByPath( "ref/soundVolumeProgress" )
	if titleLabel == nil or musicVolumeSlider == nil or soundVolumeSlider == nil or 
		musicVolumeProgress == nil or soundVolumeProgress == nil then
		return
	end
	titleLabel:enableOutline(cc.c4b(254,241,217,255),3)	
	musicVolumeSlider:setSliderValue( 40 )
	musicVolumeProgress:setPercent( 40 )
	soundVolumeSlider:setSliderValue( 70 )
	soundVolumeProgress:setPercent( 70 )
end

function UISettingPanel:OnCloseUI()
end
---------------------------------------------------------------------------------------------------------
function UISettingPanel:OnUpdateUI() 
end

function UISettingPanel:OnClickedCloseBtn()
	self:Close()
end

return UISettingPanel