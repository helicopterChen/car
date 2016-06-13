local DrawNode = cc.DrawNode
local ONE_RADIAN = (math.pi / 180)

function DrawNode:drawSector( tCenter, nArrowAngle, nSectorAngle, nMinRadius, nMaxRadius, nSegments, oColor )
	local coef = (ONE_RADIAN * (nSectorAngle / nSegments))
	local tVertices = {}
	local outerVertices = {}
	local innerVertices = {}
	local nBegin = (nArrowAngle - nSectorAngle / 2) * ONE_RADIAN
	for i = 1, nSegments + 1 do
		local rads = nBegin + (i - 1) * coef
		local iX    = tCenter.x + nMinRadius * math.cos(rads)
        local iY    = tCenter.y + nMinRadius * math.sin(rads)
        local oX    = tCenter.x + nMaxRadius * math.cos(rads)
        local oY    = tCenter.y + nMaxRadius * math.sin(rads)
        innerVertices[i] 		   	 = { x= iX, y = iY }
        outerVertices[nSegments+2-i] = { x= oX, y = oY }
	end
	local tVertices = {}
	for i, v in ipairs( innerVertices ) do
		tVertices[#tVertices+1] = v
	end
	for i, v in ipairs( outerVertices ) do
		tVertices[#tVertices+1] = v
	end
	self:drawPoly( tVertices, nSegments * 2 + 2, true, oColor )
end

function DrawNode:drawSolidSector( tCenter,  nArrowAngle, nSectorAngle, nMinRadius, nMaxRadius, nSegments, oColor )
	local coef = ((math.pi / 180) * nSectorAngle) / nSegments
	local tVertices = {}
	local outerVertices = {}
	local innerVertices = {}
	local nBegin = (nArrowAngle - nSectorAngle / 2) * ONE_RADIAN
	for i = 1, nSegments + 1 do
		local rads = nBegin + (i - 1) * coef
		local iX    = tCenter.x + nMinRadius * math.cos(rads)
        local iY    = tCenter.y + nMinRadius * math.sin(rads)
        local oX    = tCenter.x + nMaxRadius * math.cos(rads)
        local oY    = tCenter.y + nMaxRadius * math.sin(rads)
		innerVertices[i] 		   	 = { x= iX, y = iY }
        outerVertices[nSegments+2-i] = { x= oX, y = oY }
	end
	local tVertices = {}
	for i, v in ipairs( innerVertices ) do
		tVertices[#tVertices+1] = v
	end
	for i, v in ipairs( outerVertices ) do
		tVertices[#tVertices+1] = v
	end
	tVertices[#tVertices+1] = innerVertices[1]
	local tParams = {
		fillColor = oColor,
	    borderWidth  = 0,
	    borderColor  = oColor,
	}
	self:drawPolygon( tVertices, tParams )
end

function DrawNode:drawDebugSector( tCenter, nArrowAngle, nSectorAngle, nMinRadius, nMaxRadius, bIsReverse )
	local nSegments = math.floor(nSectorAngle / 15)
	if nSegments < 10 then
		nSegments = 10
	end
	self:drawSolidSector(tCenter, nArrowAngle, nSectorAngle, nMinRadius, nMaxRadius, nSegments, cc.c4f(0,0,1,0.15))
	self:drawSector(tCenter, nArrowAngle, nSectorAngle, nMinRadius, nMaxRadius, nSegments, cc.c4f(1,0,1,0.8))
	local coef = ((math.pi / 180) * nSectorAngle) / nSegments
	local beginRads = (nArrowAngle - nSectorAngle / 2) * ( (math.pi / 180) )	
	local midRads = beginRads + ((nSegments / 2) * coef)
	local endRads = (nArrowAngle + nSectorAngle / 2) * ( (math.pi / 180) )	
	local tArrowHead = {}
	local oX  = tCenter.x + nMaxRadius * math.cos(midRads)
    local oY  = tCenter.y + nMaxRadius * math.sin(midRads)
    tArrowHead = {x=oX,y=oY}
	self:drawLine( {x=tCenter.x,y=tCenter.y}, {x=oX,y=oY}, cc.c4f( 1, 1, 0, 1 ) )

	local oX  = tCenter.x + (nMaxRadius - 15) * math.cos(midRads + ONE_RADIAN )
    local oY  = tCenter.y + (nMaxRadius - 15) * math.sin(midRads + ONE_RADIAN )
	self:drawLine( {x=tArrowHead.x,y=tArrowHead.y}, {x=oX,y=oY}, cc.c4f( 1, 1, 0, 1 ) )
	local oX  = tCenter.x + (nMaxRadius - 15) * math.cos(midRads - ONE_RADIAN )
    local oY  = tCenter.y + (nMaxRadius - 15) * math.sin(midRads - ONE_RADIAN )
	self:drawLine( {x=tArrowHead.x,y=tArrowHead.y}, {x=oX,y=oY}, cc.c4f( 1, 1, 0, 1 ) )
	if bIsReverse ~= true then
		local nEndX1  = tCenter.x + (80) * math.cos(endRads)
	    local nEndY1  = tCenter.y + (80) * math.sin(endRads)
	    local nEndX2  = tCenter.x + (90) * math.cos(endRads - 20 * ONE_RADIAN )
	    local nEndY2  = tCenter.y + (90) * math.sin(endRads - 20 * ONE_RADIAN )
	    local nEndX3  = tCenter.x + (80) * math.cos(endRads - 20 * ONE_RADIAN )
	    local nEndY3  = tCenter.y + (80) * math.sin(endRads - 20 * ONE_RADIAN )
		self:drawSolidPoly( {{x=nEndX1,y=nEndY1}, {x=nEndX2,y=nEndY2}, {x=nEndX3,y=nEndY3}}, 3, cc.c4f( 0, 1, 0, 1 ) )

		local tLines = {}
		for i = 1, 10 do
			local oX  = tCenter.x + (80) * math.cos(endRads - ONE_RADIAN * 8 * i)
	    	local oY  = tCenter.y + (80) * math.sin(endRads - ONE_RADIAN * 8 * i)
	    	tLines[#tLines+1] = {x = oX, y=oY}
		end
		for i = 1, 9 do
			self:drawLine( {x=tLines[i].x,y=tLines[i].y}, {x=tLines[i+1].x,y=tLines[i+1].y}, cc.c4f( 0, 1, 0, 1 ) )
		end
	else
		local nEndX1  = tCenter.x + (80) * math.cos(beginRads)
	    local nEndY1  = tCenter.y + (80) * math.sin(beginRads)
	    local nEndX2  = tCenter.x + (90) * math.cos(beginRads + 20 * ONE_RADIAN )
	    local nEndY2  = tCenter.y + (90) * math.sin(beginRads + 20 * ONE_RADIAN )
	    local nEndX3  = tCenter.x + (80) * math.cos(beginRads + 20 * ONE_RADIAN )
	    local nEndY3  = tCenter.y + (80) * math.sin(beginRads + 20 * ONE_RADIAN )
		self:drawSolidPoly( {{x=nEndX1,y=nEndY1}, {x=nEndX2,y=nEndY2}, {x=nEndX3,y=nEndY3}}, 3, cc.c4f( 0, 1, 0, 1 ) )

		local tLines = {}
		for i = 1, 10 do
			local oX  = tCenter.x + (80) * math.cos(beginRads + ONE_RADIAN * 8 * i)
	    	local oY  = tCenter.y + (80) * math.sin(beginRads + ONE_RADIAN * 8 * i)
	    	tLines[#tLines+1] = {x = oX, y=oY}
		end
		for i = 1, 9 do
			self:drawLine( {x=tLines[i].x,y=tLines[i].y}, {x=tLines[i+1].x,y=tLines[i+1].y}, cc.c4f( 0, 1, 0, 1 ) )
		end
	end
end


function DrawNode:drawDebugRect( tCenter, nArrowAngle, nWidth, nMinRadius, nMaxRadius, bIsReverse )
	local midRads = nArrowAngle * ONE_RADIAN
	local tArrowHead = {}
	local nOuterCenterX  = tCenter.x + nMaxRadius * math.cos(midRads)
    local nOuterCenterY  = tCenter.y + nMaxRadius * math.sin(midRads)
	local nInneCenterX = tCenter.x + nMinRadius * math.cos(midRads)
	local nInneCenterY = tCenter.y + nMinRadius * math.sin(midRads)
	tArrowHead[1] = {x=nOuterCenterX,y=nOuterCenterY}
	local oX  = tCenter.x + (nMaxRadius - 25) * math.cos(midRads + 2 * ONE_RADIAN )
    local oY  = tCenter.y + (nMaxRadius - 25) * math.sin(midRads + 2 * ONE_RADIAN )
    tArrowHead[2] = {x=oX,y=oY}
	local oX  = tCenter.x + (nMaxRadius - 25) * math.cos(midRads - 2 * ONE_RADIAN )
    local oY  = tCenter.y + (nMaxRadius - 25) * math.sin(midRads - 2 * ONE_RADIAN )
    tArrowHead[3] = {x=oX,y=oY}
    self:drawSolidPoly( tArrowHead, 3, cc.c4f( 1, 1, 0, 1 ) )

	self:drawLine( {x=tCenter.x,y=tCenter.y}, {x=nOuterCenterX,y=nOuterCenterY}, cc.c4f( 1, 1, 0, 1 ) )

	local nHalfWidth = nWidth / 2
	local tVertices = {}
	local nX1 = nOuterCenterX - nHalfWidth * math.sin(midRads)
	local nY1 = nOuterCenterY + nHalfWidth * math.cos(midRads)
	local nX2 = nOuterCenterX + nHalfWidth * math.sin(midRads)
	local nY2 = nOuterCenterY - nHalfWidth * math.cos(midRads)
	tVertices[1] = { x=nX1, y=nY1 }
	tVertices[2] = { x=nX2, y=nY2 }

	local nX1 = nInneCenterX - nHalfWidth * math.sin(midRads)
	local nY1 = nInneCenterY + nHalfWidth * math.cos(midRads)
	local nX2 = nInneCenterX + nHalfWidth * math.sin(midRads)
	local nY2 = nInneCenterY - nHalfWidth * math.cos(midRads)
	tVertices[3] = { x=nX2, y=nY2 }
	tVertices[4] = { x=nX1, y=nY1 }
	local oColor = cc.c4f( 0, 0, 1, 0.2 )
	local tParams = {
		fillColor = oColor,
	    borderWidth  = 0,
	    borderColor  = oColor,
	}
	self:drawPolygon( tVertices, tParams )
	oColor = cc.c4f( 1, 0, 1, 0.5 )
	self:drawPoly( tVertices, #tVertices, true, oColor )
end