local cObjectManager = class( "cObjectManager" )

function cObjectManager:ctor()
	self.m_tGameObjects = {}
	self.m_tTypeObjectMap = {}
	self.m_tObjectClassMap = {}
	self.m_nNewObjectId = 100000000
end

function cObjectManager:GetInstance()
	if _G.__ObjectManagerInstance == nil then
		_G.__ObjectManagerInstance = cObjectManager:create()
	end
	return _G.__ObjectManagerInstance
end

function cObjectManager:Reset()
	self.m_tGameObjects = {}
end

function cObjectManager:RemoveObjectByType( sObjectType )
	local tObjectMap = self:GetObjectsByType( sObjectType )
	if tObjectMap ~= nil then
		for i, v in ipairs( tObjectMap ) do
			for idx, oObj in ipairs( self.m_tGameObjects ) do
				if v == oObj then
					table.remove( self.m_tGameObjects, idx )
					break
				end
			end
		end
		self.m_tTypeObjectMap[ sObjectType ] = {}
	end
end

function cObjectManager:RemoveObject( oGameObject )
	local nGameObjectId = oGameObject:GetGameObjectId()
	local sObjectType = oGameObject:GetObjectType()
	if nGameObjectId ~= nil and sObjectType ~= nil and self.m_tGameObjects[ nGameObjectId ] ~= nil then
		local tTypeObjectMap = self.m_tTypeObjectMap[ sObjectType ]
		if tTypeObjectMap ~= nil then
			for i, v in ipairs( tTypeObjectMap ) do
			if v == oObject then
				table.remove( tTypeObjectMap, i )
				break
			end
		end
		end
		for i, v in ipairs( self.m_tGameObjects ) do
			if v == oObject then
				table.remove( self.m_tGameObjects, i )
				break
			end
		end
	end
end

function cObjectManager:RegisterGameObject( oGameObject )
	local nGameObjectId = oGameObject:GetGameObjectId()
	local sObjectType = oGameObject:GetObjectType()
	if nGameObjectId ~= nil and sObjectType ~= nil and self.m_tGameObjects[ nGameObjectId ] == nil then
		self.m_tGameObjects[ nGameObjectId ] = oGameObject
		local tTypeObjectMap = self.m_tTypeObjectMap[ sObjectType ]
		if tTypeObjectMap ~= nil then
			table.insert( tTypeObjectMap, oGameObject )
		end
	end
end

function cObjectManager:GetGameObjectById( nGameObjectId )
	return self.m_tGameObjects[ nGameObjectId ]
end

function cObjectManager:GetObjectsByType( sObjectType )
	return self.m_tTypeObjectMap[ sObjectType ]
end

function cObjectManager:GetAllObjects()
	return self.m_tGameObjects
end

function cObjectManager:GetNewObjectId()
	local nNewObjId = self.m_nNewObjectId
	self.m_nNewObjectId = self.m_nNewObjectId + 1
	return nNewObjId
end

function cObjectManager:RegisterObjectClass( sType, cObjClass )
	self.m_tObjectClassMap[ sType ]  = cObjClass
	if self.m_tTypeObjectMap[sType] == nil then
		self.m_tTypeObjectMap[sType] = {}
	end
end

function cObjectManager:CreateObjectByType( sType, tConf )
	local CObjectClass = self.m_tObjectClassMap[ sType ]
	if CObjectClass ~= nil then
		local oGameObject = CObjectClass:create()
		if oGameObject ~= nil then
			oGameObject:SetGameObjectId( self:GetNewObjectId() )
			oGameObject:SetObjectType( sType )
			tConf = tConf or {}
			oGameObject:InitByConfig( tConf )
			self:RegisterGameObject( oGameObject )
			oGameObject:ClearAllContainers()
			oGameObject:OnInitContainers()	
			return oGameObject
		end
	end
end

function cObjectManager:Update( nTimeDelta )
	local tNeedDeleteObjects = {}
	for i, v in pairs( self.m_tGameObjects ) do
		if v.m_bNeedDelete ~= true then
			if v.DefaultUpdate ~= nil then
				v:DefaultUpdate( nTimeDelta )
			end
			if v.Update ~= nil then
				v:Update( nTimeDelta )
			end
		else
			table.insert( tNeedDeleteObjects, v )
		end
	end
	--需要被删除的对象
	for i, v in ipairs( tNeedDeleteObjects ) do
		self:RemoveObject( v )
	end
end

return cObjectManager