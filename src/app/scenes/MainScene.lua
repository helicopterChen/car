
local MainScene = class("MainScene", function()
    return display.newPhysicsScene("MainScene")
end)

local GRAVITY         = 0
local COIN_MASS       = 100
local COIN_RADIUS     = 46
local COIN_FRICTION   = 0.95
local COIN_ELASTICITY = 0.95
local WALL_THICKNESS  = 64
local WALL_FRICTION   = 1.0
local WALL_ELASTICITY = 0.5

function tmx_lookupLayer(tmx, tname, name)
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

function MainScene:getMapInfo( nId )
	local tData = {}
	local sharedFileUtils = cc.FileUtils:getInstance()
	local sPath = sharedFileUtils:fullPathForFilename( string.format("maps/map_%s.lua",nId) )
	local sDataStr = sharedFileUtils:getStringFromFile(sPath)
	local tMapInfo = require( "app.scenes.map_" .. nId )
	if tMapInfo ~= nil then
		local tOuterTracks = {}
		local nHeight = tMapInfo.tileheight * tMapInfo.height
		local tOuterTrack = tmx_lookupLayer( tMapInfo, "objectgroup", "outer" )
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
    	local tInnerTrack = tmx_lookupLayer( tMapInfo, "objectgroup", "inner" )
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
        local tTowersInfo = {}
        local tInnerTrack = tmx_lookupLayer( tMapInfo, "objectgroup", "towers" )
        if tInnerTrack ~= nil then
            if tInnerTrack.objects ~= nil then
                for i, v in ipairs(tInnerTrack.objects) do
                    table.insert( tTowersInfo, { x=v.x, y=nHeight-v.y} )
                end
            end
        end
    	tData.OuterTracks = tOuterTracks
    	tData.InnerTracks = tInnerTracks
        tData.TowersInfo = tTowersInfo
	end
	return tData
end

function MainScene:onTouch_( event )
    if event.name == "began" then
        self.screen_pressed = true
        return true
    elseif event.name == "ended" then
        self.screen_pressed = false
        return true
    end
end

local _angle_r2a = 180 / 3.1415

