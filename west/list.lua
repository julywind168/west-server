--- Functional table(list) extension
-- @module list

local list = {}

-- Create a new list
function list.new(...)
    return {...}
end

-- Find a value in a list
function list.find(tbl, predicate)
    for i, v in ipairs(tbl) do
        if predicate(v) then
            return v, i
        end
    end
end

-- Map function over a list
function list.map(tbl, func)
    local result = {}
    for i, v in ipairs(tbl) do
        result[i] = func(v)
    end
    return result
end

-- Filter a list based on a predicate
function list.filter(tbl, predicate)
    local result = {}
    for i, v in ipairs(tbl) do
        if predicate(v) then
            table.insert(result, v)
        end
    end
    return result
end

-- Reduce a list to a single value
function list.reduce(tbl, func, initial)
    local acc = initial
    for i, v in ipairs(tbl) do
        acc = func(acc, v)
    end
    return acc
end

-- Append an element to a list
function list.append(tbl, value)
    local result = {table.unpack(tbl)}
    table.insert(result, value)
    return result
end

-- Concatenate two lists
function list.concat(tbl1, tbl2)
    local result = {table.unpack(tbl1)}
    for _, v in ipairs(tbl2) do
        table.insert(result, v)
    end
    return result
end

-- Check if a list contains an element
function list.contains(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

-- Get the length of a list
function list.length(tbl)
    return #tbl
end

return list