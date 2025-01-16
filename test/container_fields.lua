--- @diagnostic disable: inject-field
-- Some generic fields that can be used among tests (so you aren't constantly redefing the stuff you need to put in the container)
-- NOTE: If a test modifies the field, then you will need to create that container field in that test itself, as it will change the field for other tests to
local Class = require "common.Modules.Class"

--- @class test.ReusableContainerFields
local fields = {}

fields.BASE_CLASS_NAME = "sdgsgsgws1"
fields.BASE_CLASS_DEFINITION = Class(fields.BASE_CLASS_NAME)
fields.BASE_CLASS_DEFINITION.baseField = true
fields.BASE_CLASS_INSTANCE = fields.BASE_CLASS_DEFINITION:new()

fields.SUB_CLASS_NAME = "htghsfgdsgnjsgpag2"
fields.SUB_CLASS_DEFINITION = Class(fields.SUB_CLASS_NAME, fields.BASE_CLASS_DEFINITION)
fields.SUB_CLASS_DEFINITION.subField = true
fields.SUB_CLASS_INSTANCE = fields.SUB_CLASS_DEFINITION:new()

return fields
