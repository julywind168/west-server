local skynet = require "skynet"
local service = require "skynet.service"

local mongo = {}; mongo.__index = mongo

function mongo.newarray(t)
    t = t or {}
    t.__array = true
    return t
end

function mongo:find_one(...)
    return skynet.call(self.service_addr, "lua", "find_one", ...)
end

function mongo:find_many(...)
    return skynet.call(self.service_addr, "lua", "find_many", ...)
end

function mongo:count(...)
    return skynet.call(self.service_addr, "lua", "count", ...)
end

function mongo:sum(...)
    return skynet.call(self.service_addr, "lua", "sum", ...)
end

-- use self.request
function mongo:insert_one(...)
    return self.request(self.service_addr, "lua", "insert_one", ...)
end

function mongo:insert_many(...)
    return self.request(self.service_addr, "lua", "insert_many", ...)
end

function mongo:update_one(...)
    return self.request(self.service_addr, "lua", "update_one", ...)
end

function mongo:update_many(...)
    return self.request(self.service_addr, "lua", "update_many", ...)
end

function mongo:delete_one(...)
    return self.request(self.service_addr, "lua", "delete_one", ...)
end

function mongo:delete_many(...)
    return self.request(self.service_addr, "lua", "delete_many", ...)
end

function mongo:update(...)
    return self.request(self.service_addr, "lua", "update", ...)
end

function mongo:update_or_insert(...)
    return self.request(self.service_addr, "lua", "update_or_insert", ...)
end

function mongo.init(opts)
    local self = {
        name = assert(opts.name),
        request = opts.async and skynet.send or skynet.call,
        poolsize = opts.poolsize or 1,
    }

    skynet.init(function ()
        local function mongo_service(name, poolsize)
            local skynet = require "skynet"
            local service = require "skynet.service"
            local worker_service = require "mongo.worker"

            local wrokers = {}
            local idx = 0
            local function get_worker()
                idx = idx + 1
                if idx > poolsize then
                    idx = 1
                end
                return wrokers[idx]
            end

            skynet.start(function()
                for i = 1, poolsize do
                    wrokers[i] = service.new(("mongo-%s-worker-%d"):format(name, i), worker_service, name, i)
                end
                skynet.dispatch("lua", function(session, source, ...)
                    skynet.redirect(get_worker(), source, "lua", session, skynet.pack(...))
                    skynet.ignoreret()
                end)
            end)
        end
        self.service_addr = service.new("mongo-"..self.name, mongo_service, self.name, self.poolsize)
    end)

    return setmetatable(self, mongo)
end

return mongo
