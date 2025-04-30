local skynet = require "skynet"
local service = require "skynet.service"

local service_addr
local snowid = {}

function snowid.int()
    return skynet.call(service_addr, "lua")
end

function snowid.string()
    return tostring(snowid.int())
end

skynet.init(function ()
    local function snowid_service()
        local skynet = require "skynet"
        local snowflake = require "west.snowid.snowflake"
        local nodes = require "config.nodes"
        local nodename = skynet.getenv("nodename")

        local id = 0
        if nodename then
            local node = nodes[nodename]
            id = assert(node and node.id)
        end
        local generator = snowflake.new(id)

        skynet.start(function()
            skynet.dispatch("lua", function(...)
                skynet.ret(skynet.pack(generator:generate()))
            end)
        end)
    end
    service_addr = service.new("snowid", snowid_service)
end)


return snowid