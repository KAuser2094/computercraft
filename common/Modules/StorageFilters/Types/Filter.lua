--- @meta _

--- @class common.Modules.StorageFilter.FilterTemplate
--- @field countLB? integer -- Amount needed AT LEAST (Including)
--- @field countUB? integer -- Amount needed AT MOST (Including)
--- @field name? common.Modules.Tabula.Array -- Regex matching the name, also maps to "*:<name>". i.e. "chest" matches "minecraft:chest"
--- @field nbthash? common.Modules.Tabula.Array -- Matches (directly!) the nbt hash of an item.
--- @field requireMatchNBT? boolean -- Whether to use the nbthash (this is required as a "nil" nbthash could mean to match no nbt or to ignore nbt)

--- @class common.Modules.StorageFilter.Filter : common.Modules.Class.Class, common.Modules.StorageFilter.FilterTemplate
local Filter = {}

--[[
    Matching fields to an item table
]]

--- @param this common.Modules.StorageFilter.Filter
--- @param itemTable ccTweaked.peripherals.inventory.item | ccTweaked.peripherals.fluidstorage.fluid
--- @return boolean matches
function Filter.MatchItemCount(this, itemTable) end

--- @param this common.Modules.StorageFilter.Filter
--- @param itemTable ccTweaked.peripherals.inventory.item | ccTweaked.peripherals.fluidstorage.fluid
--- @return string | false matchedPatternOrFalse
function Filter.MatchItemName(this, itemTable) end

--- @param this common.Modules.StorageFilter.Filter
--- @param itemTable ccTweaked.peripherals.inventory.item | ccTweaked.peripherals.fluidstorage.fluid
--- @return string | boolean matchedNBTOrBoolean
function Filter.MatchItemNBT(this, itemTable) end

--- @param this common.Modules.StorageFilter.Filter
--- @param itemTable ccTweaked.peripherals.inventory.item | ccTweaked.peripherals.fluidstorage.fluid
--- @return boolean matches
function Filter.MatchItem(this, itemTable) end

--[[
    Match Inventory/Tank
]]

--- @param this common.Modules.StorageFilter.Filter
--- @param itemList ccTweaked.peripherals.inventory.itemList | ccTweaked.peripherals.fluidstorage.fluidList
--- @return integer? index
function Filter.MatchInventoryFirst(this, itemList) end

--- @param this common.Modules.StorageFilter.Filter
--- @param itemList ccTweaked.peripherals.inventory.itemList | ccTweaked.peripherals.fluidstorage.fluidList
--- @return integer[]? index
function Filter.MatchInventoryAll(this, itemList) end
