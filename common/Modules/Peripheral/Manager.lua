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

--- @class common.Modules.Peripheral.Manager : common.Modules.Class.Class
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
    this.peripherals = Tabula:new({})
end

--- Check if name is a peripheral on the network
--- @param name string
--- @return boolean
function Manager.isSide(name)
    return not not Tabula.hasValue(peripheral.getNames(), name)
end

--- Wraps to the highest peripheral it can
--- @param name string
--- @return common.Modules.Peripheral.Peripheral?
function Manager.wrap(name)
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


return Manager
