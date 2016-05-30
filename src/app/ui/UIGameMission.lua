local UIGameMission = class("UIGameMission", _G.GAME_BASE.UIBaseClass )
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
	self:RegisterEventsHandlers( "ref/addBtn", 		"OnClicked", 	self.OnClickedAddBtn )
	self:RegisterEventsHandlers( "ref/minusBtn", 	"OnClicked", 	self.OnClickedMinusBtn )
end

function UIGameMission:InitData()
end

function UIGameMission:OnShowUI()
end

function UIGameMission:OnCloseUI()
end
---------------------------------------------------------------------------------------------------------
function UIGameMission:OnTouchEvent( event )
	print( "OnTouchEvent", event.name )
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
        	v:SetVelocity( 500, 0 )
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