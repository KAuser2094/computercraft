local Class = require "common.Modules.Class"

local pc = require "common.Modules.expect"
local TAG = "STORAGE FILTER CLASS"
pc.enableTag(TAG)

local Array = require "common.Modules.Tabula.Array"

--- @class common.Modules.StorageFilter.FilterDefinition : common.Modules.Class.ClassDefinition
local Filter = Class(TAG)

--- @param template? common.Modules.StorageFilter.FilterTemplate
--- @return common.Modules.StorageFilter.Filter
function Filter:new(template)
    --- @type common.Modules.StorageFilter.Filter
    return Filter:rawnew(template)
end

--- Init
--- @param template? common.Modules.StorageFilter.FilterTemplate
--- @param this common.Modules.StorageFilter.Filter
function Filter:init(this, template)
    template = template or {}
    this.countLB = template.countLB
    this.countUB = template.countUB
    this.name = template.name
    this.nbthash = template.nbthash
    this.requireMatchNBT = template.requireMatchNBT or false
end

--[[
    Matching fields to an item table
]]

--- @param this common.Modules.StorageFilter.Filter
--- @param itemTable ccTweaked.peripherals.inventory.item | ccTweaked.peripherals.fluidstorage.fluid
--- @return boolean matches
function Filter.MatchItemCount(this, itemTable)
    local count = itemTable.count or itemTable.amount
    local meetLB = this.countLB == nil or count >= this.countLB
    local meetUB = this.countUB == nil or count <= this.countUB
    return meetLB and meetUB
end

--- @param this common.Modules.StorageFilter.Filter
--- @param itemTable ccTweaked.peripherals.inventory.item | ccTweaked.peripherals.fluidstorage.fluid
--- @return string | false matchedPatternOrFalse
function Filter.MatchItemName(this, itemTable)
    local name = itemTable.name -- Seems a bit redundant
    local meetName
    for _, pattern in ipairs(this.name) do
        -- Try direct match
        if string.match(name, "^" .. pattern .. "$") then
            meetName = pattern
            break
        end
        -- Try "*:<pattern>" match
        if string.match(name, "^.-:" .. pattern .. "$") then
            meetName = pattern
            break
        end
    end
    return meetName or false
end

--- @param this common.Modules.StorageFilter.Filter
--- @param itemTable ccTweaked.peripherals.inventory.item | ccTweaked.peripherals.fluidstorage.fluid
--- @return string | boolean matchedNBTOrBoolean
function Filter.MatchItemNBT(this, itemTable)
    if itemTable.amount then return true end -- Fluids do not have nbt
    if not this.requireMatchNBT then return true end
    local meetMBT
    for _, nbtHash in ipairs(this.nbthash) do
        if nbtHash == "" and not itemTable.nbt then return true end -- Empty string is used to signify no nbt
        if nbtHash == itemTable.nbt then
            meetMBT = nbtHash
            break
        end
    end
    return meetMBT or false
end

--- @param this common.Modules.StorageFilter.Filter
--- @param itemTable ccTweaked.peripherals.inventory.item | ccTweaked.peripherals.fluidstorage.fluid
--- @return boolean matches
function Filter.MatchItem(this, itemTable)
    return this:MatchItemCount(itemTable) and (not not this:MatchItemName(itemTable)) and (not not this:MatchItemNBT(itemTable))
end

--[[
    Match Inventory/Tank
]]

--- @param this common.Modules.StorageFilter.Filter
--- @param itemList ccTweaked.peripherals.inventory.itemList | ccTweaked.peripherals.fluidstorage.fluidList
--- @return integer? index
function Filter.MatchInventoryFirst(this, itemList)
    local indexes = {}
    for k, _ in itemList do
        table.insert(indexes, k)
    end
    table.sort(indexes)
    for _, i in ipairs(indexes) do
        local itemTable = itemList[i]
        if this:MatchItem(itemTable) then
            return i
        end
    end
end

--- @param this common.Modules.StorageFilter.Filter
--- @param itemList ccTweaked.peripherals.inventory.itemList | ccTweaked.peripherals.fluidstorage.fluidList
--- @return integer[]? index
function Filter.MatchInventoryAll(this, itemList)
    local indexList = {}
    for i, itemTable in pairs(itemList) do
        if this:MatchItem(itemTable) then
            return table.insert(indexList, i)
        end
    end
    return not not next (indexList) and indexList or nil
end

--[[
    Filter Operations
]]

--- @param this common.Modules.StorageFilter.Filter
--- @param other common.Modules.StorageFilter.Filter
--- @return common.Modules.StorageFilter.Filter union
function Filter.Union(this, other)
    local function unionArrays(a, b)
        if a == nil or b == nil then return nil end -- If wildcard name, return wildcard
        local result = Array:new{}
        for _, v in ipairs(a or {}) do if not result:hasValue(v) then result:insert(v) end end
        for _, v in ipairs(b or {}) do if not result:hasValue(v) then result:insert(v) end end
        return result
    end
    --- @type common.Modules.StorageFilter.FilterTemplate
    local template = {}
    template.countLB = (this.countLB == nil or other.countLB == nil) and nil or math.min(this.countLB, other.countLB)
    template.countUB = (this.countUB == nil or other.countUB == nil) and nil or math.max(this.countLB, other.countLB)
    template.name = unionArrays(this.name, other.name)
    template.nbthash = unionArrays(this.nbthash, other.nbthash)
    template.requireMatchNBT = this.requireMatchNBT and other.requireMatchNBT
    return Filter:new(template)
end

--- @param this common.Modules.StorageFilter.Filter
--- @param other common.Modules.StorageFilter.Filter
--- @return common.Modules.StorageFilter.Filter intersection
function Filter.Intersection(this, other)
    local function intersectArray(a, b)
        if a == nil then return b end -- If a is wildcard, return b
        if b == nil then return a end -- if b is wildcard return a
        local result = Array:new{}
        for _, v in ipairs(a) do
            if b:hasValue(v) and not result:hasValue(v) then
                result:insert(v)
            end
        end
        return result
    end
    --- @type common.Modules.StorageFilter.FilterTemplate
    local template = {}
    template.countLB = (this.countLB == nil and other.countLB == nil) and nil or math.max((this.countLB or 0),(other.countLB or 0))
    template.countUB = (this.countUB == nil and other.countUB == nil) and nil or math.min((this.countLB or math.huge),(other.countLB or math.huge))
    template.name = intersectArray(this.name, other.name)
    template.nbthash = intersectArray(this.nbthash, other.nbthash)
    template.requireMatchNBT = this.requireMatchNBT or other.requireMatchNBT

    return Filter:new(template)
end

return Filter
