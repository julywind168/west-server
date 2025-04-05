local skynet = require "skynet"
local server = require "config"
local json = require "json"


skynet.start(function()
    math.randomseed(tonumber(tostring(os.time()):reverse()))
    skynet.error("=============================================")
    skynet.error(os.date("%Y/%m/%d %H:%M:%S ")..server.name.." start")
    skynet.error("=============================================")

    skynet.newservice("debug_console", 8000)

    skynet.error(json.encode({a = 1, hell = "world", b = {1, 2, 3}}, true))

    skynet.exit()
end)