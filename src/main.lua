LUA_PRINT = print
__LOG_STR_MAP_ = {}
print = 
function( ... )
	LUA_PRINT( ... )
	if CONFIG_DEBUG_INFO_PANEL == true then
		local logStr = ""
		for k,v in ipairs({...}) do
			logStr = logStr .. tostring( v ) .. "\t"
		end
		__LOG_STR_MAP_[#__LOG_STR_MAP_+1] = logStr
	end
end

local __require = _G["require"]

function __myRequire( path )
    return __require( string.gsub( path, '/', '.' ) )
end

_G["require"] = __myRequire

function __G__TRACKBACK__(errorMessage)
    print("------------------Trace back----------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")
end

package.path = package.path .. ";src/"
cc.FileUtils:getInstance():addSearchPath("res/")
cc.FileUtils:getInstance():setPopupNotify(false)

--local initconnection = require("debugger") 
--initconnection('127.0.0.1', 10000, 'luaidekey')
collectgarbage("setpause", 100)
collectgarbage("setstepmul", 5000)
local MyApp = require("app.MyApp")

if DEBUG_MOB_OPEN == true then
	require("mobdebug").start()
end

MyApp.new():Run()
