local Class = require "common.Modules.Class"
local PeripheralManager = require "common.Modules.Peripheral.Manager"

local Relation = require "common.Modules.Tabula.Relation"

local pc = require "common.Modules.expect"
local TAG = "SUPER FACTORY MANAGER CONTROLLER CLASS"
pc.enableTag(TAG)

local SFM_SETTINGS_KEYS = {
    BLOCK_TO_LABELS = "Kastel.SFM_Block_To_Labels",
    PROGRAMS = "Kastel.SFM_Programs",
}

--- @class apps.SFM.Controller : common.Modules.Peripheral.Manager
--- @field blockToLabelRelation common.Modules.Tabula.Relation -- Block is Source, Label is Target
--- field prgorams { [string] : apps.SFM.Programs}

--- @class apps.SFM.ControllerDefinition : common.Modules.Peripheral.ManagerDefinition
local SFM = Class(TAG, PeripheralManager)

--- @return apps.SFM.Controller
function SFM:new()
    --- @type apps.SFM.Controller
    return SFM:rawnew()
end

--- Init
--- @param this apps.SFM.Controller
function SFM:init(this)
    PeripheralManager.init(self, this)
    this.blockToLabelRelation = Relation:new(settings.get(SFM_SETTINGS_KEYS.BLOCK_TO_LABELS) or {})
end

--- Runs this in a coroutine looking for "peripheral_attach" event and pass  in the name. Attaches it from the mirror.
--- @param this apps.SFM.Controller
--- @param name string
function SFM.attach(this, name)
    PeripheralManager.attach(this,name)
end

return SFM
