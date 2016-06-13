local SceneMainGame = class("SceneMainGame",  _G.GAME_BASE.cSceneBaseClass )

function SceneMainGame:OnCreate()
end

function SceneMainGame:PreLoadRes()
    local tPreLoadData = self.m_tPreLoadData
    if tPreLoadData ~= nil then
        tPreLoadData.Textures = {}
        tPreLoadData.SpriteFrame = 
        {
            {"png/ui1_list.plist","png/ui1_list.png"},
            {"png/race_list.plist","png/race_list.png"},
            {"png/uibg_frame_list.plist","png/uibg_frame_list.png"},
        }
        tPreLoadData.Armatures = {}
        tPreLoadData.LoadUI = 
        {
            "ui/gameMain.json",
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
    local oBgImg = cc.Sprite:create("png/bg_01.png")
    if oBgImg ~= nil then
        oGameLayer:addChild(oBgImg,0,-1)
        oBgImg:setAnchorPoint( 0.5, 0.5 )
        oBgImg:setPosition( cc.p(display.width/2,display.height/2) )
    end

    local uiManager = _G.GAME_APP:GetUIManager()
    uiManager:ShowUI( "UIMainMenu", true, nil, nil, true )
end

function SceneMainGame:OnEnter()
end

function SceneMainGame:OnExit()
end

return SceneMainGame