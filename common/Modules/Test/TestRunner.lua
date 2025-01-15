local p = require "cc.pretty"
local Class = require "common.Modules.Class"

local TAG = "TEST_RUNNER"

--- @class common.Modules.Test.TestRunner.results.item
--- @field passed string[]
--- @field failed string[]

--- @alias common.Modules.Test.TestRunner.results common.Modules.Test.TestRunner.results.item[]

--- @class common.Modules.Test.ITestRunner: common.Modules.Class.IClass
--- @field addTestModule fun(self: common.Modules.Test.ITestRunner, testModule: common.Modules.Test.TestModuleDefinition) -- Adds a module to the runner using a definition
--- @field run fun(self: common.Modules.Test.ITestRunner): common.Modules.Test.TestRunner.results -- Runs the test modules added to the runner, will also return the results field
--- @field setVerbose fun(self: common.Modules.Test.ITestRunner): common.Modules.Test.ITestRunner -- Will log anything
--- @field setFailures fun(self: common.Modules.Test.ITestRunner): common.Modules.Test.ITestRunner -- Will only log the failures
--- @field setSilent fun(self: common.Modules.Test.ITestRunner): common.Modules.Test.ITestRunner -- Will not log to terminal, only file
--- @field setShow fun(self: common.Modules.Test.ITestRunner, terminal?: ccTweaked.term.Redirect): common.Modules.Test.ITestRunner -- Will also log to terminal, uses the passed in terminal if given
--- @field setCompletelySilent fun(self: common.Modules.Test.TestRunner): common.Modules.Test.ITestRunner -- Will not even print out the results

--- @class common.Modules.Test.TestRunner : common.Modules.Test.ITestRunner, common.Modules.Class.Class
--- @field modules common.Modules.Test.TestModule[]
--- @field totalTests integer
--- @field results common.Modules.Test.TestRunner.results
--- @field dbg common.Logger
--- @field formatResults fun(self: common.Modules.Test.TestRunner, totalPassed: integer, totalFailed: integer): ccTweaked.cc.pretty.Doc -- Formats the results to a pretty Doc
--- @field oldTerm? ccTweaked.term.Redirect
--- @field completeSilent? boolean

--- @class common.Modules.Test.TestRunnerDefinition : common.Modules.Class.ClassDefinition
local TestRunner = Class("TEST RUNNER")

--- @class common.Modules.Test.TestRunnerDefinition.new.kwargs
--- @field Logger common.Logger

--- Create new TestRunner instance
--- @param kwargs common.Modules.Test.TestRunnerDefinition.new.kwargs
--- @return common.Modules.Test.TestRunner
function TestRunner:new(kwargs)
    --- @type common.Modules.Test.TestRunner
    return self:rawnew(kwargs)
end

--- Init
--- @param this common.Modules.Test.TestRunner
--- @param kwargs common.Modules.Test.TestRunnerDefinition.new.kwargs
function TestRunner:init(this, kwargs)
    this.modules = {}
    this.totalTests = 0
    this.results = {}
    this.dbg = assert(kwargs.Logger, "TestRunner needs a Logger to work")

    this.dbg.logV(TAG, "Created Test Runner")
end

--- @param this common.Modules.Test.TestRunner
--- @param testModule common.Modules.Test.TestModuleDefinition
function TestRunner.addTestModule(this, testModule)
    local module = testModule:new{ Logger = this.dbg, }
    this.totalTests = this.totalTests + module.testCount
    table.insert(this.modules, module)
end

--- @param this common.Modules.Test.TestRunner
--- @return common.Modules.Test.TestRunner this -- For chaining
function TestRunner.setVerbose(this)
    this.dbg.setGlobalLevel(this.dbg.Levels.Verbose)
    this.dbg.setTagLevel(TAG, this.dbg.Levels.Verbose)

    for _, module in ipairs(this.modules) do
        module.dbg.setTagLevel(module.TAG, module.dbg.Levels.Verbose)
    end
    return this
