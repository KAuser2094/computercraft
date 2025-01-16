local Class = require "common.Modules.Class"
local TAG = "TEST MODULE BASE"
local Dbg = require "common.Modules.Logger".singleton
Dbg = Dbg.setTagLevel(TAG, Dbg.Levels.Warning)

--- @class common.Modules.Test.ITestModule : common.Modules.Class.IClass
--- @field testCount integer
--- @field run fun(self: common.Modules.Test.TestModule): string[], string[] -- Runs tests in test module, returning passed and failed

--- @class common.Modules.Test.TestModule : common.Modules.Test.ITestModule, common.Modules.Class.Class
--- @field tests table<string, fun(container: table)>
--- @field TAG string
--- @field dbg common.Logger
--- @field testInit fun(self: common.Modules.Test.TestModule, container: table) -- Initialise test container
--- @field testCleanUp fun(self: common.Modules.Test.TestModule, container: table) -- Clean up after each test

--- @class common.Modules.Test.TestModuleDefinition : common.Modules.Class.ClassDefinition
local TestModule = Class("TEST_MODULE")

--- @type table<string, fun(container: table)>
TestModule.tests = {}

--- @type integer
TestModule.testCount = 0

--- This ensures that every new test module definition starts with an empty table (As we use the table to store tests)
--- @param klass common.Modules.Test.TestModuleDefinition -- Technically not yet this type, but we can presume it so
function TestModule:postInheritInto(klass)
    klass.tests = {}
    klass.testCount = 0
end

--- @class common.Modules.Test.TestModuleDefinition.new.kwargs
--- @field Logger common.Logger

--- Create a TestModule instance
--- @param kwargs common.Modules.Test.TestModuleDefinition.new.kwargs
--- @return common.Modules.Test.TestModule
function TestModule:new(kwargs)
    --- @type common.Modules.Test.TestModule
    return self:rawnew(kwargs)
end

--- Init
--- @param this common.Modules.Test.TestModule
--- @param kwargs common.Modules.Test.TestModuleDefinition.new.kwargs
function TestModule:init(this, kwargs)
    this.TAG = this:getClassName()
    this.dbg = kwargs.Logger
    this.dbg.logV(this.TAG, "Created TestModule:", this.TAG)
end

--- @class common.Modules.Test.TestModule.container
--- @field TAG string
--- @field Logger common.Logger

--- Is ran before every test, let's you initialise the container
--- @param this common.Modules.Test.TestModule
--- @param testContainer table
function TestModule.testInit(this, testContainer) end

--- Is ran after every test, let's you clean up any changes you don't want to affect other tests (whether same module or not)
--- @param this common.Modules.Test.TestModule
--- @param testContainer table
function TestModule.testCleanUp(this, testContainer) end

--- Adds a test to the module
--- @param testName string
--- @param testFn fun(container: table)
function TestModule:addTest(testName, testFn)
    self.tests[testName] = testFn
    self.testCount = self.testCount + 1
end

--- Runs the tests in the test module, returning amount passed and failed
--- @param this common.Modules.Test.TestModule
--- @return string[]? passed
--- @return string[]? failed
function TestModule.run(this)
    this.dbg.logI(this.TAG, "Running...")
    local passed = nil
    local failed = nil
    for testName, fn in pairs(this.tests) do
        this.dbg.logI(testName, "Running...")
        local container = { TAG = testName, Logger = this.dbg }
        this:testInit(container)
        local ok, _ = pcall(fn, container)
        if ok then
            passed = passed or {}
            table.insert(passed, testName)
        else
            failed = failed or {}
            table.insert(failed, testName)
        end
        this:testCleanUp(container)
    end
    return passed, failed
end

return TestModule
