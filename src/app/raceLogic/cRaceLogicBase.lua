local cRaceLogicBase = class("cRaceLogicBase")

function cRaceLogicBase:OnStart()
end

function cRaceLogicBase:OnFinish()
end

function cRaceLogicBase:OnDestory()
    local oGameApp = self:GetGameApp()
    if oGameApp == nil then
        return
    end
    local oObjectManager = oGameApp:GetObjectManager()
    if oObjectManager == nil then
        return
    end
    if self.m_tTracksNode ~= nil then
        for i, v in ipairs(self.m_tTracksNode) do
            v:removeFromParent(false)
        end
    end
    local tCars = oObjectManager:GetObjectsByType( "CGameCar" )
    if tCars ~= nil then
        for i, v in pairs( tCars ) do
            v:RemoveFromWorld()
            v:OnDestory()
        end
    end
    oObjectManager:RemoveObjectByType( "CGameCar" )
end

function cRaceLogicBase:InitRaceWithConf( tMissionConf )
	local oGameApp = self:GetGameApp()
	if oGameApp == nil then
		return
	end
	local oDataManager = oGameApp:GetDataManager()
	if oDataManager == nil then
		return
	end
	self.m_tMissionConf = tMissionConf
	self.m_tTowersTable = oDataManager:GetDataByNameAndId( "TowersConf",tMissionConf.id )
	self:CreateDrawNode()
	self:ShowMap()
	self:CreateTrack()
	self:CreateCars()
    self:CreateTowers()
	self:RegisterDefaultCollisionHandler()
end

function cRaceLogicBase:CreateDrawNode()
	local oGameApp = self:GetGameApp()
	if oGameApp == nil then
		return
	end
	local oCurScene = oGameApp:GetCurScene()
	if oCurScene == nil then
		return
	end
	local oGameLayer = oCurScene:GetGameLayer()
	if oGameLayer == nil then
		return
	end
	if CONFIG_DEBUG_VIEW == true then
		local oDrawNode = cc.DrawNode:create()
	    if oDrawNode ~= nil then
	        oGameLayer:addChild( oDrawNode )
	        oDrawNode:setLocalZOrder( 1 )
	        self.m_oDebugDrawNode = oDrawNode
	    end
	end
end

function cRaceLogicBase:ShowMap()
	local oGameApp = self:GetGameApp()
	if oGameApp == nil then
		return
	end
	local oCurScene = oGameApp:GetCurScene()
	if oCurScene == nil then
		return
	end
	local oGameLayer = oCurScene:GetGameLayer()
	if oGameLayer == nil then
		return
	end
	local oBgImg = cc.Sprite:create( self.m_tMissionConf.bg )
    if oBgImg ~= nil then
        oGameLayer:addChild(oBgImg,0,-1)
        oBgImg:setAnchorPoint( 0, 0 )
        oBgImg:setTouchEnabled(true)
    end
end

function cRaceLogicBase:CreateTrack()
	local oGameApp = self:GetGameApp()
	if oGameApp == nil then
		return
	end
	local oCurScene = oGameApp:GetCurScene()
	if oCurScene == nil then
		return
	end
	local oGameLayer = oCurScene:GetGameLayer()
	if oGameLayer == nil then
		return
	end
	local tMapData = self:GetMapData()
	if tMapData == nil then
		return
	end
    self.m_tTracksNode = {}
	self.m_tCurMapData = tMapData
	local tLines = tMapData.OuterTracks
    local nCount = #tLines
    for i, v in ipairs(tLines) do
        local tPointA = nil
        local tPointB = nil
        if i < nCount then
            tPointA = cc.p(v.x,v.y)
            tPointB = cc.p(tLines[i+1].x,tLines[i+1].y)
        else
            tPointA = cc.p(v.x,v.y)
            tPointB = cc.p(tLines[1].x,tLines[1].y)
        end
        local oNode = cc.Node:create()
        if oNode ~= nil then
            oGameLayer:addChild(oNode)
            table.insert(self.m_tTracksNode,oNode)
        end
        local oEdgeSegment = cc.PhysicsBody:createEdgeSegment(tPointA,tPointB)
        oEdgeSegment:setCategoryBitmask(1)
        oEdgeSegment:setContactTestBitmask(1)
        oEdgeSegment:setTag( 666 )
        oNode:setPhysicsBody(oEdgeSegment)
        oNode:setPosition( cc.p(0,0) )
    end
    local tLines = tMapData.InnerTracks
    local nCount = #tLines
    for i, v in ipairs(tLines) do
        local tPointA = nil
        local tPointB = nil
        if i < nCount then
            tPointA = cc.p(v.x,v.y)
            tPointB = cc.p(tLines[i+1].x,tLines[i+1].y)
        else
            tPointA = cc.p(v.x,v.y)
            tPointB = cc.p(tLines[1].x,tLines[1].y)
        end
        local oNode = cc.Node:create()
        if oNode ~= nil then
            oGameLayer:addChild(oNode)
            table.insert(self.m_tTracksNode,oNode)
        end
        local oEdgeSegment = cc.PhysicsBody:createEdgeSegment(tPointA,tPointB)
        oEdgeSegment:setCategoryBitmask(1)
        oEdgeSegment:setContactTestBitmask(1)
        oEdgeSegment:setTag( 888 )
        oNode:setPhysicsBody(oEdgeSegment)
        oNode:setPosition( cc.p(0,0) )
    end
