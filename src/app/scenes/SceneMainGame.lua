local SceneMainGame = class("SceneMainGame",  _G.GAME_BASE.cSceneBaseClass )

function SceneMainGame:OnCreate()
end

function SceneMainGame:PreLoadRes()
    local tPreLoadData = self.m_tPreLoadData
    if tPreLoadData ~= nil then
        tPreLoadData.Textures = {}
        tPreLoadData.SpriteFrame = 
        {
        }
        tPreLoadData.Armatures = 
        {
        }
        tPreLoadData.LoadUI = 
        {
            "ui/loading.json",
            "ui/smallLoading.json",
        }
        tPreLoadData.JsonData = 
        {
        }
    end
end

function SceneMainGame:OnLoadOver()
    local oGameLayer = self:GetGameLayer()
    if oGameLayer == nil then
        return
    end
    local oBgImg = cc.Sprite:create("jpg/ui_game_option.jpg")
    if oBgImg ~= nil then
        oGameLayer:addChild(oBgImg,0,-1)
        oBgImg:setAnchorPoint( 0.5, 0.5 )
        oBgImg:setScale( 0.55 )
        oBgImg:setPosition( cc.p(display.width/2,display.height/2) )
    end

    local uiManager = _G.GAME_APP:GetUIManager()
    uiManager:ShowUI( "UIGameMain", true, nil, nil, true )
end

function SceneMainGame:OnEnter()
end

function SceneMainGame:OnExit()
end

return SceneMainGame