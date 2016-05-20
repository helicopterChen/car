local NewSceneLoadSplash = class("NewSceneLoadSplash", _G.GAME_BASE.cSceneBaseClass )

function NewSceneLoadSplash:OnCreate()
    local logoPng = cc.Sprite:create( "icon.png" )
    if logoPng ~= nil then
        logoPng:setPosition( cc.p( display.width/ 2, display.height/2) )
        self:addChild( logoPng )
        self.logoPng = logoPng
    end
end

function NewSceneLoadSplash:PreLoadRes()
	--CfgData.loadConstAndInit()
    --cUnit.initLocalConst()
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

function NewSceneLoadSplash:OnLoadOver()
    --app:setLanguage( CONFIG_GAME_LANGUAGE )   
    --app.uiManager:initControlStrMap()
end

function NewSceneLoadSplash:OnEnter()
    if self.logoPng ~= nil then
    	local actionFadeOut = cc.FadeOut:create(1.5)
    	local callback = cc.CallFunc:create( function() 
                                                _G.GAME_APP:EnterSceneMainGame()
    										end)
    	local sequence = cc.Sequence:create( {actionFadeOut, callback} )
    	self.logoPng:runAction( sequence )
    end
end

function NewSceneLoadSplash:OnExit()
end

return NewSceneLoadSplash