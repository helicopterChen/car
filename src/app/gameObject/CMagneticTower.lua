local CWorldObject = import( ".CWorldObject" )
local CMagneticTower = class( "CMagneticTower", CWorldObject  )
_G.GAME_BASE.cObjectManager:GetInstance():RegisterObjectClass( "CMagneticTower", CMagneticTower )

function CMagneticTower:InitByConfig( tConfig )
	self:SetPropertiesByConfig( tConfig )
	self.m_oNode = cc.Node:create()
	self.m_oNode:retain()
	self.m_oDebugDrawNode = cc.DrawNode:create()
	self.m_oDebugDrawNode:setLocalZOrder( 500 )
	self.m_oNode:addChild( self.m_oDebugDrawNode )
    self:UpdateView()
    self:UpdateDebugView()
end

function CMagneticTower:AddToWorld( nX, nY, oWorldNode )
	assert( oWorldNode ~= nil )
	oWorldNode:addChild( self.m_oNode )
	self.m_oNode:setPosition( cc.p( nX, nY ) )
end

function CMagneticTower:OnInitContainers()
end

function CMagneticTower:UpdateDebugView()
	if self.m_oDebugDrawNode ~= nil then
		self.m_oDebugDrawNode:clear()
		local tProps = self:GetProperties()
		if tProps ~= nil then
			self.m_oDebugDrawNode:drawDebugRect( {x=0,y=0}, tProps.ArrowAngle, tProps.RectWidth, tProps.RadiusMin, tProps.RadiusMax, tProps.IsReverse )
		end
	end
end

return CMagneticTower