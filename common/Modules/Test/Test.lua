local cdm = require "common.Modules.Class.Simple"
local TAG = "TEST MODULE BASE"
local Dbg = require "common.Modules.Logger".singleton
Dbg = Dbg.setTagLevel(TAG, Dbg.Levels.Warning)

--- @class common.ITestModule : common.Class.IClass
--- @field testCount integer
--- @field run fun(self: common.Test.TestModule): string[], string[] -- Runs tests in test module, returning passed and failed

--- @class common.Test.TestModule : common.ITestModule, common.Class.Class
--- @field tests table<string, fun(container: table)>
--- @field TAG string
--- @field dbg common.Logger
--- @field testInit fun(self: common.Test.TestModule, container: table) -- Initialise test container

--- @class common.TestModuleDefinition : common.Class.SimpleClassDefinition
local Test = cdm("ModuleTest") -- This is meant to hold tests for a module/group of related functionality

--- @class _T_est_M_odule_D_efinition.new.kwargs
--- @field Logger common.Logger

--- Returns a TestModule Instance
--- @param kwargs _T_est_M_odule_D_efinition.new.kwargs
--- @return common.ITestModule
function Test.new(kwargs)
    --- @type common.ITestModule -- Just force it to accept it
    return Test._new(kwargs)
end

--- @param this common.Test.TestModule
--- @param kwargs _T_est_M_odule_D_efinition.new.kwargs
function Test.init(this, kwargs)
    -- Get the top level definition this is:
    local thisDef = this.inherits[this:getClassName()]

    --- @type table<string, fun(container: table)>
    this.tests = thisDef:getPrivate("tests") or {}
    --- @type integer
    this.testCount = thisDef:getPrivate("testCount") or 0

    this.TAG = this:getClassName()
    this.dbg = kwargs.Logger
    this.dbg.logV(this.TAG, "Created TestModule:", this.TAG)
end

--- @class _T_est_M_odule.container
--- @field TAG string
--- @field Logger common.Logger

--- Runs the tests in the test module, returning amount passed and failed
--- @param this common.Test.TestModule
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
--- @param this common.Test.TestModule
--- @param testContainer table
function Test.testInit(this, testContainer) end

--- Adds a test to the module
--- @param testName string
--- @param testFn fun(container: table)
function Test:addTest(testName, testFn)
    if not self:getPrivate("tests") then self:setPrivate("tests", {}) end
    if not self:getPrivate("testCount") then self:setPrivate("testCount", 0) end
    self:getPrivate("tests")[testName] = testFn
    self:setPrivate("testCount", self:getPrivate("testCount") + 1)
end

return Test
