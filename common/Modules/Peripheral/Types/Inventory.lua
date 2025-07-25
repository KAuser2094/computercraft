--- @meta _

--- @class common.Modules.Peripheral.Inventory : common.Modules.Peripheral.Peripheral, ccTweaked.peripherals.Inventory
local Inventory = {}

--[[
    "Better" Versions of functions
]]

--- Push items from self to `other` inventory.
--- @param this common.Modules.Peripheral.Inventory
--- @param other common.Modules.Peripheral.Inventory | ccTweaked.peripherals.Inventory | string
--- @param fromSlot integer
--- @param limit? integer
--- @param toSlot? integer
function Inventory.pushItems(this, other, fromSlot, limit, toSlot) end

--- Pull items from self to `other` inventory.
--- @param this common.Modules.Peripheral.Inventory
--- @param other common.Modules.Peripheral.Inventory | ccTweaked.peripherals.Inventory | string
--- @param fromSlot integer
--- @param limit? integer
--- @param toSlot? integer
function Inventory.pullItems(this, other, fromSlot, limit, toSlot) end
