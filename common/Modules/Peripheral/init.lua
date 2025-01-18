--[[
    Base class for Class representation of Peripherals
]]
local Class = require "common.Modules.Class"
local pc = require "common.Modules.expect"
local TAG = "PERIPHERAL CLASS"
pc.enableTag(TAG)

-- This presumes that multi-typed peripherals are a thing, so we backport it if it is not.
require "common.Modules.BackportCC.1.99MultiTypedPeripherals".backport()

local peripheralAPI = _G.peripheral

--- @class common.Modules.Peripheral.IPeripheral : common.Modules.Class.IClass
--- @field name string -- Yes this is actually also in the proxy
--- @field type string
--- @field types ArraySet<string>
--- @field isPresent fun(self: common.Modules.Peripheral.IPeripheral): boolean -- True if this is visibly attached on the network
--- @field hasType fun(self: common.Modules.Peripheral.IPeripheral, ty: string) -- Check if `ty` is within the types of the peripheral

--- @class common.Modules.Peripheral.Peripheral : common.Modules.Peripheral.IPeripheral, common.Modules.Class.Class

--- @class common.Modules.Peripheral.PeripheralDefinition : common.Modules.Class.ClassDefinition
local Peripheral = Class("PERIPHERAL")

--- Create new Peripheral instance
--- @param nameOrWrapped string | ccTweaked.peripherals.wrappedPeripheral
--- @return common.Modules.Peripheral.Peripheral
function Peripheral:new(nameOrWrapped)
    --- @type common.Modules.Peripheral.Peripheral
    return Peripheral:rawnew(nameOrWrapped)
end

--- Init
--- @param this common.Modules.Peripheral.Peripheral
--- @param nameOrWrapped string | ccTweaked.peripherals.wrappedPeripheral -- table refers to a wrapped peripheral
function Peripheral:init(this, nameOrWrapped)
    -- TODO: Change to dbg and use dbg asserts
    pc.expectWithTag(TAG, "init.nameOrWrapped", nameOrWrapped, pc.TYPES.string, pc.TYPES.wrappedPeripheral)
    local wrapped = type(nameOrWrapped) == "string" and peripheralAPI.wrap(nameOrWrapped) or nameOrWrapped
    pc.expectWithTag(TAG, "init.wrapped", wrapped, pc.TYPES.wrappedPeripheral)
    --- @cast wrapped ccTweaked.peripherals.wrappedPeripheral

    -- Allow `this` to act like a normal wrappedPeripheral
    for k, v in pairs(wrapped) do
        rawset(this, k, v) -- Ok this doesn't really need to be rawset, but the others are so meh
    end

    local proxy = getmetatable(this)
    local mt = getmetatable(wrapped)
    for k,v in pairs(mt) do
        rawset(proxy, k, v) -- Same here
    end

    --- Make some fields explictly public, so user can see them.
    rawset(this, "name", proxy.name) -- These do I am pretty sure
    rawset(this, "type", proxy.type)
    rawset(this, "types", proxy.types)
    -- No need to make __name public, that would be weird...
end

--[[
    PeripheralAPI alias / extension
]]

--- Calls the method of a peripheral with the given args
--- @param nameOrPeripheral string | common.Modules.Peripheral.Peripheral | ccTweaked.peripherals.wrappedPeripheral
--- @param method string
--- @param ...? any
--- @return any ... Results from the call
function Peripheral.call(nameOrPeripheral, method, ...)
    --- @cast nameOrPeripheral -common.Modules.Peripheral.Peripheral
    pc.expectWithTag(TAG, "call.nameOrPeripheral", nameOrPeripheral, pc.TYPES.string, pc.TYPES.wrappedPeripheral)
    pc.expectWithTag(TAG, "call.method", method, pc.TYPES.string)
    local name --- @type string
    if type(nameOrPeripheral) == "string" then name = nameOrPeripheral
    else name = peripheralAPI.getName(nameOrPeripheral) end
    return peripheralAPI.call(name, method, ...)
end

