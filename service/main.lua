local skynet = require "skynet"
local cluster = require "skynet.cluster"
local server = require "config"
local west = require "west"
local nodes = require "config.nodes"

local nodename = skynet.getenv "nodename"
local distributed = nodename ~= nil


local startup = {}

function startup.ping()
    west.spawn("ping", "ping")

    if distributed then
        cluster.open "ping"
        skynet.exit()
    end
end

function startup.main()
    local ping = distributed and "ping@ping" or "ping"
    skynet.fork(function()
        while true do
            skynet.sleep(200)
            west.send(ping, "ping")
        end
    end)
    west.spawn("test", "test")

    if distributed then
        cluster.open "main"
        skynet.exit()
    end
end


skynet.start(function()
    skynet.error("=============================================")
    skynet.error(os.date("%Y/%m/%d %H:%M:%S ")..(nodename or server.name).." start")
    skynet.error("=============================================")

    skynet.newservice("debug_console", nodes[nodename or "main"].debug_port)

    if distributed then -- cluster mode
        cluster.reload(nodes.conf)
        startup[nodename]()
    else
        startup.ping()
        startup.main()
        skynet.exit()
    end
end)