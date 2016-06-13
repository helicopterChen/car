local cGameObject = class( "cGameObject" )
local cDataTableEx = import( "..CommonUtility.cDataTableEx" )
local cPropertiesManager = import( ".cPropertiesManager" )

function cGameObject:ctor()
	self.m_tProperties = {}
	self.m_tDirtyFlag = cDataTableEx:create()
	self.m_nGameObjectId = 0
	self.m_tContainers = {}
	self.m_sObjectType = "UNKNOWN"
	self.m_bNeedDelete = false
end

function cGameObject:OnInit()
end

function cGameObject:SetGameObjectId( nGameObjectId )
	self.m_nGameObjectId = nGameObjectId
end

function cGameObject:GetObjectType()
	return self.m_sObjectType
end

function cGameObject:SetNeedDelete()
	self.m_bNeedDelete = true
end

function cGameObject:IsNeedDelete()
	return self.m_bNeedDelete
end

function cGameObject:SetObjectType( sObjectType )
	self.m_sObjectType = sObjectType
	self:InitPropertiesByType()
end

function cGameObject:GetGameObjectId()
	return self.m_nGameObjectId
end

function cGameObject:SetProperties( tProperties )
	self.m_tProperties = tProperties
	for i, v in pairs( self.m_tProperties ) do
		self.m_tDirtyFlag[i] = { OldVal = v, CurVal = v }
	end
	self.m_tDirtyFlag:ResetDirty()
end

function cGameObject:GetPropertieConf()
	local oPropertiesManager =  cPropertiesManager:GetInstance()
	if oPropertiesManager ~= nil then
		return oPropertiesManager:GetPropertieConfByName( self:GetObjectType() )
	end
end

function cGameObject:GetPropertieConfByAttriName( sAttriName )
	local tPropConf = self:GetPropertieConf()
	if tPropConf ~= nil then
		for i, v in ipairs( tPropConf ) do
			if v.AttriName == sAttriName then
				return v
			end
		end
	end
end

function cGameObject:GetProperties()
	return self.m_tProperties
end

function cGameObject:GetPropertyVal( sPropName )
	return self.m_tProperties[ sPropName ]
end

function cGameObject:SetPropertyVal( sPropName, val )
	local tAttriConf = self:GetPropertieConfByAttriName( sPropName )
	local oldVal = self.m_tProperties[ sPropName ]
	if tAttriConf ~= nil and oldVal ~= nil then
		if tAttriConf.Type == "string" then
			self.m_tProperties[ sPropName ] = val or tAttriConf.DefaultVal
		elseif tAttriConf.Type == "boolean" then
			if type(val) == "boolean" then
				self.m_tProperties[ sPropName ] = val
			else
				if v.DefaultVal == "true" then
					self.m_tProperties[sPropName] = true
					val = true
				else
					self.m_tProperties[sPropName] = false
					val = false
				end
			end
		else
			if tAttriConf.Round == "Up" then
				self.m_tProperties[ sPropName ] = math.ceil(tonumber(val) or tonumber(tAttriConf.DefaultVal))
			elseif tAttriConf.Round == "Down" then
				self.m_tProperties[ sPropName ] = math.floor(tonumber(val) or tonumber(tAttriConf.DefaultVal))
			else
				self.m_tProperties[ sPropName ] = tonumber(val) or tonumber(tAttriConf.DefaultVal)
			end
		end
		if oldVal ~= val then
			self.m_tDirtyFlag[sPropName] = { OldVal = oldVal, CurVal = val}
		end
	end
end

function cGameObject:InitPropertiesByType()
	local oPropertiesManager =  cPropertiesManager:GetInstance()
	if oPropertiesManager ~= nil then
		oPropertiesManager:InitObjectByProperty( self )
	end
end

function cGameObject:ClearAllContainers()
	local tNeedDeleteContainers = {}
	for i, v in pairs( self.m_tContainers ) do
		table.insert( tNeedDeleteContainers, i )
	end
	for i, v in ipairs( tNeedDeleteContainers ) do
		self:DestoryContainer( v )
	end
	self.m_tContainers = {}
end

function cGameObject:CreateContainerByType( sName, nMaxSize, sType )
	sType = sType or "CObjectContainer"
	if self.m_tContainers[sName] == nil then
		local CContainerCreateClass = _G.TObjectContainerClassMap[ sType ]
		if CContainerCreateClass ~= nil then
			local oContainer = CContainerCreateClass:create( nMaxSize )
			if oContainer ~= nil then
				oContainer:SetClassType( sType )
				oContainer:SetOwner( self )
				oContainer:SetName( sName )
				self.m_tContainers[sName] = oContainer
			end
		end
	end
end

function cGameObject:GetContainerByName( sName )
	return self.m_tContainers[ sName ]
end

function cGameObject:GetAllContainers()
	return self.m_tContainers
end

function cGameObject:DestoryContainerByName( sName )
	local oContainer = self:GetContainerByName( sName )
	if oContainer ~= nil then
		oContainer:DestoryContainer()
		self.m_tContainers[sName] = nil
	end
end

