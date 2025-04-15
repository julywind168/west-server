local skynet = require "skynet"
local service = require "skynet.service"

local sqlx = {}; sqlx.__index = sqlx

function sqlx:prepare(...)
    return skynet.call(self.service_addr, "lua", "prepare", ...)
end

function sqlx:query(...)
    return skynet.call(self.service_addr, "lua", "query", ...)
end

function sqlx:execute(...)
    return skynet.call(self.service_addr, "lua", "execute", ...)
end

function sqlx.init(name)
    local self = { name = name }

    skynet.init(function()
        local function sqlx_service(name)
            local skynet = require "skynet"
            local mysql = require "skynet.db.mysql"
            local conf = require(("config.sqlx-%s"):format(name))

            local db
            local function init()
                db = mysql.connect(conf)
                db:query("set charset utf8mb4")
            end

            local command = {}

            function command.prepare(...)
                return db:prepare(...)
            end

            function command.query(...)
                return db:query(...)
            end

            function command.execute(...)
                return db:execute(...)
            end

            skynet.start(function()
                skynet.dispatch("lua", function(session, source, cmd, ...)
                    local f = command[cmd]
                    skynet.ret(skynet.pack(f(...)))
                end)
                init()
            end)
        end
        self.service_addr = service.new("sqlx-" .. name, sqlx_service, name)
    end)

    return setmetatable(self, sqlx)
end

return sqlx
