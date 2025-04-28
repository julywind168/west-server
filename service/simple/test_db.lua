local west = require "west"
local log = require "west.log"
local mongo = require "west.mongo".init { name = "game" }
local redis = require "west.redis".init("game")


west.on("started", function()
    -- test empty array
    mongo:insert_one("users", {
        id = os.time(),
        backpack = mongo.array()
    })

    redis:set("hello", "redis!")
    log.info("hello", redis:get("hello"))
    west.stop()
end)


return {}
