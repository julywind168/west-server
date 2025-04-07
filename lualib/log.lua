local skynet = require "skynet"
local service = require "skynet.service"
local json = require "json"

local service_addr
local log = {
    LEVEL_TRACE = 1,
    LEVEL_DEBUG = 2,
    LEVEL_INFO = 3,
    LEVEL_WARN = 4,
    LEVEL_ERROR = 5
}

local function report(level, fmt, ...)
    if not service_addr then
        log.init()
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
---@field level number
---@field color boolean

--- @param conf LogConfig|nil
--- @return self
function log.init(conf)
    skynet.init(function ()
        local log_service = function (conf)
            local skynet = require "skynet"
            local log_level = conf and conf.level or 1 -- TRACE
            local enable_color = conf and conf.color == false and false or true -- default to true

            local tags = { "TRACE", "DEBUG", "INFO", "WARN", "ERROR" }
            local color_tags = {
                "\27[36mTRACE\27[0m",
                "\27[32mDEBUG\27[0m",
                "\27[37mINFO\27[0m",
                "\27[33mWARN\27[0m",
                "\27[31mERROR\27[0m"
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

        service_addr = service.new("log", log_service, conf)
    end)
    return log
end

return log