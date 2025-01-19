--[[
    Extra array functions on top of Tabula and overloads functions to keep arrays "contiguous", is only a seperate class so I don't spam Tabula TOO much with stuff
]]

local Class = require "common.Modules.Class"
local Tabula = require "common.Modules.Tabula"

local pc = require "common.Modules.expect"
local TAG = "NON-CONTIGUOUS ARRAY"
pc.enableTag(TAG)

--- @class common.Modules.Tabula.Array : common.Modules.Tabula.Tabula

--- @class common.Modules.Tabula.ArrayDefinition : common.Modules.Tabula.TabulaDefinition
local Array = Class(TAG, Tabula)

--- Ceates a tabula array intance
--- @param baseArray any[] -- NOTE: This will deep merge its k-v pairs into the instance table
--- @return common.Modules.Tabula.Array
function Array:new(baseArray)
    --- @type common.Modules.Tabula.Array
    return Array:rawnew(baseArray)
end

-- TODO: When I make the proxy protect a setting, add it here
Array.isTabulaArray = true -- We do this to save compute time running `expect.isType` over and over
Array:markProxy("isTabulaArray") -- We want each array to hold their own private value for this
Array:markDefinitionOnly("isTabulaArray") -- Stop from trying to edit here

--- Takes in an array and makes it contiguous if it is sparse. NOTE: DO NOT RUN THIS IF INTEGER KEYS MAY NOT BE PART OF THE ARRAY OR HAVE ADDITIONAL MEANING
--- @param arr table
--- @param maxIntegerKey? integer -- If you know this is the case, this will skip looking for it
function Array.fixArray(arr, maxIntegerKey)
    maxIntegerKey = maxIntegerKey or 0
    if maxIntegerKey == 0 then
        for k,_ in pairs(arr) do
            if type(k) == "number" and k % 1 == 0 then -- integer
                if maxIntegerKey < k then maxIntegerKey = k end
            end
        end
    end
    if #arr == maxIntegerKey then return end -- This is already is not sparse
    -- Go up the array, figure out where the space is, then contuously make values found into the next slot free
    local nextFreeSpace
    for i=1, maxIntegerKey do
        if nextFreeSpace == nil and arr[i] == nil then nextFreeSpace = i end -- Check where the first sapce is, and it being set flags we start shifting the values over.
        if nextFreeSpace ~= nil and arr[i] ~= nil then arr[nextFreeSpace] = arr[i] ; arr[i] = nil ; nextFreeSpace = nextFreeSpace + 1 end -- Shift over the value
    end
end

--[[
    OVERLOADS
]]

--- Removes 1 k-v pairs with v == the value given.
--- @param tbl table
--- @param value any
--- @return any keyRemoved
function Array.removeByValue(tbl, value)
    local beforeN = #tbl
    Tabula.removeByValue(tbl, value)
    if beforeN < #tbl then -- We know the array became sparse
        Array.fixArray(tbl, beforeN)
    end
end

--[[
    REPRESENTATIONS
]]

--- @generic K, V
--- Returns a set of the values in the array (and nothing else)
--- @param arr { [K]: V } | V[]
--- @return { [V]: true } set
function Array.asSet(arr)
    local set = {}
    for _, v in ipairs(arr) do
        set[v] = true
    end
    return set
end

--[[
    ???
]]

--- Will remove the duplicates in an array (NOTE: this keeps the first instance of each value)
--- @param arr table
function Array.removeDuplicates(arr)
    local seen = {}
    local writeIndex = 0
    local arraySize = #arr
    for readIndex=1, arraySize do
        local value = arr[readIndex]
        if not seen[value] then
            seen[value] = true
            arr[writeIndex] = value
            writeIndex = writeIndex + 1
        end
    end

    for i=writeIndex, arraySize do
        arr[i] = nil
    end
end

return Array
