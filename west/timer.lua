local skynet = require "skynet"

local timer = {}

local timers = {} -- id => {func, interval, is_repeating, cancelled}
local timer_id = 0

local function gen_timer_id()
    timer_id = timer_id + 1
    return timer_id
end

local function timer_callback(id)
    local t = timers[id]
    if not t or t.cancelled then
        return
    end

    t.func()

    if t.is_repeating and not t.cancelled then -- cortinue
        skynet.timeout(t.interval, function()
            timer_callback(id)
        end)
    else
        timers[id] = nil
    end
end

local function add_timer(delay, func, is_repeating)
    if is_repeating then
        assert(delay > 0, "Invalid interval for repeating timer")
    end

    local id = gen_timer_id()
    timers[id] = {
        func = func,
        interval = delay,
        is_repeating = is_repeating,
        cancelled = false,
    }

    skynet.timeout(delay, function()
        timer_callback(id)
    end)

    return id
end

function timer.once(delay, func)
    return add_timer(delay, func, false)
end

function timer.loop(interval, func)
    return add_timer(interval, func, true)
end

function timer.cancel(id)
    local t = timers[id]
    if t then
        t.cancelled = true
        timers[id] = nil
    end
end

function timer.clear()
    for id, t in pairs(timers) do
        t.cancelled = true
        timers[id] = nil
    end
end

return timer
