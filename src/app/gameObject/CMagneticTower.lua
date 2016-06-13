local CWorldObject = import( ".CWorldObject" )
local CMagneticTower = class( "CMagneticTower", CWorldObject  )
_G.GAME_BASE.cObjectManager:GetInstance():RegisterObjectClass( "CMagneticTower", CMagneticTower )
local ONE_RADIAN = (math.pi / 180)


function CMagneticTower:OnInitContainers()
	self.m_nTotalTime = 0
end

function CMagneticTower:OnInitOk()
    self:UpdateView()
    --self:UpdatePhysicalBody()
    self:UpdateEffectRegion()
    self:UpdateDebugView()
    self.m_bPushState = false
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

function CMagneticTower:Update( dt )
	self.m_nTotalTime = self.m_nTotalTime + dt
	self:UpdateEffectDebugView()
end

function CMagneticTower:UpdateEffectDebugView()
	if self.m_oEffectDebugNode ~= nil then
		self.m_oEffectDebugNode:clear()
		if self.m_bCarInRangle == true then
			self.m_oEffectDebugNode:drawSolidCircle( cc.p(0,0), 30, 360, 20, cc.c4f(0,1,0,0.5) )
		end
		local tProps = self:GetProperties()
		if tProps ~= nil then
			local nTime = math.floor(self.m_nTotalTime) % (tProps.PullTime + tProps.PushTime)
			self.m_bPushState = ( nTime > (tProps.PullTime -1) )
			if self.m_bPushState == true then
				self.m_oEffectDebugNode:drawSolidCircle(cc.p(0,0), 15, 360, 6, cc.c4f(1,0,0,0.7))
			else
				self.m_oEffectDebugNode:drawSolidCircle(cc.p(0,0), 15, 360, 6, cc.c4f(0,1,1,0.7))
			end

			if self.m_oEffectCar ~= nil then
				local nCarX, nCarY = self.m_oEffectCar:GetPosition()
				local nTowerX, nTowerY = self:GetPosition()
				local tPos = { x = nCarX - nTowerX, y = nCarY - nTowerY }
				self.m_oEffectDebugNode:drawLine( cc.p(0,0), tPos, cc.c4f(0,1,0,1) )
			end
		end
	end
end

function CMagneticTower:CheckInRange( nX, nY )
	local bInRangle = false
	local tProperties = self:GetProperties()
	if tProperties == nil then
		return
	end
	local tVec = {x=nX - tProperties.X, y=nY - tProperties.Y}
	local nVerticesNum = #self.m_tVertices
	local nAngleTotal = 0
	for i = 1, nVerticesNum do
		local tPot1 = self.m_tVertices[i]
		local tPot2 = nil
		if i == nVerticesNum then
			tPot2 = self.m_tVertices[1]
		else
			tPot2 = self.m_tVertices[i+1]
		end
		local tVec1 = { x = tPot1.x - tVec.x, y = tPot1.y - tVec.y }
		local tVec2 = { x = tPot2.x - tVec.x, y = tPot2.y - tVec.y }
		local nAngle = math.abs(cc.pGetAngle( tVec1, tVec2 ) * ( 180 / math.pi ))
		nAngleTotal = nAngleTotal + nAngle
	end
	bInRangle = (math.abs( nAngleTotal - 360 ) <= 0.00001)
	if self.m_bCarInRangle ~= bInRangle then
		self.m_bCarInRangle = bInRangle
	end
	return bInRangle
end

function CMagneticTower:UpdatePhysicalBody()
	local tProps = self:GetProperties()
	if tProps ~= nil then
		local tVertices = self:GetEffectRegion( {x=0,y=0}, tProps.ArrowAngle, tProps.RectWidth, tProps.RadiusMin, tProps.RadiusMax, tProps.IsReverse )
		if tVertices ~= nil then
			local oTowerEffectRegion = cc.PhysicsBody:createEdgePolygon( tVertices )
			oTowerEffectRegion:setCategoryBitmask(1)
		    oTowerEffectRegion:setContactTestBitmask(1)
		    oTowerEffectRegion:setVelocity(cc.p(0,0))
		    oTowerEffectRegion:setTag( self:GetGameObjectId() )
		    oTowerEffectRegion:setAngularVelocityLimit(0)
		    oTowerEffectRegion:setVelocityLimit(0)
		    self.m_oNode:setPhysicsBody(oTowerEffectRegion)
		    self.m_oEffectRegion = oTowerEffectRegion
		    self.m_tVertices = tVertices
		end
	end
end

function CMagneticTower:UpdateEffectRegion()
	local tProps = self:GetProperties()
	if tProps ~= nil then
		self.m_tVertices = self:GetEffectRegion( {x=0,y=0}, tProps.ArrowAngle, tProps.RectWidth, tProps.RadiusMin, tProps.RadiusMax, tProps.IsReverse )
	end
end

function CMagneticTower:GetEffectRegion( tCenter, nArrowAngle, nWidth, nMinRadius, nMaxRadius, bIsReverse )
	local midRads = nArrowAngle * ONE_RADIAN
	local nOuterCenterX  = tCenter.x + nMaxRadius * math.cos(midRads)
    local nOuterCenterY  = tCenter.y + nMaxRadius * math.sin(midRads)
	local nInneCenterX = tCenter.x + nMinRadius * math.cos(midRads)
	local nInneCenterY = tCenter.y + nMinRadius * math.sin(midRads)
	local nHalfWidth = nWidth / 2
	local tVertices = {}
	local nDeltaX = nHalfWidth * math.sin(midRads)
	local nDeltaY = nHalfWidth * math.cos(midRads)
	local nX1 = nOuterCenterX - nDeltaX
	local nY1 = nOuterCenterY + nDeltaY
	local nX2 = nOuterCenterX + nDeltaX
	local nY2 = nOuterCenterY - nDeltaY
	tVertices[1] = { x=nX1, y=nY1 }
	tVertices[2] = { x=nX2, y=nY2 }

	local nX1 = nInneCenterX - nDeltaX
	local nY1 = nInneCenterY + nDeltaY
	local nX2 = nInneCenterX + nDeltaX
	local nY2 = nInneCenterY - nDeltaY
	tVertices[3] = { x=nX2, y=nY2 }
	tVertices[4] = { x=nX1, y=nY1 }
	return tVertices
end

function CMagneticTower:IsCharInRange()
	return self.m_bCarInRangle
end

function CMagneticTower:AddEffectCar( oCar )
	self.m_oEffectCar = oCar
end

function CMagneticTower:IsReverse()
	return (self:GetPropertyVal( "IsReverse" ) == true)
end

function CMagneticTower:IsPushState()
	return self.m_bPushState
end

function CMagneticTower:GetArrowVector()
	local tVector = { x = 1, y = 0 }
	local tProps = self:GetProperties()
	if tProps ~= nil then
		local midRads = tProps.ArrowAngle * ONE_RADIAN
		tVector.x = math.cos(midRads)
		tVector.y = math.sin(midRads)
	end
	return tVector
end

function CMagneticTower:GetArrowAngle()
	return self:GetPropertyVal( "ArrowAngle" )
end

return CMagneticTower