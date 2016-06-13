local cRaceLogicBase = class("cRaceLogicBase")

function cRaceLogicBase:ctor()
    self.m_bRealStart = false
    self.m_nRaceTotalTime = 0
end

function cRaceLogicBase:OnStart()
end

function cRaceLogicBase:OnFinish()
end

function cRaceLogicBase:OnPause()
end

function cRaceLogicBase:OnResume()
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
    local oCurScene = oGameApp:GetCurScene()
    if oCurScene == nil then
        return
    end
    local oSceneRoot = oCurScene:GetSceneRoot()
    if self.m_tTracksNode ~= nil then
        for i, v in ipairs(self.m_tTracksNode) do
            v:removeFromParent(true)
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
    oSceneRoot:getEventDispatcher():removeEventListener( self.m_oContactListener )
    self.m_oContactListener = nil
end

function cRaceLogicBase:RealStartRace()
    self.m_bRealStart = true
    for i, v in ipairs( self.m_tCars ) do
        v:SetStop(false)
    end
end

function cRaceLogicBase:IsRealStart()
    return self.m_bRealStart
end

function cRaceLogicBase:GetRaceTotalTime()
    return self.m_nRaceTotalTime
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
    self.m_bIsReverse = tMissionConf.isReverse
	self.m_tTowersTable = oDataManager:GetDataByNameAndId( "TowersConf",tMissionConf.id )
	self:CreateDrawNode()
	self:ShowMap()
	self:CreateTrack()
	self:CreateCars()
    self:CreateTowers()
    self:CreateMapItems()
    self:UpdateDebugView()
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
	if CONFIG_SHOW_DEBUG_VIEW == true then
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
        local nWidth = tMapInfo.tilewidth * tMapInfo.width
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
        tData.MapWidth  = nWidth
        tData.MapHeight = nHeight
    end
    return tData
end

local _angle_r2a = 180 / math.pi
local nSpeed = -800

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
    self.m_oContactListener = contactListener

    contactListener:registerScriptHandler(function(contact, solve)
                                            return self:CollisionHandler_EVENT_PHYSICS_CONTACT_BEGIN(contact, solve)
                                          end, 
                                          cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)

    contactListener:registerScriptHandler(function(contact, solve)
                                            return self:CollisionHandler_EVENT_PHYSICS_CONTACT_PRESOLVE(contact, solve)
                                          end, 
                                          cc.Handler.EVENT_PHYSICS_CONTACT_PRESOLVE)

    contactListener:registerScriptHandler(function(contact, solve)
                                            return self:CollisionHandler_EVENT_PHYSICS_CONTACT_POSTSOLVE(contact, solve)
                                          end, 
                                          cc.Handler.EVENT_PHYSICS_CONTACT_POSTSOLVE)

	contactListener:registerScriptHandler(function(contact, solve)
											return self:CollisionHandler_EVENT_PHYSICS_CONTACT_SEPERATE(contact, solve)
										  end, 
										  cc.Handler.EVENT_PHYSICS_CONTACT_SEPERATE)

	oSceneRoot:getEventDispatcher():addEventListenerWithFixedPriority(contactListener, 1)
end

function cRaceLogicBase:CollisionHandler_EVENT_PHYSICS_CONTACT_PRESOLVE(contact, solve)
    local oGameApp = self:GetGameApp()
    assert(oGameApp ~= nil)
    local oObjectManager = oGameApp:GetObjectManager()
    assert(oObjectManager ~= nil)
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
    if nTagA > 100000000 and nTagB < 100000000 then
        local oCar = oObjectManager:GetGameObjectById( nTagA )
        if oCar == nil then
            return
        end
        local potA = shapeB:getPointA()
        local potB = shapeB:getPointB()
        local tNorVec = cc.pNormalize( { x=potB.x-potA.x, y=potB.y-potA.y } )
        local tNorVelocity = cc.pNormalize( bodyA:getVelocity() )
        local nCosAlpha = ( tNorVec.x * tNorVelocity.x + tNorVec.y * tNorVelocity.y )
        local angle = math.acos(nCosAlpha) * _angle_r2a
        if angle < 150 then
            oCar:DetachFromTower()
        end
        if angle < 165 then
            oCar:DeEffectFromTower()
        end
        oCar.m_nLastCollisionTime = os.clock()
    end
    return true
end

function cRaceLogicBase:CollisionHandler_EVENT_PHYSICS_CONTACT_POSTSOLVE(contact, solve)
    return true
end

function cRaceLogicBase:CollisionHandler_EVENT_PHYSICS_CONTACT_BEGIN(contact, solve)
    return true
end

