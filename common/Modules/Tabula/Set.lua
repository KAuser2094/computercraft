local Class = require "common.Modules.Class"
local Tabula = require "common.Modules.Tabula"

local pc = require "common.Modules.expect"
local TAG = "SET"
pc.enableTag(TAG)

--- @class common.Modules.Tabula.Set : common.Modules.Tabula.Tabula

--- @class common.Modules.Tabula.SetDefinition : common.Modules.Tabula.TabulaDefinition
local Set = Class(TAG, Tabula)

--- Ceates a tabula array intance
--- @param baseSet { [any]: true } | table -- NOTE: This will deep merge its k-v pairs into the instance table
--- @return common.Modules.Tabula.Set
function Set:new(baseSet)
    --- @type common.Modules.Tabula.Set
    return Set:rawnew(baseSet)
end


return Set
