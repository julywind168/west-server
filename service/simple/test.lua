local skynet = require "skynet"
local lettre = require "lettre"
local uuid = require "uuid"
local json = require "json"
local log = require "west.log"
local echo = require "west.echo"
local west = require "west"
local mq = require "west.mq"
local timer = require "west.timer"
local calc_pool = require "west.pool".init { name = "calc", init_size = 5, max_size = 6 }
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

    -- protected '/user/*' route
    e.use(middleware.key_auth("/user/", "west"))

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

    -- test pool
    log.info("calc_pool size", calc_pool:size())

    local calces = calc_pool:get_many(4)
    for i, addr in ipairs(calces) do
        calces[i] = west.start(addr, "calc." .. i)
    end

    for i, calc in ipairs(calces) do
        west.send(calc, "exit")
    end

    skynet.sleep(100)
    log.info("calc_pool size", calc_pool:size())

    -- test mq
    skynet.sleep(100)
    mq:pub("test-started", "welcome to west")
    mq:pub("test-started", "welcome to west 2")

    -- test timer
    timer.once(50, function()
        log.debug("timer once")
    end)

    local id
    local count = 0
    id = timer.loop(50, function()
        count = count + 1
        log.debug("timer every ", count)
        if count >= 3 then
            timer.cancel(id)
            log.warn("timer cancel", id)
        end
    end)

    -- test lettre to send mail
    -- smtp_server: "smtp.gmail.com" | "smtp.qq.com" | ...
    --[[
        local mailer = lettre.mailer("smtp_server", "smtp_username", "smtp_password")
        mailer:send_text{
            from = "me@gmail.com",
            to = "who@gmail.com",
            subject = "Happy new year",
            body = "Be happy!"
        }
        log.info("email sent")
    ]]
end)

return {}
