--- Add an extra "-" to the "--[[" below to uncomment block
--[[

local Class = require "common.Modules.Class"

local pc = require "common.Modules.expect"
local TAG = "EXAMPLE CLASS"
pc.enableTag(TAG)

--- @class CHANGE_ME_TO_CLASS : common.Modules.Class.Class

--- @class CHANGE_ME_TO_CLASS_DEFINITION : common.Modules.Class.ClassDefinition
local CHANGE_ME_TO_CLASS_NAME = Class(TAG)

--- Change the "..." to actually parameters (if any) and actually implement the init function if needed

--- @return CHANGE_ME_TO_CLASS
function CHANGE_ME_TO_CLASS_NAME:new(...)
    --- @type CHANGE_ME_TO_CLASS
    return CHANGE_ME_TO_CLASS_NAME:rawnew(...)
end

--- Init
--- @param this CHANGE_ME_TO_CLASS
function CHANGE_ME_TO_CLASS_NAME:init(this, ...)

end

return CHANGE_ME_TO_CLASS_NAME

--]]
