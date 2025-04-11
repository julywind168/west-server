--- It's similar to golang echo https://echo.labstack.com/

local skynet = require "skynet"
local httpd = require "http.httpd"
local socket = require "skynet.socket"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"
local json = require "cjson"
local http = require "echo.http"

local BODY_LIMIT = 8192

local echo = {}

local function format_http_date()
    local days = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" }
    local months = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }
    local time = os.time()
    local date = os.date("!*t", time)
    return string.format(
        "%s, %02d %s %04d %02d:%02d:%02d GMT",
        days[date.wday], date.day, months[date.month], date.year, date.hour, date.min, date.sec
    )
end

local function checknumber(value, base)
    return tonumber(value, base) or 0
end

local function urldecode(input)
    input = string.gsub (input, "+", " ")
    input = string.gsub (input, "%%(%x%x)", function(h) return string.char(checknumber(h,16)) end)
    input = string.gsub (input, "\r\n", "\n")
    return input
end

function echo.new()
    local SSLCTX_SERVER = nil
    local function gen_interface(protocol, fd, certfile, keyfile)
        if protocol == "http" then
            return {
                init = nil,
                close = nil,
                read = sockethelper.readfunc(fd),
                write = sockethelper.writefunc(fd),
            }
        elseif protocol == "https" then
            local tls = require "http.tlshelper"
            if not SSLCTX_SERVER then
                SSLCTX_SERVER = tls.newctx()
                -- gen cert and key
                -- openssl req -x509 -newkey rsa:2048 -days 3650 -nodes -keyout server-key.pem -out server-cert.pem
                SSLCTX_SERVER:set_cert(certfile, keyfile)
            end
            local tls_ctx = tls.newtls("server", SSLCTX_SERVER)
            return {
                init = tls.init_responsefunc(fd, tls_ctx),
                close = tls.closefunc(tls_ctx),
                read = tls.readfunc(fd, tls_ctx),
                write = tls.writefunc(fd, tls_ctx),
            }
        else
            error(string.format("Invalid protocol: %s", protocol))
        end
    end

    local server = {
        protocol = "http",
        certfile = "",
        keyfile = "",
    }
    local handle = {
        get = {},
        post = {}
    }
    local middlewares = {}

    local function chain_middleware(handler)
        local wrapped = handler
        for i = #middlewares, 1, -1 do
            wrapped = middlewares[i](wrapped)
        end
        return wrapped
    end

    function server.use(middleware)
        table.insert(middlewares, middleware)
    end

    function server.get(path, cb)
        handle.get[path] = cb
    end

    function server.post(path, cb)
        handle.post[path] = cb
    end

    local function accept(id, addr)
        socket.start(id)
        local interface = gen_interface(server.protocol, id, server.certfile, server.keyfile)
        if interface.init then
            interface.init()
        end

        local function ret(...)
            local ok, err = httpd.write_response(interface.write, ...)
            if not ok then
                -- if err == sockethelper.socket_error , that means socket closed.
                skynet.error(string.format("response error: fd = %d, %s", id, err))
            end
            socket.close(id)
            if interface.close then
                interface.close()
            end
        end

        local function close(errmsg)
            if errmsg then
                skynet.error(errmsg)
            end
            socket.close(id)
            if interface.close then
                interface.close()
            end
        end

        local code, url, method, header, body = httpd.read_request(interface.read, BODY_LIMIT)
        local content_type = header and header["content-type"]
        if not code then
            return close(url)
        end
        if code ~= http.StatusOK then
            return ret(code)
        end
        if content_type then
            if content_type:find("urlencoded") then
                body = urldecode(body)
            end
            if content_type:find("json") then
                body = json.decode(body) or {}
            end
        end
        method = method:lower()

        local path, query = urllib.parse(url)
        if not handle[method] then
            skynet.error(string.format("method %s not allowed", method))
            return ret(http.StatusMethodNotAllowed)
        end
        local cb = handle[method][path]
        if not cb then
            skynet.error(string.format("path %s not found", path))
            return ret(http.StatusNotFound)
        end

        local c = {
            request = {
                addr = addr,
                method = method,
                path = path,
                query = query,
                header = header,
                body = body,
            },
            response = {
                status = http.StatusOK,
                header = {
                    ["connection"] = "close",
                    ["server"] = "skynet",
                },
                body = "",
            },
        }

        function c.string(rcode, rbody)
            c.response.status = rcode
            c.response.body = rbody
            c.response.header["content-type"] = "text/plain"
        end

        function c.json(rcode, rbody)
            c.response.status = rcode
            c.response.body = json.encode(rbody)
            c.response.header["content-type"] = "application/json"
        end

        -- TODO: add more response type
        local handler = chain_middleware(cb)
        local ok, r = pcall(handler, c)
        if ok then
            if r then
                if type(r) == "string" then
                    c.string(http.StatusOK, r)
                elseif type(r) == "table" then
                    c.json(http.StatusOK, r)
                else
                    error(string.format("Invalid response: %s", tostring(r)))
                end
            end
        else
            skynet.error(string.format('Handle method: "%s", path: "%s", client: "%s" error: %s', method, path, addr, r))
            return ret(http.StatusInternalServerError)
        end
        c.response.header["Date"] = format_http_date()
        return ret(c.response.status, c.response.body, c.response.header)
    end

    local started = false

    function server.start(uri)
        if started then
            error("server already started")
        end
        started = true
        local host, port = string.match(uri, "^([^:]*):(%d+)$")
        skynet.error(string.format("Listen on %s:%d", host, port))
        local id = socket.listen(host or "0.0.0.0", tonumber(port))

        socket.start(id, function(id, addr)
            accept(id, addr)
        end)
    end

    function server.startTLS(uri, certfile, keyfile)
        server.protocol = "https"
        server.certfile = certfile
        server.keyfile = keyfile
        server.start(uri)
    end

    return server
end

return echo