local cDataTableEx = {}

local function CompareTab( tab1, tab2 )
	if tab1 == nil or tab2 == nil then
		return false
	end
	local tElemInTab1 = {}
	for i, v in pairs(tab1) do
		tElemInTab1[i] = true
	end
	for i, v in pairs(tab2) do
		local val1 = tab1[i]
		if type(val1) ~= type(v) then
			return false
		end
		if type(val1) == "table" and type(v) == "table" then
			if CompareTab( val1, v ) == false then
				return false
			end
		else
			if val1 ~= v then
				return false
			end
		end
		tElemInTab1[i] = nil
	end
	if next(tElemInTab1) ~= nil then
		return false
	end
	return true
end

function cDataTableEx:create()
	local o = 
	{ 
		___t = {},
		___TableEx = true,
		___dirty = false,
		IsDirty = function( self )
					local bIsDirty = rawget( self, "___dirty" )
					if bIsDirty == true then
						return true
					else
						for i, v in pairs( self.___t ) do
							if type(v) == "table" then
								if v:IsDirty() == true then
									return true
								end
							end
						end
					end
					return false
				end,
		SetDirty = function( self, bIsDirty )
					self.___dirty = bIsDirty
				end,
		ResetDirty = function( self )
						rawset( self, "___dirty", false )
						for i, v in pairs( self.___t ) do
							if type(v) == "table" then
								v:ResetDirty()
							end
						end
					 end,
		GetData = function( self )
					local tData = {}
						for i, v in pairs( self.___t ) do
							if type(v) == "table" then
								tData[i] = v:GetData()
							else
								tData[i] = v
							end
						end
					return tData
				  end,
		Compare = function( self, tTab )
					local bSame = false
					local tSelfData = self:GetData()
					if rawget(tTab, "___TableEx") == true then
						tTab = tTab:GetData()
					end
					return CompareTab( tSelfData, tTab )
				  end,
	}
	local tab = 
	{
		__newindex = function ( self, key, val )
						if type(val) == "table" then
							if rawget(val, "___TableEx") == true then
								val = val:GetData()
							end
							if self.___t[ key ] == nil then
								local tNewTab = cDataTableEx:create()
								for i, v in pairs( val ) do
									if tNewTab[i] ~= v then
										tNewTab[i] = v
										rawset( tNewTab, "___dirty", true )
									end
								end
								self.___t[ key ] = tNewTab
								rawset( tNewTab, "___dirty", true )
							else
								local tData = self.___t[key]
								if tData:Compare( val) ~= true then
									local tRealData = tData:GetData()
									for i, v in pairs( tRealData) do
										if val[i] == nil then
											tData[i] = nil
										end
									end
									for i, v in pairs( val ) do
										if tData[i] ~= v then
											tData[i] = v
											rawset( tData, "___dirty", true )
										end
									end
								end
							end
						else
							local originVal = self.___t[key]
							if originVal ~= val then
								self.___t[key] = val
								rawset( self, "___dirty", true )
							end
						end
					end,		
		__index = function( self, key )
					return self.___t[key]
				  end,		
	}
	setmetatable( o, tab )
	return o
end

return cDataTableEx