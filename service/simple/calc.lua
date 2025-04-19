local west = require "west"
local log = require "west.log"

local calc = {}

west.on("started", function ()
    log.info(west.self(), "started")
end)

west.on("stopped", function ()
    log.info(west.self(), "stopped")
end)

function calc:exit()
    west.stop()
end

function calc:add(x, y)
    return x + y
end

function calc:sub(x, y)
    return x - y
end

function calc:mul(x, y)
    return x * y
end

function calc:div(x, y)
    if y == 0 then
        return nil, "divided by zero"
    end
    return x / y
end

return calc