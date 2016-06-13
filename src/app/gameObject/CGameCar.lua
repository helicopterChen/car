local CWorldObject = import( ".CWorldObject" )
local CGameCar = class( "CGameCar", CWorldObject )
_G.GAME_BASE.cObjectManager:GetInstance():RegisterObjectClass( "CGameCar", CGameCar )


function CGameCar:OnInitContainers()
end

function CGameCar:OnInitOk()
	self.m_oCarBody = nil
    self:UpdateView()
    self:UpdatePhysicalBody()
    self:UpdateDebugView()
    self.m_nLastCollisionTime = os.clock()
    self.m_nLastDetachTime = os.clock()
    self.m_oNode:setLocalZOrder( 15 )
    self.m_bStoped = true
end

local _angle_r2a = 180 / math.pi
function CGameCar:Update( dt )
	if self.m_bStoped == true then
		return
	end
	local nSpeed = self:GetPropertyVal( "Speed" )
	local nMaxSpeed = self:GetPropertyVal( "MaxSpeed" )
	local nAccelaration = self:GetPropertyVal( "Accelaration" )
	if nSpeed ~= nil and nAccelaration ~= nil and nMaxSpeed ~= nil then
		local nNowSpeed = nSpeed + nAccelaration * dt
		if nNowSpeed > nMaxSpeed then
			nNowSpeed = nMaxSpeed
		end
		local nX, nY = self:GetPosition()
		self:SetPropertyVal( "Speed", nNowSpeed )
		if self.m_oAnchorTower ~= nil then
			local nNowTime = os.clock()
			if nNowTime - self.m_nLastCollisionTime < 0.05 then
				return
			end
			local nTowerX, nTowerY = self.m_oAnchorTower:GetPosition()
			local tArror = { x=nX - nTowerX, y=nY - nTowerY }
			local nDistance = cc.pGetLength( tArror )
			local nDistanceDiff = nDistance - self.m_nAttachDistance
			if nDistanceDiff >= 5 and nDistanceDiff <= 80 then
				local bIsReverse = self.m_oAnchorTower:IsReverse()
				local nAngle = cc.pToAngleSelf( tArror ) * _angle_r2a
				if bIsReverse == true then
	            	self:SetRotation( nAngle - 90.003 )
	            else
	            	self:SetRotation( nAngle + 90.003 )
				end
			elseif nDistanceDiff > 80 then
				self:DetachFromTower()
			end
		end
		if self.m_oMagneticTower ~= nil then
			local tArrowVector = self.m_oMagneticTower:GetArrowVector()
			if tArrowVector ~= nil then
				local nSpeed = 150
				if self.m_bPushState == false then
					self:SetPosition( nX - tArrowVector.x * nSpeed * dt, nY - tArrowVector.y * nSpeed *  dt )
				else
					self:SetPosition( nX + tArrowVector.x * nSpeed * dt, nY + tArrowVector.y * nSpeed *  dt )
				end
				if self.m_oMagneticTower:CheckInRange( nX, nY ) ~= true then
					self:DeEffectFromTower()
				end
			end
		end
	end
end

function CGameCar:UpdatePhysicalBody()
	if self.m_oNode ~= nil then
		local oCarBody = cc.PhysicsBody:createCircle(25, cc.PhysicsMaterial(0.2, 1, 0), cc.vertex2F( 0,0 ) )
		oCarBody:setCategoryBitmask(1)
	    oCarBody:setContactTestBitmask(1)
	    oCarBody:setVelocity(cc.p(0,0))
	    oCarBody:setTag( self:GetGameObjectId() )
	    oCarBody:setAngularVelocityLimit(0)
	    self.m_oNode:setPhysicsBody(oCarBody)
	    self.m_oCarBody = oCarBody
	end
end

function CGameCar:UpdateDebugView()
	if self.m_oDebugDrawNode ~= nil then
		self.m_oDebugDrawNode:clear()
		self.m_oDebugDrawNode:drawSolidCircle( cc.p(0,0), 25, 360, 20, cc.c4f(0,1,0,0.25) )
		self.m_oDebugDrawNode:drawCircle( cc.p(0,0), 25, 360, 20, false, cc.c4f(1,1,0,0.6) )
	end