function cRaceLogicBase:CollisionHandler_EVENT_PHYSICS_CONTACT_SEPERATE(contact, solve)
    local oGameApp = self:GetGameApp()
    assert(oGameApp ~= nil)
    local oObjectManager = oGameApp:GetObjectManager()
    assert(oObjectManager ~= nil)
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
    if nTagA > 100000000 and nTagB > 100000000 then
        return
    elseif nTagA > 100000000 and nTagB < 100000000 then
        local oCar = oObjectManager:GetGameObjectById( nTagA )
        if oCar == nil then
            return
        end
        local potA = nil
        local potB = nil
        if self.m_bIsReverse == true then
            potA = shapeB:getPointB()
            potB = shapeB:getPointA()       
        else
            potA = shapeB:getPointA()
            potB = shapeB:getPointB() 
        end
        local tNorVec = cc.pNormalize( { x=potB.x-potA.x, y=potB.y-potA.y } )
        local tNorVelocity = cc.pNormalize( bodyA:getVelocity() )
        local nCosAlpha = ( tNorVec.x * tNorVelocity.x + tNorVec.y * tNorVelocity.y )
        local nAddAngle = 0
        if self.m_bIsReverse == true then
            nAddAngle = -180
        end
        oCar:SetRotation( math.atan2(tNorVec.y,tNorVec.x ) * _angle_r2a + nAddAngle)
        oCar:UpdateVelocity() 
        local angle = math.acos(nCosAlpha) * _angle_r2a
        if angle < 15 then
            oCar:SetMinSpeed( 600 )
        elseif angle < 35 then
            oCar:SetMinSpeed( 400 )
        elseif angle < 75 then
            oCar:SetMinSpeed( 300 )
        elseif angle < 90 and angle <= 105 then
            oCar:SetMinSpeed( 100 )
        end
    elseif nTagA < 100000000 and nTagB > 100000000 then
        local potA = shapeA:getPointA()
        local potB = shapeA:getPointB()
        local vec = {x=potB.x-potA.x,y=potB.y-potA.y}
        local nDistance = math.sqrt( vec.x * vec.x + vec.y * vec.y )
        local norVec = { x = vec.x / nDistance, y = vec.y /nDistance}
        local velocity = bodyB:getVelocity()
        local nDistanceV = math.sqrt( velocity.x * velocity.x + velocity.y * velocity.y )
        local cosDelta = ((velocity.x * vec.x + velocity.y * vec.y ) / (nDistanceV * nDistance) )
        local angle = math.acos(cosDelta) * _angle_r2a
        local oCar = oObjectManager:GetGameObjectById( nTagB )
        if oCar ~= nil then
            local nAddAngle = 0
            if self.m_bIsReverse == true then
                nAddAngle = -180
            end
            oCar:SetRotation( math.atan2(vec.y,vec.x ) * _angle_r2a + nAddAngle)
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
    local tMissConf = self.m_tMissionConf
    if tMissConf == nil then
        return
    end
    self.m_tCars = {}
    local nBeginRot = tMissConf.begin_rot
    for i = 1, tMissConf.carNum do
        local nOX = tMissConf[string.format( "car%s_oX", i )]
        local nOY = tMissConf[string.format( "car%s_oY", i )]
        local tCarConf = oDataManager:GetDataByNameAndId( "CarConf", 10000 + i )
        if tCarConf ~= nil then
            local tConfData = { Type = tCarConf.id, 
                                View = tCarConf.view, 
                                Speed = 0, 
                                MaxSpeed = tCarConf.maxSpeed, 
                                Accelaration = tCarConf.accelaration 
                              }
            local oCar = oObjectManager:CreateObjectByType( "CGameCar", tConfData )
            if oCar ~= nil then
                oCar:AddToWorld( nOX, nOY, oGameLayer )
                oCar:SetRotation( nBeginRot )
                table.insert(self.m_tCars,oCar)
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
            local bIsReverse = v.isReverse
            if self.m_bIsReverse == true then
                bIsReverse = not v.isReverse
            end
            local oTower = nil
            if v.type == 1 then
                oTower = oObjectManager:CreateObjectByType( "CAnchorTower", { X=v.x, Y=v.y, IsReverse = bIsReverse, View = v.view,
                                                            ArrowAngle = v.param1, AngleSector = v.param2, 
                                                            RadiusMin = v.param3,  RadiusMax = v.param4 } )
            elseif v.type == 2 then
                oTower = oObjectManager:CreateObjectByType( "CMagneticTower", { X=v.x, Y=v.y, IsReverse = bIsReverse, View = v.view,
                                                            ArrowAngle = v.param1, RectWidth = v.param2, 
                                                            RadiusMin = v.param3,  RadiusMax = v.param4,
                                                            PullTime = v.param5, PushTime = v.param6  } )
            end
            if oTower ~= nil then
                table.insert( self.m_tTowers, oTower )
                oTower:AddToWorld( v.x, v.y, oGameLayer )
            end  
        end 
    end
