local CWorldObject = class( "CWorldObject", _G.GAME_BASE.cGameObject  )
_G.GAME_BASE.cObjectManager:GetInstance():RegisterObjectClass( "CWorldObject", CWorldObject )

function CWorldObject:InitByConfig( tConfig )
	self:SetPropertiesByConfig( tConfig )
	self.m_oNode = cc.Node:create()
	self.m_oNode:retain()
    self:UpdateView()
end

function CWorldObject:AddToWorld( nX, nY, oWorldNode )
	assert( oWorldNode ~= nil )
	oWorldNode:addChild( self.m_oNode )
	self.m_oNode:setPosition( cc.p( nX, nY ) )
end

function CWorldObject:OnInitContainers()
end

function CWorldObject:UpdateView()
	local sView = self:GetPropertyVal( "View" )
	if sView ~= nil and sView ~= "" then
		if self.m_oNode ~= nil then
	        local oSprite = cc.Sprite:create( sView )
	        oSprite:setScale( 0.5 )
	        self.m_oNode:addChild( oSprite )
	        oSprite:setTag( 999901 )
	        self.m_oNode:setLocalZOrder( 10 )
	    end
	end
end

function CWorldObject:UpdateDebugView()
end

function CWorldObject:RemoveFromWorld()
	if self.m_oNode ~= nil then
		self.m_oNode:removeFromParent(false)
	end
end

function CWorldObject:OnDestory()
	if self.m_oNode ~= nil then
		self.m_oNode:release()
	end
end

return CWorldObject