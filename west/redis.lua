local skynet = require "skynet"
local service = require "skynet.service"

local redis = {}

function redis.__index(self, key)
    return function (first, ...)
        if first == self then
            return skynet.call(self.service_addr, "lua", key, ...)
        else
            return skynet.call(self.service_addr, "lua", key, first, ...)
        end
    end
end

---@param name string
---@return self
function redis.init(name)
    local self = {
        name = assert(name),
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

            skynet.start(function()
                skynet.dispatch("lua", function(session, source, cmd, ...)
                    local f = db[cmd]
                    if session ~= 0 then
                        skynet.ret(skynet.pack(f(db, ...)))
                    else
                        f(db, ...)
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