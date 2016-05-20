local cNetMsgPacket = class("cNetMsgPacket")

cNetMsgPacket.TYPE_READ = 0
cNetMsgPacket.TYPE_WRITE = 1

function cNetMsgPacket:ctor( nType, nOpcode, sData, nLength )
	self.m_nOpcode = nOpcode or 0
	self.m_sData = sData or ""
	self.m_nLength = (nLength or 0) + 1
	self.m_nType = nType or cNetMsgPacket.TYPE_READ
	self.m_nOffset = 1
end

function cNetMsgPacket:GetData()
	return self.m_sData
end

function cNetMsgPacket:GetLengh()
	return self.m_nLength
end

function cNetMsgPacket:GetOffset()
	return self.m_nOffset
end  

function cNetMsgPacket:GetOpCode()
	return self.m_nOpcode
end

function cNetMsgPacket:GetType()
	return self.m_nType
end
-----------------------------------------------------------------
--读取,创建一个readPacket之后,会自动管理读取位置的偏移
function cNetMsgPacket:ResetOffset()
	self.m_nOffset = 1
end

function cNetMsgPacket:ReadUint8()
	assert( self.m_nType == cNetMsgPacket.TYPE_READ )
	assert( self.m_nOffset + 1 <= self.m_nLength )
	local nNumber = struct.unpack( 'B', self.m_sData, self.m_nOffset )
	self.m_nOffset = self.m_nOffset + 1
	return nNumber
end

function cNetMsgPacket:ReadInt8()
	assert( self.m_nType == cNetMsgPacket.TYPE_READ )
	assert( self.m_nOffset + 1 <= self.m_nLength )
	local nNumber = struct.unpack( 'b', self.m_sData, self.m_nOffset )
	self.m_nOffset = self.m_nOffset + 1
	return nNumber
end

function cNetMsgPacket:ReadUint16()
	assert( self.m_nType == cNetMsgPacket.TYPE_READ )
	assert( self.m_nOffset + 2 <= self.m_nLength )
	local nNumber = struct.unpack( 'H', self.m_sData, self.m_nOffset )
	self.m_nOffset = self.m_nOffset + 2
	return nNumber
end

function cNetMsgPacket:ReadInt16()
	assert( self.m_nType == cNetMsgPacket.TYPE_READ )
	assert( self.m_nOffset + 2 <= self.m_nLength )
	local nNumber = struct.unpack( 'h', self.m_sData, self.m_nOffset )
	self.m_nOffset = self.m_nOffset + 2
	return nNumber
end

function cNetMsgPacket:ReadUint32()
	assert( self.m_nType == cNetMsgPacket.TYPE_READ )
	assert( self.m_nOffset + 4 <= self.m_nLength )
	local nNumber = struct.unpack( 'I', self.m_sData, self.m_nOffset )
	self.m_nOffset = self.m_nOffset + 4
	return nNumber
end

function cNetMsgPacket:ReadInt32()
	assert( self.m_nType == cNetMsgPacket.TYPE_READ )
	assert( self.m_nOffset + 4 <= self.m_nLength )
	local nNumber = struct.unpack( 'i', self.m_sData, self.m_nOffset )
	self.m_nOffset = self.m_nOffset + 4
	return nNumber
end

function cNetMsgPacket:ReadUint64()
	assert( self.m_nType == cNetMsgPacket.TYPE_READ )
	assert( self.m_nOffset + 8 <= self.m_nLength )
	local nNumber = struct.unpack( 'L', self.m_sData, self.m_nOffset )
	self.m_nOffset = self.m_nOffset + 8
	return nNumber
end

function cNetMsgPacket:ReadInt64()
	assert( self.m_nType == cNetMsgPacket.TYPE_READ )
	assert( self.m_nOffset + 8 <= self.m_nLength )
	local nNumber = struct.unpack( 'l', self.m_sData, self.m_nOffset )
	self.m_nOffset = self.m_nOffset + 8
	return nNumber
end

function cNetMsgPacket:ReadFloat()
	assert( self.m_nType == cNetMsgPacket.TYPE_READ )
	assert( self.m_nOffset + 4 <= self.m_nLength )
	local nNumber = struct.unpack( 'f', self.m_sData, self.m_nOffset )
	self.m_nOffset = self.m_nOffset + 4
	return nNumber
end

function cNetMsgPacket:ReadDouble()
	assert( self.m_nType == cNetMsgPacket.TYPE_READ )
	assert( self.m_nOffset + 8 <= self.m_nLength )
	local nNumber = struct.unpack( 'd', self.m_sData, self.m_nOffset )
	self.m_nOffset = self.m_nOffset + 8
	return nNumber
end

function cNetMsgPacket:ReadFixedLenString( nCharSize )
	assert( self.m_nType == cNetMsgPacket.TYPE_READ )
	assert( self.m_nOffset + nCharSize <= self.m_nLength )
	local sString = struct.unpack( string.format('c%d', nCharSize), self.m_sData, self.m_nOffset )
	self.m_nOffset = self.m_nOffset + nCharSize
	return sString
end

function cNetMsgPacket:ReadByFormat( sFormat )
	local pReadFunc = cNetMsgPacket.READ_FORMAT_FUNC[ sFormat ]
	if pReadFunc ~= nil then
		return pReadFunc( self )
	end
end
-----------------------------------------------------------------
--写入
function cNetMsgPacket:Write()
	assert( self.m_nType == cNetMsgPacket.TYPE_WRITE )
end

function cNetMsgPacket:WriteUint8( val )
	assert( self.m_nType == cNetMsgPacket.TYPE_WRITE )
	assert( val ~= nil and type(val) == 'number' and val >= 0 and val <= 255 )
	local sData = struct.pack( 'B', val )
	self.m_sData = self.m_sData .. sData
	self.m_nLength = self.m_nLength + 1
