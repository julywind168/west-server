local skynet = require "skynet"
local service = require "skynet.service"
local mc = require "skynet.multicast"
local west = require "west"
local dict = require "west.dict"
local distributed = skynet.getenv("nodename") ~= nil
local nodes = require "config.nodes"

local function new_channel(id)
    local subscriber = {}

    local subscribed = false
    local channel = mc.new {
        channel = id,
        dispatch = function(_, _, ...)
            for _, callback in pairs(subscriber) do
                callback(...)
            end
        end
    }

    local self = {}

    local sid = 0
    function self.sub(callback)
        if subscribed == false then
            channel:subscribe()
            subscribed = true
        end
        sid = sid + 1
        subscriber[sid] = callback

        return function()
            subscriber[sid] = nil
            if next(subscriber) == nil then
                channel:unsubscribe()
                subscribed = false
            end
        end
    end

    function self.sub_once(callback)
        local s = {}
        s.cancel = self.sub(function(...)
            s.cancel()
            callback(...)
        end)
        return s.cancel
    end

    function self.sub_many(callback, n)
        local s = {}
        local count = 0
        s.cancel = self.sub(function(...)
            count = count + 1
            if count >= n then
                s.cancel()
            end
            callback(...)
        end)
        return s.cancel
    end

    function self.pub(...)
        channel:publish(...)
    end

    return self
end


local mq = { channels = {} }; mq.__index = mq

function mq:pub(ch_name, ...)
    self.channels[ch_name] = self.channels[ch_name] or new_channel(self:channel_id(ch_name))
    self.channels[ch_name].pub(west.self(), ...)
    if distributed then
        skynet.send(self.service_addr, "lua", "broadcast", west.self(), ch_name, ...)
    end
end

function mq:sub(ch_name, f)
    self.channels[ch_name] = self.channels[ch_name] or new_channel(self:channel_id(ch_name))
    return self.channels[ch_name].sub(f)
end

function mq:sub_once(ch_name, f)
    self.channels[ch_name] = self.channels[ch_name] or new_channel(self:channel_id(ch_name))
    return self.channels[ch_name].sub_once(f)
end

function mq:sub_many(ch_name, f, n)
    self.channels[ch_name] = self.channels[ch_name] or new_channel(self:channel_id(ch_name))
    return self.channels[ch_name].sub_many(f, n)
end

function mq:delete(ch_name)
    skynet.send(self.service_addr, "lua", "delete", ch_name)
    self.channels[ch_name] = nil
end

function mq:channel_id(ch_name)
    return skynet.call(self.service_addr, "lua", "channel_id", ch_name)
end

skynet.init(function()
    local function mq_service(nodelist)
        local skynet = require "skynet"
        require "skynet.manager"
        local cluster = require "skynet.cluster"
        local mc = require "skynet.multicast"
        local nodename = skynet.getenv("nodename")

        local command = {}
        local channel = {}

        function command.channel_id(ch_name)
            if not channel[ch_name] then
                channel[ch_name] = mc.new()
            end
            return channel[ch_name].channel
        end

        function command.delete(ch_name)
            if channel[ch_name] then
                channel[ch_name]:delete()
                channel[ch_name] = nil
            end
        end

        -- broadcast to all nodes
        function command.broadcast(source, ch_name, ...)
            for _, node in ipairs(nodelist) do
                if node ~= nodename then
                    cluster.send(node, "mq", "message", source, ch_name, ...)
                end
            end
        end

        -- message from other nodes
        function command.message(source, ch_name, ...)
            if channel[ch_name] then
                channel[ch_name]:publish(source, ...)
            end
        end

        skynet.start(function()
            skynet.dispatch("lua", function(session, source, cmd, ...)
                local f = command[cmd]
                skynet.ret(skynet.pack(f(...)))
            end)
            skynet.name("mq")
        end)
    end

    mq.service_addr = service.new("mq", mq_service, dict.keys(nodes.conf))
end)


return mq