function MainScene:ctor()
    self.collisionIgnoreTime = 0
	local sharedFileUtils = cc.FileUtils:getInstance()
    sharedFileUtils:addSearchPath("res/")
	self.world = self:getPhysicsWorld()
    self.world:setAutoStep(false)
    self.world:setGravity(cc.p(0, GRAVITY))
    self.world:setDebugDrawMask(1)

    local oBgImg = cc.Sprite:create("png/map_bg_1002.png")
    if oBgImg ~= nil then
        oBgImg:addTo(self)
        oBgImg:setAnchorPoint( 0, 0 )
        oBgImg:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch_))
        oBgImg:setTouchEnabled(true)
    end
    local tMapData = self:getMapInfo(1002)
    local contactListener  = cc.EventListenerPhysicsContact:create()
    contactListener:registerScriptHandler(function(contact)
        local bodyA = contact:getShapeA():getBody()
        local bodyB = contact:getShapeB():getBody()
        local oNodeA = contact:getShapeA():getBody():getNode()
        local oNodeB = contact:getShapeB():getBody():getNode()
        local shapeA = contact:getShapeA()
        local shapeB = contact:getShapeB()
        if bodyA ~= nil and bodyB ~= nil and shapeA ~= nil and shapeB ~= nil and oNodeA ~= nil and oNodeB ~= nil then
            local nTagA = bodyA:getTag()
            local nTagB = bodyB:getTag()
            if nTagA > 1000 and nTagB < 1000 then
                self.collisionIgnoreTime = 0.08
            end
        end
        return true
    end, cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)

    contactListener:registerScriptHandler(function(contact, solve)
        return true
    end, cc.Handler.EVENT_PHYSICS_CONTACT_PRESOLVE)

    contactListener:registerScriptHandler(function(contact, solve)
    end, cc.Handler.EVENT_PHYSICS_CONTACT_POSTSOLVE)

    local nSpeed = -800
    contactListener:registerScriptHandler(function(contact)
        local bodyA = contact:getShapeA():getBody()
        local bodyB = contact:getShapeB():getBody()
        local oNodeA = contact:getShapeA():getBody():getNode()
        local oNodeB = contact:getShapeB():getBody():getNode()
        local shapeA = contact:getShapeA()
        local shapeB = contact:getShapeB()
        if bodyA ~= nil and bodyB ~= nil and shapeA ~= nil and shapeB ~= nil and oNodeA ~= nil and oNodeB ~= nil then
        	local nTagA = bodyA:getTag()
        	local nTagB = bodyB:getTag()
        	if nTagA > 1000 and nTagB < 1000 then
        		--local vec = bodyA:getVelocity()
        		---local nDistance = math.sqrt( vec.x * vec.x + vec.y * vec.y )
        		--local norVec = { x = vec.x / nDistance, y = vec.y /nDistance}
        		--bodyA:setVelocity( cc.p( norVec.x * 300, norVec.y * 300) )
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
                    self.carObj.SpeedDownTime = 1.0
                    self.carObj.SpeedDownFactor = 0.5
                    self.carObj.SpeedMinFactor = 0.5
                    bodyA:setVelocity( cc.p( norVec.x * nSpeed * 0.7, norVec.y * nSpeed * 0.7) )
                elseif angle > 105 then
                    self.carObj.SpeedDownTime = 1.0
                    self.carObj.SpeedDownFactor = 0.4
                    self.carObj.SpeedMinFactor = 0.4
                    bodyA:setVelocity( cc.p( norVec.x * nSpeed * 0.4, norVec.y * nSpeed * 0.4) )
                else
                    self.carObj.SpeedDownTime = 1.0
                    self.carObj.SpeedDownFactor = 0.2
                    self.carObj.SpeedMinFactor = 0.2
                    bodyA:setVelocity( cc.p( norVec.x * nSpeed * 0.2, norVec.y * nSpeed * 0.2) )
                end
        	end
        	if nTagB > 1000 and nTagA < 1000 then
        		--local vec = bodyA:getVelocity()
        		--local nDistance = math.sqrt( vec.x * vec.x + vec.y * vec.y )
        		--local norVec = { x = vec.x / nDistance, y = vec.y /nDistance}
        		--bodyA:setVelocity( cc.p( norVec.x * 300, norVec.y * 300))
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
                    self.carObj.SpeedDownTime = 1.0
                    self.carObj.SpeedDownFactor = 0.5
                    self.carObj.SpeedMinFactor = 0.5
                    bodyB:setVelocity( cc.p( norVec.x * nSpeed * 0.7, norVec.y * nSpeed * 0.7) )
                elseif angle > 105 then
                    self.carObj.SpeedDownTime = 1.0
                    self.carObj.SpeedDownFactor = 0.4
                    self.carObj.SpeedMinFactor = 0.4
                    bodyB:setVelocity( cc.p( norVec.x * nSpeed * 0.4, norVec.y * nSpeed * 0.4) )
                else
                    self.carObj.SpeedDownTime = 1.0
                    self.carObj.SpeedDownFactor = 0.2
                    self.carObj.SpeedMinFactor = 0.2
                    bodyBsetVelocity( cc.p( norVec.x * nSpeed * 0.2, norVec.y * nSpeed * 0.2) )
                end
        	end
        end
    end, cc.Handler.EVENT_PHYSICS_CONTACT_SEPERATE)

    self:getEventDispatcher():addEventListenerWithFixedPriority(contactListener, 1)

    local lines = tMapData.OuterTracks
	local nCount = #lines
	for i, v in ipairs(lines) do
		local pointA = nil
		local pointB = nil
		if i < nCount then
			pointA = cc.p(v.x,v.y)
		    pointB = cc.p(lines[i+1].x,lines[i+1].y)
		else
			pointA = cc.p(v.x,v.y)
		    pointB = cc.p(lines[1].x,lines[1].y)
		end
		local node = cc.Node:create()
	    if node ~= nil then
	    	node:setContentSize( cc.size(100,20) )
			node:setColor( cc.c3b(127,127,127) )
	    	node:addTo(self)
	    end
	    local coinBody = cc.PhysicsBody:createEdgeSegment(pointA,pointB)
	    coinBody:setCategoryBitmask(1)
	    coinBody:setContactTestBitmask(1)
	    coinBody:setTag( 666 )
	    node:setPhysicsBody(coinBody)
	    node:setPosition( cc.p(0,0) )
	end

	local lines = tMapData.InnerTracks
	local nCount = #lines
	for i, v in ipairs(lines) do
		local pointA = nil
		local pointB = nil
		if i < nCount then
			pointA = cc.p(v.x,v.y)
		    pointB = cc.p(lines[i+1].x,lines[i+1].y)
		else
			pointA = cc.p(v.x,v.y)
		    pointB = cc.p(lines[1].x,lines[1].y)
		end
		local node = cc.Node:create()
	    if node ~= nil then
	    	node:setContentSize( cc.size(100,20) )
			node:setColor( cc.c3b(127,127,127) )
	    	node:addTo(self)
	    end
	    local coinBody = cc.PhysicsBody:createEdgeSegment(pointA,pointB)
	    coinBody:setCategoryBitmask(1)
	    coinBody:setContactTestBitmask(1)
	    coinBody:setTag( 888 )
	    node:setPhysicsBody(coinBody)
	    node:setPosition( cc.p(0,0) )
	end
    self.m_towers = {}
    local tTowersInfo = tMapData.TowersInfo
    if tTowersInfo ~= nil then
        for i, v in ipairs(tTowersInfo) do
            local oSprite = cc.Sprite:create( "png/model_ta_0002.png" )
            if oSprite ~= nil then
                self:addChild( oSprite )
                oSprite:setScale( 0.6 )
                oSprite:setPosition( cc.p(v.x,v.y) )
                oSprite:setLocalZOrder( 10 )
                table.insert( self.m_towers, { x=v.x, y=v.y } )
            end
        end
    end
    local drawNode = cc.DrawNode:create()
    if drawNode ~= nil then
        drawNode:addTo( self )
        drawNode:setLocalZOrder( 500 )
        self.drawNode = drawNode
    end
    local _scheduler = cc.Director:getInstance():getScheduler()
    timerId1 = _scheduler:scheduleScriptFunc(function(dt) self:update(dt) end, 0.016667, false)
    timerId2 = _scheduler:scheduleScriptFunc(function(dt) self:addObj(dt) end, 0.5, false)
