local skynet = require "skynet"
local server = require "config"


skynet.start(function()
    math.randomseed(tonumber(tostring(os.time()):reverse()))
    skynet.error("=============================================")
    skynet.error(os.date("%Y/%m/%d %H:%M:%S ")..server.name.." start")
    skynet.error("=============================================")

    skynet.newservice("debug_console", 8000)

    skynet.exit()
end)