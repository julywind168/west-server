local skynet = require "skynet"
local service = require "skynet.service"
local json = require "json"

local service_addr
local log = {
    LEVEL_TRACE = 1,
    LEVEL_DEBUG = 2,
    LEVEL_INFO = 3,
    LEVEL_WARN = 4,
    LEVEL_ERROR = 5,

    config = {
        level = 1, -- TRACE
        color = true
    }
}

local function report(level, fmt, ...)
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
    skynet.send(service_addr, "lua", level, msg)
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

---@class LogConfig
---@field level number|nil
---@field color boolean|nil

--- @param conf LogConfig|nil
--- @return self
function log.init(conf)
    if conf then
        if conf.level then
            log.config.level = conf.level
        end
        if conf.color then
            log.config.color = conf.color
        end
    end
    return log
end

skynet.init(function ()
    local log_service = function (conf)
        local skynet = require "skynet"
        local log_level = conf and conf.level or 1 -- TRACE
        local enable_color = conf and conf.color == false and false or true -- default to true

        local tags = { "TRACE", "DEBUG", "INFO", "WARN", "ERROR" }
        local color_tags = {
            "\027[90mTRACE\027[0m", -- Gray (bright black)
            "\027[34mDEBUG\027[0m", -- Blue
            "\027[32mINFO\027[0m",  -- Green
            "\027[33mWARN\027[0m",  -- Yellow
            "\027[31mERROR\027[0m"  -- Red
        }

        local function log(level, msg)
            if level >= log_level then
                skynet.error(string.format("%s %s", enable_color and color_tags[level] or tags[level], msg))
            end
        end

        skynet.start(function()
            skynet.dispatch("lua", function(_,_, ...)
                log(...)
            end)
        end)
    end
    service_addr = service.new("log", log_service, log.config)
end)

return log