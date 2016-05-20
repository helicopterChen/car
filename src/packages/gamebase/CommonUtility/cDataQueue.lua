local cDataQueue = class( "cDataQueue" )

function cDataQueue:ctor()
	self.m_tQueue = {}
end

function cDataQueue:InQueue( tData )
	table.insert( self.m_tQueue, tData )
end

function cDataQueue:OutQueue()
	local tData = self.m_tQueue[1]
	if tData ~= nil then
		table.remove( self.m_tQueue, 1 )
		return tData
	end
end

function cDataQueue:IsEmpty()
	return (#self.m_tQueue == 0)
end

function cDataQueue:Back()
	return self.m_tQueue[#self.m_tQueue]
end

function cDataQueue:Front()
	return self.m_tQueue[1]
end

function cDataQueue:Clear()
	self.m_tQueue = {}
end

function cDataQueue:Count()
	return #self.m_tQueue
end

function cDataQueue:GetDataInQueue()
	return self.m_tQueue
end

return cDataQueue