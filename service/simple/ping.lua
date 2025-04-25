local west = require "west"
local log = require "west.log"
local mq = require "west.mq"

local ping = {
    count = 0
}

west.on("started", function ()
    log.info(west.self(), "started")
    mq:sub("test-started", function (src, ...)
        log.info("ping: get test-started,", ("[%s]:"):format(src), ...)
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