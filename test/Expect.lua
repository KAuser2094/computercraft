--- @diagnostic disable: undefined-field, param-type-mismatch
local SimpleClassMaker = assert(require "common.Modules.Class.Simple")
local TestModule = assert(require "common.Modules.Test.Test")

local pc = assert(require "common.Modules.expect")
local Logger = assert(require "common.Modules.Logger")

--- @class test.TestExpect : common.TestModuleDefinition
local TestClass = SimpleClassMaker("Test_Expect", TestModule)

function TestClass.init(this, kwargs)
    TestModule.init(this, kwargs)
end

function TestClass.testInit(this, c)
end

--- @class test._E_xpect.container : _T_est_M_odule.container

--[[
TestClass:addTest("CHANGME", function (container)
    --- @cast container test._E_xpect.container
    local TAG = container.TAG
    local Dbg = container.Logger

end)
--]]

---[[
TestClass:addTest("expect and expectWithTag", function (container)
    --- @cast container test._E_xpect.container
    local TAG = container.TAG
    local Dbg = container.Logger

    local oldTerm = Logger.singleton.getOutputTerminal() -- Don't log to the terminal
    Logger.singleton.setOutputTerminal(nil)

    pc.enableTag(TAG)
    pc.setTagLevel(TAG, Dbg.Levels.Verbose)

    -- Check valid cases
    Dbg.assertWithTag(TAG, pc.isType("this is string", "string"), "Could not match type string")
    Dbg.assertWithTag(TAG, pc.isType("this is string", "dfafasdf", nil, "string"), "Could not match type string with later `string` and nil")
    Dbg.assertFunctionRunsWithTag(TAG, pc.expectWithTag, { TAG, "this is id", "string", "string"})
    Dbg.assertFunctionRunsWithTag(TAG, pc.expectWithTag, { TAG, "this is id", 1, "integer"})


    Logger.singleton.setOutputTerminal(oldTerm)
end)
--]]

return TestClass
