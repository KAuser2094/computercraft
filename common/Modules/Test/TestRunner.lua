local cdm = require "common.Modules.Class.Simple"

local TAG = "TEST_RUNNER"

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

    self.dbg.logV(TAG, "Created Test Runner")
end

--- @param this TestRunner
--- @param testModule TestModuleDefinition
function TestRunner.addTestModule(this, testModule)
    local module = testModule.new{
        Logger = this.dbg,
    }
    this.totalTests = this.totalTests + module.testCount
    table.insert(this.modules, module)
end

--- @param this TestRunner
--- @return TestRunner.results results
function TestRunner.run(this)
    this.dbg.logI(TAG, "Starting Tests")
    local totalPassed = 0
    local totalFailed = 0
    for _, module in ipairs(this.modules) do
        local modName = module.TAG

        local passed, failed = module:run()
        if passed then
            this.results[modName] = this.results[modName] or {}
            this.results[modName].passed = passed
            totalPassed = totalPassed + #passed
        end
        if failed then
            this.results[modName] = this.results[modName] or {}
            this.results[modName].failed = failed
            totalFailed = totalFailed + #failed
        end
    end
    -- TODO: Display total results better
    print("Passed:", totalPassed, "/", this.totalTests)
    print("Failed:", totalFailed, "/", this.totalTests)

    return this.results
end

return TestRunner
--- TODO:
--- Add option to toggle the logger (and options) to Verbose (Everything), Fails (Just the fails), Silent (Just the results), CompletelySilent (Not even the results)
--- Better format the results printed out
