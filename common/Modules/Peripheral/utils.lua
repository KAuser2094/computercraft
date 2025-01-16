local TAG = "Peripheral Utils"
local pc = require "common.Modules.expect"
pc.enableTag(TAG)
local utils = {}

--- Takes in a peripheral side in any form and returns the side string itself
--- @param sideOrWrappedOrClass string | ccTweaked.peripherals.wrappedPeripheral | common.Modules.Peripheral.Peripheral
--- @return string? side
function utils.getName(sideOrWrappedOrClass)
    -- Side case
    if type(sideOrWrappedOrClass) == "string" and peripheral.isPresent(sideOrWrappedOrClass) then return sideOrWrappedOrClass end
    -- Wrapped case
    --- @cast sideOrWrappedOrClass ccTweaked.peripherals.wrappedPeripheral
    if pc.isType(sideOrWrappedOrClass, pc.TYPES.wrappedPeripheral) then return peripheral.getName(sideOrWrappedOrClass) end
    -- Class case
    --- @cast sideOrWrappedOrClass common.Modules.Peripheral.Peripheral
    if type(sideOrWrappedOrClass) == "table" and sideOrWrappedOrClass.side then return sideOrWrappedOrClass.side end
end

return utils
