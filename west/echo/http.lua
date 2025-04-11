local http = {
    -- 2xx: Success
    StatusOK = 200,                  -- 请求成功
    StatusCreated = 201,             -- 资源创建成功（如创建房间）
    StatusAccepted = 202,            -- 请求已接受，但处理未完成
    StatusNoContent = 204,           -- 请求成功，但无返回内容

    -- 3xx: Redirection
    StatusMovedPermanently = 301,    -- 资源永久重定向
    StatusFound = 302,               -- 资源临时重定向
    StatusNotModified = 304,         -- 资源未修改（缓存相关）

    -- 4xx: Client Error
    StatusBadRequest = 400,          -- 客户端请求错误（如参数错误）
    StatusUnauthorized = 401,        -- 未授权（需要登录）
    StatusForbidden = 403,           -- 禁止访问（权限不足）
    StatusNotFound = 404,            -- 资源未找到（如房间不存在）
    StatusMethodNotAllowed = 405,    -- 不支持的 HTTP 方法
    StatusConflict = 409,            -- 资源冲突（如房间 ID 已存在）
    StatusTooManyRequests = 429,     -- 请求过多（限流）

    -- 5xx: Server Error
    StatusInternalServerError = 500, -- 服务器内部错误
    StatusNotImplemented = 501,      -- 功能未实现
    StatusBadGateway = 502,          -- 网关错误
    StatusServiceUnavailable = 503,  -- 服务不可用（如数据库宕机）
    StatusGatewayTimeout = 504,      -- 网关超时
}

return http