end

--- @param this common.Modules.Test.TestRunner
--- @return common.Modules.Test.TestRunner this -- For chaining
function TestRunner.setFailures(this)
    this.dbg.setGlobalLevel(this.dbg.Levels.Fatal)
    this.dbg.setTagLevel(TAG, this.dbg.Levels.Fatal)
    for _, module in ipairs(this.modules) do
        module.dbg.setTagLevel(module.TAG, module.dbg.Levels.Fatal)
    end
    return this
end

--- @param this common.Modules.Test.TestRunner
--- @return common.Modules.Test.TestRunner this -- For chaining
function TestRunner.setSilent(this)
    this.oldTerm = this.dbg.getGlobalOutputTerminal()
    this.dbg.setGlobalOutputTerminal() -- Simply don't log to the terminal :)
    this.dbg.getTagSettings(TAG):setOutputTerminal()
    for _, module in ipairs(this.modules) do
        module.dbg.getTagSettings(module.TAG):setOutputTerminal()
    end
    return this
end

--- @param this common.Modules.Test.TestRunner
--- @param terminal? ccTweaked.term.Redirect
--- @return common.Modules.Test.TestRunner this -- For chaining
function TestRunner.setShow(this, terminal)
    this.completeSilent = false
    terminal = terminal or this.oldTerm
    this.dbg.setGlobalOutputTerminal(terminal)
    this.dbg.getTagSettings(TAG):setOutputTerminal(terminal)
    for _, module in ipairs(this.modules) do
        module.dbg.getTagSettings(module.TAG):setOutputTerminal(terminal)
    end
    this.oldTerm = nil
    return this
end

--- @param this common.Modules.Test.TestRunner
--- @return common.Modules.Test.TestRunner this -- For chaining
function TestRunner.setCompleteSilence(this)
    this:setSilent()
    this.completeSilent = true
    return this
end

--- @param this common.Modules.Test.TestRunner
--- @param totalPassed integer
--- @param totalFailed integer
--- @return ccTweaked.cc.pretty.Doc
function TestRunner.formatResults(this, totalPassed, totalFailed)
    local mt = { insert = function (self, ...) for _,v in pairs({...}) do table.insert(self, v) end end } ; mt.__index = mt -- Small Class to not have to spam table.insert
    local p_result = setmetatable({}, mt) -- Array containing the strings/Docs to concat
    p_result:insert("------------------ ", p.space_line)
    p_result:insert("Passed:", p.space, p.pretty(totalPassed), "/", p.pretty(this.totalTests), p.space_line)
    p_result:insert("Failed:", p.space, p.pretty(totalFailed), "/", p.pretty(this.totalTests), p.space_line)
    p_result:insert(p.space_line, "------------------ ", p.space_line)
    local moduleSpecificResults = false
    for modName, result in pairs(this.results) do
        -- TODO: Maybe add passed to results (probably with an option)

        if this.results[modName].failed then
            moduleSpecificResults = true
            p_result:insert(modName, ":", p.space_line)
            p_result:insert(p.space, p.space, "(FAILED):", p.space_line)
            for _, testName in ipairs(result.failed) do
                p_result:insert(p.space, p.space, p.space, p.space, testName, p.space_line)
            end
        end
    end
    if moduleSpecificResults then
        p_result:insert(p.space_line, "------------------ ", p.space_line)
    end

    p_result = p.concat(table.unpack(p_result))
    return p_result
end

--- @param this common.Modules.Test.TestRunner
--- @return common.Modules.Test.TestRunner.results results
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
    local formattedResultsDoc = this:formatResults(totalPassed, totalFailed)
    if this.oldTerm and not this.completeSilent then -- If the logger printout was silenced but you still want to see results
        p.print(formattedResultsDoc)
    end
    this.dbg.logT(TAG, "RESULTS:", p.line, formattedResultsDoc)
    return this.results
end

return TestRunner
