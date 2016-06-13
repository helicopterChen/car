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
	self.m_oLoadingProgressBar = self:SeekNodeByPath( "ref/loadingProgressBar" )
end

function UILoading:OnCloseUI()
	self.m_bCanclose = false
end
---------------------------------------------------------------------------------------------------------
function UILoading:OnUpdateUI()
	local oGameApp = self:GetGameApp()
	if oGameApp == nil then
		return
	end
	local oSceneManager = oGameApp:GetSceneManager()
	if oSceneManager == nil then
		return
	end
	local oUIManager = self:GetUIManager()
	local oResManager = oGameApp:GetResManager()
	if oUIManager == nil or oResManager == nil then
		return
	end
	local oCurScene = oSceneManager:GetCurScene()
	if oCurScene == nil then
		return
	end
	local nTotalSize = oResManager:GetTotalLoadSize()
	local nLoadedSize = oResManager:GetLoadedSize()
	if nTotalSize == 0 or nLoadedSize == 0 then
		nTotalSize = 1
		nLoadedSize = 1
	end
	local nTimePercent = (oCurScene.m_nTimePast / 1.5);
	if nTimePercent >= 1 then
		nTimePercent = 1
	end
	local nPercent = (((nLoadedSize / nTotalSize) +  nTimePercent ) / 2)
	if nPercent >= 1 then
		nPercent = 1
		if self.m_bCanclose == true then
			self:Close()
		end
	end
	if self.m_oLoadingProgressBar ~= nil then
		self.m_oLoadingProgressBar:setPercent( nPercent * 100 )
	end	
end

function UILoading:SetCanClose()
	self.m_bCanclose = true
end

return UILoading