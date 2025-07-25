local Class = require "common.Modules.Class"

local pc = require "common.Modules.expect"
local TAG = "SUPER FACTORY MANAGER PROGRAM CLASS"
pc.enableTag(TAG)

--- @alias apps.SFM.Program.Blocks.item.mode
--- | "CONDITON"
--- | "EVERY BLOCK"

--- @class apps.SFM.Program.Blocks.item
--- @field label string
--- @field filters common.Modules.StorageFilter.Filter[]
--- @field mode apps.SFM.Program.Blocks.item.mode

--- @class apps.SFM.Program.Blocks
--- @field conditions apps.SFM.Program.Blocks.item[] -- Conditions are a disjunction of conjunctions.
--- @field inputs apps.SFM.Program.Blocks.item[]
--- @field outputs apps.SFM.Program.Blocks.item[]

--- @class apps.SFM.Program :common.Modules.Class.Class
--- @field name string
--- @field active boolean
--- @field interval integer
--- @field blocks apps.SFM.Program.Blocks

--- @class apps.SFM.ProgramDefinition : common.Modules.Class.ClassDefinition
local Program = Class(TAG)

--- @return apps.SFM.Program
function Program:new(serialisedProgram)
    --- @type apps.SFM.Program
    return Program:rawnew(serialisedProgram)
end

--- Init
--- @param this apps.SFM.Program
function Program:init(this, serialisedProgram)
    serialisedProgram = serialisedProgram or {}

end

return Program