end

function MainScene:OnEnter()
end

function MainScene:OnExit()
    scheduler.unscheduleGlobal(timerId1)
    scheduler.unscheduleGlobal(timerId2)
end

local myCar = nil
function MainScene:update(dt)
    if dt > 0.02 then 
        dt = 0.02 
    end
    if self.world ~= nil then
        self.world:step(dt)
    end
    if myCar ~= nil then
        local ox,oy = myCar:getPositionX(),myCar:getPositionY() 
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
        self:setPosition( cc.p( x, y ) )
    end
    if self.carObj ~= nil and self.carObj.SpeedDownTime ~= nil then
        self.carObj.SpeedDownFactor = self.carObj.SpeedDownFactor + ((0.8 - self.carObj.SpeedMinFactor) / 1.0) * dt     
        if self.carObj.SpeedDownFactor >= 0.8 then
            self.carObj.SpeedDownFactor = 0.8
        end
        self.carObj.SpeedDownTime = self.carObj.SpeedDownTime - dt
        if self.carObj.SpeedDownTime <= 0 then
            self.carObj.SpeedDownTime = 0
        end    
    end
    if self.collisionIgnoreTime ~= nil then
        if self.collisionIgnoreTime > 0 then
            self.collisionIgnoreTime = self.collisionIgnoreTime - dt
            if self.collisionIgnoreTime <= 0 then
                self.collisionIgnoreTime = 0
            end
        end
    end
    if self.carObj ~= nil then
        self.drawNode:clear()
        for i, v in ipairs( self.m_towers ) do
            self.drawNode:drawSolidCircle( cc.p(v.x,v.y), 270, 360, 32, cc.c4f(1,0,1,0.1) )
            self.drawNode:drawCircle( cc.p(v.x,v.y), 270, 360, 32, false, cc.c4f(1,0,1,0.5) )
        end
        if self.drawNode ~= nil then
            local oPhysicsBody = self.carObj:getPhysicsBody()
            if oPhysicsBody ~= nil then
                local tCurPos = oPhysicsBody:getPosition()
                self.drawNode:drawCircle( cc.p(tCurPos.x,tCurPos.y), 50, 360, 32, false, cc.c4f(0,1,1,0.5) )
                local tVelocity = oPhysicsBody:getVelocity()
                local tTower = self:findTower()
                if tTower ~= nil then
                    local tArror = { x=tCurPos.x - tTower.x, y=tCurPos.y - tTower.y }
                    if tTower ~= nil and tCurPos ~= nil and tVelocity ~= nil and tArror ~= nil then
                        local nAngle = math.atan2( tArror.y,tArror.x )
                        local nSpeed = -800
                        local nFactor = self.carObj.SpeedDownFactor or 1.0
                        local x = math.cos( nAngle - _angle_r2a * 90.0025 ) * nFactor * nSpeed
                        local y = math.sin( nAngle - _angle_r2a * 90.0025 ) * nFactor * nSpeed
                        local nDistance = self:getDistance( tTower, tCurPos )
                        local ox = -math.cos( nAngle - _angle_r2a * 90.0025 ) * nFactor * 150
                        local oy = -math.sin( nAngle - _angle_r2a * 90.0025 ) * nFactor * 150
                        self.drawNode:drawLine( cc.p( tCurPos.x, tCurPos.y ), cc.p( tCurPos.x + ox, tCurPos.y + oy ), cc.c4f(1,1,0,1) )
                        self.drawNode:drawSolidCircle( cc.p(tTower.x,tTower.y), nDistance, 360, 32, cc.c4f(1,1,0,0.1) )
                        if self.screen_pressed == true and self.collisionIgnoreTime == 0 then
                            oPhysicsBody:setVelocity( cc.p( x, y ) )
                            local oSprite = self.carObj:getChildByTag(999901)
                            if oSprite ~= nil then
                                oSprite:setRotation( -math.atan2( y,x ) * _angle_r2a )
                            end
                            self.drawNode:drawCircle( cc.p(tCurPos.x,tCurPos.y), 50, 360, 32, false, cc.c4f(1,0,0,0.5) )
                        end
                    end
                end
            end
        end
    end        
        --[[
        if self.screen_pressed == true then
            local oPhysicsBody = self.carObj:getPhysicsBody()
            if oPhysicsBody ~= nil then
                local tCurPos = oPhysicsBody:getPosition()
                local tVelocity = oPhysicsBody:getVelocity()
                local tTower = self:findTower()
                if tTower ~= nil then
                    local tArror = { x=tCurPos.x - tTower.x, y=tCurPos.y - tTower.y }
                    if tTower ~= nil and tCurPos ~= nil and tVelocity ~= nil and tArror ~= nil then
                        local nAngle = math.atan2( tArror.y,tArror.x )
                        local nSpeed = -800
                        local nFactor = self.carObj.SpeedDownFactor or 1.0
                        local x = math.cos( nAngle - _angle_r2a * 90 ) * nFactor * nSpeed
                        local y = math.sin( nAngle - _angle_r2a * 90 ) * nFactor * nSpeed
                        --oPhysicsBody:setVelocity( cc.p( x, y ) )
                        if self.drawNode ~= nil then
                        --    self.drawNode:drawLine( cc.p( tCurPos.x, tCurPos.y ), cc.p( tCurPos.x + x, tCurPos.y + y ), cc.c3b( 255, 0, 0 ) )
                        end
                    end 
                end
            end
        end
        --]]
