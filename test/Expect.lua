--- @diagnostic disable: undefined-field, param-type-mismatch
local SimpleClassMaker = assert(require "common.Modules.Class.Simple")
local ClassMaker = assert(require("common.Modules.Class")) -- LuaLS why are you being like this
local TestModule = assert(require "common.Modules.Test.Test")

local pc = assert(require "common.Modules.expect")

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
local sd2 = SimpleClassMaker(s2Name, sd1)
local cd1 = ClassMaker(c1Name)
local cd2 = ClassMaker(c2Name, cd1)

local si1 = sd1.new()
local si2 = sd2.new()
local ci1 = cd1.new()
local ci2 = cd2.new()

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

    pc.enableTag(TAG)
    pc.setTagLevel(TAG, Dbg.Levels.Verbose)

    local fn = function () end
    local ctbl = setmetatable({}, { __call = function () return "this is a callable" end } )

    local expectWithTagRunsTests = {
        -- Base types
        { TAG, "id",    "s",    "string"}, --
        { TAG, "id",    1,      "number"}, --
        { TAG, "id",    nil,    "nil"}, --
        { TAG, "id",    true,   "boolean"}, { TAG, "id",    false,    "boolean"}, --
        { TAG, "id",    fn,     "function"}, --
        { TAG, "id",    {},     "table"}, --
        -- Extra base types
        { TAG, "id",    ctbl,   pc.TYPES.callable}, { TAG, "id",    fn,   pc.TYPES.callable}, --
        { TAG, "id",    5,      pc.TYPES.integer}, --
        { TAG, "id",    ci1,    pc.TYPES.class}, --
        { TAG, "id",    si1,    pc.TYPES.class}, --
        { TAG, "id",    cd1,    pc.TYPES.classdefinition}, --
        { TAG, "id",    sd1,    pc.TYPES.classdefinition}, --
        -- Check multiple types works
        { TAG, "id",    "s",    "string", "number", "nil"}, --
        { TAG, "id",    1,      "string", "number", "nil"}, --
        { TAG, "id",    nil,    "string", "number", "nil"}, --
        -- Class
        -- "Normal"":
        ---- Instance
        { TAG, "id",    ci1,      c1Name}, -- Name --
        { TAG, "id",    ci1,      cd1}, -- Definition --
        { TAG, "id",    ci1,      ci1}, -- Instance --
        ------ Redundant
        { TAG, "id",    ci2,      c2Name}, -- Name --
        { TAG, "id",    ci2,      cd2}, -- Definition --
        { TAG, "id",    ci2,      ci2}, -- Instance --
        ------ Inheritance test
        { TAG, "id",    ci2,      c1Name}, -- Name --
        { TAG, "id",    ci2,      cd1}, -- Definition --
        { TAG, "id",    ci2,      ci1}, -- Instance --
        -- Simple:
        ---- Instance
        { TAG, "id",    si1,      s1Name}, -- Name --
        { TAG, "id",    si1,      sd1}, -- Definition --
        { TAG, "id",    si1,      si1}, -- Instance --
        ------ Redundant
        { TAG, "id",    si2,      s2Name}, -- Name --
        { TAG, "id",    si2,      sd2}, -- Definition --
        { TAG, "id",    si2,      si2}, -- Instance --
        ------ Inheritance test
        { TAG, "id",    si2,      s1Name}, -- Name --
        { TAG, "id",    si2,      sd1}, -- Definition --
        { TAG, "id",    si2,      si1}, -- Instance --
    }

    -- Check valid cases
    for index, _args in ipairs(expectWithTagRunsTests) do
        Dbg.assertFunctionRunsWithTag(TAG, pc.expectWithTag, _args, "Failed expectWithTagRuns test no. " .. index)
    end
end)
--]]

return TestClass
