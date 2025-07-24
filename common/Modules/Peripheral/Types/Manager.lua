--- @meta _

--- @class common.Modules.Peripheral.Manager : common.Modules.Class.Class
--- @field names common.Modules.Tabula.Set
--- @field peripherals common.Modules.Tabula.Tabula
local Manager = {}

--[[
    PeripheralAPI, overloads
]]

--- Wraps to the highest peripheral it can
--- @param name string
--- @return common.Modules.Peripheral.Peripheral?
function Manager.wrap(name) end

--[[
    Syncing mirror to network
]]

--- Updates the names and peripherals stored within this manager
--- @param this common.Modules.Peripheral.Manager
function Manager.sync(this) end

--- Runs this in a coroutine looking for "peripheral_detach" event and pass in the name. Detaches it from the mirror.
--- @param this common.Modules.Peripheral.Manager
--- @param name string
function Manager.detach(this, name) end

--- Runs this in a coroutine looking for "peripheral_attach" event and pass in the name. Attaches it from the mirror.
--- @param this common.Modules.Peripheral.Manager
--- @param name string
function Manager.attach(this, name) end
