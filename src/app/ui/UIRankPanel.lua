local UIRankPanel = class("UIRankPanel", _G.GAME_BASE.UIBaseClass )
---------------------------------------------------------------------------------------------------------
function UIRankPanel:InitConfig()
	self.m_sJsonFilePath = "ui/rankPanel.json"
	self.m_bScaleOpenAction = true
	self.m_tDynItemCacheLoadTable = 
	{
		{ "ui/rankListItem.json", 15 },
	}
end

function UIRankPanel:OnInitEventsHandler()
	self:RegisterEventsHandlers( "ref/closeBtn", 	  				"OnClicked", 	self.OnClickedCloseBtn  )
end

function UIRankPanel:InitData()
end

function UIRankPanel:OnShowUI()
	local rankListView = self:SeekNodeByPath( "ref/rankListLayer/rankList" )
	if rankListView == nil then
		return
	end
	local nRankWidth = 850
	local nRankHeight = 80	
	rankListView:removeAllItems()
	rankListView:setBounceable(true)
	rankListView:reload()
	self:ClearDynmicItemUseMark( "ui/rankListItem.json" )
	for i = 1, 15 do
		local oRankListRootNode = self:GetUnusedDynamicItemCache("ui/rankListItem.json")
		local rankLabel = ccuiloader_seekNodeEx( oRankListRootNode, "rankLabel" )
		if rankLabel ~= nil then
			rankLabel:setString( i )
		end
		local oRankItem = rankListView:newItem( oRankListRootNode )
		if oRankItem ~= nil then
			oRankItem:setContentSize( cc.size(nRankWidth,nRankHeight) )
			oRankItem:setItemSize( nRankWidth, nRankHeight )
			rankListView:addItem(oRankItem)
		end
	end
	rankListView:reload()
end

function UIRankPanel:OnCloseUI()
end
---------------------------------------------------------------------------------------------------------
function UIRankPanel:OnUpdateUI() 
end

function UIRankPanel:OnClickedCloseBtn()
	self:Close()
end

return UIRankPanel