local cSceneManager = class("cSceneManager")
local cDataQueue =  import( "..CommonUtility.cDataQueue")

function cSceneManager:ctor()
	self.m_oCurScene = nil
    self.m_tEnterSceneQueue = cDataQueue:new()
end

function cSceneManager:GetInstance()
	if _G.__oSceneManager == nil then
		_G.__oSceneManager = cSceneManager:new()
	end
	return _G.__oSceneManager
end

function cSceneManager:EnterScene( sceneName, bUsePhysics, args, callback, tCallbackData )
    if self.m_oCurScene == nil then
        self:RealEnterScene( sceneName, bUsePhysics, args, callback, tCallbackData  )
    else
        self.m_tEnterSceneQueue:InQueue( {sceneName, bUsePhysics, args, callback, tCallbackData} )
    end
end

function cSceneManager:RealEnterScene( sceneName, bUsePhysics, args, callback, tCallbackData )
    local oGameApp = self:GetGameApp()
    if oGameApp == nil then
        return
    end
    if bUsePhysics == nil then
        bUsePhysics = false
    end
    local oUIManager = _G.GAME_APP:GetUIManager()
    local oResManager = _G.GAME_APP:GetResManager()
    local sceneClass = require(string.format("app/scenes/%s", sceneName))
    if sceneClass ~= nil and oUIManager ~= nil and oGameApp ~= nil then
        local oScene = sceneClass:new()
        local oSceneRoot = nil
        if bUsePhysics == true then
            oSceneRoot = display.newPhysicsScene( sceneName )
        else
            oSceneRoot = display.newScene( sceneName )
        end
        if oScene ~= nil and oSceneRoot ~= nil then
            oScene:SetGameApp( oGameApp )
            if self.m_oCurScene == nil then
                oGameApp:SetResManagerUpdate(true)
                oScene.m_sName = sceneName
                oScene:SetSceneRoot( oSceneRoot, bUsePhysics)
                oScene:OnCreate( unpack(checktable(args)) )
                self.m_oCurScene = oScene
                oScene:SetCallback( callback, tCallbackData )
                display.replaceScene( oSceneRoot )
            else
                local sOldSceneName = self.m_oCurScene.m_sName
                if self.m_oCurScene ~= nil then
                    oUIManager:CloseAllUI()
                    oUIManager:DestoryAllUI()
                    --Factory.clearUnitPool() 
                end
                collectgarbage("collect")
                oGameApp:SetResManagerUpdate(true)
                oScene:SetSceneRoot( oSceneRoot, bUsePhysics )
                oScene:OnCreate( unpack(checktable(args)) )
                oScene.m_sName = sceneName
                self.m_oCurScene = oScene
                oScene:SetCallback( callback, tCallbackData )
                display.replaceScene( oSceneRoot, transitionType, time, more)
                if sOldSceneName ~= "SceneSplash" then
                    local function realShowLoadingCallback()
                        local uiLoading = oUIManager:GetUIByName( "UILoading" )
                        if uiLoading ~= nil then
                            uiLoading.m_oCurSceneName = sceneName
                            uiLoading.m_oCurScene = oScene
                        end
                    end
                    oUIManager:RealShowUI( "UILoading", true, realShowLoadingCallback )
                end
            end
            if oResManager ~= nil then
                local oResLoader = oResManager:CreateNewResLoader( sceneName )
                if oResLoader ~= nil then
                    oResLoader:SetOwnerScene( oScene )
                    oScene:SetResLoader( oResLoader )
                    oResLoader:SetLoadOverDestory(true)
                    oScene:PreLoadRes()
                    oScene:AddPreLoadResWork()
                end
            end
            oResManager:RunAsyncLoader( sceneName, cSceneManager.AsyncLoadOverCallback )
            --Factory.clearUnitPool()   
            if sceneName ~= "SceneSplash" and sceneName ~= "SceneLoadSplash" and sceneName ~= "UILoading" then
                if CONFIG_DEBUG_INFO_PANEL == true then
                    oUIManager:ShowUI( "UIDebugInfoPanel", true )
                end
                --uiManager:ShowUI( "UICoverLayer" )
            end    
        end
    end
end

function cSceneManager:GetCurScene()
	return self.m_oCurScene
end

function cSceneManager.AsyncLoadOverCallback( sLoaderName, nLoaderId, tCallbackData )
    local oGameApp = _G.GAME_APP
    if oGameApp == nil then
        return
    end
    local oResManager = oGameApp:GetResManager()
    if oResManager ~= nil then
        local oAsyncLoader = oResManager:GetAsyncLoaderByName( sLoaderName )
        if oAsyncLoader ~= nil then
            local oOwnerScene = oAsyncLoader:GetOwnerScene()
            if oOwnerScene ~= nil then
                oOwnerScene:OnLoadOver( oOwnerScene.m_tPreLoadData )
                oOwnerScene:DefaultLoadOver() 
                oGameApp:SetResManagerUpdate(false)
                if oOwnerScene.m_pCallback ~= nil then
                    oOwnerScene.m_pCallback( oOwnerScene.m_tCallbackData, oOwnerScene )
                end
            end
        end
    end
end

function cSceneManager:Update(dt)
    local tEnterSceneData = self.m_tEnterSceneQueue:OutQueue()
    if tEnterSceneData ~= nil then
        self:RealEnterScene( unpack( tEnterSceneData ) )
    end
end

function cSceneManager:SetGameApp( oGameApp )
    self.m_oGameApp = oGameApp
end

function cSceneManager:GetGameApp()
    return self.m_oGameApp
end

function cSceneManager:Reset()
end

return cSceneManager