end

function cRaceLogicBase:GetMapData()
	local oGameApp = self:GetGameApp()
	if oGameApp == nil then
		return
	end
	local tMissionConf = self.m_tMissionConf
	if tMissionConf == nil then
		return
	end
	local tData = {}
    local tMapInfo = require( "maps.map_" .. tMissionConf.mapId )
    if tMapInfo ~= nil then
        local tOuterTracks = {}
        local nHeight = tMapInfo.tileheight * tMapInfo.height
        local tOuterTrack = self:LookupLayer( tMapInfo, "objectgroup", "outer" )
        if tOuterTrack ~= nil then
            if tOuterTrack.objects ~= nil then
                local tTackInfo = tOuterTrack.objects[1]
                if tTackInfo ~= nil and tTackInfo.name == "track" then
                    local nOuterX = tTackInfo.x
                    local nOuterY = tTackInfo.y
                    for i, v in ipairs( tTackInfo.polygon ) do
                        table.insert( tOuterTracks, {x=nOuterX+v.x,y=nHeight-(nOuterY+v.y)})
                    end
                end
            end
        end
        local tInnerTracks = {}
        local tInnerTrack = self:LookupLayer( tMapInfo, "objectgroup", "inner" )
        if tInnerTrack ~= nil then
            if tInnerTrack.objects ~= nil then
                local tTackInfo = tInnerTrack.objects[1]
                if tTackInfo ~= nil and tTackInfo.name == "track" then
                    local nInnerX = tTackInfo.x
                    local nInnerY = tTackInfo.y
                    for i, v in ipairs( tTackInfo.polygon ) do
                        table.insert( tInnerTracks, {x=nInnerX+v.x,y=nHeight-(nInnerY+v.y)})
                    end
                end
            end
        end
        tData.OuterTracks = tOuterTracks
        tData.InnerTracks = tInnerTracks
    end
    return tData
end

function cRaceLogicBase:RegisterDefaultCollisionHandler()
	local oGameApp = self:GetGameApp()
	if oGameApp == nil then
		return
	end
	local oCurScene = oGameApp:GetCurScene()
	if oCurScene == nil then
		return
	end
	local oSceneRoot = oCurScene:GetSceneRoot()
	if oSceneRoot == nil then
		return
	end
	local contactListener  = cc.EventListenerPhysicsContact:create()
	contactListener:registerScriptHandler(function(contact, solve)
											self:CollisionHandler_EVENT_PHYSICS_CONTACT_SEPERATE(contact, solve)
										  end, 
										  cc.Handler.EVENT_PHYSICS_CONTACT_SEPERATE)

	oSceneRoot:getEventDispatcher():addEventListenerWithFixedPriority(contactListener, 1)
end

local _angle_r2a = 180 / math.pi
local nSpeed = -800

