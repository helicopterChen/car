local UIMissionChoice = class("UIMissionChoice", _G.GAME_BASE.UIBaseClass )
---------------------------------------------------------------------------------------------------------
function UIMissionChoice:InitConfig()
	self.m_sJsonFilePath = "ui/missionChoice.json"
	self.m_tDynItemCacheLoadTable = 
	{
		{ "ui/raceItem.json", 16 },
	}
end

function UIMissionChoice:OnInitEventsHandler()
	self:RegisterEventsHandlers( "ref/backBtn", 	  				"OnClicked", 	self.OnClickedBackBtn  )
	self:RegisterEventsHandlers( "ref/leftBtn", 	  				"OnClicked", 	self.OnClickedLeftBtn  )
	self:RegisterEventsHandlers( "ref/rightBtn", 	  				"OnClicked", 	self.OnClickedRightBtn  )
	self:RegisterEventsHandlers( "ref/startBtn", 	  				"OnClicked", 	self.OnClickedStartBtn  )
	self:RegisterEventsHandlers( "ref/racePageLayer/raceView", 	  	"PageViewEvent",self.OnRacePageViewEvent  )
end

function UIMissionChoice:InitData()
end

function UIMissionChoice:OnShowUI()
	local oGameApp = self:GetGameApp()
	local oDataManager = oGameApp:GetDataManager()
	local oUIManager = self:GetUIManager()
	local oRaceView = self:SeekNodeByPath( "ref/racePageLayer/raceView" )
	if oRaceView == nil or oDataManager == nil or oUIManager == nil then
		return
	end
	local tMissionViewConf = oDataManager:GetDataByName( "MissionViewConf" )
	if tMissionViewConf == nil then
		return
	end
	self:ClearDynmicItemUseMark( "ui/raceItem.json" )
	oRaceView:setPageColAndRow( 2, 2 )
	oRaceView:removeAllItems()
	for i, v in ipairs(tMissionViewConf) do
		local raceItem = self:GetUnusedDynamicItemCache("ui/raceItem.json")
		if raceItem ~= nil then
			local raceNameLabel = ccuiloader_seekNodeEx( raceItem, "raceNameLabel" )
			local trackIcon = ccuiloader_seekNodeEx(raceItem,"trackIcon")
			if raceNameLabel ~= nil and trackIcon ~= nil then
				raceNameLabel:enableOutline(cc.c4b(254,241,217,255),3)	
				raceNameLabel:setString( v.name )
				oUIManager:ReplaceSpriteIconByName( trackIcon, v.iconName)
			end
			local oPageViewItem = oRaceView:newItem()
			oPageViewItem.m_tMissionView = v
			raceItem.m_tMissionView = v
			oPageViewItem.m_oRaceItem = raceItem
			oPageViewItem:addChild( raceItem )
			oRaceView:addItem( oPageViewItem )
		end
	end
	oRaceView:reload()
	self:UpdateSelRaceItem()
end

function UIMissionChoice:OnCloseUI()
end
---------------------------------------------------------------------------------------------------------
function UIMissionChoice:OnUpdateUI()
end

function UIMissionChoice:OnClickedBackBtn()
	local oUIManager = self:GetUIManager()
	if oUIManager ~= nil then
		oUIManager:ShowUI( "UIMainMenu", true )
	end
	self:Close()
end

function UIMissionChoice:OnClickedLeftBtn()
	local oRaceView = self:SeekNodeByPath( "ref/racePageLayer/raceView" )
	local leftBtn = self:SeekNodeByPath( "ref/leftBtn" )
	local rightBtn = self:SeekNodeByPath( "ref/rightBtn" )
	if oRaceView == nil or leftBtn == nil or rightBtn == nil then
		return
	end
	local nPageCount = oRaceView:getPageCount()
	local nNewPageIdx = oRaceView:getCurPageIdx() -1 
	if nNewPageIdx < 1 then
		return
	end
	leftBtn:setButtonEnabled(false)
	rightBtn:setButtonEnabled(false)
	oRaceView:gotoPage( nNewPageIdx,true, false)
end

function UIMissionChoice:OnClickedRightBtn()
	local oRaceView = self:SeekNodeByPath( "ref/racePageLayer/raceView" )
	local leftBtn = self:SeekNodeByPath( "ref/leftBtn" )
	local rightBtn = self:SeekNodeByPath( "ref/rightBtn" )
	if oRaceView == nil or leftBtn == nil or rightBtn == nil then
		return
	end
	local nPageCount = oRaceView:getPageCount()
	local nNewPageIdx = oRaceView:getCurPageIdx() + 1 
	if nNewPageIdx > nPageCount then
		return
	end
	leftBtn:setButtonEnabled(false)
	rightBtn:setButtonEnabled(false)
	oRaceView:gotoPage( nNewPageIdx,true, true)
end

function UIMissionChoice:OnClickedStartBtn()
	if self.m_oSelItem == nil then
		return
	end
	local tMissionView = self.m_oSelItem.m_tMissionView
	if tMissionView == nil then
		return
	end
	_G.GAME_APP:EnterSceneMission( tMissionView.missId )
end

function UIMissionChoice:OnRacePageViewEvent( event )
	if event.name == "pageChange" then
		local oRaceView = self:SeekNodeByPath( "ref/racePageLayer/raceView" )
		local leftBtn = self:SeekNodeByPath( "ref/leftBtn" )
		local rightBtn = self:SeekNodeByPath( "ref/rightBtn" )
		if oRaceView == nil or leftBtn == nil or rightBtn == nil then
			return
		end
		leftBtn:setButtonEnabled(true)
		rightBtn:setButtonEnabled(true)
	elseif event.name == "clicked" then
		if event.item == nil then
			return
		end
		local oRaceItem = event.item.m_oRaceItem
		local tMissionView = event.item.m_tMissionView
		if tMissionView == nil or oRaceItem == nil then
			return
		end
		self.m_oSelItem = oRaceItem
		self:UpdateSelRaceItem()
	end
end

function UIMissionChoice:UpdateSelRaceItem()
	local oUIManager = self:GetUIManager()
	local oRaceView = self:SeekNodeByPath( "ref/racePageLayer/raceView" )
	if oRaceView == nil or oUIManager == nil then
		return
	end
	local tAllItems = oRaceView:getAllItems()
	if tAllItems == nil then
		return
	end
	if self.m_oSelItem == nil then
		self.m_oSelItem = tAllItems[1].m_oRaceItem
	end
	for i, v in ipairs( tAllItems ) do
		local titleSpr = ccuiloader_seekNodeEx( v.m_oRaceItem, "titleSpr")
		if titleSpr ~= nil then
			local tOptions = titleSpr.options
			if tOptions ~= nil and tOptions.fileNameData ~= nil and tOptions.fileNameData.path ~= nil then
				local sFilePath = tOptions.fileNameData.path
				if sFilePath ~= nil then
					if self.m_oSelItem == v.m_oRaceItem then
						oUIManager:ReplaceSpriteIconByName( titleSpr, string.gsub(sFilePath,"_normal", "_pressed") )
					else
						oUIManager:ReplaceSpriteIconByName( titleSpr, string.gsub(sFilePath,"_pressed", "_normal") )
					end
				end
			end
		end
	end
end

return UIMissionChoice