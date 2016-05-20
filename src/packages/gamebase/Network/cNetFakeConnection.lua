local cNetFakeConnection = class( "cNetFakeConnection" )
local cNetMsgPacket = import(".cNetMsgPacket")
local cDataQueue = import( "..CommonUtility.cDataQueue" )

function cNetFakeConnection:ctor( sIpAddress, nPort )
	self.m_sIpAddress = sIpAddress
	self.m_nPort = nPort
	self.m_bConnected = false
	self.m_oFakeServer = nil
	self.m_oRecvEventQueue 	 = cDataQueue:create()
	self.m_oRecvMessageQueue = cDataQueue:create()
	self.m_oSendMessageQueue = cDataQueue:create()
	self.m_tHandler = {}
end

function cNetFakeConnection:IsConnected()
	return self.m_bConnected
end

function cNetFakeConnection:SetConnected( bConnectOk )
	self.m_bConnected = bConnectOk
end

function cNetFakeConnection:GetIpAddress()
	return self.m_sIpAddress
end

function cNetFakeConnection:GetPort()
	return self.m_nPort
end

function cNetFakeConnection:IsFake()
	return true
end

function cNetFakeConnection:SetFakeServer( oFakeServer )
	self.m_oFakeServer = oFakeServer
end

function cNetFakeConnection:GetFakeServer()
	return self.m_oFakeServer
end

function cNetFakeConnection:DoConnect()
	local oFakeServerManager = _G.m_oNetFakeServerManager
	if oFakeServerManager == nil then
		return
	end
	return oFakeServerManager:RecvDoConnectRequest( self )
end

function cNetFakeConnection:DisConnect()
	--如果server有这个连接，则请求断开
	local oFakeServerManager = _G.m_oNetFakeServerManager
	if oFakeServerManager == nil then
		return
	end
	oFakeServerManager:RecvDisConnectRequest( self )
	self.m_sAccount = ""
	self.m_sPassword = ""	
	self.m_bConnected = false
end

function cNetFakeConnection:Update( nTimeDelta )
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
				_G.CC_LOG( string.format( "[○Error] No handler opcode = %s [%s]", nOpCode, (_G.SCEventNameMap[nOpCode] or "") ) )
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

function cNetFakeConnection:BindHandler( pCallback, nType )
	self.m_tHandler[nType] = pCallback
end

function cNetFakeConnection:GetHandlerByType( nType )
	return self.m_tHandler[ nType ]
end

function cNetFakeConnection:SendPacket( oPacket )
	assert( oPacket ~= nil and (oPacket:GetType() == cNetMsgPacket.TYPE_WRITE) )
	local nOpCode = oPacket:GetOpCode()
	_G.CC_LOG( string.format( "[○Send]: opcode = %s length = %s [%s]", nOpCode, string.len(oPacket:GetData()), (_G.CSEventNameMap[nOpCode] or "") ) )
	local oFakeServer = self:GetFakeServer()
	if oFakeServer ~= nil then
		oFakeServer:RecvNetMessage( self, oPacket:GetOpCode(), oPacket:GetData(), string.len(oPacket:GetData()) )
	end
end

function cNetFakeConnection:RecvEventPacket( nOpCode, sErr )
	_G.CC_LOG( string.format( "[○Recv Event]: opcode =%s, err=%s", nOpCode, sErr ) )
	self.m_oRecvEventQueue:InQueue( { nOpCode, sErr } )
end

function cNetFakeConnection:RecvMessagePacket( oPacket )
	assert( oPacket ~= nil and (oPacket:GetType() == cNetMsgPacket.TYPE_READ) )
	local nOpCode = oPacket:GetOpCode()
	_G.CC_LOG( string.format( "[○Recv]: opcode =%s, length=%s [%s]", nOpCode, string.len(oPacket:GetData()), (_G.SCEventNameMap[nOpCode] or "") ) )
	self.m_oRecvMessageQueue:InQueue( oPacket )
end

return cNetFakeConnection