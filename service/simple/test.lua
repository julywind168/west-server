local uuid = require "uuid"
local json = require "json"
local log = require "west.log"
local echo = require "west.echo"


local test = {}

function test.started()
    -- pretty json
    log.debug(json.encode({a = 1, hello = "world"}, true))

    -- uuid v4/v7
    log.info("test uuid v4", uuid.v4())
    log.info("test uuid v7", uuid.v7())

    -- test echo
    local e = echo.new()

    e.get("/", function (c)
        return "hello world"
    end)

    e.get("/user/query", function (c)
        local user = {
            name = c.query.name or "anonymous",
            age = 18
        }
        return user
    end)

    e.start(":8887")
end


return test