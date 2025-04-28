local west = require "west"
local log = require "west.log"
local mq = require "west.mq"

local ping = {
    count = 0
}

west.on("started", function ()
    log.info(west.self(), "started")
    mq:sub_once("test-started", function (...)
        log.info("ping: get test-started,", ...)
    end)
end)

west.on("stopped", function ()
    log.info(west.self(), "stopped")
end)


function ping:ping()
    self.count = self.count + 1
    log.info("ping:", self.count)
    return "pong"
end

return ping