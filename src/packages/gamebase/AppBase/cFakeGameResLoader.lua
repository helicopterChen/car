local cFakeGameResLoader = class("cFakeGameResLoader")
local cDataQueue = import("..CommonUtility.cDataQueue")

function cFakeGameResLoader:ctor()
	self.m_bIsFake = true
	self.m_tJsonCfgDataLoaded = {}
	self.m_tSpriteFrameLoaded = {}
	self.m_tJsonCfgLoadQueue = cDataQueue:new()
	self.m_tSpriteFrameLoadQueue = cDataQueue:new()
end

function cFakeGameResLoader:GetInstance()
	if _G.__oFakeResLoader == nil then
		_G.__oFakeResLoader = cFakeGameResLoader:new()
	end
	return _G.__oFakeResLoader
end

function cFakeGameResLoader:AddSpriteFramesWithFileAsync(plistFilename,texture, handler)
	self.m_tSpriteFrameLoadQueue:InQueue( {plistFilename,texture, handler} )
	return true
end

function cFakeGameResLoader:LoadSpriteFrame(plistFilename,texture, handler)
	display.addSpriteFrames(plistFilename,texture)
	self.m_tSpriteFrameLoaded[plistFilename] = true
	if handler ~= nil then
		handler()
	end
end

function cFakeGameResLoader:AddJsonFileDecodeAsync(jsonFilename,handler)
	self.m_tJsonCfgLoadQueue:InQueue({jsonFilename,handler})
	return true
end

function cFakeGameResLoader:LoadJsonFileData(jsonFilename,handler)
	self.m_tJsonCfgDataLoaded[jsonFilename] = true
	if handler ~= nil then
		handler()
	end
end

function cFakeGameResLoader:ClearJsonCfgDataByName(jsonName)
	self.m_tJsonCfgDataLoaded = {}
end

function cFakeGameResLoader:IsJsonCfgDataLoaded(jsonName)
	return self.m_tJsonCfgDataLoaded[jsonName]
end

function cFakeGameResLoader:IsSpriteFrameLoaded(jsonName)
	return self.m_tSpriteFrameLoaded[jsonName]
end

function cFakeGameResLoader:GetJsonCfgDataByName(jsonName)
end

function cFakeGameResLoader:Update( dt )
	local tWork = self.m_tSpriteFrameLoadQueue:OutQueue()
	if tWork ~= nil then
		self:LoadSpriteFrame( unpack(tWork) )
		return
	end
	local tWork = self.m_tJsonCfgLoadQueue:OutQueue()
	if tWork ~= nil then
		self:LoadJsonFileData( unpack(tWork) )
		return
	end
end

return cFakeGameResLoader