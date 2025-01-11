local cdm = require "common.Modules.Class.Simple"

--- TODO: Make this follow the coding style I decided on

--- @class ITestModule : IClass
--- @field testCount integer
--- @field run fun(self: TestModule): string[], string[] -- Runs tests in test module, returning passed and failed

--- @class TestModule : ITestModule, Class
--- @field tests table<string, fun(container: table)>
--- @field TAG string
--- @field dbg Logger
--- @field testInit fun(self: TestModule, container: table) -- Initialise test container

--- @class TestModuleDefinition : SimpleClassDefinition
local Test = cdm("ModuleTest") -- This is meant to hold tests for a module/group of related functionality

--- @class TestModuleDefinition.new.kwargs
--- @field Logger Logger

--- Returns a TestModule Instance
--- @param kwargs TestModuleDefinition.new.kwargs
--- @return ITestModule
function Test.new(kwargs)
    --- @type ITestModule -- Just force it to accept it
    return Test._new(kwargs)
end

--- @param this TestModule
--- @param kwargs TestModuleDefinition.new.kwargs
function Test.init(this, kwargs)
    this.TAG = this:getClassName()
    this.dbg = kwargs.Logger
    this.dbg.logV(this.TAG, "Created TestModule:", this.TAG)
end

--- @type table<string, fun(container: table)>
Test.tests = {}

--- @type integer
Test.testCount = 0

--- @class TestModule.container
--- @field TAG string
--- @field Logger Logger

--- Runs the tests in the test module, returning amount passed and failed
--- @param this TestModule
--- @return string[]? passed
--- @return string[]? failed
function Test.run(this)
    this.dbg.logI(this.TAG, "Running...")
    local passed = nil
    local failed = nil
    for testName, fn in pairs(this.tests) do
        this.dbg.logI(testName, "Running...")
        local container = { TAG = testName, Logger = this.dbg }
        this:testInit(container)
        local ok, err = pcall(fn, container)
        if ok then
            passed = passed or {}
            table.insert(passed, testName)
        else
            failed = failed or {}
            table.insert(failed, testName)
        end
    end
    return passed, failed
end

--- Is ran before every test, let's you initialise the container
--- @param this TestModule
--- @param testContainer table
function Test.testInit(this, testContainer) end

--- Adds a test to the module
--- @param testName string
--- @param testFn fun(container: table)
function Test:addTest(testName, testFn)
    self.tests[testName] = testFn
    self.testCount = self.testCount + 1
end

return Test
