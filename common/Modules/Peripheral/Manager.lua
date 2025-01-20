--[[
    Manages the peripherals visible on the network
]]

local Class = require "common.Modules.Class"
local Peripheral = require "common.Modules.Peripheral"
local Inventory = require "common.Modules.Peripheral.Inventory"
local FluidStorage = require "common.Modules.Peripheral.FluidStorage"

local Tabula = require "common.Modules.Tabula"
local Set = require "common.Modules.Tabula.Set"

local pc = require "common.Modules.expect"
local TAG = "PERIPHERAL MANAGER CLASS"
pc.enableTag(TAG)

local peripheralAPI = _G.peripheral

local DIRECTIONS = {
    top = true,
    bottom = true,
    front = true,
    back = true,
    left = true,
    right = true,
}

--- @class common.Modules.Peripheral.Manager : common.Modules.Peripheral.IManager, common.Modules.Class.Class
--- @field names common.Modules.Tabula.Set
--- @field peripherals common.Modules.Tabula.Tabula

--- @class common.Modules.Peripheral.ManagerDefinition : common.Modules.Class.ClassDefinition
local Manager = Class(TAG)


--- @return common.Modules.Peripheral.Manager
function Manager:new()
    --- @type common.Modules.Peripheral.Manager
    return Manager:rawnew()
end

--- Init
--- @param this common.Modules.Peripheral.Manager
function Manager:init(this)
    this.names = Set:new({})
    this.peripherals = Set:new({})
end

--[[
    PeripheralAPI, overloads
]]

--- Wraps to the highest peripheral it can
--- @param name string
--- @return common.Modules.Peripheral.Peripheral?
function Manager.wrap(name)
    --- @type ccTweaked.peripherals.wrappedPeripheral?
    local wrapped = peripheral.wrap(name)
    if not wrapped then return end
    local P = nil
    if wrapped.list then
        P = Inventory(wrapped)
    elseif wrapped.tanks then
        P = FluidStorage(wrapped)
    else
        P = Peripheral(wrapped)
    end
    return P
end

--[[
    Syncing mirror to network
]]

--- Updates the names and peripherals stored within this manager
--- @param this common.Modules.Peripheral.Manager
function Manager.sync(this)
    this.names:emptyTable()
    this.peripherals:emptyTable()

    for _, name in ipairs(peripheralAPI.getNames()) do
        this.names[name] = true
        this.peripherals[name] = Manager.wrap(name)
    end
end

--- Runs this in a coroutine looking for "peripheral_detach" event and pass in the name. Detaches it from the mirror.
--- @param this common.Modules.Peripheral.Manager
--- @param name string
function Manager.detach(this, name)
    if not this.names[name] then
        -- How did this happen??
        this:sync() -- Just update everything in that case
    else
        if DIRECTIONS[name] then -- We don't store the peripherals directly next to the computer (If they disconnected they likely will become new blocks)
            this.names[name] = nil
            this.peripherals[name] = nil
        else
            this.names[name] = false
        end
    end
end

--- Runs this in a coroutine looking for "peripheral_attach" event and pass in the name. Attaches it from the mirror.
--- @param this common.Modules.Peripheral.Manager
--- @param name string
function Manager.attach(this, name)
    if this.names[name] then
        -- How does this happen?
        this:sync() -- Just update everything in that case
    else
        if this.names[name] == nil then -- We do not have the peripheral stored already
            local P = this.wrap(name)
            this.peripherals[name] = P
        end
        this.names[name] = true
    end
end

return Manager
