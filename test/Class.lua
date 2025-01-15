local Class = require "common.Modules.Class"
local TestModule = require "common.Modules.Test.Test"

local _cn1 = "sdgsgsgws1"
local _cd1 = Class(_cn1)
local _ci1 = _cd1:new()

local _cn2 = "htghsfgdsgnjsgpag2"
local _cd2 = Class(_cn2, _cd1)
local _ci2 = _cd2:new()

--- @class test.ClassTests : common.Modules.Test.TestModuleDefinition
local ClassTests = Class("CLASS TESTS", TestModule)

function ClassTests:init(this, kwargs)
    TestModule.init(self, this, kwargs)
end

function ClassTests.testInit(this, c)
    c.ClassName = _cn1
    c.ClassDef = _cd1
    c.Class = _ci1

    c.SubClassName = _cn2
    c.SubClassDef = _cd2
    c.SubClass = _ci2
end

--- @class test.ClassTests.container : common.Modules.Test.TestModule.container
--- @field ClassName string
--- @field ClassDef common.Modules.Class.ClassDefinition
--- @field Class common.Modules.Class.Class
--- @field SubClassName string
--- @field SubClassDef common.Modules.Class.ClassDefinition
--- @field SubClass common.Modules.Class.Class

ClassTests:addTest("CHECK CLASS FIELDS", function (container)
    --- @cast container test.ClassTests.container
    local TAG = container.TAG
    local Dbg = container.Logger
end)

return ClassTests
