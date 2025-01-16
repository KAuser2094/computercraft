--- @diagnostic disable: inject-field, undefined-field
local Class = require "common.Modules.Class"
local TestModule = require "common.Modules.Test.Test"
local ExampleFields = require "test.container_fields"
local pc = require "common.Modules.expect"

--- @class test.ExpectTests : common.Modules.Test.TestModuleDefinition
local ExpectTests = Class("EXPECT TESTS", TestModule)

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

    c.fn = function () end
    c.thread = coroutine.create(c.fn)
    c.callableTbl = setmetatable({}, { __call = function () end })
end

--- @class test.ExpectTests.container : common.Modules.Test.TestModule.container
--- @field ClassName string
--- @field ClassDef common.Modules.Class.ClassDefinition
--- @field Class common.Modules.Class.Class
--- @field SubClassName string
--- @field SubClassDef common.Modules.Class.ClassDefinition
--- @field SubClass common.Modules.Class.Class
--- @field fn function
--- @field thread thread
--- @field callableTbl table

--[[
ExpectTests:addTest("CHANGEME", function (container)
    --- @cast container test.ExpectTests.container
    local TAG = container.TAG
    local Dbg = container.Logger
    ---

end)
--]]

---[[
ExpectTests:addTest("TEST EXPECT FUNCTIONS RUN AND ERROR", function (container)
    --- @cast container test.ExpectTests.container
    local TAG = container.TAG
    local Dbg = container.Logger
    ---
    pc.enableTag(TAG)

    local expectRunsArgs = {
        -- Base types
        {TAG, "index", nil, "nil"},
        {TAG, "index", true, nil, "boolean"}, {TAG, "index", false, "djfaoafsa", {} , "boolean"}, -- Add extra tests for nil passed in and it actually checking later types
        {TAG, "index", "value", "string"},
        {TAG, "index", 0, "number"},
        {TAG, "index", container.fn, "function"},
        {TAG, "index", {}, "table"},
        {TAG, "index", container.thread, "thread"},
        -- Extra types
        {TAG, "index", 1, pc.TYPES.integer},
        {TAG, "index", container.fn, pc.TYPES.callable}, {TAG, "index", container.callableTbl, pc.TYPES.callable},
        {TAG, "index", container.Class, pc.TYPES.Class},
        {TAG, "index", container.ClassDef, pc.TYPES.ClassDefinition},
        -- Class
        {TAG, "index", container.SubClass, container.SubClassName},
        {TAG, "index", container.SubClass, container.SubClass},
        {TAG, "index", container.SubClass, container.SubClassDef},
        {TAG, "index", container.SubClass, container.ClassName},
        {TAG, "index", container.SubClass, container.Class},
        {TAG, "index", container.SubClass, container.ClassDef},
    }

    for _, args in ipairs(expectRunsArgs) do
        Dbg.assertFunctionRunsWithTag(TAG, pc.expectWithTag, args, Dbg.buildString("Failed expect given args: ", args))
    end

    local expectErrorsArgs = {
        -- Base types
        {TAG, "index", {}, "nil", "string", "integer", "fadjofoafn"},
        {TAG, "index", nil, "boolean"}, {TAG, "index", nil, "boolean"},
        {TAG, "index", nil, "string"},
        {TAG, "index", nil, "number"},
        {TAG, "index", nil, "function"},
        {TAG, "index", nil, "table"},
        {TAG, "index", nil, "thread"},
        -- Extra types
        {TAG, "index", 1.5, pc.TYPES.integer},
        {TAG, "index", nil, pc.TYPES.callable}, {TAG, "index", {}, pc.TYPES.callable},
        {TAG, "index", container.Class, pc.TYPES.ClassDefinition},
        {TAG, "index", container.ClassDef, pc.TYPES.Class},
        -- Class
        {TAG, "index", container.Class, container.SubClassName},
        {TAG, "index", container.Class, container.SubClass},
        {TAG, "index", container.Class, container.SubClassDef},
    }

    Dbg.logT(TAG, "(IGNORE IF THIS IS ON TERMINAL)", "ANY FOLLOWING ERRORS IN LOG FILE ARE TO BE EXPECTED, CHECKING IF FUNCTIONS DO ERROR")
    for _, args in ipairs(expectErrorsArgs) do
        Dbg.assertFunctionErrorsWithTag(TAG, pc.expectWithTag, args, Dbg.buildString("Succeeded (expected fail) expect given args: ", args))
    end
    Dbg.logT(TAG, "(IGNORE IF THIS IS ON TERMINAL)", "END OF CHECKING IF FUNCTIONS ERROR")
end)
--]]

return ExpectTests
