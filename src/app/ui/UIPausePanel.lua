local UIPausePanel = class("UIPausePanel", _G.GAME_BASE.UIBaseClass )
---------------------------------------------------------------------------------------------------------
function UIPausePanel:InitConfig()
	self.m_sJsonFilePath = "ui/pausePanel.json"
	self.m_bScaleOpenAction = true
end

function UIPausePanel:OnInitEventsHandler()
	self:RegisterEventsHandlers( "ref/closeBtn", 	  				"OnClicked", 	self.OnClickedCloseBtn  )
	self:RegisterEventsHandlers( "ref/resumeBtn", 	  				"OnClicked", 	self.OnClickedResumeBtn  )
end

function UIPausePanel:InitData()
end

function UIPausePanel:OnShowUI()
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

function UIPausePanel:OnCloseUI()
end
---------------------------------------------------------------------------------------------------------
function UIPausePanel:OnUpdateUI() 
end

function UIPausePanel:OnClickedCloseBtn()
	local uiManager = self:GetUIManager()
	local oGameApp = self:GetGameApp()
    if oGameApp == nil or uiManager == nil then
        return
    end
    local oRaceLogicManager = oGameApp:GetRaceLogicManager()
    if oRaceLogicManager == nil then
    	return
    end
    oRaceLogicManager:SetPauseRace(false)
	self:Close()
end

function UIPausePanel:OnClickedResumeBtn()
	local uiManager = self:GetUIManager()
	local oGameApp = self:GetGameApp()
    if oGameApp == nil or uiManager == nil then
        return
    end
    local oRaceLogicManager = oGameApp:GetRaceLogicManager()
    if oRaceLogicManager == nil then
    	return
    end
    oRaceLogicManager:SetPauseRace(false)
    self:Close()
end

return UIPausePanel