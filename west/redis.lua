local skynet = require "skynet"
local service = require "skynet.service"

local redis = {}; redis.__index = redis

-- calles
function redis:get(key)
    return skynet.call(self.service_addr, "lua", "get", key)
end

-- requestes
function redis:set(key, value)
    return self.request(self.service_addr, "lua", "set", key, value)
end

function redis:del(key)
    return self.request(self.service_addr, "lua", "del", key)
end


---@class RedisOpts
---@field name string
---@field async boolean?

---@param opts RedisOpts
---@return self
function redis.init(opts)
    local self = {
        name = assert(opts.name),
        request = opts.async and skynet.send or skynet.call
    }
    skynet.init(function ()
        local function redis_service(name)
            local skynet = require "skynet"
            local redis = require "skynet.db.redis"
            local conf = require(string.format("config.redis-%s", name))

            local db
            local function init()
                db = redis.connect(conf)
            end

            local command = {}

            function command.get(key)
                return db:get(key)
            end

            function command.set(key, value)
                return db:set(key, value)
            end

            function command.del(key)
                return db:del(key)
            end

            skynet.start(function()
                skynet.dispatch("lua", function(session, source, cmd, ...)
                    local f = assert(command[cmd])
                    if session ~= 0 then
                        skynet.ret(skynet.pack(f(...)))
                    else
                        f(...)
                    end
                end)
                init()
            end)
        end
        self.service_addr = service.new("redis-"..self.name, redis_service, self.name)
    end)
    return setmetatable(self, redis)
end

return redis