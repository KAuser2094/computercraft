local Class = require "common.Modules.Class"

local pc = require "common.Modules.expect"
local TAG = "TABULA"
pc.enableTag(TAG)

--- @class common.Modules.Tabula.Tabula : common.Modules.Class.Class, table -- No clue if the "table" does anything

--- @class common.Modules.Tabula.TabulaDefinition : common.Modules.Class.ClassDefinition
local Tabula = Class(TAG)

--- Ceates a tabula intance
--- @param baseTable table -- NOTE: This will deep merge its k-v pairs into the instance table
--- @return common.Modules.Tabula.Tabula
function Tabula:new(baseTable)
    --- @type common.Modules.Tabula.Tabula
    return Tabula:rawnew(baseTable)
end

function Tabula:init(this, baseTable)
    --- For Tabula we specifically need the class methods and fields to ALL be private
    local proxy = getmetatable(this)
    for k,v in pairs(this) do
        rawset(proxy, k, v)
        this[k] = nil
    end
    Tabula.deepMerge(this, baseTable)
end

--[[
    Vanilla table module
]]

--- @overload fun(tbl: table, value: any) -- Cursed way of typing this
--- @see table.insert
--- @param tbl table
--- @param pos integer
--- @param value any
function Tabula.insert(tbl, pos, value)
    if value then
        table.insert(tbl, pos, value)
    else
        table.insert(tbl, pos)
    end
end

--- @see table.remove
--- @param tbl table
--- @param pos? integer
--- @return any
function Tabula.remove(tbl, pos)
    return table.remove(tbl, pos)
end

--[[
    CHECKS
]]

--- Check if the given table is {}
--- @param tbl table
--- @return boolean empty
function Tabula.isEmpty(tbl)
    return not not next(tbl)
end

--- Check if table has the value, and if so will return the key it found it at
--- @param tbl table
--- @param value any
--- @return any? keyFound
function Tabula.hasValue(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then
            return k
        end
    end
end

--- @generic K, V
--- Returns the return value from if ANY key-value pair put in the function returns truthy
--- @param tbl { [K]: V }
--- @param func fun(key: K, value: V): any -- Takes in key and value and returns a truthy value if it passes
--- @return any? returnAtPassed
function Tabula.any(tbl, func)
    for k, v in pairs(tbl) do
        local res = func(k,v)
        if res then return res end
    end
end

--- @generic K, V
--- Returns the return value from if ALL key-value pair put in the function returns truthy
--- @param tbl { [K]: V }
--- @param func fun(key: K, value: V): any -- Takes in key and value and returns a truthy value if it passes
--- @return boolean allPassed
function Tabula.all(tbl, func)
    for k,v in pairs(tbl) do
        local res = func(k,v)
        if not res then return false end
    end
    return true
end

--[[
    Table operations not in `table`
]]

--- @generic K, V
--- Collects the keys in a table (order not guarenteed)
--- @param tbl { [K]: V }
--- @return K[]
function Tabula.getKeys(tbl)
    local keys = {}
    for k, _ in pairs(tbl) do
        table.insert(keys, k)
    end
    return keys
end

--- @generic K, V
--- Collects the values in a table (order not guarenteed)
--- @param tbl { [K]: V }
--- @return V[]
function Tabula.getValues(tbl)
    local values = {}
    for _, v in pairs(tbl) do
        table.insert(values, v)
    end
    return values
end

--- @generic T
--- Removes 1 k-v pairs with v == the value given.
--- @param tbl table
--- @param value T
--- @return any keyRemoved
function Tabula.removeByValue(tbl, value)
    local k = Tabula.hasValue(tbl, value)
    if k == nil then return nil end
    tbl[k] = nil
    return k -- This is just here for the sake of "parity" between table.remove
end

--[[
    MERGE
]]

--- Shallow merges second arg into the first
--- @param tbl table
--- @param other table
function Tabula.shallowMerge(tbl, other)
    local function shallowMerge(_tbl, _other)
        for k,v in pairs(_other) do
                _tbl[k] = v
        end
    end
    shallowMerge(tbl, other)
end

--- Deep merges second arg into the first
--- @param tbl table
--- @param other table
function Tabula.deepMerge(tbl, other)
    local function deepMerge(_tbl, _other)
        for k,v in pairs(_other) do
            if type(v) == "table" then
                -- Errors if tbl[k] is not a table (or false in which case it overrides, both dumb),
                -- I am not adding extra presumptions, just make sure the shape is correct
                _tbl[k] = _tbl[k] or {}
                deepMerge(_tbl[k], v)
            else
                _tbl[k] = v
            end
        end
    end
    deepMerge(tbl, other)
end

--[[
    COPY
]]

--- Returns a shallow copy of the table (will be a vanilla table, mot Tabula class)
--- @param tbl table
--- @return table copy
function Tabula.shallowCopy(tbl)
    local copy = {}
    Tabula.shallowMerge(copy, tbl)
    return copy
end

--- Returns a deep copy of the table (will be a vanilla table, mot Tabula class)
--- @param tbl table
--- @return table copy
function Tabula.deepCopy(tbl)
    local copy = {}
    Tabula.deepMerge(copy, tbl)
    return copy
end

return Tabula
