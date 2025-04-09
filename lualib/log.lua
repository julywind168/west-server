local skynet = require "skynet"
local json = require "json"

local LOG_LEVEL = tonumber(skynet.getenv "log_level")
local ENABLE_COLOR = skynet.getenv("log_color") == "true"
local ENABLE_LOCATION = skynet.getenv("log_location") == "true"

local log = {
    TRACE = 1,
    DEBUG = 2,
    INFO = 3,
    WARN = 4,
    ERROR = 5
}

local TAGS = { "TRACE", "DEBUG", "INFO", "WARN", "ERROR" }
local COLOR_TAGS = {
    "\027[90mTRACE\027[0m", -- Gray (bright black)
    "\027[34mDEBUG\027[0m", -- Blue
    "\027[32mINFO\027[0m",  -- Green
    "\027[33mWARN\027[0m",  -- Yellow
    "\027[31mERROR\027[0m"  -- Red
}

local function log_message(level, fmt, ...)
    if level < LOG_LEVEL then
        return
    end

    local msg
    if type(fmt) == "string" and string.match(fmt, "%%[dfsqxXaA]") then
        msg = string.format(fmt, ...)
    else
        local args = {fmt, ...}
        for i, v in ipairs(args) do
            if type(v) == "table" then
                local str = json.encode(v)
                args[i] = #str <= 100 and str or json.encode(v, true)
            else
                args[i] = tostring(v)
            end
        end
        msg = table.concat(args, ", ")
    end

    if ENABLE_LOCATION then
        local info = debug.getinfo(3)
        if info then
            local filename = string.match(info.short_src, "[^/%.]+%.lua")
            msg = string.format("[%s:%d] %s", filename, info.currentline, msg)
        end
    end

    skynet.error(string.format("%s %s", ENABLE_COLOR and COLOR_TAGS[level] or TAGS[level], msg))
end

function log.trace(...)
    log_message(log.TRACE, ...)
end

function log.debug(...)
    log_message(log.DEBUG, ...)
end

function log.info(...)
    log_message(log.INFO, ...)
end

function log.warn(...)
    log_message(log.WARN, ...)
end

function log.error(...)
    log_message(log.ERROR, ...)
end

return log