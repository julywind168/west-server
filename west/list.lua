--- Functional table(list) extension
-- @module list

local list = {}

-- Create a new list
function list.new(...)
    return {...}
end

function list.indexof(t, value)
    for i, v in ipairs(t) do
        if v == value then
            return i
        end
    end
    return nil
end

-- Find a value in a list
function list.find(t, predicate)
    for i, v in ipairs(t) do
        if predicate(v) then
            return i, v
        end
    end
end

-- Map function over a list
function list.map(t, f)
    local result = {}
    for i, v in ipairs(t) do
        result[i] = f(v)
    end
    return result
end

-- Filter a list based on a predicate
function list.filter(t, predicate)
    local result = {}
    for i, v in ipairs(t) do
        if predicate(v) then
            table.insert(result, v)
        end
    end
    return result
end

-- Fold a list using a function
function list.fold(t, init, f)
    local acc = init
    for _, v in ipairs(t) do
        acc = f(acc, v)
    end
    return acc
end

-- Append an element to a list
function list.append(t, value)
    local result = {table.unpack(t)}
    table.insert(result, value)
    return result
end

-- Concatenate two lists
function list.concat(t1, t2)
    local result = {table.unpack(t1)}
    for _, v in ipairs(t2) do
        table.insert(result, v)
    end
    return result
end

-- Check if a list has an element
function list.has(t, value)
    for _, v in ipairs(t) do
        if v == value then
            return true
        end
    end
    return false
end

-- Check if a list contains an subset
function list.contains(t, subset)
    assert(type(t) == "table", "Expected a table for t")
    assert(type(subset) == "table", "Expected a table for subset")
    for key, value in pairs(subset) do
        if t[key] ~= value then
            return false
        end
    end
    return true
end

-- Get the length of a list
function list.length(t)
    return #t
end

function list.copy(t)
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

return list