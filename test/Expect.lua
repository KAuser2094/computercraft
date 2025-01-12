--- @diagnostic disable: undefined-field, param-type-mismatch
local SimpleClassMaker = assert(require "common.Modules.Class.Simple")
local ClassMaker = assert(require("common.Modules.Class")) -- LuaLS why are you being like this
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


local s1Name = "gadfsafafna_1" -- Probably unique :)
local s2Name = "fdanfgdgdafg_2"
local c1Name = "hghghtfgdrg_1"
local c2Name = "thgjhjghhjgj_2"
local sd1 = SimpleClassMaker(s1Name)
local sd2 SimpleClassMaker(s2Name, sd1)
local cd1 = ClassMaker(c1Name)
local cd2 = ClassMaker(c2Name, cd1)


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

    local expectWithTagTests ={
        -- Base types
        { TAG, "id",    "s",    "string"},
        { TAG, "id",    1,      nil, "number"},
        { TAG, "id",    "s",    "nil"},
        { TAG, "id",    "s",    "boolean"},
        { TAG, "id",    "s",    "function"},
        { TAG, "id",    "s",    "table"},
        -- Extra base types
        { TAG, "id",    setmetatable({}, {
            __call = function ()
                return "this is a callable"
            end}),              "callable"},
        { TAG, "id",    5,      "integer"},
        -- Class
    }

    -- Check valid cases
    Dbg.assertWithTag(TAG, pc.isType("this is string", "string"), "Could not match type string")
    Dbg.assertWithTag(TAG, pc.isType("this is string", "dfafasdf", nil, "string"), "Could not match type string with later `string` and nil")
    Dbg.assertFunctionRunsWithTag(TAG, pc.expectWithTag, { TAG, "this is id", "string", "string"})
    Dbg.assertFunctionRunsWithTag(TAG, pc.expectWithTag, { TAG, "this is id", 1, "integer"})


    Logger.singleton.setOutputTerminal(oldTerm)
end)
--]]

return TestClass
