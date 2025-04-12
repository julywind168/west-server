local skynet = require "skynet"
local raw_exit = skynet.exit

local args = { ... }
local S = require("service.simple." .. args[1])

local function try(name, ...)
    local f = S[name]
    if f then
        return f(S, ...)
    end
end

function skynet.exit()
    try("stopped")
    raw_exit()
end

skynet.start(function()
    skynet.dispatch("lua", function(session, address, cmd, ...)
        local f = assert(S[cmd], cmd)
        if session ~= 0 then
            skynet.ret(skynet.pack(f(S, ...)))
        else
            f(S, ...)
        end
    end)
    try("started", table.unpack(args, 2))
end)
