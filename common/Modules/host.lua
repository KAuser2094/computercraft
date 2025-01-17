--[[
    Some helper functions to work with versioning and stuff for CC itself and platform (whether that be Minecraft or some emulator)
local host = require "common.Modules.host"
]]

local module = {}

--- Extract the ComputerCraft version (Will return the `Major`, `Minor`, and `Patch` versions in seperate variables)
function module.getCCVersion()
    local cc_version = _G._HOST:match("ComputerCraft (%d+%.%d+%.%d+)")
    local major, minor, patch = cc_version:match("(%d+)%.(%d+)%.(%d+)")
    major = tonumber(major)
    minor = tonumber(minor)
    patch = tonumber(patch)

    --- @cast major integer
    --- @cast minor integer
    --- @cast patch integer

    return major, minor, patch
end

--- Returns the platform that this is running on
function module.getPlatform()
    local platform = _G._HOST:match("%(([%w%-]+)")
    return platform
end

--- Returns the Platform version. (Will return the `Major`, `Minor`, and `Patch` versions in seperate variables)
function module.getPlatformVersion()
    local platform_version = _G._HOST:match("%(.- (v?%d+%.%d+%.%d+)%)")
    local major, minor, patch = platform_version:match("v?(%d+)%.(%d+)%.(%d+)")
    major = tonumber(major)
    minor = tonumber(minor)
    patch = tonumber(patch)

    --- @cast major integer
    --- @cast minor integer
    --- @cast patch integer

    return major, minor, patch
end

--- Returns whether this is running in minecraft
--- @return boolean onMinecraft
function module.onMinecraft()
    return "Minecraft" == module.getPlatform()
end

--- Returns whether this is running on CraftOS-PC Emulator
--- @return boolean onCraftOSPC
function module.onCraftOSPC()
    return "CraftOS-PC" == module.getPlatform()
end

-- Versioning functions

--- Compares between versions and returns true if the FIRST is EARILER than the SECOND
--- @param ma1 integer
--- @param mi1 integer
--- @param pa1 integer
--- @param ma2 integer
--- @param mi2 integer
--- @param pa2 integer
--- @return boolean firstVersionIsEarlier
local function lessThan(ma1, mi1, pa1, ma2, mi2, pa2)
    if ma1 ~= ma2 then return ma1 < ma2 end
    if mi1 ~= mi2 then return mi1 < mi2 end
    if pa1 ~= pa2 then return pa1 < pa2 end
    return false -- Exactly Equal
end

--- Compares between versions and returns true if the FIRST is EARILER than the SECOND
--- @param ma1 integer
--- @param mi1 integer
--- @param pa1 integer
--- @param ma2 integer
--- @param mi2 integer
--- @param pa2 integer
--- @return boolean firstVersionIsLater
local function greaterThan(ma1, mi1, pa1, ma2, mi2, pa2)
    return lessThan(ma2, mi2, pa2, ma1, mi1, pa1)
end

--- Compares between versions and returns true if they are equal
--- @param ma1 integer
--- @param mi1 integer
--- @param pa1 integer
--- @param ma2 integer
--- @param mi2 integer
--- @param pa2 integer
local function equalTo(ma1, mi1, pa1, ma2, mi2, pa2)
    return ma1 == ma2 and mi1 == mi2 and pa1 == pa2
end

--- Whether the version CURRENTLY ON is BEFORE the target version
--- @param major? integer For Target Version
--- @param minor? integer For Target Version
--- @param patch? integer For Target Version
--- @return boolean currentlyOnOlderVersion
function module.beforeCCVersion(major, minor, patch)
    major = major or 0
    minor = minor or 0
    patch = patch or 0
    -- Is current before target == is target after or equal to current
    return equalTo(major, minor, patch, module.getCCVersion()) or greaterThan(major, minor, patch, module.getCCVersion())
end

--- Whether the version CURRENTLY ON is AFTER or EQUAL to the target version
--- @param major? integer For Target Version
--- @param minor? integer For Target Version
--- @param patch? integer For Target Version
--- @return boolean upToDateForVersion
function module.atLeastCCVersion(major, minor, patch)
    major = major or 0
    minor = minor or 0
    patch = patch or 0
    -- is current after or equal to target == is target before current
    return lessThan(major, minor, patch, module.getCCVersion())
end

--- Whether the version CURRENTLY ON is BEFORE the target version
--- @param major? integer For Target Version
--- @param minor? integer For Target Version
--- @param patch? integer For Target Version
--- @return boolean currentlyOnOlderVersion
function module.beforePlatformVersion(major, minor, patch)
    major = major or 0
    minor = minor or 0
    patch = patch or 0
    -- Is current before target == is target after or equal to current
    return equalTo(major, minor, patch, module.getPlatformVersion()) or greaterThan(major, minor, patch, module.getPlatformVersion())
end

--- Whether the version CURRENTLY ON is AFTER or EQUAL to the target version
--- @param major? integer For Target Version
--- @param minor? integer For Target Version
--- @param patch? integer For Target Version
--- @return boolean upToDateForVersion
function module.atLeastPlatformVersion(major, minor, patch)
    major = major or 0
    minor = minor or 0
    patch = patch or 0
    -- is current after or equal to target == is target before current
    return lessThan(major, minor, patch, module.getPlatformVersion())
end

--[[
    Add common versioning comparisons (like multiple peripheral types being anything equal and after 1.99)
]]
-- TODO: Read above -_-

--- Checks if peripherals have a singular type only
--- @return boolean singularTypedPeripherals
function module.peripheralSingleTyped()
    return module.beforeCCVersion(1,99)
end

--- Checks if peripherals were multi-typed
--- @return boolean multiTypedPeripherals
function module.peripheralMultiTyped()
    return module.atLeastCCVersion(1,99)
end

return module
