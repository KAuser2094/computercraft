local p = require "cc.pretty"
local cdm = require "common.Modules.Class.Simple"

local TAG = "TEST_RUNNER"

--- TODO: Make this follow the coding style I decided on

--- @class TestRunner.results.item
--- @field passed string[]
--- @field failed string[]

--- @alias TestRunner.results TestRunner.results.item[]

--- @class ITestRunner: IClass
--- @field addTestModule fun(self: TestRunner, testModule: TestModuleDefinition) -- Adds a module to the runner using a definition
--- @field run fun(self: ITestRunner): TestRunner.results -- Runs the test modules added to the runner, will also return the results field
--- @field setVerbose fun(self: ITestRunner): ITestRunner -- Will log anything
--- @field setFailures fun(self: ITestRunner): ITestRunner -- Will only log the failures
--- @field setSilent fun(self: ITestRunner): ITestRunner -- Will not log to terminal, only file
--- @field setShow fun(self: ITestRunner, terminal?: ccTweaked.term.Redirect): ITestRunner -- Will also log to terminal, uses the passed in terminal if given
--- @field setCompletelySilent fun(self: TestRunner): ITestRunner -- Will not even print out the results

--- @class TestRunner : ITestRunner, Class
--- @field modules TestModule[]
--- @field totalTests integer
--- @field results TestRunner.results
--- @field dbg Logger
--- @field formatResults fun(self: TestRunner, totalPassed: integer, totalFailed: integer): ccTweaked.cc.pretty.Doc -- Formats the results to a pretty Doc
--- @field oldTerm? ccTweaked.term.Redirect
--- @field completeSilent? boolean

--- @class TestRunnerDefinition : SimpleClassDefinition
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
    self.dbg = assert(kwargs.Logger, "TestRunner needs a Logger to work")

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
--- @return TestRunner this -- For chaining
function TestRunner.setVerbose(this)
    this.dbg.setGlobalLevel(this.dbg.Levels.Verbose)
    this.dbg.setTagLevel(TAG, this.dbg.Levels.Verbose)
    for _, module in ipairs(this.modules) do
        module.dbg.setTagLevel(module.TAG, module.dbg.Levels.Verbose)
    end
    return this
end

--- @param this TestRunner
--- @return TestRunner this -- For chaining
function TestRunner.setFailures(this)
    this.dbg.setGlobalLevel(this.dbg.Levels.Fatal)
    this.dbg.setTagLevel(TAG, this.dbg.Levels.Fatal)
    for _, module in ipairs(this.modules) do
        module.dbg.setTagLevel(module.TAG, module.dbg.Levels.Fatal)
    end
    return this
end

--- @param this TestRunner
--- @return TestRunner this -- For chaining
function TestRunner.setSilent(this)
    this.oldTerm = this.dbg.getOutputTerminal()
    this.dbg.setOutputTerminal() -- Simply don't log to the terminal :)
    return this
end

--- @param this TestRunner
--- @param terminal? ccTweaked.term.Redirect
--- @return TestRunner this -- For chaining
function TestRunner.setShow(this, terminal)
    this.completeSilent = false
    terminal = terminal or this.oldTerm
    this.dbg.setOutputTerminal(terminal)
    this.oldTerm = nil
    return this
end

--- @param this TestRunner
--- @return TestRunner this -- For chaining
function TestRunner.setCompleteSilence(this)
    this:setSilent()
    this.completeSilent = true
    return this
end

--- @param this TestRunner
--- @param totalPassed integer
--- @param totalFailed integer
--- @return ccTweaked.cc.pretty.Doc
function TestRunner.formatResults(this, totalPassed, totalFailed)
    local mt = { insert = function (self, ...) for _,v in pairs({...}) do table.insert(self, v) end end } ; mt.__index = mt -- Small Class to not have to spam table.insert
    local p_result = setmetatable({}, mt) -- Array containing the strings/Docs to concat
    p_result:insert("Passed:", p.space, p.pretty(totalPassed), "/", p.pretty(this.totalTests), p.space_line)
    p_result:insert("Failed:", p.space, p.pretty(totalFailed), "/", p.pretty(this.totalTests), p.space_line)
    p_result:insert(p.space_line, "------------------ ", p.space_line)
    for modName, result in pairs(this.results) do
        p_result:insert(modName, ":", p.space_line)
        -- TODO: Maybe add passed to results (probably with an option)

        if this.results[modName].failed then
            p_result:insert(p.space, p.space, "(FAILED):", p.space_line)
            for _, testName in ipairs(this.results[modName].failed) do
                p_result:insert(p.space, p.space, p.space, p.space, testName, p.space_line)
            end
        end
    end

    p_result = p.concat(table.unpack(p_result))
    return p_result
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
    p.print(this:formatResults(totalPassed, totalFailed))
    return this.results
end

return TestRunner
