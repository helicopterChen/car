local CWorldObject = import( ".CWorldObject" )
local CAnchorTower = class( "CAnchorTower", CWorldObject )
_G.GAME_BASE.cObjectManager:GetInstance():RegisterObjectClass( "CAnchorTower", CAnchorTower )

function CAnchorTower:InitByConfig( tConfig )
	self:SetPropertiesByConfig( tConfig )
	self.m_oNode = cc.Node:create()
	self.m_oNode:retain()
	self.m_oDebugDrawNode = cc.DrawNode:create()
	self.m_oDebugDrawNode:setLocalZOrder( 500 )
	self.m_oNode:addChild( self.m_oDebugDrawNode )
    self:UpdateView()
    self:UpdateDebugView()
end

function CAnchorTower:OnInitContainers()
end

function CAnchorTower:UpdateDebugView()
	if self.m_oDebugDrawNode ~= nil then
		self.m_oDebugDrawNode:clear()
		local tProps = self:GetProperties()
		if tProps ~= nil then
			self.m_oDebugDrawNode:drawDebugSector( {x=0,y=0}, tProps.ArrowAngle, tProps.AngleSector, tProps.RadiusMin, tProps.RadiusMax, tProps.IsReverse )
		end
	end
end

return CAnchorTower