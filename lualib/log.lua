local skynet = require "skynet"
local json = require "json"

local log_level = tonumber(skynet.getenv "log_level")
local log_color = skynet.getenv "log_color" == "true"

local log = {
    LEVEL_TRACE = 1,
    LEVEL_DEBUG = 2,
    LEVEL_INFO = 3,
    LEVEL_WARN = 4,
    LEVEL_ERROR = 5
}

local tags = { "TRACE", "DEBUG", "INFO", "WARN", "ERROR" }
local color_tags = {
    "\027[90mTRACE\027[0m", -- Gray (bright black)
    "\027[34mDEBUG\027[0m", -- Blue
    "\027[32mINFO\027[0m",  -- Green
    "\027[33mWARN\027[0m",  -- Yellow
    "\027[31mERROR\027[0m"  -- Red
}

local function report(level, fmt, ...)
    if level < log_level then
        return
    end
    local msg
    if type(fmt) == "string" and string.match(fmt, "%%[dfsqxXaA]") then -- fmt?
        msg = string.format(fmt, ...)
    else
        local args = {fmt, ...}
        for index, value in ipairs(args) do
            if type(value) == "table" then
                local str = json.encode(value)
                args[index] = #str <= 100 and str or json.encode(value, true)
            else
                args[index] = tostring(value)
            end
        end
        msg = table.concat(args, ", ")
    end
    skynet.error(string.format("%s %s", log_color and color_tags[level] or tags[level], msg))
end

function log.trace(...)
    report(log.LEVEL_TRACE, ...)
end

function log.debug(...)
    report(log.LEVEL_DEBUG, ...)
end

function log.info(...)
    report(log.LEVEL_INFO, ...)
end

function log.warn(...)
    report(log.LEVEL_WARN, ...)
end

function log.error(...)
    report(log.LEVEL_ERROR, ...)
end


return log