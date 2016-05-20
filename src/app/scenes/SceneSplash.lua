local SceneSplash = class("SceneSplash",  _G.GAME_BASE.cSceneBaseClass )

function SceneSplash:OnCreate()
end

function SceneSplash:PreLoadRes()
end

function SceneSplash:OnLoadOver()
end

function SceneSplash:OnEnter()
	local logoPng = cc.Sprite:create( "icon.png" )
    if logoPng ~= nil then
    	local actionFadeIn = cc.FadeIn:create(1)
    	local callback = cc.CallFunc:create( function() 
                                                _G.GAME_APP:EnterLoadSplash()
    										end)
    	local sequence = cc.Sequence:create( {actionFadeIn, callback} )
    	logoPng:setPosition( cc.p( display.width/ 2, display.height/2) )
    	logoPng:setOpacity( 0 )
    	logoPng:runAction( sequence )
    	self:addChild( logoPng )
    end
end

function SceneSplash:OnExit()
end

return SceneSplash