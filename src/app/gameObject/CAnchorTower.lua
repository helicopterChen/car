local CWorldObject = import( ".CWorldObject" )
local CAnchorTower = class( "CAnchorTower", CWorldObject )
_G.GAME_BASE.cObjectManager:GetInstance():RegisterObjectClass( "CAnchorTower", CAnchorTower )


function CAnchorTower:OnInitContainers()
end

function CAnchorTower:OnInitOk()
    self:UpdateView()
    self:UpdateDebugView()
    self.m_bCarInRangle = true
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

function CAnchorTower:UpdateEffectDebugView()
	if self.m_oEffectDebugNode ~= nil then
		self.m_oEffectDebugNode:clear()
		if self.m_bCarInRangle == true then
			self.m_oEffectDebugNode:drawSolidCircle( cc.p(0,0), 30, 360, 20, cc.c4f(0,1,0,0.5) )
		end
		if self.m_oAttachCar ~= nil then
			local nCarX, nCarY = self.m_oAttachCar:GetPosition()
			local nTowerX, nTowerY = self:GetPosition()
			local tPos = { x = nCarX - nTowerX, y = nCarY - nTowerY }
			self.m_oEffectDebugNode:drawLine( cc.p(0,0), tPos, cc.c4f(0,1,0,1) )
		end
	end
end

function CAnchorTower:Update( dt )
	self:UpdateEffectDebugView()
end

function CAnchorTower:CheckInRange( nX, nY )
	local bInRangle = false
	local nSelfX = self:GetPropertyVal( "X" )
	local nSelfY = self:GetPropertyVal( "Y" )
	local tProperties = self:GetProperties()
	if tProperties == nil then
		return
	end
	local tVec = {x=nX - tProperties.X, y=nY - tProperties.Y}
	local nAngle = cc.pToAngleSelf( tVec ) * (180 / math.pi)
	local nDistance = cc.pGetLength( tVec )
	if nDistance > tProperties.RadiusMin and nDistance < tProperties.RadiusMax then
	    local nTowerAngle = tProperties.ArrowAngle
	    local nAngleDelta = (nAngle - nTowerAngle) % 360
	    if nAngleDelta > 180 then
	   		nAngleDelta = 360 - nAngleDelta
	    end
	    if nAngleDelta < tProperties.AngleSector / 2 then
			bInRangle = true
	    end
	end
	self.m_nAngle = nAngle
	self.m_nDistance = nDistance
	if self.m_bCarInRangle ~= bInRangle then
		self.m_bCarInRangle = bInRangle
		self:UpdateDebugView()
	end
	return bInRangle
end

function CAnchorTower:IsCharInRange()
	return self.m_bCarInRangle
end

function CAnchorTower:AddAttachCar( oCar )
	self.m_oAttachCar = oCar
end

function CAnchorTower:IsReverse()
	return (self:GetPropertyVal( "IsReverse" ) == true)
end

return CAnchorTower