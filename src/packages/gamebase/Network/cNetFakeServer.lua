--[[
	客户端假的Server
--]]
local cNetFakeServer = class("cNetFakeServer")

function cNetFakeServer:ctor( sIpAddress, nPort )
	self.m_sIpAddress = sIpAddress
	self.m_nPort = nPort
	self.m_bIsRunning = false
	self.m_tConnections = {}
	self.m_tNetEventsNeedSend = {}
	self.m_tNetMessageNeedSend = {}
	self.m_tNetMessageHandlers = {}
end

function cNetFakeServer:Run()
	self.m_bIsRunning = true
end

function cNetFakeServer:Init()
end

function cNetFakeServer:IsRunning()
	return self.m_bIsRunning
end

function cNetFakeServer:ShutDown()
	self.m_bIsRunning = false
	self.m_tConnections = {}
	self.m_tNetEventsNeedSend = {}
	self.m_tNetMessageNeedSend = {}
	self.m_tNetMessageHandlers = {}
end

function cNetFakeServer:RecvConnect( oFakeConnection )
	local bFoundConnection = false
	for i, v in ipairs(self.m_tConnections) do
		if v:GetIpAddress() == oFakeConnection:GetIpAddress() and v:GetPort() == oFakeConnection:GetPort() then
			bFoundConnection = true
			break
		end
	end
	if bFoundConnection == false then
		table.insert( self.m_tConnections, oFakeConnection )
	end
	oFakeConnection:SetFakeServer( self )
	--发送链接成功的网络事件消息
	local oNetFakeServerManager = _G.m_oNetFakeServerManager
	if oNetFakeServerManager ~= nil then
		self:SendNetEvent( oFakeConnection, 1, "Connect Ok" )
	end
	self:OnRecvConnect( oFakeConnection )
	return true
end

function cNetFakeServer:RecvDisConnect( oFakeConnection )
	for i, v in ipairs( self.m_tConnections ) do
		if v:GetIpAddress() == oFakeConnection:GetIpAddress() and v:GetPort() == oFakeConnection:GetPort() then
			self:OnRecvDisConnect( oFakeConnection )
			table.remove( self.m_tConnections, i )
			break
		end
	end
end

function cNetFakeServer:RecvNetMessage( oFakeConnection, nOpCode, sData, nDataLength )
	_G.CC_LOG( string.format( "[□Recv] opcode = %s lengh=%s [%s]", nOpCode, nDataLength, (_G.CSEventNameMap[nOpCode] or "") ) )
	local oNetFakeServerManager = _G.m_oNetFakeServerManager
	local pHandler = self.m_tNetMessageHandlers[ nOpCode ]
	if pHandler ~= nil and oNetFakeServerManager ~= nil then
		local oPacket = oNetFakeServerManager:CreatePacket( nOpcode, sData, nDataLength )
		if oPacket ~= nil then
			pHandler( self, oFakeConnection, oPacket )
			--如果是收到GM命令就马上进行存储，如果不是，就标志为需要进行数据保存,延后存储
			self:OnSaveData( (nOpCode == _G.CSEventEnum.CS_GM_MESSAGE ) )
		end
	end
end

function cNetFakeServer:CreatePacket( nOpcode, sData, nDataLength )
	local oNetFakeServerManager = _G.m_oNetFakeServerManager
	if oNetFakeServerManager ~= nil then
		return oNetFakeServerManager:CreatePacket( nOpcode, sData, nDataLength )
	end
end

function cNetFakeServer:SendNetMessage( oFakeConnection, oSendPacket )
	if oFakeConnection ~= nil then
		table.insert( self.m_tNetMessageNeedSend, { Connection = oFakeConnection, SendPacket = oSendPacket } )
	end
end

function cNetFakeServer:SendNetEvent( oFakeConnection, nOpCode, sErr )
	table.insert( self.m_tNetEventsNeedSend, { Connection = oFakeConnection, OpCode = nOpCode, Err = sErr } )
end

function cNetFakeServer:RegisterEventHandler( nOpCode, pHandler )
	assert( nOpCode ~= nil and type( nOpCode ) == 'number' and pHandler ~= nil and type(pHandler) == 'function' )
	_G.CC_LOG( string.format( "RegisterEventHandler nOpCode =%s", nOpCode ) )
	self.m_tNetMessageHandlers[nOpCode] = pHandler
end

function cNetFakeServer:Update( nTimeDelta )
	if self.m_bIsRunning == true then
		--这里真正的进行send
		for i, v in ipairs( self.m_tNetEventsNeedSend ) do
			local oFakeConnection = v.Connection
			local nOpCode = v.OpCode
			local sErr = v.Err
			if oFakeConnection ~= nil and nOpCode ~= nil and sErr ~= nil then
				local pHandler = oFakeConnection:GetHandlerByType( 1 )
				if pHandler ~= nil then
					pHandler( nOpCode, sErr )
				end
			end
		end
		for i, v in ipairs( self.m_tNetMessageNeedSend ) do
			local oFakeConnection = v.Connection
			local oPacket = v.SendPacket
			if oFakeConnection ~= nil and oPacket ~= nil then
				local pHandler = oFakeConnection:GetHandlerByType( 2 )
				if pHandler ~= nil then
					local nOpCode = oPacket:GetOpCode()
					_G.CC_LOG( string.format( "[□Send] opcode = %s lengh=%s [%s]", nOpCode, string.len( oPacket:GetData()), (_G.SCEventNameMap[nOpCode] or "") ) )
					pHandler( oPacket:GetOpCode(), oPacket:GetData(), string.len( oPacket:GetData()) )
				end
			end
		end
		self.m_tNetEventsNeedSend = {}
		self.m_tNetMessageNeedSend = {}
		self:OnUpdate( nTimeDelta )
	end
end

return cNetFakeServer