local skynet = require "skynet"
require "skynet.manager"
local cluster = require "skynet.cluster"
local nodename = skynet.getenv "nodename"

skynet.register_protocol {
    name = "west",
    id = 255,                    -- PTYPE_WEST
    pack = skynet.pack,
    unpack = skynet.unpack,
}

local west = {
    name = ""
}
local callback = {}

function west.new(sname)
    return skynet.newservice("simple", sname)
end

function west.start(service, name, ...)
    skynet.call(service, "west", "start", name, ...)
end

function west.spawn(name, sname, ...)
    west.start(west.new(sname), name, ...)
    return nodename and nodename.."@"..name or name
end

-- fullname: node@name | name
function west.call(fullname, ...)
    local node, name = fullname:match "^(%w+)@(.+)$"; name = name or fullname;
    if node == nodename then
        return skynet.call(name, "lua", ...)
    else
        return cluster.call(node, name, ...)
    end
end

function west.send(fullname, ...)
    local node, name = fullname:match "^(%w+)@(.+)$"; name = name or fullname;
    if node == nodename then
        return skynet.send(name, "lua", ...)
    else
        return cluster.send(node, name, ...)
    end
end

function west.init(name)
    if nodename then
        assert(nodename ~= "", "invalid empty nodename")
        west.name = nodename.."@"..name
        cluster.register(name)
    else
        west.name = name
    end
    skynet.register(name)
end

--- register simple service lifecycle handler
---@param event 'started' | 'stopped'
---@param f function
function west.on(event, f)
    callback[event] = f
end

function west.try(event, ...)
    local f = callback[event]
    if f then
        callback[event] = nil
        f(...)
    end
end

function west.self()
    return west.name
end

function west.stop()
    west.try("stopped")
    skynet.exit()
end

return west