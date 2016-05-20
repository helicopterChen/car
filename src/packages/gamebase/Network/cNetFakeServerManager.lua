--[[
	客户端假的Server管理器
--]]
local cNetMsgPacket = import( ".cNetMsgPacket" )
local cNetFakeServerManager = class("cNetFakeServerManager")

function cNetFakeServerManager:ctor()
	self.m_tServers = {}
	self.m_tNameServerMap = {}
end

function cNetFakeServerManager:Reset()
	self.m_tServers = {}
	self.m_tNameServerMap = {}
end

function cNetFakeServerManager:SetGameApp( oGameApp )
	self.m_oGameApp = oGameApp
end

function cNetFakeServerManager:GetGameApp()
	return self.m_oGameApp
end

function cNetFakeServerManager:GetInstance()
	if _G.__NetFakeServerManager == nil then
		_G.__NetFakeServerManager = cNetFakeServerManager:create()
	end
	return _G.__NetFakeServerManager
end

function cNetFakeServerManager:CreatePacket( nOpcode, sData, nLength )
	if sData == nil then
		return cNetMsgPacket:create( cNetMsgPacket.TYPE_WRITE, nOpcode )
	else
		return cNetMsgPacket:create( cNetMsgPacket.TYPE_READ, nOpcode, sData, nLength )
	end
end

function cNetFakeServerManager:CreateServer( sName, sIpAddress, nPort, cCreateClass )
	if self.m_tNameServerMap[ sName ] ~= nil then
		return self:GetServerByName( sName ), false
	end	
	local oServer = nil
	if cCreateClass == nil then
		oServer = CNetFakeServer:create( sIpAddress, nPort )
	elseif cCreateClass ~= nil then
		oServer = cCreateClass:create( sIpAddress, nPort )
	end
	if oServer ~= nil then
		table.insert( self.m_tServers, oServer )
		self.m_tNameServerMap[ sName ] = { Name = sName, IpAddress = sIpAddress, Port = nPort, Server = oServer }
		return oServer, true
	end
	return nil, false
end


function cNetFakeServerManager:GetServer( sIpAddress, nPort )
	for i, v in pairs( self.m_tNameServerMap ) do
		if v.IpAddress == sIpAddress and v.Port == nPort then
			return v.Server
		end
	end
end

function cNetFakeServerManager:GetServerByName( sName )
	local tConf = self.m_tNameServerMap[ sName ]
	if tConf ~= nil then
		return tConf.Server
	end
end

function cNetFakeServerManager:DisConnectByName( sName )
	local oServer = self:GetServerByName( sName )
	if oServer ~= nil then
		oServer:DisConnect()
	end
end

function cNetFakeServerManager:ReConnectByName( sName )
	local oServer = self:GetServerByName( sName )
	if oServer ~= nil then
		return oServer:DoConnect()
	end
end

function cNetFakeServerManager:RecvDoConnectRequest( oFakeConnection )
	assert( oFakeConnection ~= nil )
	local oServer = self:GetServer( oFakeConnection:GetIpAddress(), oFakeConnection:GetPort() )
	if oServer ~= nil and oServer:IsRunning() == true then
		return oServer:RecvConnect( oFakeConnection )
	end
end

function cNetFakeServerManager:RecvDisConnectRequest( oFakeConnection )
	assert( oFakeConnection ~= nil )
	local oServer = self:GetServer( oFakeConnection:GetIpAddress(), oFakeConnection:GetPort() )
	if oServer ~= nil and oServer:IsRunning() == true then
		return oServer:RecvDisConnect( oFakeConnection )
	end
end

function cNetFakeServerManager:Update( nTimeDelta )
	if self.m_tServers ~= nil then
		for i, v in pairs( self.m_tServers ) do
			v:Update( nTimeDelta )
		end
	end
end

return cNetFakeServerManager