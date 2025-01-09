local cdm = require "common.Modules.Class.SimpleClass"

--- @class TestModule : IClass
--- @field tests function[]
--- @field testCount integer
--- @field TAG string
--- @field dbg Logger
--- @field testInit fun(self: TestModule, container: table) -- Initialise test container
--- @field run fun(self: TestModule): string[], string[] -- Runs tests in test module, returning passed and failed

--- @class TestModuleDefinition : ISimpleClassDefinition
local Test = cdm("NoduleTest") -- This is meant to hold tests for a module/group of related functionality

--- @class TestModuleDefinition.new.kwargs
--- @field Logger Logger

--- Returns a TestModule Instance
--- @param kwargs TestModuleDefinition.new.kwargs
--- @return TestModule
function Test.new(kwargs)
    --- @type TestModule -- Just force it to accept it
    return Test._new(kwargs)
end

--- @param self TestModule
--- @param kwargs TestModuleDefinition.new.kwargs
function Test.init(self, kwargs)
    -- Checks on self are in case this is inheriting anoother test module with tests,
    -- Why you would ever do that idk.
    self.tests = self.tests or {}
    self.testCount = self.testCount or 0
    self.TAG = self:getClassName()
    self.dbg = kwargs.Logger
end

--- Runs the tests in the test module, returning amount passed and failed
--- @param self TestModule
--- @return string[]? passed
--- @return string[]? failed
function Test.run(self)
    self.dbg.logI(self.TAG, "Running...")
    local passed = nil
    local failed = nil
    for testName, fn in pairs(self.tests) do
        self.dbg.logI(testName, "Running")
        local container = { TAG = testName }
        self:testInit(container)
        local ok, _ = pcall(fn, container)
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
--- @param self TestModule
--- @param testContainer table
function Test.testInit(self, testContainer) end

return Test