function cRaceLogicBase:CollisionHandler_EVENT_PHYSICS_CONTACT_SEPERATE(contact, solve)
	local shapeA = contact:getShapeA()
    local shapeB = contact:getShapeB()
    if shapeA == nil or shapeB == nil then
    	return
    end
	local bodyA = shapeA:getBody()
    local bodyB = shapeB:getBody()
    if bodyA == nil or bodyB == nil then
    	return
    end
    local oNodeA = bodyA:getNode()
    local oNodeB = bodyB:getNode()
    if oNodeA == nil or oNodeB == nil then
    	return
    end
    local nTagA = bodyA:getTag()
    local nTagB = bodyB:getTag()
    if nTagA == nil or nTagB == nil then
    	return
    end
    if nTagA > 1000 and nTagB < 1000 then
        local potA = shapeB:getPointA()
        local potB = shapeB:getPointB()
        local vec = {x=potB.x-potA.x,y=potB.y-potA.y}
        local nDistance = math.sqrt( vec.x * vec.x + vec.y * vec.y )
        local norVec = { x = vec.x / nDistance, y = vec.y /nDistance}
        local velocity = bodyA:getVelocity()
        local nDistanceV = math.sqrt( velocity.x * velocity.x + velocity.y * velocity.y )
        local cosDelta = ((velocity.x * vec.x + velocity.y * vec.y ) / (nDistanceV * nDistance) )
        local angle = math.acos(cosDelta) * _angle_r2a
        local cosDeltaX = math.acos(( vec.x ) / ( nDistance )) * _angle_r2a
        local oSprite = oNodeA:getChildByTag(999901)
        if oSprite ~= nil then
            oSprite:setRotation( 180-math.atan2(vec.y,vec.x ) * _angle_r2a )
        end
        if self.carObj ~= nil and self.carObj.SpeedDownTime ~= nil and self.carObj.SpeedDownTime > 0 then
            local nFactor = self.carObj.SpeedDownFactor
            bodyA:setVelocity( cc.p( norVec.x * nSpeed * nFactor, norVec.y * nSpeed * nFactor) )
            return
        end
        if angle > 155 then
            bodyA:setVelocity( cc.p( norVec.x * nSpeed, norVec.y * nSpeed) )
        elseif angle > 145 then
            bodyA:setVelocity( cc.p( norVec.x * nSpeed * 0.7, norVec.y * nSpeed * 0.7) )
        elseif angle > 105 then
            bodyA:setVelocity( cc.p( norVec.x * nSpeed * 0.4, norVec.y * nSpeed * 0.4) )
        elseif angle > 0 and angle <= 105 then
            bodyA:setVelocity( cc.p( norVec.x * nSpeed * 0.2, norVec.y * nSpeed * 0.2) )
        end
    end
    if nTagB > 1000 and nTagA < 1000 then
        local potA = shapeA:getPointA()
        local potB = shapeA:getPointB()
        local vec = {x=potB.x-potA.x,y=potB.y-potA.y}
        local nDistance = math.sqrt( vec.x * vec.x + vec.y * vec.y )
        local norVec = { x = vec.x / nDistance, y = vec.y /nDistance}
        local velocity = bodyB:getVelocity()
        local nDistanceV = math.sqrt( velocity.x * velocity.x + velocity.y * velocity.y )
        local cosDelta = ((velocity.x * vec.x + velocity.y * vec.y ) / (nDistanceV * nDistance) )
        local angle = math.acos(cosDelta) * _angle_r2a
        
        if oSprite ~= nil then
            oSprite:setRotation( 180-math.atan2(vec.y,vec.x ) * _angle_r2a )
        end
        if self.carObj ~= nil and self.carObj.SpeedDownTime ~= nil and self.carObj.SpeedDownTime > 0 then
            local nFactor = self.carObj.SpeedDownFactor
            bodyB:setVelocity( cc.p( norVec.x * nSpeed * nFactor, norVec.y * nSpeed * nFactor) )
            return
        end
        if angle > 155 then
            bodyB:setVelocity( cc.p( norVec.x * nSpeed, norVec.y * nSpeed) )
        elseif angle > 145 then
            bodyB:setVelocity( cc.p( norVec.x * nSpeed * 0.7, norVec.y * nSpeed * 0.7) )
        elseif angle > 105 then
            bodyB:setVelocity( cc.p( norVec.x * nSpeed * 0.4, norVec.y * nSpeed * 0.4) )
        elseif angle > 0 and angle <= 105 then
            bodyB:setVelocity( cc.p( norVec.x * nSpeed * 0.2, norVec.y * nSpeed * 0.2) )
        end
  	end
end

function cRaceLogicBase:LookupLayer(tmx, tname, name)
    if not tmx then 
        return nil
    end
    local layers = tmx.layers
    if not layers then
        return nil
    end
    for _, layer in pairs(layers) do
        if layer.type == tname and layer.name == name then
            return layer
        end
    end

    return nil
end

