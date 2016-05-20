
local cNetConnection = class( "cNetConnection" )
local cDataQueue = import( "..CommonUtility.cDataQueue" )
local cNetMsgPacket = import(".cNetMsgPacket")

function cNetConnection:ctor( sIpAddress, nPort )
	self.m_oSocket = xmjsocket.appSocket:new()
	self.m_oSocket:startup()
	self.m_oRecvEventQueue 	 = cDataQueue:create()
	self.m_oRecvMessageQueue = cDataQueue:create()
	self.m_oSendMessageQueue = cDataQueue:create()
	self.m_sIpAddress = sIpAddress
	self.m_nPort = nPort
	self.m_bConnected = false
end

function cNetConnection:IsConnected()
	return self.m_bConnected
end

function cNetConnection:SetConnected( bConnectOk )
	self.m_bConnected = bConnectOk
end

function cNetConnection:GetIpAddress()
	return self.m_sIpAddress
end

function cNetConnection:GetPort()
	return self.m_nPort
end

function cNetConnection:IsFake()
	return false
end

function cNetConnection:DoConnect()
	return self.m_oSocket:connect( self.m_nPort, self.m_sIpAddress )
end

function cNetConnection:DisConnect()
	self.m_oSocket:destroy()
	self.m_bConnected = false
end

function cNetConnection:Update( nTimeDelta )
	self.m_oSocket:refresh()
	if self.m_bConnected == true then
		self.m_oSocket:receive()
	end
	local tEventPacket = self.m_oRecvEventQueue:OutQueue()
	while (tEventPacket ~= nil) do
		local nOpCode = tEventPacket[1]
		local sErr = tEventPacket[2]
		if nOpCode ~= nil then
			local pHandler = _G.T_EVENTS_HANDLERS
			if pHandler ~= nil then
				pHandler( nOpCode, sErr )
			end
		end
		tEventPacket = self.m_oRecvEventQueue:OutQueue()
	end
	local oRecvPacket = self.m_oRecvMessageQueue:OutQueue()
	while (oRecvPacket ~= nil) do
		local nOpCode = oRecvPacket:GetOpCode()
		local sData = oRecvPacket:GetData()
		local nDataLength = string.len(oRecvPacket:GetData())
		if nOpCode ~= nil and sData ~= nil and nDataLength ~= nil and _G.T_MESSAGE_HANDLERS ~= nil then
			local pHandler = _G.T_MESSAGE_HANDLERS[ nOpCode ]
			if pHandler ~= nil then
				local oConnectionManager = _G.m_oNetConnectionManager
				if oConnectionManager ~= nil then
					local oPacket = oConnectionManager:CreatePacket( nOpCode, sData, nDataLength )
					if oPacket ~= nil then
						pHandler( oPacket, self )
					end
				end
			else
				_G.CC_LOG( string.format( "[●Error] No handler opcode = %s [%s]", nOpCode, (_G.SCEventNameMap[nOpCode] or "") ) )
			end
		end
		oRecvPacket = self.m_oRecvMessageQueue:OutQueue()
	end
	local oSendPacket= self.m_oSendMessageQueue:OutQueue()
	while (oSendPacket ~= nil) do
		self.m_oSocket:sending( oSendPacket:GetOpCode(), oSendPacket:GetData(), string.len(oSendPacket:GetData()) )
		oSendPacket = self.m_oSendMessageQueue:OutQueue()
	end
end

function cNetConnection:BindHandler( pHandler, nType )
	self.m_oSocket:bindHandler( pHandler, nType )
end

function cNetConnection:CreatePacket( nOpCode, sData, nDataLength )
	local oNetConnectionManager = _G.m_oNetConnectionManager
end

function cNetConnection:SendPacket( oPacket )
	assert( oPacket ~= nil and (oPacket:GetType() == CNetMsgPacket.TYPE_WRITE) )
	local nOpCode = oPacket:GetOpCode()
	_G.CC_LOG( string.format( "[●Send]: opcode = %s length = %s [%s]", nOpCode, string.len(oPacket:GetData()), (_G.CSEventNameMap[nOpCode] or "") ) )
	self.m_oSendMessageQueue:InQueue( oPacket )
end

function cNetConnection:RecvEventPacket( nOpCode, sErr )
	_G.CC_LOG( string.format( "[●Recv Event]: opcode =%s, err=%s", nOpCode, sErr ) )
	self.m_oRecvEventQueue:InQueue( { nOpCode, sErr } )
end

function cNetConnection:RecvMessagePacket( oPacket )
	assert( oPacket ~= nil and (oPacket:GetType() == CNetMsgPacket.TYPE_READ) )
	local nOpCode = oPacket:GetOpCode()
	_G.CC_LOG( string.format( "[●Recv]: opcode =%s, length=%s [%s]", nOpCode, string.len(oPacket:GetData()), (cNetConnectionSCEventNameMap[nOpCode] or "") ) )
	self.m_oRecvMessageQueue:InQueue( oPacket )
end

return cNetConnection