end

function CGameCar:OnPropertiesChanged( tDirtyData )
	for i, v in pairs(tDirtyData) do
		if v.OldVal ~= v.CurVal then
			if i == "Rotation" or i == "Speed" then
				self:UpdateVelocity()
			end
		end
	end
end

function CGameCar:SetVelocity( x, y )
	if self.m_oCarBody ~= nil then
		self.m_oCarBody:setVelocity( cc.p(x,y) )
		if x == 0 and y == 0 then
			self.m_oCarBody:setVelocityLimit( 0 )
		else
			self.m_oCarBody:setVelocityLimit( 800 )
		end
	end
end

function CGameCar:SetMinSpeed( nMinSpeed )
	local nSpeed = self:GetPropertyVal( "Speed" )
	if nMinSpeed < nSpeed then
		self:SetPropertyVal( "Speed", nMinSpeed )
	end
	self.m_nLastCollisionTime = os.clock()
end

function CGameCar:UpdateVelocity()
	local nNowTime = os.clock()
	if nNowTime - self.m_nLastCollisionTime < 0.05 then
		return
	end
	local nRotation = self:GetPropertyVal( "Rotation" )
	local nSpeed = self:GetPropertyVal( "Speed" )
	if nRotation ~= nil and nSpeed ~= nil then
		self:SetVelocity( nSpeed * math.cos( (nRotation * math.pi/180) ), nSpeed * math.sin( (nRotation * math.pi/180) ) )
	end
end

function CGameCar:AttachToTower( oAnchorTower )
	if self.m_oAnchorTower == oAnchorTower then
		return
	end
	if self.m_oMagneticTower ~= nil then
		self.m_oMagneticTower:AddEffectCar(nil)
	end
	if self.m_oAnchorTower ~= nil then
		self.m_oAnchorTower:AddAttachCar(nil)
	end
	self.m_oAnchorTower = oAnchorTower
	if oAnchorTower == nil then
		return
	end
	local nTowerX, nTowerY = oAnchorTower:GetPosition()
	local nX, nY = self:GetPosition()
	self.m_nAttachDistance = cc.pGetLength( { x=nTowerX-nX,y=nTowerY-nY} )
end

function CGameCar:EffectByTower( oMageneticTower )
	if self.m_oMagneticTower == oMageneticTower then
		return
	end	
	if self.m_oMagneticTower ~= nil then
		self.m_oMagneticTower:AddEffectCar(nil)
	end
	if self.m_oAnchorTower ~= nil then
		self.m_oAnchorTower:AddAttachCar(nil)
	end
	self.m_oMagneticTower = oMageneticTower
	if oMageneticTower == nil then
		return
	end
	local tProps = self.m_oMagneticTower:GetProperties()
	if tProps.IsReverse == false then
		self:SetRotation( tProps.ArrowAngle + 90 )
	else
		self:SetRotation( tProps.ArrowAngle - 90 )
	end
	self.m_bPushState = oMageneticTower:IsPushState()
end

function CGameCar:IsAttached()
	return ( self.m_oAnchorTower ~= nil)
end

function CGameCar:CanAttachTower()
	local nNowTime = os.clock()
	if nNowTime - self.m_nLastDetachTime > 0.1 then
		return true
	end
end

function CGameCar:DetachFromTower()
	self.m_nLastDetachTime = os.clock()
	if self.m_oAnchorTower ~= nil then
		self.m_oAnchorTower:AddAttachCar( nil )
		self.m_oAnchorTower = nil
	end
end

function CGameCar:DeEffectFromTower()
	self.m_nLastDetachTime = os.clock()
	if self.m_oMagneticTower ~= nil then
		self.m_oMagneticTower:AddEffectCar( nil )
		self.m_oMagneticTower = nil
	end
end

function CGameCar:SetStop( bStop )
	self.m_bStoped = bStop
	if bStop == true then
		self:SetPropertyVal( "Speed", 0 )
		self:SetVelocity( cc.p(0,0) )
	end
end

return CGameCar