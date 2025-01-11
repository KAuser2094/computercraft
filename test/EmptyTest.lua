--- @diagnostic disable: undefined-field
local SimpleClassMaker = assert(require "common.Modules.Class.Simple")
local TestModule = assert(require "common.Modules.Test.Test")

-- --- @class test.CHANGEME : common.TestModuleDefinition
--- @type table -- DELETE THIS LINE (Just here to make LuaLS shut up)
local TestClass = SimpleClassMaker("Test_CHANGEME", TestModule)

function TestClass.init(this, kwargs)
    TestModule.init(this, kwargs)
end

function TestClass.testInit(this, c)
end

-- --- @class test._C_HANGE_M_E.container : _T_est_M_odule.container

--[[
TestClass:addTest("CHANGME", function (container)
    --- @cast container test._C_HANGE_M_E.container
    local TAG = container.TAG
    local Dbg = container.Logger
end)
--]]

return TestClass
