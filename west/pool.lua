--- simple service pool
--- threshold is 20% of init_size

local skynet = require "skynet"
local service = require "skynet.service"

local pool = {}; pool.__index = pool


function pool:get_one()
    return skynet.call(self.service_addr, "lua", "get_one")
end

function pool:get_many(n)
    assert(n > 0)
    return skynet.call(self.service_addr, "lua", "get_many", n)
end

function pool:size()
    return skynet.call(self.service_addr, "lua", "size")
end

function pool:clear()
    skynet.send(self.service_addr, "lua", "clear")
end

---@class PoolOpts
---@field name string simple service name
---@field init_size number pool init size (greater than or equal 5)
---@field max_size number? pool max size, default is equal to init_size

---init pool service
---@param opts PoolOpts
---@return self
function pool.init(opts)
    local init_size = assert(opts.init_size)
    local max_size = opts.max_size or init_size
    assert(init_size >= 5)
    assert(init_size <= max_size)
    local self = { name = assert(opts.name) }

    skynet.init(function()
        local function pool_service(name, init_size, max_size)
            local skynet = require "skynet"
            local west = require "west"
            local threshold = init_size // 5

            local queue = {}

            local function init()
                for i = 1, init_size do
                    queue[i] = west.new(name)
                end
            end

            local started = false
            local function start_spawn()
                started = true
                skynet.fork(function()
                    while #queue < max_size do
                        table.insert(queue, west.new(name))
                        skynet.sleep(1)
                    end
                    started = false
                end)
            end

            local function pop()
                local s = table.remove(queue, 1)
                if #queue <= threshold and started == false then
                    start_spawn()
                end
                return s
            end

            local command = {}

            function command.get_one()
                return pop() or west.new(name)
            end

            function command.get_many(n)
                local results = {}
                for i = 1, n do
                    results[i] = pop() or west.new(name)
                end
                return results
            end

            function command.size()
                return #queue
            end

            function command.clear()
                for _, s in ipairs(queue) do
                    skynet.send(s, "west", "exit")
                end
                queue = {}
            end

            skynet.start(function()
                skynet.dispatch("lua", function(session, source, cmd, ...)
                    local f = command[cmd]
                    skynet.ret(skynet.pack(f(...)))
                end)
                init()
            end)
        end
        self.service_addr = service.new(("%s-pool"):format(self.name), pool_service, self.name, init_size, max_size)
    end)

    return setmetatable(self, pool)
end


return pool