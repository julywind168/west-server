local log = require "west.log"

local ping = {
    count = 0
}

function ping:started()
    log.info("ping:started")
end

function ping:stopped()
end

function ping:ping()
    self.count = self.count + 1
    log.info("ping:", self.count)
    return "pong"
end

return ping