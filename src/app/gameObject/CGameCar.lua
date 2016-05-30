local CWorldObject = import( ".CWorldObject" )
local CGameCar = class( "CGameCar", CWorldObject )
_G.GAME_BASE.cObjectManager:GetInstance():RegisterObjectClass( "CGameCar", CGameCar )

function CGameCar:InitByConfig( tConfig )
	self:SetPropertiesByConfig( tConfig )
	self.m_oNode = cc.Node:create()
	self.m_oCarBody = nil
	self.m_oNode:retain()
    self:UpdateView()
    self:UpdatePhysicalBody()
end

function CGameCar:AddToWorld( nX, nY, oWorldNode )
	assert( oWorldNode ~= nil )
	oWorldNode:addChild( self.m_oNode )
	self.m_oNode:setPosition( cc.p( nX, nY ) )
end

function CGameCar:OnInitContainers()
end

function CGameCar:UpdateView()
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

function CGameCar:UpdatePhysicalBody()
	if self.m_oNode ~= nil then
		local oCarBody = cc.PhysicsBody:createCircle(25, cc.PhysicsMaterial(0.2, 1, 0), cc.vertex2F( 0,0 ) )
		oCarBody:setCategoryBitmask(1)
	    oCarBody:setContactTestBitmask(1)
	    oCarBody:setVelocity(cc.p(0,0))
	    oCarBody:setTag( 1001 )
	    oCarBody:setAngularVelocityLimit(0)
	    self.m_oNode:setPhysicsBody(oCarBody)
	    self.m_oCarBody = oCarBody
	end
end

function CGameCar:UpdateDebugView()
end

function CGameCar:GetPosition()
end

function CGameCar:SetPosition()
end

function CGameCar:SetVelocity( x, y )
	if self.m_oCarBody ~= nil then
		self.m_oCarBody:setVelocity( cc.p(x,y) )
		if x == 0 and y == 0 then
			self.m_oCarBody:setVelocityLimit( 0 )
		else
			self.m_oCarBody:setVelocityLimit( 9999 )
		end
	end
end

function CGameCar:GetPosition()
	if self.m_oNode ~= nil then
		return self.m_oNode:getPositionX(), self.m_oNode:getPositionY()
	end
end

return CGameCar