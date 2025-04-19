local skynet = require "skynet"
local uuid = require "uuid"
local json = require "json"
local log = require "west.log"
local echo = require "west.echo"
local west = require "west"
local middleware = require "west.echo.middleware"
local distributed = skynet.getenv "nodename" ~= nil


west.on("started", function()
    -- pretty json
    log.debug(json.encode({ a = 1, hello = "world" }, true))

    -- uuid v4/v7
    log.info("test uuid v4", uuid.v4())
    log.info("test uuid v7", uuid.v7())

    -- test echo
    local e = echo.new()

    e.use(middleware.cors_with_config({
        allow_origins = { "*" },
        allow_methods = { "*" },
        allow_headers = { "*" },
    }))

    e.get("/", function(c)
        return "hello world"
    end)

    e.get("/user/query", function(c)
        local user = {
            name = c.query.name or "anonymous",
            age = 18
        }
        return user
    end)

    e.start(":8887")

    -- test ping
    local ping = distributed and "ping@ping" or "ping"
    skynet.fork(function()
        while true do
            skynet.sleep(200)
            west.send(ping, "ping")
        end
    end)
end)

return {}