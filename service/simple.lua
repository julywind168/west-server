local skynet = require "skynet"
local west = require "west"

local service_name = assert(...)
local S

local command = {}

local started = false
function command.start(name, ...)
    if started == false then
        S = require("service.simple." .. service_name)
        west.init(name)
        west.try("started", ...)
        started = true
    end
end

function command.exit()
    west.stop()
end

skynet.start(function()
    skynet.dispatch("west", function(session, address, cmd, ...)
        local f = assert(command[cmd], cmd)
        if session ~= 0 then
            skynet.ret(skynet.pack(f(...)))
        else
            f(...)
        end
    end)

    skynet.dispatch("lua", function(session, address, cmd, ...)
        assert(started, "service not started")
        local f = assert(S[cmd], cmd)
        if session ~= 0 then
            skynet.ret(skynet.pack(f(S, ...)))
        else
            f(S, ...)
        end
    end)
end)
