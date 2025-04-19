local skynet = require "skynet"
local west = require "west"

local name = assert(...)
local S = require("service.simple." .. name)

local command = {}

local started = false
function command.start(name, ...)
    if started == false then
        west.init(name)
        west.try("started", ...)
        started = true
    end
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
