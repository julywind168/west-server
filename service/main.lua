local skynet = require "skynet"
local server = require "config"
local json = require "json"
local log = require "log".init()


skynet.start(function()
    math.randomseed(tonumber(tostring(os.time()):reverse()))
    skynet.error("=============================================")
    skynet.error(os.date("%Y/%m/%d %H:%M:%S ")..server.name.." start")
    skynet.error("=============================================")

    skynet.newservice("debug_console", 8000)

    skynet.error(json.encode({a = 1, hell = "world", b = {1, 2, 3}}, true))

    log.info("test log info")
    log.error("test log error id:%d", 123)
    log.debug("test log debug")
    log.warn("test log warn", {
        hello = "world",
        a = 1,
        b = {1, 2, 3},
    })

    skynet.exit()
end)