end

function MainScene:findTower()
    if self.carObj ~= nil then
        local oPhysicsBody = self.carObj:getPhysicsBody()
        if oPhysicsBody ~= nil and self.m_towers ~= nil then
            local tCurPos = oPhysicsBody:getPosition()
            for i, v in ipairs( self.m_towers) do
                local nDistance = self:getDistance( tCurPos, v )
                if nDistance < 270 then
                    return v
                end
            end
        end
    end
end

function MainScene:getDistance( tPos1, tPos2 )
    local nDeltaX = ( tPos1.x - tPos2.x )
    local nDeltaY = ( tPos1.y - tPos2.y )
    return math.sqrt( nDeltaX * nDeltaX + nDeltaY * nDeltaY )
end

local nCount = 5
function MainScene:addObj()
    if nCount <= 0 then
        return
    end
    local node = cc.Node:create()
    if node ~= nil then
        local sprite = cc.Sprite:create( "png/test_kadingche03.png" )
        node:addChild( sprite )
        sprite:setTag( 999901 )
        node:setLocalZOrder( 10 )
        node:addTo(self)
        self.carObj = node
    end
    myCar = node
    local coinBody = cc.PhysicsBody:createCircle(25, cc.PhysicsMaterial(0.2, 1, 0), cc.vertex2F( 0,0 ) )
    coinBody:setCategoryBitmask(1)
    coinBody:setContactTestBitmask(1)
    coinBody:setVelocity(cc.p(400,-100))
    coinBody:setTag( 1001 )
    coinBody:setAngularVelocityLimit(0)
    node:setPhysicsBody(coinBody)
    node:setPosition( cc.p(800,480) )
    nCount = nCount - 1
end

return MainScene
