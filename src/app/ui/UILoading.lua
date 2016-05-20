local UILoading = class("UILoading", _G.GAME_BASE.UIBaseClass )
---------------------------------------------------------------------------------------------------------
function UILoading:InitConfig()
	self.m_sJsonFilePath = "ui/loading.json"
end

function UILoading:OnInitEventsHandler()
end

function UILoading:InitData()
	self.m_bCanclose = false
end

function UILoading:OnShowUI()
end

function UILoading:OnCloseUI()
	self.m_bCanclose = false
end
---------------------------------------------------------------------------------------------------------
function UILoading:OnUpdateUI()
	--[[
	local sceneManager = app.sceneManager
	local uiManager = self:getUIManager()
	if sceneManager == nil or uiManager == nil then
		return
	end
	local curScene = sceneManager:GetCurScene()
	if curScene == nil then
		return
	end
	local nTotalSize = app.resManager:GetTotalLoadSize();
	local nLoadedSize = app.resManager:GetLoadedSize();
	if nTotalSize == 0 or nLoadedSize == 0 then
		nTotalSize = 1
		nLoadedSize = 1
	end
	local loadingProgressBar = self:SeekNodeByPath("ref/loadingProgressBar" )
	if loadingProgressBar ~= nil then
		local nTimePercent = (curScene.timePast / 1.5);
		if nTimePercent >= 1 then
			nTimePercent = 1;
		end
		local nPercent = (((nLoadedSize / nTotalSize) +  nTimePercent ) / 2);
		if nPercent >= 1 then
			nPercent = 1;
			if self.m_bCanclose == true then
				self:close()
			end
		end
		loadingProgressBar:setPercent( nPercent * 100 );
	end
	--]]
end

function UILoading:SetCanClose()
	self.m_bCanclose = true
end

return UILoading