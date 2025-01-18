--[[
    A class representation of the inventory peripheral, with other features
]]

local Class = require "common.Modules.Class"
local Peripheral = require "common.Modules.Peripheral"

local pc = require "common.Modules.expect"
local TAG = "INVENTORY CLASS"
pc.enableTag(TAG)

--- @class common.Modules.Peripheral.Inventory : common.Modules.Peripheral.Peripheral, ccTweaked.peripherals.Inventory


--- @class common.Modules.Peripheral.InventoryDefinition : common.Modules.Peripheral.PeripheralDefinition, ccTweaked.peripherals.Inventory
local Inventory = Class(TAG, Peripheral)

--- @param nameOrWrapped string | ccTweaked.peripherals.wrappedPeripheral
--- @return common.Modules.Peripheral.Inventory
function Inventory:new(nameOrWrapped)
    --- @type common.Modules.Peripheral.Inventory
    return Inventory:rawnew(nameOrWrapped)
end

--[[
    Some extra helper functions
]]

--- Returns whether the inventory had all slots filled (NOT whether it is full itself, vanilla CC Tweaked does not have a reasonable way to do that)
--- @param this common.Modules.Peripheral.Inventory | ccTweaked.peripherals.wrappedPeripheral
--- @return boolean allSlotsHaveItem
function Inventory.isAllSlotsHaveItem(this)
    return #this.list() == this.size()
end

--- Returns the amount of slots filled in the inventory
--- @param this common.Modules.Peripheral.Inventory | ccTweaked.peripherals.wrappedPeripheral
--- @return integer slotCountWithItem
function Inventory.getCountlotsWithItem(this)
    local count = 0
    for _, _ in pairs(this.list()) do
        count = count + 1
    end
    return count
end

--- Check to see if inventory is empty
--- @param this common.Modules.Peripheral.Inventory | ccTweaked.peripherals.wrappedPeripheral
--- @return boolean empty
function Inventory.isEmpty(this)
    local _, value = next(this.list())
    return not not value
end

return Inventory
