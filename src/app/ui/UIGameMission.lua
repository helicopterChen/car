local UIGameMission = class("UIGameMission", _G.GAME_BASE.UIBaseClass )
local TimeUtility = _G.GAME_BASE.TimeUtility
---------------------------------------------------------------------------------------------------------
function UIGameMission:InitConfig()
	self.m_sJsonFilePath = "ui/gameMission.json"
	self.m_bTouchMode = cc.TOUCH_MODE_ALL_AT_ONCE
	self.m_bTouchSwallowEnabled = false
	self.m_bTouchEnabled = true
end

function UIGameMission:OnInitEventsHandler()
	local refLayer = self:SeekNodeByPath( "ref" )
	if refLayer ~= nil then
		refLayer:setTouchEnabled(true)
		refLayer:setTouchSwallowEnabled(false)
    	refLayer:setTouchMode(cc.TOUCH_MODE_ALL_AT_ONCE)
	end
	self:RegisterEventsHandlers( "ref", "TouchEvent", self.OnTouchEvent )
	self:RegisterEventsHandlers( "ref/backBtn", 	"OnClicked", 	self.OnClickedBackBtn )
	self:RegisterEventsHandlers( "ref/pauseBtn", 	"OnClicked", 	self.OnClickedPauseBtn )
end

function UIGameMission:InitData()
end

function UIGameMission:OnShowUI()
	local oGameApp = self:GetGameApp()
	if oGameApp == nil then
		return
	end
	local oRaceLogicManager = oGameApp:GetRaceLogicManager()
	if oRaceLogicManager == nil then
		return
	end
	self.m_oRaceLogicManager = oRaceLogicManager
	self.m_oTimeLabel = self:SeekNodeByPath( "ref/timeLabel" )
	self.m_oTimeLabel:enableOutline(cc.c4b(254,241,217,255),3)	
end

function UIGameMission:OnCloseUI()
end
---------------------------------------------------------------------------------------------------------
function UIGameMission:OnUpdateSec( dt )
	if self.m_nCountDownTime ~= nil then
		local countDownLabel = self:SeekNodeByPath( "startLayer.FILL_SCREEN/countDownLabel" )
		if countDownLabel ~= nil then
			if self.m_nCountDownTime ~= 0 then
				countDownLabel:setString( math.floor(self.m_nCountDownTime) )
			else
				countDownLabel:setString( "Go" )
			end
		end
		if self.m_nCountDownTime < 0 then
			local startLayer = self:SeekNodeByPath( "startLayer.FILL_SCREEN" )
			if startLayer ~= nil then
				startLayer:setVisible(false)
			end
			self.m_oRaceLogicManager:RealStartRace()
		end
		self.m_nCountDownTime = self.m_nCountDownTime - 1
	end
end

function UIGameMission:OnUpdateUI( dt )
	if self.m_oTimeLabel ~= nil then
		local oCurRaceLogic = self.m_oRaceLogicManager:GetCurRaceLogic()
		if oCurRaceLogic ~= nil then
			if oCurRaceLogic:IsRealStart() == true then
				local nTotalTimeSec = oCurRaceLogic:GetRaceTotalTime()
				local sTimeStr = TimeUtility.TransTimeValToStr( math.floor(nTotalTimeSec * 60))
				self.m_oTimeLabel:setString( sTimeStr )
			end
		end
	end
end

function UIGameMission:BeginCountDown( nCountDownTime )
	self.m_nCountDownTime = nCountDownTime
	local startLayer = self:SeekNodeByPath( "startLayer.FILL_SCREEN" )
	if startLayer ~= nil then
		startLayer:setVisible(true)
	end
end

function UIGameMission:OnTouchEvent( event )
	local oCurScene = _G.GAME_APP:GetCurScene()
	if oCurScene == nil then
		return
	end
	if event.name == "added" or event.name == "removed" then
		local _, point = next( event.points )
		if point ~= nil then
			local btnEvent = { name = "began", x = point.x, y = point.y }
			if event.name == "removed" then
				btnEvent.name = "ended"
			end
			if self.checkMultiClickButtons ~= nil then
				for i, btn in ipairs( self.checkMultiClickButtons ) do
					if btn:onTouch_( btnEvent ) == true then
						break
					end
				end
			end
		end
	else
		local fakeEvent = { name = event.name }
		local point = event.points["0"]
		if point ~= nil then
			for i, v in pairs( point ) do
				fakeEvent[i] = v
			end
		end
		if oCurScene.OnTouch ~= nil then
			oCurScene:OnTouch( fakeEvent )
		end		
	end
    return true
end

function UIGameMission:OnClickedBackBtn()
	_G.GAME_APP:EnterSceneMainGame()
end

function UIGameMission:OnClickedPauseBtn()
	local uiManager = self:GetUIManager()
	local oGameApp = self:GetGameApp()
    if oGameApp == nil or uiManager == nil then
        return
    end
    local oRaceLogicManager = oGameApp:GetRaceLogicManager()
    if oRaceLogicManager == nil then
    	return
    end
    oRaceLogicManager:SetPauseRace(not oRaceLogicManager:IsPauseUpdate())
    uiManager:ShowUI( "UIPausePanel", true )
end

function UIGameMission:OnClickedAddBtn()
	local oGameApp = self:GetGameApp()
    if oGameApp == nil then
        return
    end
    local oObjectManager = oGameApp:GetObjectManager()
    if oObjectManager == nil then
        return
    end
    local tCars = oObjectManager:GetObjectsByType( "CGameCar" )
    if tCars ~= nil then
        for i, v in pairs( tCars ) do
        	v:SetVelocity( 800, 0 )
        end
    end
end

function UIGameMission:OnClickedMinusBtn()
	local oGameApp = self:GetGameApp()
    if oGameApp == nil then
        return
    end
    local oObjectManager = oGameApp:GetObjectManager()
    if oObjectManager == nil then
        return
    end
    local tCars = oObjectManager:GetObjectsByType( "CGameCar" )
    if tCars ~= nil then
        for i, v in pairs( tCars ) do
        	v:SetVelocity( 0, 0 )
        end
    end
end

return UIGameMission