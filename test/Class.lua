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

--[[
ClassTests:addTest("CHANGEME", function (container)
    --- @cast container test.ClassTests.container
    local TAG = container.TAG
    local Dbg = container.Logger
    ---

end)
--]]

---[[
ClassTests:addTest("CHECK CLASS FIELDS", function (container)
    --- @cast container test.ClassTests.container
    local TAG = container.TAG
    local Dbg = container.Logger
    --- TODO:
    --- Class Instance only (not making a loop for this)
    Dbg.assertWithTag(TAG, container.Class["isAClass"] ~= nil, "Class is missing field: " .. "isAClass")
    Dbg.assertWithTag(TAG, container.ClassDef["isAClass"] == nil, "ClassDef has field it shouldn't " .. "isAClass")
    Dbg.assertWithTag(TAG, container.SubClass["isAClass"] ~= nil, "SubClass is missing field: " .. "isAClass")
    Dbg.assertWithTag(TAG, container.SubClassDef["isAClass"] == nil, "SubClassDef has field it shouldn't " .. "isAClass")

    local ClassFields = {
        -- Public
        "getClassName",
        "getAllClassNames",
        "isClass",
        "isExactClass",
        "inheritsClass",
        -- Proxy / Private
        "__expect",
        "__expectGetTypes",
    }

    for _, key in ipairs(ClassFields) do
        Dbg.assertWithTag(TAG, container.Class[key] ~= nil, "Class is missing field: " .. key)
        Dbg.assertWithTag(TAG, container.ClassDef[key] ~= nil, "ClassDef is missing field: " .. key)

        Dbg.assertWithTag(TAG, container.SubClass[key] ~= nil, "SubClass is missing field: " .. key)
        Dbg.assertWithTag(TAG, container.SubClassDef[key] ~= nil, "SubClassDef is missing field: " .. key)
    end

    local ClassDefinitionOnlyFields = { -- Oh god this is long
        "__className",
        "__directlyInherits",
        "__inherits",
        "isAClassDefinition",
        "__definitionSettings",
        "markDefinitionOnly", "markPublic", "markProxy",
        "markDoNotInherit", "markMergeOnInherit", "markDeepMergeOnInherit", "markAppendOnInherit",
        "markTypesExpected", "markAbstractField", "markAbstractMethod",
        "preInheritInto", "postInheritInto", "preInit", "postInit",
        "preCheckInvariant", "postCheckInvariant",
        "preIndex", "postIndex", "preNewIndex",
        "forInheritsBottomUp", "forInheritsTopDown",
        "inheritInto", "inheritFrom",
        "init", "rawnew", "new",
    }

    for _, key in ipairs(ClassDefinitionOnlyFields) do
        Dbg.assertWithTag(TAG, container.ClassDef[key] ~= nil, "ClassDef is missing field: " .. key)
        Dbg.assertWithTag(TAG, container.Class[key] == nil, "Class has ClassDefOnly field: " .. key)

        Dbg.assertWithTag(TAG, container.SubClassDef[key] ~= nil, "SubClassDef is missing field: " .. key)
        Dbg.assertWithTag(TAG, container.SubClass[key] == nil, "SubClass has SubClassDefOnly field: " .. key)
    end
end)
--]]

return ClassTests
