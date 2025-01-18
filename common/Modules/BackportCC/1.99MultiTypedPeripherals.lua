--- @diagnostic disable: deprecated
--[[
    Backports multityped peripherals, before CC v1.99 peripherals would only have a singular type. this gets changed to have multiple types instead and functions to help that

    This includes:
    - wrap: (will also include the single typed field) but includes the "types" metatable field now
    - getType: will return multiple types
    - hasType: Added, used to check through types
    - find: when given a "type" can now also search for secondary/generic peripheral typing

    It also gives the option to call the old functions, by running in an environment without the overloads

    NOTE: We only change "_ENV" NOT "_G" this means that the change is within the running programs environment only. Any other program will act as normal

    Use "backportGlobal" to do that, however note that it has no check on if it is already loaded as there is no reasonable way to check that.
]]

local host = require "common.Modules.host"
local expect = require "cc.expect".expect -- Using this given the original does.

-- Isolate old wrap and getType to avoid conflicts and circular references/stack overflow
local isolatedEnv = setmetatable({}, { __index = _ENV })

isolatedEnv.peripheral = {} -- Make sure it accessed the old peripheral api not the replaced one

for k,v in pairs(_G.peripheral) do
    isolatedEnv.peripheral[k] = v
end

local oldWrap = _G.peripheral.wrap
local oldGetType = _G.peripheral.getType
local oldFind = _G.peripheral.find
local isolatedWrap = setfenv(oldWrap, isolatedEnv) -- I could probably find a way to do this in an actually lua 5.2 way but I am lazy, so setfenv it is
local isolatedGetType = setfenv(oldGetType, isolatedEnv)
local isolatedFind = setfenv(oldFind, isolatedEnv)

 -- TODO: Add "expect" type checking to all of these

 --- Wrap a side into a peripheral
 --- @param side string
 --- @return ccTweaked.peripherals.wrappedPeripheral? wrapped
local function wrap(side)
    local wrapped = isolatedWrap(side)
    if not wrapped then return nil end
    local mt = getmetatable(wrapped)
    mt.type = isolatedGetType(side)
    mt.types = { isolatedGetType(side)} -- First item being this and unpacking ensures anything expecting old getType will still work
    -- Add types as needed (Using cast to easily find the methods I want to use to confirm type)
    --- @cast wrapped ccTweaked.peripherals.Inventory
    if wrapped.list then table.insert(mt.types, "inventory") end
    --- @cast wrapped ccTweaked.peripherals.FluidStorage
    if wrapped.tanks then table.insert(mt.types, "fluid_storage") end
    --- @cast wrapped ccTweaked.peripherals.EnergyStorage
    if wrapped.getEnergyCapacity then table.insert(mt.types, "energy_stroage") end
    --- @cast wrapped ccTweaked.peripherals.Modem
    if wrapped.isWireless and not wrapped.isWireless() then table.insert(mt.types, "peripheral_hub") end -- SPECIFICALLY wired modems
    ---- @cast wrapped ccTweaked.peripherals.WiredModem
    -- Already has its type
    --- @cast wrapped ccTweaked.peripherals.Printer
    -- Already has its type
    --- @cast wrapped ccTweaked.peripherals.Speaker
    -- Already has its type
    --- @cast wrapped ccTweaked.peripherals.Drive
    -- Already has its type
    --- @cast wrapped ccTweaked.peripherals.Computer
    -- Already has its type
    --- @cast wrapped ccTweaked.peripherals.Command
    -- TODO: ?
    --- @cast wrapped ccTweaked.peripherals.Monitor
    -- Already has its type

    for _, ty in ipairs(mt.types) do
        mt.types[ty] = true
    end

    return wrapped
end

