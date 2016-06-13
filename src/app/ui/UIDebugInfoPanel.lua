local UIDebugInfoPanel = class("UIDebugInfoPanel", _G.GAME_BASE.UIBaseClass )
---------------------------------------------------------------------------------------------------------
function UIDebugInfoPanel:InitConfig()
	self.m_sJsonFilePath = "ui/debugInfoPanel.json"
	self.m_bTouchSwallowEnabled = false
	self.m_bTouchEnabled = false
end

function UIDebugInfoPanel:OnInitEventsHandler()
	self:RegisterEventsHandlers( "ref/debugSwitchBtn", 	  				"OnClicked", 	self.OnClickedDebugSwitchBtn )
	self:RegisterEventsHandlers( "ref/funcPanel/showDebugInfoBtn", 	  	"OnClicked", 	self.OnClickedShowDebugInfoBtn )
	self:RegisterEventsHandlers( "ref/funcPanel/clearBtn", 				"OnClicked", 	self.OnClickedClearBtn )
end

function UIDebugInfoPanel:InitData()
end

function UIDebugInfoPanel:OnShowUI()
	local funcPanel = self:SeekNodeByPath( "ref/funcPanel" )
	if funcPanel == nil then
		return
	end
	funcPanel:setVisible(false)
end

function UIDebugInfoPanel:OnCloseUI()
	local funcPanel = self:SeekNodeByPath( "ref/funcPanel" )
	if funcPanel == nil then
		return
	end
	funcPanel:setVisible(false)
end
---------------------------------------------------------------------------------------------------------
function UIDebugInfoPanel:OnClickedDebugSwitchBtn()
	local funcPanel = self:SeekNodeByPath( "ref/funcPanel" )
	if funcPanel == nil then
		return
	end
	funcPanel:setVisible( not funcPanel:isVisible() )
	local switchLabel = self:SeekNodeByPath( "ref/debugSwitchBtn/Label" ) 
	if funcPanel:isVisible() == true then
		switchLabel:setString( "-" )
	else
		switchLabel:setString( "+" )
	end
end


function UIDebugInfoPanel:OnClickedShowDebugInfoBtn()
	local oInfoListView = self:SeekNodeByPath( "ref/funcPanel/infoPanel/infoListView" )
	if oInfoListView == nil then
		return
	end
	oInfoListView:removeAllItems()
	for i, v in ipairs( _G.__LOG_STR_MAP_ ) do
		local infoLabel = cc.LabelTTF:create( v, "", 20, cc.size( 950, 0 ), cc.ui.TEXT_ALIGN_LEFT )
		local oNewItem = oInfoListView:newItem( infoLabel );
		infoLabel:setFontName( CONFIG_DEFAULT_TTF or "" )
		if oNewItem ~= nil then
			local contentSize = infoLabel:getContentSize()
			oNewItem:setItemSize( contentSize.width, contentSize.height );
			infoLabel:setColor( cc.c3b( 0, 255, 0 ) )
			oInfoListView:addItem( oNewItem )
		end
	end
	oInfoListView:reload()
end

function UIDebugInfoPanel:OnClickedClearBtn()
	local oInfoListView = self:SeekNodeByPath( "ref/funcPanel/infoPanel/infoListView" )
	if oInfoListView == nil then
		return
	end
	oInfoListView:removeAllItems()
	oInfoListView:reload()
end


return UIDebugInfoPanel