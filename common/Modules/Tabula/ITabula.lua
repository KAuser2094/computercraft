--- @meta _

--- @class common.Modules.Tabula.ITabula : common.Modules.Class.Class, table -- No clue if the "table" does anything
local Tabula = {}

--[[
    Vanilla table module
]]

--- @overload fun(tbl: table, value: any) -- Cursed way of typing this
--- @see table.insert
--- @param tbl table
--- @param pos integer
--- @param value any
function Tabula.insert(tbl, pos, value) end

--- @see table.remove
--- @param tbl table
--- @param pos? integer
--- @return any? removedValue
function Tabula.remove(tbl, pos) end

--[[
    CHECKS
]]

--- Check if the given table is {}
--- @param tbl table
--- @return boolean empty
function Tabula.isEmpty(tbl) end

--- Check if table has the value, and if so will return the key it found it at
--- @param tbl table
--- @param value any
--- @return any? keyFound
function Tabula.hasValue(tbl, value) end

--- @generic K, V
--- Returns the return value from if ANY key-value pair put in the function returns truthy
--- @param tbl { [K]: V }
--- @param func fun(key: K, value: V): any -- Takes in key and value and returns a truthy value if it passes
--- @return any? returnAtPassed
function Tabula.any(tbl, func) end

--- @generic K, V
--- Returns the return value from if ALL key-value pair put in the function returns truthy
--- @param tbl { [K]: V }
--- @param func fun(key: K, value: V): any -- Takes in key and value and returns a truthy value if it passes
--- @return boolean allPassed
function Tabula.all(tbl, func) end

--[[
    Table operations not in `table`
]]

--- Empties out the table
--- @param tbl table
function Tabula.emptyTable(tbl) end

--- @generic K, V
--- Collects the keys in a table (order not guarenteed)
--- @param tbl { [K]: V }
--- @return K[]
function Tabula.getKeys(tbl) end

--- @generic K, V
--- Collects the values in a table (order not guarenteed)
--- @param tbl { [K]: V }
--- @return V[]
function Tabula.getValues(tbl) end

--- Removes 1 k-v pairs with v == the value given.
--- @param tbl table
--- @param value any
--- @return any keyRemoved
function Tabula.removeByValue(tbl, value) end

--[[
    MERGE
]]

--- Shallow merges second arg into the first
--- @param tbl table
--- @param other table
function Tabula.shallowMerge(tbl, other) end

--- Deep merges second arg into the first
--- @param tbl table
--- @param other table
function Tabula.deepMerge(tbl, other) end

--[[
    COPY
]]

--- Returns a shallow copy of the table (will be a vanilla table, mot Tabula class)
--- @param tbl table
--- @return table copy
function Tabula.shallowCopy(tbl) end

--- Returns a deep copy of the table (will be a vanilla table, mot Tabula class)
--- @param tbl table
--- @return table copy
function Tabula.deepCopy(tbl) end
