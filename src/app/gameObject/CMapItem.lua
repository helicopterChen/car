local CWorldObject = import( ".CWorldObject" )
local CMapItem = class( "CMapItem", CWorldObject  )
_G.GAME_BASE.cObjectManager:GetInstance():RegisterObjectClass( "CMapItem", CMapItem )

function CMapItem:OnInitContainers()
end

function CMapItem:OnInitOk()
    self:UpdateView()
    self:UpdateEffectRegion()
    self:UpdateDebugView()
end

function CMapItem:UpdateDebugView()
	if self.m_oDebugDrawNode ~= nil then
		self.m_oDebugDrawNode:clear()
		local nType = self:GetPropertyVal( "Type" )
		if nType == 1 then
			self.m_oDebugDrawNode:drawRect( cc.p(-42,-172), cc.p(42,172), cc.c4f(1,0,0,0.5) )
			self.m_oDebugDrawNode:drawSolidRect( cc.p(-42,-172), cc.p(42,172), cc.c4f(1,0,0,0.15) )
		elseif nType == 2 then
			self.m_oDebugDrawNode:drawRect( cc.p(-40,-40), cc.p(40,40), cc.c4f(1,0,0,0.5) )
			self.m_oDebugDrawNode:drawSolidRect( cc.p(-40,-40), cc.p(40,40), cc.c4f(1,0,0,0.15) )
		elseif nType == 3 then
			self.m_oDebugDrawNode:drawRect( cc.p(-140,-70), cc.p(140,70), cc.c4f(1,0,0,0.5) )
			self.m_oDebugDrawNode:drawSolidRect( cc.p(-140,-70), cc.p(140,70), cc.c4f(1,0,0,0.15) )
		elseif nType == 4 then
			self.m_oDebugDrawNode:drawRect( cc.p(-30,-30), cc.p(30,30), cc.c4f(1,0,0,0.5) )
			self.m_oDebugDrawNode:drawSolidRect( cc.p(-30,-30), cc.p(30,30), cc.c4f(1,0,0,0.15) )
		end
	end
end

function CMapItem:UpdateEffectRegion()
end

return CMapItem