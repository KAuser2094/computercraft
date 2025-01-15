local store = require "common.Modules.Class.store"

local function append(tbl, other)
    for _, item in ipairs(other) do
        table.insert(tbl, item)
    end
end

local function removeDuplicatesBackwards(tbl)
    local i = #tbl
    local found = {}
    while i > 0 do
        local item = tbl[i]
        if not found[item] then
            found[item] = true
        else
            table.remove(tbl, i)
            i = i - 1
        end
        i = i - 1
    end

end

--- @param top common.Modules.Class.ClassDefinition
--- @return string[] heirarchy
local function getHierarchy(top, noDuplicates, foundSet)
    noDuplicates = noDuplicates or false
    foundSet = foundSet or {}
    local heirarchy = {}
    for _, baseName in ipairs(top.__directlyInherits) do
        if not noDuplicates or not foundSet[baseName] then
            foundSet[baseName] = true
            local base = store.getDefinition(baseName)
            if base then
                table.insert(heirarchy, baseName)
                local base_heirarchy = getHierarchy(base, noDuplicates, foundSet)
                append(heirarchy, base_heirarchy)
            end
        end
    end
    return heirarchy
end

local iterator = {}

--- @param top common.Modules.Class.ClassDefinition The definition whose heirarchy we are iterating (note that it itself is not included)
--- @param noDuplicates? boolean Whether to strip duplicates (Will pick the duplicate that is earliest to return)
--- @return fun(): common.Modules.Class.ClassDefinition? iter The iterator function itself that returns the actual definitions this inherits
function iterator.forInheritsBottomUp(top, noDuplicates)
    noDuplicates = noDuplicates or false
    local hierarchy = getHierarchy(top)
    if noDuplicates then
        removeDuplicatesBackwards(hierarchy)
    end

    local index = #hierarchy + 1  -- Start from after the last element

    --- @type fun(): common.Modules.Class.ClassDefinition?
    return function()
        index = index - 1
        if index > 0 then
            local cls = store.getDefinition(hierarchy[index])
            return cls
        end
    end
end

--- @param top common.Modules.Class.ClassDefinition The definition whose heirarchy we are iterating (note that it itself is not included)
--- @param noDuplicates? boolean Whether to strip duplicates (Will pick the duplicate that is earliest to return)
--- @return fun(): common.Modules.Class.ClassDefinition? iter The iterator function itself that returns the actual definitions this inherits
function iterator.forInheritsTopDown(top, noDuplicates)
    noDuplicates = noDuplicates or false
    local hierarchy = getHierarchy(top, noDuplicates)

    local max = #hierarchy + 1  -- Start from after the last element
    local index = 0

    --- @type fun(): common.Modules.Class.ClassDefinition?
    return function()
        index = index + 1
        if index < max then
            local cls = store.getDefinition(hierarchy[index])
            return cls
        end
    end
end

return iterator
