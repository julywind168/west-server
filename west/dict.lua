local dict = {}

-- 从键值对列表{{k, v}, ...} 创建字典
function dict.from_list(pairs)
    local result = {}
    for _, pair in ipairs(pairs) do
        local k, v = pair[1], pair[2]
        result[k] = v
    end
    return result
end

function dict.foreach(t, f)
    for k, v in pairs(t) do
        f(k, v)
    end
end

function dict.copy(t)
    local result = {}
    for k, v in pairs(t) do
        result[k] = v
    end
    return result
end

function dict.deepcopy(t)
    local function copy(orig)
        if type(orig) ~= "table" then
            return orig
        end
        local r = {}
        for k, v in pairs(orig) do
            r[copy(k)] = copy(v)
        end
        return r
    end
    return copy(t)
end

function dict.get(t, key)
    return t[key]
end

function dict.has_key(t, key)
    return t[key] ~= nil
end

function dict.has_value(t, value)
    for k, v in pairs(t) do
        if v == value then
            return true
        end
    end
    return false
end

function dict.keyof(t, value)
    for k, v in pairs(t) do
        if v == value then
            return k
        end
    end
    return nil
end

function dict.keys(t)
    local keys = {}
    for k in pairs(t) do
        table.insert(keys, k)
    end
    return keys
end

function dict.values(t)
    local values = {}
    for _, v in pairs(t) do
        table.insert(values, v)
    end
    return values
end

function dict.insert(t, key, value)
    local result = {}
    for k, v in pairs(t) do
        result[k] = v
    end
    result[key] = value
    return result
end

function dict.delete(t, key)
    local result = {}
    for k, v in pairs(t) do
        if k ~= key then
            result[k] = v
        end
    end
    return result
end

function dict.find(t, predicate)
    for k, v in pairs(t) do
        if predicate(k, v) then
            return k, v
        end
    end
end

function dict.map(t, f)
    local result = {}
    for k, v in pairs(t) do
        result[k] = f(k, v)
    end
    return result
end

function dict.fold(t, init, f)
    local acc = init
    for k, v in pairs(t) do
        acc = f(acc, k, v)
    end
    return acc
end

-- 将字典转为键值对列表 {{k, v}, ...}
function dict.to_list(t)
    local result = {}
    for k, v in pairs(t) do
        table.insert(result, { k, v })
    end
    return result
end

function dict.size(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

function dict.contains(parent, subset)
    assert(type(parent) == "table", "Expected a table for parent")
    assert(type(subset) == "table", "Expected a table for subset")
    for key, value in pairs(subset) do
        if parent[key] ~= value then
            return false
        end
    end
    return true
end

return dict
