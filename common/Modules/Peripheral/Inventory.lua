--[[
    A class representation of the inventory peripheral, with other features
]]

local Class = require "common.Modules.Class"
local Peripheral = require "common.Modules.Peripheral"

local pc = require "common.Modules.expect"
local TAG = "INVENTORY CLASS"
pc.enableTag(TAG)


--- @class common.Modules.Peripheral.InventoryDefinition : common.Modules.Peripheral.PeripheralDefinition, ccTweaked.peripherals.Inventory
local Inventory = Class(TAG, Peripheral)

--- @param nameOrWrapped string | ccTweaked.peripherals.wrappedPeripheral
--- @return common.Modules.Peripheral.Inventory
function Inventory:new(nameOrWrapped)
    --- @type common.Modules.Peripheral.Inventory
    return Inventory:rawnew(nameOrWrapped)
end

--- @param this common.Modules.Peripheral.Inventory
--- @param nameOrWrapped string | ccTweaked.peripherals.wrappedPeripheral -- table refers to a wrapped peripheral
function Inventory:init(this, nameOrWrapped)
    Peripheral.init(self, this, nameOrWrapped)
    -- Redifine as the above block overwrites with the normal versions
    this.pushItems = function (_this, other, fromSlot, limit, toSlot) return Inventory.pushItems(_this, other, fromSlot, limit, toSlot) end
    this.pullItems = function (_this, other, fromSlot, limit, toSlot) return Inventory.pullItems(_this, other, fromSlot, limit, toSlot) end
end

--[[
    "Better" Versions of functions
]]

--- Push items from self to `other` inventory.
--- @param this common.Modules.Peripheral.Inventory
--- @param other common.Modules.Peripheral.Inventory | ccTweaked.peripherals.Inventory | string
--- @param fromSlot integer
--- @param limit? integer
--- @param toSlot? integer
function Inventory.pushItems(this, other, fromSlot, limit, toSlot)
    -- TODO: Add expect
    local otherName
    if type(other) == "string" then otherName = other
    else otherName = Inventory.getName(other) end
    return peripheral.call(this.name, "pushItems", otherName, fromSlot, limit, toSlot)
end

--- Pull items from self to `other` inventory.
--- @param this common.Modules.Peripheral.Inventory
--- @param other common.Modules.Peripheral.Inventory | ccTweaked.peripherals.Inventory | string
--- @param fromSlot integer
--- @param limit? integer
--- @param toSlot? integer
function Inventory.pullItems(this, other, fromSlot, limit, toSlot)
    -- TODO: Add expect
    local otherName
    if type(other) == "string" then otherName = other
    else otherName = Inventory.getName(other) end
    return peripheral.call(this.name, "pullItems", otherName, fromSlot, limit, toSlot)
end


--[[
    Some extra helper functions
]]

--- Returns whether the inventory had all slots filled (NOT whether it is full itself, vanilla CC Tweaked does not have a reasonable way to do that)
--- @param this common.Modules.Peripheral.Inventory | ccTweaked.peripherals.wrappedPeripheral
--- @return boolean allSlotsHaveItem
function Inventory.doAllSlotsHaveItem(this)
    return #this.list() == this.size()
end

--- Returns the amount of slots filled in the inventory
--- @param this common.Modules.Peripheral.Inventory | ccTweaked.peripherals.wrappedPeripheral
--- @return integer slotCountWithItem
function Inventory.getCountSlotsWithItem(this)
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
    return not not next(this.list())
end

return Inventory
