local cdm = require "common.Modules.Class.Simple"

--- @class TestRunner.results.item
--- @field passed string[]
--- @field failed string[]

--- @alias TestRunner.results TestRunner.results.item[]

--- @class TestRunner : IClass
--- @field modules TestModule[]
--- @field totalTests integer
--- @field results TestRunner.results
--- @field dbg Logger
--- @field addTestModule fun(self: TestRunner, testModule: TestModuleDefinition) -- Adds a module to the runner using a definition
--- @field run fun(self: TestRunner): TestRunner.results -- Runs the test modules added to the runner, will also return the results field

--- @class TestRunnerDefinition : ISimpleClassDefinition
local TestRunner = cdm("TestRunner")

--- @class TestRunnerDefinition.new.kwargs
--- @field Logger Logger

--- Create a TestRunner instance
--- @param kwargs TestRunnerDefinition.new.kwargs
--- @return TestRunner
function TestRunner.new(kwargs)
    --- @type TestRunner
    return TestRunner._new(kwargs)
end

--- @param self TestRunner
--- @param kwargs TestRunnerDefinition.new.kwargs
function TestRunner.init(self, kwargs)
    self.modules = {}
    self.totalTests = 0
    self.results = {}
    self.dbg = kwargs.Logger
end

--- @param self TestRunner
--- @param testModule TestModuleDefinition
function TestRunner.addTestModule(self, testModule)
    local module = testModule.new{
        Logger = self.dbg,
    }
    self.totalTests = self.totalTests + module.testCount
    table.insert(self.modules, module)
end

--- @param self TestRunner
--- @return TestRunner.results results
function TestRunner.run(self)
    self.dbg.logI("TEST RUNNER", "Starting Tests")
    local totalPassed = 0
    local totalFailed = 0
    for _, module in ipairs(self.modules) do
        local modName = module.TAG
        local passed, failed = module:run()
        if passed then
            self.results[modName] = self.results[modName] or {}
            self.results[modName].passed = passed
            totalPassed = totalPassed + #passed
        end
        if failed then
            self.results[modName] = self.results[modName] or {}
            self.results[modName].failed = failed
            totalFailed = totalFailed + #failed
        end
    end
    -- TODO: Display total results better
    print("Passed:", totalPassed, "/", self.totalTests)
    print("Failed:", totalFailed, "/", self.totalTests)

    return self.results
end

return TestRunner
