
--- @class common.Modules.Test.TestModuleDefinition
local Test = {}
Test.__index = Test

--- Creates a new Testing Module
--- @param MODULE_NAME string
--- @param DEBUGGER common.Logger
--- @return common.Modules.Test.TestModule -- The module instance
function Test:new(MODULE_NAME, DEBUGGER)
    --- @class common.Modules.Test.TestModule : common.Modules.Test.TestModuleDefinition
    local t = setmetatable({}, self)
    --- @type table<string, fun(ctx: common.Modules.Test.BaseContext)>
    t.tests = {}
    t.testCount = 0
    t.TAG = MODULE_NAME
    t.dbg = DEBUGGER
    t.dbg.logV(t.TAG, "Created TestModule:", t.TAG)
    return t
end

--- @class common.Modules.Test.BaseContext
--- @field TAG string
--- @field debugger common.Logger

--- Ran before each test in module.
--- @param this common.Modules.Test.TestModule - The module instance
--- @param ctx table
--- @return common.Modules.Test.BaseContext populated_ctx
function Test.testInitialise(this, ctx)
    ctx.debugger = this.dbg
    ctx.TAG = this.TAG
    return ctx
end

--- Ran after each test in module. (This probably should never need to be used)
--- @param this common.Modules.Test.TestModule - The module instance
--- @param ctx common.Modules.Test.BaseContext
function Test.testCleanUp(this, ctx) end

--- Adds a test to the module
--- @param this common.Modules.Test.TestModule - The module instance
--- @param testName string
--- @param test_fn fun(ctx: common.Modules.Test.BaseContext)
function Test.addTest(this, testName, test_fn)
    this.tests[testName] = test_fn
    this.testCount = this.testCount + 1
end

return Test
