local skynet = require "skynet"
local server = require "config"
local json = require "json"
local log = require "west.log"
local uuid = require "uuid"


skynet.start(function()
    skynet.error("=============================================")
    skynet.error(os.date("%Y/%m/%d %H:%M:%S ")..server.name.." start")
    skynet.error("=============================================")

    skynet.newservice("debug_console", 8000)
    skynet.newservice("benchmark")

    -- test hotfix
    -- rlwrap nc 127.0.0.1 8000
    -- inject [ping_addr] hotfix/fix_ping.lua
    local ping = skynet.newservice("simple", "ping")

    skynet.fork(function()
        while true do
            skynet.sleep(200)
            skynet.send(ping, "lua", "ping")
        end
    end)


    log.debug(json.encode({a = 1, hello = "world"}, true))

    log.info("test uuid v4", uuid.v4())
    log.info("test uuid v7", uuid.v7())

    -- skynet.exit()
end)