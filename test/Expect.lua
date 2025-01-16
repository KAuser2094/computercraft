--- @diagnostic disable: inject-field, undefined-field
local Class = require "common.Modules.Class"
local TestModule = require "common.Modules.Test.Test"
local ExampleFields = require "test.container_fields"
local pc = require "common.Modules.expect"

--- @class test.ExpectTests : common.Modules.Test.TestModuleDefinition
local ExpectTests = Class("CLASS TESTS", TestModule)

function ExpectTests:init(this, kwargs)
    TestModule.init(self, this, kwargs)
end

function ExpectTests.testInit(this, c)
    c.ClassName = ExampleFields.BASE_CLASS_NAME
    c.ClassDef =  ExampleFields.BASE_CLASS_DEFINITION
    c.Class = ExampleFields.BASE_CLASS_INSTANCE

    c.SubClassName = ExampleFields.SUB_CLASS_NAME
    c.SubClassDef = ExampleFields.SUB_CLASS_DEFINITION
    c.SubClass = ExampleFields.SUB_CLASS_INSTANCE
end

--- @class test.ExpectTests.container : common.Modules.Test.TestModule.container
--- @field ClassName string
--- @field ClassDef common.Modules.Class.ClassDefinition
--- @field Class common.Modules.Class.Class
--- @field SubClassName string
--- @field SubClassDef common.Modules.Class.ClassDefinition
--- @field SubClass common.Modules.Class.Class

--[[
ExpectTests:addTest("CHANGEME", function (container)
    --- @cast container test.ExpectTests.container
    local TAG = container.TAG
    local Dbg = container.Logger
    ---

end)
--]]

---[[
ExpectTests:addTest("Test Basic Expect Types", function (container)
    --- @cast container test.ExpectTests.container
    local TAG = container.TAG
    local Dbg = container.Logger
    ---
    pc.enableTag(TAG)


end)
--]]

return ExpectTests
