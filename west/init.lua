local skynet = require "skynet"
require "skynet.manager"
local cluster = require "skynet.cluster"
local nodename = skynet.getenv "nodename"

local west = {
    name = ""
}

function west.spawn(name, sname, ...)
    skynet.newservice("simple", sname, name, ...)
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

function west.self()
    return west.name
end

return west