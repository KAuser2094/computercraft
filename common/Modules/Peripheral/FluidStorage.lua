
local Class = require "common.Modules.Class"
local Peripheral = require "common.Modules.Peripheral"

local pc = require "common.Modules.expect"
local TAG = "FLUID STORAGE CLASS"
pc.enableTag(TAG)

--- @class common.Modules.Peripheral.FluidStorage : common.Modules.Peripheral.Peripheral, ccTweaked.peripherals.FluidStorage


--- @class common.Modules.Peripheral.FluidStorageDefinition : common.Modules.Peripheral.PeripheralDefinition, ccTweaked.peripherals.FluidStorage
local FluidStorage = Class(TAG, Peripheral)

--- @param nameOrWrapped string | ccTweaked.peripherals.wrappedPeripheral
--- @return common.Modules.Peripheral.FluidStorage
function FluidStorage:new(nameOrWrapped)
    --- @type common.Modules.Peripheral.FluidStorage
    return FluidStorage:rawnew(nameOrWrapped)
end

return FluidStorage
