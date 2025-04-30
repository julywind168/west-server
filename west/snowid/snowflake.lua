-------------------------------------------------------------------------------
-- 雪花算法的高性能分布式ID生成器
-- 结构：42位时间戳 + 10位机器ID + 12位序列号
-- 
-- @usage
--   local snowflake = require "snowflake"
--   local generator = snowflake.new(1)  -- 机器ID=1
--   local id = generator:generate()
-------------------------------------------------------------------------------

local skynet = require "skynet"
local Snowflake = {}; Snowflake.__index = Snowflake

local TIMESTAMP_BITS = 42
local MACHINE_ID_BITS = 10
local SEQUENCE_BITS = 12

local MAX_MACHINE_ID = 2^MACHINE_ID_BITS - 1  -- 1023
local MAX_SEQUENCE = 2^SEQUENCE_BITS - 1      -- 4095


-- 构造函数
function Snowflake.new(machine_id)
    local self = {}
    self.machine_id = machine_id or 0
    assert(self.machine_id >= 0 and self.machine_id <= MAX_MACHINE_ID, "Machine ID must be between 0 and " .. MAX_MACHINE_ID)
    self.sequence = 0
    self.last_timestamp = 0
    return setmetatable(self, Snowflake)
end

-- 获取当前时间戳（毫秒）
function Snowflake:current_time()
    return skynet.time() * 1000  -- 转换为毫秒（简单示例，生产环境建议更高精度）
end

-- 等待下一毫秒
function Snowflake:wait_next_millis(last_timestamp)
    local current = self:current_time()
    while current <= last_timestamp do
        skynet.sleep(1)
        current = self:current_time()
    end
    return current
end

-- 生成雪花ID
function Snowflake:generate()
    local timestamp = self:current_time()

    -- 如果时钟回拨，使用上一次的时间戳（更健壮的处理方式）
    if timestamp < self.last_timestamp then
        skynet.error("Clock moved backwards. Refusing to generate id for " .. (self.last_timestamp - timestamp) .. " milliseconds")
        timestamp = self.last_timestamp
    end

    -- 同一毫秒内生成多个ID
    if timestamp == self.last_timestamp then
        self.sequence = (self.sequence + 1) & MAX_SEQUENCE  -- 12位序列号（0-4095）
        if self.sequence == 0 then  -- 当前毫秒序列号用尽，等待下一毫秒
            timestamp = self:wait_next_millis(timestamp)
        end
    else
        self.sequence = 0  -- 新毫秒重置序列号
    end

    self.last_timestamp = timestamp

    -- 组合ID（42位时间戳 + 10位机器ID + 12位序列号）
    local id = (timestamp << 22) | (self.machine_id << 12) | self.sequence
    return id
end

return Snowflake