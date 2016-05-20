local cObjectContainer = class( "cObjectContainer" )

function cObjectContainer:ctor( nMaxSize )
	self.m_tObjects = {}
	assert( nMaxSize == nil or (nMaxSize) > 0 )
	self.m_nMaxSize = nMaxSize or -1
	self.m_oOwner = nil
	self.m_sName = ""
	self.m_sClassType = "Unknown"
end

function cObjectContainer:GetAllObjects()
	return self.m_tObjects
end

function cObjectContainer:GetObjectsByKey( sKeyAttri, val )
	local tObjects = {}
	for i, v in ipairs( self.m_tObjects ) do
		local tProperties = v:GetProperties()
		if tProperties ~= nil then
			if tProperties[sKeyAttri] == val then
				table.insert( tObjects, v )
			end
		end
	end
	return tObjects
end

function cObjectContainer:SetOwner( oOwner )
	self.m_oOwner = oOwner
end

function cObjectContainer:GetOwner()
	return self.m_oOwner
end

function cObjectContainer:SetName( sName )
	self.m_sName = sName
end

function cObjectContainer:GetName()
	return self.m_sName
end

function cObjectContainer:SetClassType( sClassType )
	self.m_sClassType = sClassType
end

function cObjectContainer:GetClassType()
	return self.m_sClassType
end

function cObjectContainer:AddObjectToContainer( oObject )
	if self.m_nMaxSize ~= -1 then	--数量限制.
		local nObjectNum = self:GetCurObjectNum()
		assert( nObjectNum ~= nil )
		if self.m_nMaxSize == nObjectNum then
			return false
		end
	end
	if self:OnCheckAddObject( oObject ) == true then
		table.insert( self.m_tObjects, oObject )
		self.OnAddObjectToContainer( oObject )
		return true
	end
end

function cObjectContainer:OnCheckAddObject( oObject )
	return true
end

function cObjectContainer:OnAddObjectToContainer( oObject )
end

function cObjectContainer:OnCheckRemoveObject( oObject )
	return true
end

function cObjectContainer:OnRemoveObjectFromContainer( oObject )
end

function cObjectContainer:DestoryContainer()
	self:OnDestoryContainer()
end

function cObjectContainer:OnDestoryContainer()
end

function cObjectContainer:RemoveObjectFromContainer( oObject )
	if self:OnCheckRemoveObject( oObject ) == true then
		for i, v in ipairs( self.m_tObjects ) do
			if v == oObject then
				table.remove( self.m_tObjects, i )
				break
			end
		end
		self:OnRemoveObjectFromContainer( oObject )
	end 
end

function cObjectContainer:RemoveAllObjects()
	local tObjects = {}
	local tAllObj = self:GetAllObjects()
	if tAllObj ~= nil then
		for i, v in ipairs( tAllObj ) do
			table.insert( tObjects, v )
		end
	end
	for i, v in ipairs( tObjects ) do
		self:RemoveObjectFromContainer( v )
	end
	self.m_tObjects = {}
end

function cObjectContainer:GetMaxSize()
	return self.m_nMaxSize
end

function cObjectContainer:GetCurObjectNum()
	return #self.m_tObjects
end

function cObjectContainer:PrintDesc()
	_G.CC_LOG( string.format( "*******[Name=%s(%s)] Size=%s/%s**************************", self:GetName(),self:GetClassType(),self:GetCurObjectNum(),self:GetMaxSize()) )
	for i, v in ipairs( self.m_tObjects ) do
		v:PrintDesc() 
	end
	_G.CC_LOG( "***************************************************************************" )
end

function cObjectContainer:Print()
	print( string.format( "*******[Name=%s(%s)] Size=%s/%s**************************", self:GetName(),self:GetClassType(),self:GetCurObjectNum(),self:GetMaxSize()) )
	for i, v in ipairs( self.m_tObjects ) do
		v:Print() 
	end
	print( "***************************************************************************" )
end

if _G.TObjectContainerClassMap == nil then
	_G.TObjectContainerClassMap = {}
end

_G.TObjectContainerClassMap["cObjectContainer"] = cObjectContainer

return cObjectContainer