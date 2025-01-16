--[[
    Holds functions required for inheritance
]]

local inheritance = {}

local function append(tbl, other)
    if type(other) == "string" then
        other = { other }
    end
    for _, item in ipairs(other) do
        table.insert(tbl, item)
    end
end

--- Shallow merges
--- @param tbl table
--- @param other table
local function shallowMerge(tbl, other)
    for k,v in pairs(other) do
        tbl[k] = v
    end
end

--- Shallow merges, skipping any key in the preserve table
--- @param tbl table
--- @param other table
--- @param preserve? string[]
local function shallowMergeWithPreserve(tbl, other, preserve)
    for k,v in pairs(other) do
        if not preserve then
            tbl[k] = v
        elseif not preserve[k] then
            tbl[k] = v
        end
    end
end

--- Deep Merges
--- @param tbl table
--- @param other table
local function deepMerge(tbl, other)
    for k, v in pairs(other) do
        if type(v) == "table" then
            tbl[k] = tbl[k] or {} -- Presumes same shape of tables (ignoring other types)
            deepMerge(tbl[k], v)
        else
            tbl[k] = v
        end
    end
end

--[[
    FOR REFERENCE:
    ...
]]

--- Uses self as a base class to inherit into the given klass
--- @param self common.Modules.Class.ClassDefinition
--- @param klass common.Modules.Class.ClassDefinition
function inheritance.inheritInto(self, klass)
    table.insert(klass.__directlyInherits, self.__className)
    klass.__inherits[self.__className] = self
    --- Class specific work
    for base in self:forInheritsBottomUp(true) do
        base:preInheritInto(klass)
    end
    self:preInheritInto(klass)

    --- Merge all settings up (NOTE: sets can be merged up, arrays need to be appended, more complicated types need to be done case by case)
    shallowMerge(klass.__definitionSettings.CLASS_DEFINITION_ONLY, self.__definitionSettings.CLASS_DEFINITION_ONLY)
    shallowMerge(klass.__definitionSettings.PUBLIC, self.__definitionSettings.PUBLIC)
    shallowMerge(klass.__definitionSettings.PROXY, self.__definitionSettings.PROXY)
    shallowMerge(klass.__definitionSettings.INVARIANT_EXPECT, self.__definitionSettings.INVARIANT_EXPECT)
    for k, types in pairs(self.__definitionSettings.INVARIANT_TYPES) do -- TODO: Check if deepMerge also works here (I think it does)
        if not klass.__definitionSettings.INVARIANT_TYPES[k] then
            klass.__definitionSettings.INVARIANT_TYPES[k] = {}
        end
        shallowMerge(klass.__definitionSettings.INVARIANT_TYPES[k], types)
    end
    shallowMerge(klass.__definitionSettings.INHERIT_DO_NOT_COPY, self.__definitionSettings.INHERIT_DO_NOT_COPY)
    shallowMerge(klass.__definitionSettings.INHERIT_MERGE, self.__definitionSettings.INHERIT_MERGE)
    shallowMerge(klass.__definitionSettings.INHERIT_DEEP_MERGE, self.__definitionSettings.INHERIT_DEEP_MERGE)

    -- TODO: THE OVERLOAD INVARIANT (MERGE UP AS WELL AS ADD ANY CONFLICTS)

    --- Shallow copy all fields that are not marked do not copy.
    shallowMergeWithPreserve(klass, self, klass.__definitionSettings.INHERIT_DO_NOT_COPY)

    --- Shallow merge up all fields marked as so
    for k, _ in ipairs(klass.__definitionSettings.INHERIT_MERGE) do
        klass[k] = klass[k] ~= nil and klass[k] or {} -- nil is treated as empty table, obviously will error if it isn't a table, which is should.
        local selfTbl = self[k] or {} -- We don't want to change the values of the other definition
        shallowMerge(klass[k], selfTbl)
    end

    --- Deep merge up all fields marked as so
    for k, _ in ipairs(klass.__definitionSettings.INHERIT_DEEP_MERGE) do
        klass[k] = klass[k] ~= nil and klass[k] or {} -- nil is treated as empty table, obviously will error if it isn't a table, which is should.
        local selfTbl = self[k] or {} -- We don't want to change the values of the other definition
        deepMerge(klass[k], selfTbl)
    end

    -- Appends the fields marked as so TODO: Fix thie append function to actually work as you would want.
    for k, _ in ipairs(klass.__definitionSettings.INHERIT_APPEND) do
        klass[k] = klass[k] ~= nil and klass[k] or {} -- nil is treated as empty table, obviously will error if it isn't a table, which is should.
        local selfTbl = self[k] or {} -- We don't want to change the values of the other definition
        append(klass[k], selfTbl)
    end

    --- Class specific work
    for base in self:forInheritsBottomUp(true) do
        base:postInheritInto(klass)
    end
    self:postInheritInto(klass)
end

--- Inherits from the given classes, goes from last given to first.
--- @param self common.Modules.Class.ClassDefinition
--- @param klass? common.Modules.Class.ClassDefinition Base class to inherit from
--- @param ... common.Modules.Class.ClassDefinition ...
function inheritance.inheritFrom(self, klass, ...)
    local count = select("#", klass, ...) -- I *BELIEVE* that (CC Tweaks) lua would actually allow for tables CONSTRUCTED with nils to not terminate the # operator.
    local klasses = { klass, ... }
    for i=count, 1, -1 do
        local kls = klasses[i]
        if kls then
            kls:inheritInto(self)
        end
    end
end

return inheritance
