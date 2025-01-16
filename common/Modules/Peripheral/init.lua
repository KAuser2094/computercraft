--[[
    Base class for Class representation of Peripherals
]]
local Class = require "common.Modules.Class"
local utils = require "common.Modules.Peripheral.utils"

local EmuAPI = require "common.Modules.CraftOSAPI.init"
EmuAPI.overloadIfNeeded() -- This is already ran, this is just here to be explicit

local peripheral = _G.peripheral

--- @class common.Modules.Peripheral.IPeripheral : common.Modules.Class.IClass -- I wanted to inherit from the "wrappedPeripheral" type ccTweaked addon gives, but it includes ALL methods
--- @field side string
--- @field wrapped ccTweaked.peripherals.wrappedPeripheral

--- @class common.Modules.Peripheral.Peripheral : common.Modules.Peripheral.IPeripheral, common.Modules.Class.Class


--- @class common.Modules.Peripheral.PeripheralDefinition : common.Modules.Class.ClassDefinition
local Peripheral = Class("PERIPHERAL")

--- Init
--- @param this common.Modules.Peripheral.Peripheral
--- @param nameOrWrapped string | ccTweaked.peripherals.wrappedPeripheral -- table refers to a wrapped peripheral
function Peripheral:init(this, nameOrWrapped)
    -- TODO: Change to dbg and use dbg asserts
    this.side = assert(utils.getName(nameOrWrapped))
    this.wrapped = assert(peripheral.wrap(this.side))
    -- TODO: Type/Types

    -- Allow this to act like a normal wrappedPeripheral
    for k, v in pairs(this.wrapped) do
        this[k] = v
    end
end

--- Check if this peripheral is actually attached still
--- @param this common.Modules.Peripheral.Peripheral
function Peripheral.onNetwork(this)
    return peripheral.isPresent(this.side)
end

--- Equal metamethod, checks whether they refer to the same side name on the network
--- @param this common.Modules.Peripheral.Peripheral
--- @param other common.Modules.Peripheral.Peripheral
function Peripheral.__eq(this, other)
    return this.side == other.side
end
Peripheral:markProxy("__eq")

--- @param this common.Modules.Peripheral.Peripheral
function Peripheral.__tostring(this)
    return this:getClassName() .. ": " .. this.side
end

return Peripheral
