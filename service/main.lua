local skynet = require "skynet"
local server = require "config"
local json = require "json"
local log = require "log"
local uuid = require "uuid"


skynet.start(function()
    math.randomseed(tonumber(tostring(os.time()):reverse()))
    skynet.error("=============================================")
    skynet.error(os.date("%Y/%m/%d %H:%M:%S ")..server.name.." start")
    skynet.error("=============================================")

    skynet.newservice("debug_console", 8000)

    skynet.error(json.encode({a = 1, hell = "world", b = {1, 2, 3}}, true))

    log.trace("test log trace")
    log.debug("test log debug")
    log.info("test log info id:%d", 123)
    log.warn("test log warn", {
        hello = "world",
        a = 1,
        b = {1, 2, 3},
    })
    log.error("test error info")

    log.info("test uuid v4", uuid.v4())
    log.info("test uuid v7", uuid.v7())

    skynet.exit()
end)