end

function cRaceLogicBase:CreateMapItems()
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
    self.m_tMapItems = {}
    local tMapItemsConf = oDataManager:GetDataByNameAndId( "MapItemsConf", self.m_tMissionConf.id )
    if tMapItemsConf ~= nil then
        for i, v in ipairs( tMapItemsConf ) do
            local oMapItem = oObjectManager:CreateObjectByType( "CMapItem",  { X=v.x, Y=v.y, View = v.view, Type = v.type, Rotation = v.rotation } )
            if oMapItem ~= nil then
                table.insert( self.m_tMapItems, oMapItem )
                oMapItem:AddToWorld( v.x, v.y, oGameLayer )
                oMapItem:SetRotation( v.rotation )
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
    if self.m_bRealStart == true then
        self.m_nRaceTotalTime = self.m_nRaceTotalTime + dt
    end
end

function cRaceLogicBase:OnUpdate(dt)
    self:CheckAnchorTowerRule()
    self:CheckMagneticTowerRule()
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
    local tCurMapData = self.m_tCurMapData
    if self.m_oCar ~= nil and self.m_oGameLayer ~= nil and tCurMapData ~= nil then
        local ox, oy = self.m_oCar:GetPosition()
        local x = 640 - ox
        local y = 360 - oy
        if y > 0 then
            y = 0
        end
        if y < -tCurMapData.MapHeight + 720 then
            y = -tCurMapData.MapHeight + 720 
        end
        if x > 0 then
            x = 0
        end
        if x < -tCurMapData.MapWidth + 1280 then
            x = -tCurMapData.MapWidth + 1280
        end
        self.m_oGameLayer:setPosition( cc.p( x, y ) )
    end
end

function cRaceLogicBase:OnCalcResult()
end

function cRaceLogicBase:CheckAnchorTowerRule()
    local oGameApp = self:GetGameApp()
    if oGameApp == nil then
        return
    end
    local oObjectManager = oGameApp:GetObjectManager()
    if oObjectManager == nil then
        return
    end
    if self.m_oCar == nil then
        return
    end
    local ox, oy = self.m_oCar:GetPosition()
    for i, v in ipairs( self.m_tTowers ) do
        if v.CheckInRange ~= nil then
            v:CheckInRange( ox, oy )
        end
    end
end

function cRaceLogicBase:CheckMagneticTowerRule()
end

function cRaceLogicBase:OnUpdateAI( dt )
end

function cRaceLogicBase:OnUpdateNetworkMsg()
end

function cRaceLogicBase:OnTouch( event )
    local oGameApp = self:GetGameApp()
    if oGameApp == nil then
        return
    end
    local oObjectManager = oGameApp:GetObjectManager()
    if oObjectManager == nil then
        return
    end
    local nOX, nOY = self.m_oCar:GetPosition()
    local oAnchorTower = nil
    local oMagneticTower = nil
    if event.name ~= "ended" then
        for i, v in ipairs( self.m_tTowers ) do
            if v:GetPropertyVal( "Type" ) == 1 and v:CheckInRange( nOX, nOY ) == true then
                oAnchorTower = v
                break
            end
        end
        if oAnchorTower == nil then
            for i, v in ipairs( self.m_tTowers ) do
                if v:GetPropertyVal( "Type" ) == 2 and v:CheckInRange( nOX, nOY ) == true then
                    oMagneticTower = v
                    break
                end
            end
        end
    else
        for i, v in ipairs( self.m_tTowers ) do
            if v.AddAttachCar ~= nil then
                v:AddAttachCar( nil )
            end
        end
    end
    if oAnchorTower ~= nil then
        if self.m_oCar:IsAttached() ~= true  then
            if self.m_oCar:CanAttachTower() == true then
                self.m_oCar:AttachToTower( oAnchorTower )
                oAnchorTower:AddAttachCar( self.m_oCar )
            end
        end
    else
        self.m_oCar:AttachToTower( nil )
    end
    if oAnchorTower ~= nil then
        return
    end
    if oMagneticTower ~= nil then
        if self.m_oCar:IsAttached() ~= true then
            if self.m_oCar:CanAttachTower() == true then
                self.m_oCar:EffectByTower( oMagneticTower )
                oMagneticTower:AddEffectCar( self.m_oCar )
            end
        end
    else
        self.m_oCar:EffectByTower( nil )
    end
end

function cRaceLogicBase:DefaultCollisionHanlder()
end

return cRaceLogicBase