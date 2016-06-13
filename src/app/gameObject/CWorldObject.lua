local CWorldObject = class( "CWorldObject", _G.GAME_BASE.cGameObject  )
_G.GAME_BASE.cObjectManager:GetInstance():RegisterObjectClass( "CWorldObject", CWorldObject )


function CWorldObject:OnInitOk()
end

function CWorldObject:InitByConfig( tConfig )
	self:SetPropertiesByConfig( tConfig )
	self.m_oNode = cc.Node:create()
	self.m_oNode:retain()
	if CONFIG_SHOW_DEBUG_VIEW == true then
		self.m_oDebugDrawNode = cc.DrawNode:create()
		self.m_oDebugDrawNode:setLocalZOrder( 500 )
		self.m_oNode:addChild( self.m_oDebugDrawNode )
		self.m_oEffectDebugNode = cc.DrawNode:create()
		self.m_oEffectDebugNode:setLocalZOrder( 550 )
		self.m_oNode:addChild( self.m_oEffectDebugNode )
	end
	self:UpdateView()
end

function CWorldObject:AddToWorld( nX, nY, oWorldNode )
	assert( oWorldNode ~= nil )
	oWorldNode:addChild( self.m_oNode )
	self.m_oNode:setPosition( cc.p( nX, nY ) )
end


function CWorldObject:GetPosition()
	if self.m_oNode ~= nil then
		return self.m_oNode:getPositionX(), self.m_oNode:getPositionY()
	end
end

function CWorldObject:SetPosition( nX, nY )
	if self.m_oNode ~= nil then
		self.m_oNode:setPosition( cc.p( nX, nY ) )
	end
end

function CWorldObject:OnInitContainers()
end

function CWorldObject:UpdateView()
	local sView = self:GetPropertyVal( "View" )
	if sView ~= nil and sView ~= "" then
		if self.m_oNode ~= nil then
	        local oSprite = cc.Sprite:create( sView )
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
		self.m_oNode = nil
	end
end

function CWorldObject:SetRotation( nRotAngle )
	self:SetPropertyVal( "Rotation", nRotAngle )
	if self.m_oNode ~= nil then
		self.m_oNode:setRotation( -nRotAngle )
	end
end

function CWorldObject:OnDestory()
	if self.m_oNode ~= nil then
		self.m_oNode:release()
	end
end

return CWorldObject