function cGameObject:SetPropertiesByConfig( tConfigData )
	if tConfigData ~= nil then
		local tPropertieConf = self:GetPropertieConf()
		if tPropertieConf ~= nil then
			for i, v in ipairs( tPropertieConf ) do
				local sAttriName = v.AttriName
				local oldVal = self.m_tProperties[sAttriName]
				if tConfigData[sAttriName] ~= nil then
					local newVal = nil
					if v.Type == "string" then
						newVal = tConfigData[sAttriName] or v.DefaultVal
					elseif v.Type == "boolean" then
						if type(tConfigData[sAttriName]) == "boolean" then
							newVal = tConfigData[sAttriName]
						else
							if v.DefaultVal == "true" then
								newVal = true
							else
								newVal = false
							end
						end	
					elseif v.Type ~= "string" then
						if v.Round == "Up" then
							newVal = math.ceil( tConfigData[sAttriName] or tonumber(v.DefaultVal) )
						elseif v.Round == "Down" then
							newVal = math.floor( tConfigData[sAttriName] or tonumber(v.DefaultVal) )
						else
							newVal = tConfigData[sAttriName] or tonumber(v.DefaultVal)
						end
					end
					self.m_tProperties[sAttriName] = newVal
					if oldVal ~= newVal then
						self.m_tDirtyFlag[sAttriName] = { OldVal = oldVal, CurVal = newVal}
					end
				end
			end
		end
	end
end

function cGameObject:OnReadProperties()
end

function cGameObject:ReadPropertiesFromPacket( oPacket )
	local tPropertieConf = self:GetPropertieConf()
	if tPropertieConf ~= nil then
		for i, v in ipairs( tPropertieConf ) do
			if v.SYN == true then --ÐèÒª½øÐÐÍ¬²½µÄÊôÐÔ²Å»á½øÐÐ¶ÁÈ¡
				if v.Type ~= "string" then
					if v.Round == "Up" then
						self.m_tProperties[ v.AttriName ] = math.ceil(oPacket:ReadByFormat( v.Type ) or tonumber(v.DefaultVal))
					elseif v.Round == "Down" then
						self.m_tProperties[ v.AttriName ] = math.floor(oPacket:ReadByFormat( v.Type ) or tonumber(v.DefaultVal))
					else
						self.m_tProperties[ v.AttriName ] = oPacket:ReadByFormat( v.Type ) or tonumber(v.DefaultVal)
					end
				elseif v.Type == "string" then
					assert( v.Length ~= nil and v.Length > 0 )
					self.m_tProperties[ v.AttriName ] = oPacket:ReadFixedLenString( v.Length ) or v.DefaultVal
				end
			end
		end
	end
	self:OnReadProperties()
end

function cGameObject:WritePropertiesToPacket( oPacket )
	local tPropertieConf = self:GetPropertieConf()
	if tPropertieConf ~= nil then
		for i, v in ipairs( tPropertieConf ) do
			if v.SYN == true then
				if v.Type == "string" then
					oPacket:WriteFixedLenString( v.Length, self.m_tProperties[v.AttriName] or tostring(v.DefaultVal) )
				elseif v.Type ~= "string" then
					oPacket:WriteByFormat( v.Type, self.m_tProperties[v.AttriName] or tonumber(v.DefaultVal) )
				end 
			end
		end
	end
end

function cGameObject:CopyProperties( oObject )
	local tProperties = oObject:GetProperties()
	if tProperties ~= nil then
		self:SetPropertiesByConfig( tProperties )
	end
end

function cGameObject:PrintDesc()
	_G.CC_LOG( string.format( "======GameObject [%s] [%s]======", self:GetObjectType(), self:GetGameObjectId()) )
	for i, v in pairs( self.m_tProperties ) do
		if type(v) == 'string' then
			_G.CC_LOG( string.format( "%s='%s'", i, v ) )
		else
			_G.CC_LOG( string.format( "%s=%s", i, v ) )
		end
	end
	_G.CC_LOG( "---------Containers-----------" )
	for i, v in pairs( self.m_tContainers ) do
		v:PrintDesc()
	end
	_G.CC_LOG( "=================================" )
end

function cGameObject:Print()
	_G.CC_LOG( string.format( "======GameObject [%s] [%s]======", self:GetObjectType(), self:GetGameObjectId()) )
	for i, v in pairs( self.m_tProperties ) do
		if type(v) == 'string' then
			print( string.format( "%s='%s'", i, v ) )
		else
			print( string.format( "%s=%s", i, v ) )
		end
	end
	_G.CC_LOG( "---------Containers-----------" )
	for i, v in pairs( self.m_tContainers ) do
		v:Print()
	end
	_G.CC_LOG( "=================================" )
end

function cGameObject:Update()
end

function cGameObject:DefaultUpdate()
	if self.OnPropertiesChanged ~= nil and self.m_tDirtyFlag:IsDirty() == true then
		self:OnPropertiesChanged( self.m_tDirtyFlag:GetData() )
		for i, v in pairs( self.m_tProperties ) do
			self.m_tDirtyFlag[i] = {OldVal=v,CurVal=v}
		end
		self.m_tDirtyFlag:ResetDirty()
	end
end

return cGameObject