--- Get the type(s) from the peripheral
--- @param peripheral string | ccTweaked.peripherals.wrappedPeripheral
--- @return string? ... The types
local function getType(peripheral)
    expect(1, peripheral, "string", "table")
    local wrapped = type(peripheral) == "string" and wrap(peripheral) or peripheral
    if not wrapped then return nil end
    -- Confirm it actually is a peripheral
    if type(wrapped) ~= "table" or not getmetatable(wrapped) or not getmetatable(wrapped).__name == "peripheral" then
        error("getType expected a wrapped peripheral with types set, as a string was not passed in, did not get it", 2)
    end
    --- @cast wrapped ccTweaked.peripherals.wrappedPeripheral

    local mt = getmetatable(wrapped)
    if not mt.types then mt.types = getmetatable(wrap(mt.name)).types end -- Updates the wrapped peripheral if it was made before this overload
    return table.unpack(mt.types)
end

--- Returns if the passed in type exists within the peripheral's types
--- @param peripheral string | ccTweaked.peripherals.wrappedPeripheral
--- @param peripheralType string
--- @return boolean? hasType -- Only nil-able because original is
local function hasType(peripheral, peripheralType)
    expect(1, peripheral, "string", "table")
    expect(2, peripheralType, "string")

    local types = { _G.peripheral.getType(peripheral) }
    for _, ty in ipairs(types) do
        if ty == peripheralType then return true end
    end
    return false
end

--- Finds and returns wrapped peripherals which have the given type and pass the filter
--- @param peripheralType string
--- @param filter fun(name: string, wrapped: ccTweaked.peripherals.wrappedPeripheral): boolean
--- @return ccTweaked.peripherals.wrappedPeripheral? ... The found peripherals, all wrapped
local function find(peripheralType, filter)
    expect(1, peripheralType, "string")
    --- @diagnostic disable-next-line: param-type-mismatch
    expect(2, filter, "function", "nil") -- WHY DOES THE CC TWEAKED LUA LS ADDON HAVE THE LITERALS INCOMPLETE ????

    local found = {}
    for _, side in ipairs(_G.peripheral.getNames()) do
        if hasType(side, peripheralType) then
            local wrapped = wrap(side)
            --- @cast wrapped ccTweaked.peripherals.wrappedPeripheral
            if filter == nil or filter(side, wrapped) then
                table.insert(found, wrapped)
            end
        end
    end
    return table.unpack(found)
end

local module = {}

function module.backportGlobal(forceOverload)
    if forceOverload or (host.peripheralSingleTyped() and not _G.peripheral.backportMultiTypes) then

        _G.peripheral.wrap = wrap
        _G.peripheral.getType = getType
        _G.peripheral.hasType = hasType
        _G.peripheral.find = find

        -- Stop running this over and over for no reasons
        _G.peripheral.backportMultiTypes = true
    end
end

function module.backport(forceOverload)
    if forceOverload or (host.peripheralSingleTyped() and not _ENV.peripheral.backportMultiTypes) then

        _ENV.peripheral.wrap = wrap
        _ENV.peripheral.getType = getType
        _ENV.peripheral.hasType = hasType
        _ENV.peripheral.find = find

        -- Stop running this over and over for no reasons
        _ENV.peripheral.backportMultiTypes = true
    end
end

--- Boolean to see if this has been ran once in this script
--- @return boolean alreadyOverloaded
function module.hasBackportedAlready()
    return _ENV.peripheral.backportMultiTypes
end

-- TODO: Add warnings that if there was a global backport outside this script that these are incorrect, right now we presume that you would only use local backport

--- Runs old wrap before overload
--- @param side string
--- @return ccTweaked.peripherals.wrappedPeripheral? wrappedPeripheral
function module.oldWrap(side)
    return isolatedWrap(side)
end

--- Runs old getType
--- @param peripheral string | ccTweaked.peripherals.wrappedPeripheral
--- @return string
function module.oldGetTyoe(peripheral)
    return isolatedGetType(peripheral)
end

--- Runs old find
--- @param peripheralType string
--- @param filter fun(name: string, wrapped: ccTweaked.peripherals.wrappedPeripheral):boolean
--- @return ccTweaked.peripherals.wrappedPeripheral? ... Returns multiple: whatever is found
function module.oldFind(peripheralType, filter)
    return isolatedFind(peripheralType, filter)
end

return module
