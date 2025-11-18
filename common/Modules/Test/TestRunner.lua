--- @class common.Modules.Test.TestRunnerDefinition
local TestRunner = {}
TestRunner.__index = TestRunner

--- Creates a new Test Runner
--- @return common.Modules.Test.TestRunner
function TestRunner:new()
    --- @class common.Modules.Test.TestRunner : common.Modules.Test.TestRunnerDefinition
    local t = setmetatable({}, self)
    --- @type common.Modules.Test.TestModule[]
    t.modules = {}
    t.moduleCount = 0
    return t
end

--- Adds a test module instance to this runner
--- @param this common.Modules.Test.TestRunner
--- @param module common.Modules.Test.TestModule
function TestRunner.addModule(this, module)
    table.insert(this.modules, module)
    this.moduleCount = this.moduleCount + 1
end

--- @class common.Modules.Test.results
--- @field totalPassed integer
--- @field totalFailed integer
--- @field modules table<string, common.Modules.Test.results.moduleResult> -- String being the module's name

--- @class common.Modules.Test.results.moduleResult
--- @field passed integer
--- @field failed integer
--- @field tests table<string, common.Modules.Test.results.moduleResult.testResult> -- String being the test's name

--- @class common.Modules.Test.results.moduleResult.testResult
--- @field ok boolean
--- @field error nil|string
--- @field traceback nil|string
--- @field ctx table

--- Executes all tests in all modules and returns structured results
--- @param this common.Modules.Test.TestRunner
--- @return common.Modules.Test.results results
function TestRunner.run(this)
    --- @type common.Modules.Test.results
    local results = {
        totalPassed = 0,
        totalFailed = 0,
        modules = {},
    }

    for _, module in ipairs(this.modules) do
        --- @type common.Modules.Test.results.moduleResult
        local modResult = {
            passed = 0,
            failed = 0,
            tests = {},
        }

        for testName, fn in pairs(module.tests) do
            local ctx = {}
            ctx = module:testInitialise(ctx)

            local ok, err = pcall(fn, ctx)

            if ok then
                modResult.tests[testName] = {
                    ok = true,
                    error = nil,
                    traceback = nil,
                    ctx = ctx,
                }
                modResult.passed = modResult.passed + 1
                results.totalPassed = results.totalPassed + 1
            else
                modResult.tests[testName] = {
                    ok = false,
                    error = err,
                    traceback = debug.traceback(),
                    ctx = ctx,
                }
                modResult.failed = modResult.failed + 1
                results.totalFailed = results.totalFailed + 1
            end

            module:testCleanUp(ctx)
        end
        results.modules[module.TAG] = modResult
    end

    return results
end

return TestRunner
