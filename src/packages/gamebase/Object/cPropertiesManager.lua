local cPropertiesManager = class( "cPropertiesManager" )

function cPropertiesManager:ctor()
	self.m_tPropertiesConf = {}
end

function cPropertiesManager:GetInstance()
	if _G.__PropertiesConfManager == nil then
		_G.__PropertiesConfManager = cPropertiesManager:create()
	end
	return _G.__PropertiesConfManager
end

function cPropertiesManager:SetGameApp( oGameApp )
	self.m_oGameApp = oGameApp
end

function cPropertiesManager:GetGameApp()
	return self.m_oGameApp
end

function cPropertiesManager:SetPropertieConf( tPropConf )
	self.m_tPropertiesConf = tPropConf
end

function cPropertiesManager:GetPropertieConfByName( sPropConfName )
	local tPropConf = self.m_tPropertiesConf[ sPropConfName ]
	if tPropConf ~= nil then
		return tPropConf
	end
end

function cPropertiesManager:InitObjectByProperty( oGameObject )
	local sObjectType = oGameObject:GetObjectType()
	assert( sObjectType ~= nil )
	local tPropConf = self:GetPropertieConfByName( sObjectType )
	if tPropConf ~= nil then
		local tObjectProperties = {}
		for i, v in ipairs( tPropConf ) do
			if v.Type == "string" then
				tObjectProperties[v.AttriName] = v.DefaultVal
			else
				tObjectProperties[v.AttriName] = tonumber( v.DefaultVal )
			end
		end
		oGameObject:SetProperties( tObjectProperties )
	end
end

function cPropertiesManager:PrintDesc()
	for i, v in pairs( self.m_tPropertiesConf ) do
		_G.CC_LOG( string.format( "%s = {", i ) )
		for i, v in ipairs(v) do
			if v.Type == "string" then
				_G.CC_LOG( string.format( "    {AttriName = '%s', Type = '%s', SYN = '%s',  DefaultVal = '%s', Length = '%s' }", v.AttriName, v.Type, tostring(v.SYN), v.DefaultVal, v.Length ) )
			else
				_G.CC_LOG( string.format( "    {AttriName = '%s', Type = '%s', SYN = '%s',  DefaultVal = '%s' }", v.AttriName, v.Type, tostring(v.SYN), v.DefaultVal ) )
			end
		end
		_G.CC_LOG( "}" )
	end
end

return cPropertiesManager