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

function west.new(sname)
    return skynet.newservice("simple", sname)
end

---start a simple service
---@param service_addr number skynet service address (from west.new(sname))
---@param name string service unique name (in self node)
---@param ... any
---@return string service west simple service
function west.start(service_addr, name, ...)
    skynet.call(service_addr, "west", "start", name, ...)
    return nodename and nodename.."@"..name or name
end

function west.spawn(name, sname, ...)
    return west.start(west.new(sname), name, ...)
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
    else
        west.name = name
    end
    skynet.register(name)
end

local callback = {}

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