local west = require "west"
local log = require "west.log"
local mongo = require "west.mongo".init{name = "game"}
local redis = require "west.redis".init("game")


local test = {}

function test:started()
    -- test empty array
    mongo:insert_one("users", {
        id = os.time(),
        backpack = mongo.newarray()
    })

    redis:set("hello", "redis!")
    log.info("hello", redis:get("hello"))
    west.stop()
end

function test:stopped()
    log.info("stopped")
end

return test