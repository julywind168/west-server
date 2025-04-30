local http = require "west.echo.http"

---@class (exact) CORSConfig
---@field allow_origins string[] 允许的来源
---@field allow_methods string[] 允许的方法
---@field allow_headers string[] 允许的请求头
---@field max_age number? 预检请求的有效期（秒）

--- CORS 中间件
--- @param config CORSConfig
--- @return function f CORS middleware function
local function cors_with_config(config)
    return function(next)
        return function(ctx)
            local request = ctx.request
            local response = ctx.response
            local origin = request.header["origin"]
            if not origin then
                return next(ctx)
            end
            local allowed_origin = ""
            for _, o in ipairs(config.allow_origins) do
                if o == "*" or o == origin then
                    allowed_origin = o
                    break
                end
            end
            if allowed_origin == "" then
                return next(ctx)
            end
            -- 设置 CORS 头
            response.header["access-control-allow-origin"] = allowed_origin

            -- 处理预检请求（OPTIONS）
            if request.method == "options" then
                response.header["access-control-allow-methods"] = table.concat(config.allow_methods, ",")
                response.header["access-control-allow-headers"] = table.concat(config.allow_headers, ",")
                if config.max_age > 0 then
                    response.header["access-control-max-age"] = tostring(config.max_age)
                end
                return ctx.string(http.StatusNoContent, "")
            end

            return next(ctx)
        end
    end
end

-- header: Authorization: key
local function key_auth(uri_prefix, key)
    return function(next)
        return function(ctx)
            local auth = ctx.request.header["authorization"]
            if ctx.uri:sub(1, #uri_prefix) == uri_prefix and auth ~= key then
                return ctx.string(http.StatusUnauthorized, "Unauthorized")
            end
            return next(ctx)
        end
    end
end

return {
    cors_with_config = cors_with_config,
    key_auth = key_auth
}