--- Returns wrapped peripherals of found valid targets given type and filter
--- @param ty string
--- @param filter fun(name: string, wrapped: ccTweaked.peripherals.wrappedPeripheral): boolean
--- @return ccTweaked.peripherals.wrappedPeripheral? ... The found wrapped peripherals
function Peripheral.find(ty, filter)
    pc.expectWithTag(TAG, "find.ty", ty, pc.TYPES.string)
    pc.expectWithTag(TAG, "find.filter", filter, pc.TYPES["function"], pc.TYPES["nil"])
    return peripheralAPI.find(ty, filter)
end

--- Returns an array given the methods
--- @param nameOrPeripheral string | common.Modules.Peripheral.Peripheral | ccTweaked.peripherals.wrappedPeripheral
--- @return string[]? methods
function Peripheral.getMethods(nameOrPeripheral)
    --- @cast nameOrPeripheral -common.Modules.Peripheral.Peripheral
    pc.expectWithTag(TAG, "getMethods.nameOrPeripheral", nameOrPeripheral, pc.TYPES.string, pc.TYPES.wrappedPeripheral)
    local name --- @type string
    if type(nameOrPeripheral) == "string" then name = nameOrPeripheral
    else name = peripheralAPI.getName(nameOrPeripheral) end
    return peripheralAPI.getMethods(name)
end

--- Get the name of the peripheral on the network
--- @param peripheral common.Modules.Peripheral.Peripheral | ccTweaked.peripherals.wrappedPeripheral
--- @return string name
function Peripheral.getName(peripheral)
    --- @cast peripheral -common.Modules.Peripheral.Peripheral
    pc.expectWithTag(TAG, "getName.peripheral", peripheral, pc.TYPES.wrappedPeripheral)
    return peripheralAPI.getName(peripheral)
end

--- Returns all peripherals visible to the computer
--- @return string[]
function Peripheral.getNames()
    return peripheralAPI.getNames()
end

--- Gets the types of a peripheral
--- @param nameOrPeripheral string | common.Modules.Peripheral.Peripheral | ccTweaked.peripherals.wrappedPeripheral
--- @return string? ... The types
function Peripheral.getType(nameOrPeripheral)
    --- @cast nameOrPeripheral -common.Modules.Peripheral.Peripheral
    pc.expectWithTag(TAG, "getType.nameOrPeripheral", nameOrPeripheral, pc.TYPES.string, pc.TYPES.wrappedPeripheral)
    return peripheralAPI.getType(nameOrPeripheral)
end

--- Check peripheral has type
--- @param nameOrPeripheral string | common.Modules.Peripheral.Peripheral | ccTweaked.peripherals.wrappedPeripheral
--- @param peripheral_type string
--- @return boolean? hasType
function Peripheral.hasType(nameOrPeripheral, peripheral_type)
    --- @cast nameOrPeripheral -common.Modules.Peripheral.Peripheral
    pc.expectWithTag(TAG, "getType.nameOrPeripheral", nameOrPeripheral, pc.TYPES.string, pc.TYPES.wrappedPeripheral)
    return peripheralAPI.hasType(nameOrPeripheral, peripheral_type)
end

Peripheral:markPublic("hasType")

--- Check if name or peripheral exists on the visible network
--- @param nameOrPeripheral string | common.Modules.Peripheral.Peripheral | ccTweaked.peripherals.wrappedPeripheral
--- @return boolean isPresent
function Peripheral.isPresent(nameOrPeripheral)
    --- @cast nameOrPeripheral -common.Modules.Peripheral.Peripheral
    pc.expectWithTag(TAG, "isPresent.nameOrPeripheral", nameOrPeripheral, pc.TYPES.string, pc.TYPES.wrappedPeripheral)
    local name --- @type string
    if type(nameOrPeripheral) == "string" then name = nameOrPeripheral
    else name = peripheralAPI.getName(nameOrPeripheral) end
    return peripheralAPI.isPresent(name)
end

Peripheral:markPublic("isPresent")

--[[
    Metamethods
]]

--- Equal metamethod, checks whether they refer to the same side name on the network
--- @param this common.Modules.Peripheral.Peripheral
--- @param other common.Modules.Peripheral.Peripheral
function Peripheral.__eq(this, other)
    return this.name == other.name
end
Peripheral:markProxy("__eq")

--- @param this common.Modules.Peripheral.Peripheral
function Peripheral.__tostring(this)
    return this:getClassName() .. ": " .. this.name
end

return Peripheral