end

function cNetMsgPacket:WriteInt8( val )
	assert( self.m_nType == cNetMsgPacket.TYPE_WRITE )
	assert( val ~= nil and type(val) == 'number' and val >= -127 and val >= 127 )
	local sData = struct.pack( 'b', val )
	self.m_sData = self.m_sData .. sData
	self.m_nLength = self.m_nLength + 1
end

function cNetMsgPacket:WriteUint16( val )
	assert( self.m_nType == cNetMsgPacket.TYPE_WRITE )
	assert( val ~= nil and type(val) == 'number' and val >= 0 and val <= 65535 )
	local sData = struct.pack( 'H', val )
	self.m_sData = self.m_sData .. sData
	self.m_nLength = self.m_nLength + 2
end

function cNetMsgPacket:WriteInt16( val )
	assert( self.m_nType == cNetMsgPacket.TYPE_WRITE )
	assert( val ~= nil and type(val) == 'number' and val >= -32767 and val <= 32767 )
	local sData = struct.pack( 'h', val )
	self.m_sData = self.m_sData .. sData
	self.m_nLength = self.m_nLength + 21
end

function cNetMsgPacket:WriteUint32( val )
	assert( self.m_nType == cNetMsgPacket.TYPE_WRITE )
	assert( val ~= nil and type(val) == 'number' and val >= 0 and val <= 4294967295 )
	local sData = struct.pack( 'I', val )
	self.m_sData = self.m_sData .. sData
	self.m_nLength = self.m_nLength + 1
end

function cNetMsgPacket:WriteInt32( val )
	assert( self.m_nType == cNetMsgPacket.TYPE_WRITE )
	assert( val ~= nil and type(val) == 'number' and val >= -2147483647 and val <= 2147483647 )
	local sData = struct.pack( 'i', val )
	self.m_sData = self.m_sData .. sData
	self.m_nLength = self.m_nLength + 1
end

function cNetMsgPacket:WriteUint64( val )
	assert( self.m_nType == cNetMsgPacket.TYPE_WRITE )
	assert( val ~= nil and type(val) == 'number' )
	local sData = struct.pack( 'L', val )
	self.m_sData = self.m_sData .. sData
	self.m_nLength = self.m_nLength + 1
end

function cNetMsgPacket:WriteInt64( val )
	assert( self.m_nType == cNetMsgPacket.TYPE_WRITE )
	assert( val ~= nil and type(val) == 'number' )
	local sData = struct.pack( 'l', val )
	self.m_sData = self.m_sData .. sData
	self.m_nLength = self.m_nLength + 1
end

function cNetMsgPacket:WriteFloat( val )
	assert( self.m_nType == cNetMsgPacket.TYPE_WRITE )
	assert( val ~= nil and type(val) == 'number' )
	local sData = struct.pack( 'f', val )
	self.m_sData = self.m_sData .. sData
	self.m_nLength = self.m_nLength + 4
end

function cNetMsgPacket:WriteDouble( val )
	assert( self.m_nType == cNetMsgPacket.TYPE_WRITE )
	assert( val ~= nil and type(val) == 'number' )
	local sData = struct.pack( 'd', val )
	self.m_sData = self.m_sData .. sData
	self.m_nLength = self.m_nLength + 8
end

function cNetMsgPacket:WriteFixedLenString( nCharSize, val )
	assert( self.m_nType == cNetMsgPacket.TYPE_WRITE )
	assert( val ~= nil and type(val) == 'string' )
	local sData = struct.pack( string.format( 'c%d', nCharSize), val )
	self.m_sData = self.m_sData .. sData
	self.m_nLength = self.m_nLength + nCharSize
end

function cNetMsgPacket:WriteCharString( val )
	assert( self.m_nType == cNetMsgPacket.TYPE_WRITE )
	assert( val ~= nil and type(val) == 'string' )
	local nLengh = string.len( val )
	self:WriteFixedLenString( nLengh, val )
end

function cNetMsgPacket:WriteByFormat( sFormat, val )
	local pWriteFunc = cNetMsgPacket.WRITE_FORMAT_FUNC[ sFormat ]
	if pWriteFunc ~= nil then
		return pWriteFunc( self, val )
	end
end
-----------------------------------------------------------------
cNetMsgPacket.READ_FORMAT_FUNC = 
{
	["uint8"]  = cNetMsgPacket.ReadUint8,
	["uint16"] = cNetMsgPacket.ReadUint16,
	["uint32"] = cNetMsgPacket.ReadUint32,
	["uint64"] = cNetMsgPacket.ReadUint64,
	["int8"]   = cNetMsgPacket.ReadInt8,
	["int16"]  = cNetMsgPacket.ReadInt16,
	["int32"]  = cNetMsgPacket.ReadInt32,
	["int64"]  = cNetMsgPacket.ReadInt64,
	["float"]  = cNetMsgPacket.ReadFloat,
	["double"] = cNetMsgPacket.ReadDouble,
}

cNetMsgPacket.WRITE_FORMAT_FUNC = 
{
	["uint8"]  = cNetMsgPacket.WriteUint8,
	["uint16"] = cNetMsgPacket.WriteUint16,
	["uint32"] = cNetMsgPacket.WriteUint32,
	["uint64"] = cNetMsgPacket.WriteUint64,
	["int8"]   = cNetMsgPacket.WriteInt8,
	["int16"]  = cNetMsgPacket.WriteInt16,
	["int32"]  = cNetMsgPacket.WriteInt32,
	["int64"]  = cNetMsgPacket.WriteInt64,
	["float"]  = cNetMsgPacket.WriteFloat,
	["double"] = cNetMsgPacket.WriteDouble,
}
-----------------------------------------------------------------
return cNetMsgPacket