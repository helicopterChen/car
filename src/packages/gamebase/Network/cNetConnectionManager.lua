local cNetConnectionManager = class( "cNetConnectionManager" )
local cNetConnection = import( ".cNetConnection" )
local cNetFakeConnection = import( ".cNetFakeConnection" )
local cNetConnection = import( ".cNetConnection" )

function cNetConnectionManager:ctor()
	self.m_tConnections = {}
	self.m_tNameConnMap = {}
end

function cNetConnectionManager:Reset()
	for i, v in pairs( self.m_tNameConnMap ) do
		self:DisConnectByName( i )
	end
	self.m_tConnections = {}
	self.m_tNameConnMap = {}
end

function cNetConnectionManager:GetInstance()
	if _G.__NetConnectionManager == nil then
		_G.__NetConnectionManager = cNetConnectionManager:create()
	end
	return _G.__NetConnectionManager
end

function cNetConnectionManager:CreatePacket( nOpcode, sData, nLength )
	if sData == nil then
		return cNetConnection:create( cNetConnection.TYPE_WRITE, nOpcode )
	else
		return cNetConnection:create( cNetConnection.TYPE_READ, nOpcode, sData, nLength )
	end
end

function cNetConnectionManager:CreateConnection( sName, sIpAddress, nPort, bFake )
	bFake = bFake or false
	if self.m_tNameConnMap[ sName ] ~= nil then
		return self:GetConnectionByName( sName ), false
	end
	local oConnection = nil
	if bFake == false then
		oConnection = cNetConnection:create( sIpAddress, nPort )
	else
		oConnection = cNetFakeConnection:create( sIpAddress, nPort )
	end
	if oConnection ~= nil then
		oConnection:BindHandler(cNetConnectionManager.NetEventsHandler,1)
		oConnection:BindHandler(cNetConnectionManager.NetMessageHandler,2)
	end
	if oConnection ~= nil then
		table.insert( self.m_tConnections, oConnection )
		self.m_tNameConnMap[ sName ] = { Name = sName, IpAddress = sIpAddress, Port = nPort, Connection = oConnection }
		return oConnection, false
	end
	return nil, false
end

function cNetConnectionManager:GetConnection( sIpAddress, nPort )
	for i, v in pairs( self.m_tNameConnMap ) do
		if v.IpAddress == sIpAddress and v.Port == nPort then
			return v.Connection
		end
	end
end

function cNetConnectionManager:GetConnectionByName( sName )
	local tConf = self.m_tNameConnMap[ sName ]
	if tConf ~= nil then
		return tConf.Connection
	end
end

function cNetConnectionManager:DisConnectByName( sName )
	local oConnection = self:GetConnectionByName( sName )
	if oConnection ~= nil then
		oConnection:DisConnect()
	end
end

function cNetConnectionManager:ReConnectByName( sName )
	local oConnection = self:GetConnectionByName( sName )
	if oConnection ~= nil then
		return oConnection:DoConnect()
	end
end

function cNetConnectionManager:Update( nTimeDelta )
	if self.m_tConnections ~= nil then
		for i, v in pairs( self.m_tConnections ) do
			v:Update( nTimeDelta )
		end
	end
end

function cNetConnectionManager.NetEventsHandler( nFlag, sErr )
	local oNetConnectionManager = cNetConnectionManager:GetInstance()
	if oNetConnectionManager == nil then
		return
	end
	--这里，暂时默认处理只有一个连接的情况
	if #oNetConnectionManager.m_tConnections ~= 1 then
		return
	end
	local oConnection = oNetConnectionManager.m_tConnections[1]
	if oConnection == nil then
		return
	end
	oConnection:SetConnected( (nFlag == 1) )
	oConnection:RecvEventPacket( nFlag, sErr )
end

function cNetConnectionManager.NetMessageHandler( nOpcode, sData, nLength )
	local oNetConnectionManager = cNetConnectionManager:GetInstance()
	if oNetConnectionManager == nil then
		return
	end
	if #oNetConnectionManager.m_tConnections ~= 1 then
		return
	end
	local oConnection = oNetConnectionManager.m_tConnections[1]
	if oConnection == nil then
		return
	end
	local oPacket = oNetConnectionManager:CreatePacket( nOpcode, sData, nLength )
	if oPacket == nil then
		return
	end
	oConnection:RecvMessagePacket( oPacket )
end

return cNetConnectionManager