function cRaceLogicBase:CreateCars()
	local oGameApp = self:GetGameApp()
	if oGameApp == nil then
		return
	end
	local oObjectManager = oGameApp:GetObjectManager()
	local oDataManager = oGameApp:GetDataManager()
	local oCurScene = oGameApp:GetCurScene()
	if oObjectManager == nil or oCurScene == nil or oDataManager == nil then
		return
	end
	local oGameLayer = oCurScene:GetGameLayer()
	if oGameLayer == nil then
		return
	end
	for i = 1, 3 do
		local tCarConf = oDataManager:GetDataByNameAndId( "CarConf", 10000 + i )
		if tCarConf ~= nil then
			local oCar = oObjectManager:CreateObjectByType( "CGameCar", { Type = tCarConf.id, View = tCarConf.view } )
			if oCar ~= nil then
				oCar:AddToWorld( 800, 480, oGameLayer )
                self.m_oCar = oCar
			end
		end
	end
    self.m_oGameLayer = oGameLayer
end

function cRaceLogicBase:CreateTowers()
    local oGameApp = self:GetGameApp()
    if oGameApp == nil then
        return
    end
    local oObjectManager = oGameApp:GetObjectManager()
    local oDataManager = oGameApp:GetDataManager()
    local oCurScene = oGameApp:GetCurScene()
    if oObjectManager == nil or oCurScene == nil or oDataManager == nil then
        return
    end
    local oGameLayer = oCurScene:GetGameLayer()
    if oGameLayer == nil then
        return
    end
    self.m_tTowers = {}
    local tTowerConf = oDataManager:GetDataByNameAndId( "TowersConf", self.m_tMissionConf.id )
    if tTowerConf ~= nil then
        for i, v in ipairs(tTowerConf) do
            local oTower = nil
            if v.type == 1 then
                oTower = oObjectManager:CreateObjectByType( "CAnchorTower", { X=v.x, Y=v.y, IsReverse = v.isReverse, View = v.view,
                                                            ArrowAngle = v.param1, AngleSector = v.param2, 
                                                            RadiusMin = v.param3,  RadiusMax = v.param4 } )
            elseif v.type == 2 then
                oTower = oObjectManager:CreateObjectByType( "CMagneticTower", { X=v.x, Y=v.y, IsReverse = v.isReverse, View = v.view,
                                                            ArrowAngle = v.param1, RectWidth = v.param2, 
                                                            RadiusMin = v.param3,  RadiusMax = v.param4 } )
            end
            if oTower ~= nil then
                table.insert( self.m_tTowers, oTower )
                oTower:AddToWorld( v.x, v.y, oGameLayer )
            end  
        end 
    end
end

function cRaceLogicBase:SetGameApp( oGameApp )
	self.m_oGameApp = oGameApp
end

function cRaceLogicBase:GetGameApp()
	return self.m_oGameApp
end

function cRaceLogicBase:OnDefaultUpdate( dt )
	self:CheckFinish()
    self:UpdateCamera()
	self:UpdateDebugView()
end

function cRaceLogicBase:OnUpdate(dt)
end

function cRaceLogicBase:CheckFinish()
end

function cRaceLogicBase:UpdateDebugView()
	if self.m_oDebugDrawNode ~= nil and self.m_tCurMapData ~= nil then
		self.m_oDebugDrawNode:clear()
		local tMapData = self.m_tCurMapData
		if tMapData ~= nil then
			local tOuterTrack = tMapData.OuterTracks
			if tOuterTrack ~= nil then
				local oColor = cc.c4f( 1, 0, 0, 1 )
				self.m_oDebugDrawNode:drawPoly( tOuterTrack, #tOuterTrack, true, oColor )
			end
			local tInnerTrack = tMapData.InnerTracks
			if tInnerTrack ~= nil then
				local oColor = cc.c4f( 1, 0, 1, 1 )
				self.m_oDebugDrawNode:drawPoly( tInnerTrack, #tInnerTrack, true, oColor )
			end
		end
	end
end

function cRaceLogicBase:UpdateCamera()
    if self.m_oCar ~= nil and self.m_oGameLayer ~= nil then
        local ox,oy = self.m_oCar:GetPosition()
        local x = 960 - ox
        local y = 540 - oy
        if y > 0 then
            y = 0
        end
        if y < -360 then
            y = -360
        end
        if x > 0 then
            x = 0
        end
        self.m_oGameLayer:setPosition( cc.p( x, y ) )
    end
end

function cRaceLogicBase:OnCalcResult()
end

function cRaceLogicBase:CheckAnchorTowerRule()
end

function cRaceLogicBase:CheckMagneticTowerRule()
end

function cRaceLogicBase:OnUpdateAI( dt )
end

function cRaceLogicBase:OnUpdateNetworkMsg()
end

function cRaceLogicBase:OnTouch( event )
	self:CheckAnchorTowerRule()
	self:CheckMagneticTowerRule()
end

function cRaceLogicBase:DefaultCollisionHanlder()
end

return cRaceLogicBase