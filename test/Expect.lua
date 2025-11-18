--- @diagnostic disable: inject-field, undefined-field
local TestModule = require "common.Modules.Test.Test"
local DEBUGGER = require "common.Modules.Logger".singleton -- Let's not spam create loggers

local pc = require "common.Modules.expect"
local ExampleFields = require "test.contexts.Class"

local ExpectTest = TestModule:new("Expect Test", DEBUGGER)

--- @class test.Expect.Context : common.Modules.Test.BaseContext
--- @field ClassName string
--- @field ClassDef common.Modules.Class.ClassDefinition
--- @field Class common.Modules.Class.Class
--- @field SubClassName string
--- @field SubClassDef common.Modules.Class.ClassDefinition
--- @field SubClass common.Modules.Class.Class
--- @field fn function
--- @field thread thread
--- @field callableTbl table

local fn = function () end
local thread = coroutine.create(fn)
local callableTbl = setmetatable({}, { __call = function () end })

--- Test Specific initialisation of test context
--- @param ctx table
--- @return test.Expect.Context ctx
function ExpectTest:testInitialise(ctx)
    ctx = TestModule.testInitialise(self, ctx)
    --- Cast ctx to appropriate if needed:
    --- @cast ctx test.Expect.Context
    ctx.ClassName = ExampleFields.BASE_CLASS_NAME
    ctx.ClassDef =  ExampleFields.BASE_CLASS_DEFINITION
    ctx.Class = ExampleFields.BASE_CLASS_INSTANCE

    ctx.SubClassName = ExampleFields.SUB_CLASS_NAME
    ctx.SubClassDef = ExampleFields.SUB_CLASS_DEFINITION
    ctx.SubClass = ExampleFields.SUB_CLASS_INSTANCE

    ctx.fn = fn
    ctx.thread = thread
    ctx.callableTbl = callableTbl
    return ctx
end

function ExpectTest:testCleanUp(ctx) end

---[[

ExpectTest:addTest("TEST EXPECT FUNCTIONS RUN AND ERROR", function (ctx)
    --- @cast ctx test.Expect.Context
    local TAG = ctx.TAG
    local dbg = ctx.debugger
    ---
    pc.enableTag(TAG)

    local expectRunsArgs = {
        -- Base types
        {TAG, "index", nil, "nil"},
        {TAG, "index", true, nil, "boolean"}, {TAG, "index", false, "djfaoafsa", {} , "boolean"}, -- Add extra tests for nil passed in and it actually checking later types
        {TAG, "index", "value", "string"},
        {TAG, "index", 0, "number"},
        {TAG, "index", ctx.fn, "function"},
        {TAG, "index", {}, "table"},
        {TAG, "index", ctx.thread, "thread"},
        -- Extra types
        {TAG, "index", 1, pc.TYPES.integer},
        {TAG, "index", ctx.fn, pc.TYPES.callable}, {TAG, "index", ctx.callableTbl, pc.TYPES.callable},
        {TAG, "index", ctx.Class, pc.TYPES.Class},
        {TAG, "index", ctx.ClassDef, pc.TYPES.ClassDefinition},
        -- Class
        {TAG, "index", ctx.SubClass, ctx.SubClassName},
        {TAG, "index", ctx.SubClass, ctx.SubClass},
        {TAG, "index", ctx.SubClass, ctx.SubClassDef},
        {TAG, "index", ctx.SubClass, ctx.ClassName},
        {TAG, "index", ctx.SubClass, ctx.Class},
        {TAG, "index", ctx.SubClass, ctx.ClassDef},
    }

    for _, args in ipairs(expectRunsArgs) do
        dbg.assertFunctionRunsWithTag(TAG, pc.expectWithTag, args, dbg.buildString("Failed expect given args: ", args))
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
        {TAG, "index", ctx.Class, pc.TYPES.ClassDefinition},
        {TAG, "index", ctx.ClassDef, pc.TYPES.Class},
        -- Class
        {TAG, "index", ctx.Class, ctx.SubClassName},
        {TAG, "index", ctx.Class, ctx.SubClass},
        {TAG, "index", ctx.Class, ctx.SubClassDef},
    }

    dbg.logT(TAG, "(IGNORE IF THIS IS ON TERMINAL)", "ANY FOLLOWING ERRORS IN LOG FILE ARE TO BE EXPECTED, CHECKING IF FUNCTIONS DOES ERROR")
    for _, args in ipairs(expectErrorsArgs) do
        dbg.assertFunctionErrorsWithTag(TAG, pc.expectWithTag, args, dbg.buildString("Succeeded (expected fail) expect given args: ", args))
    end
    dbg.logT(TAG, "(IGNORE IF THIS IS ON TERMINAL)", "END OF CHECKING IF FUNCTIONS ERROR")
end)

--]]


return ExpectTest
