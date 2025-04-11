local skynet = require "skynet"
local json = require "json"
local luajson = require "lua-json"
local log = require "west.log"

local function profile(f, n)
    local t = skynet.now()
    for i = 1, n do
        f()
    end
    return ((skynet.now() - t) / 100).."s"
end

local t = {
    hello = "world",
    a = 1,
    b = { 1, 2, 3 },
    c = {
        x = {
            a = 1,
            b = 2,
            c = 3,
        },
        y = {
            a = 1,
            b = 2,
            c = 3,
        },
    }
}

local function test_rust_json()
    json.decode(json.encode(t))
end

local function test_lua_json()
    luajson.decode(luajson.encode(t))
end

local function test()
    local iterations = 10000
    local t1 = profile(test_rust_json, iterations)
    local t2 = profile(test_lua_json, iterations)

    log.info(("json benchmark: encode/decode %d iterations"):format(iterations), {
        rust = t1,
        lua = t2,
    })
end

skynet.start(function()
    test()
end)
