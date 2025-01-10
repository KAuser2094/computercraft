--- @diagnostic disable: undefined-field
--- Tests the implentation of the basic IClass from SimpleClass and Class.
local SimpleClass = require "common.Modules.Class.Simple"
local TestModule = require "common.Modules.Test.Test"
local cdf = require("common.Modules.Class")("Test_Class")
local scdf = require("common.Modules.Class.Simple")("Test_SimpleClass")
local cdi = cdf.new()
local scdi = scdf.new()

--- @class TestIClassDefinition : TestModuleDefinition
local TestIClass = SimpleClass("Test_IClass", TestModule)


function TestIClass.testInit(self, c)
    c = {}
    c.ClassDef = cdf
    c.Class = cdi
    c.SimpleClassDef = scdf
    c.SimpleClass = scdi
end

--- @class TestIClass.container
--- @field ClassDef IClassDefinition
--- @field Class IClass
--- @field SimpleClassDef ISimpleClassDefinition
--- @field SimpleClass IClass

-- This is only here as the "Interface" Class does not exist for them -_-
TestIClass:addTest("Check has fields", function (container)
    --- @cast container TestIClass.container

    assert(container.Class.isAClass, "Class does not have isAClass")
    assert(container.SimpleClass.isAClass)
    assert(not container.Class.isAClassDefinition, "Class should not have isAClassDefinition")
    assert(not container.SimpleClass.isAClassDefinition)
    assert(container.ClassDef.isAClassDefinition) -- I already got lazy to make the messages
    assert(container.SimpleClassDef.isAClassDefinition)
    assert(not container.SimpleClassDef.isAClass)
    assert(not container.ClassDef.isAClass, "How did ClassDef get isAClass")

    local ClassFields = {
        "getClassName", "getAllClassNames", "inheritsClass", "isExactClass", "isClass",
        "className", "inherits", "getPrivateTable", "getPrivate", "setPrivateTable", "setPrivate"
    }

    local SimpleClassDefOnlyFields = { --  Due to how SimpleClass works, its private fields are just the definition only fields (as we strip out everything else)
        "init", "_new", "new"
    }

    local ClassDefFields = { -- For fields that Class will technically also have
        "__instanceSettings", "__otherSettings",
        "preIndex", "postIndex", "preNewIndex"
    }

    local ClassDefOnlyFields = {
        "init", "_new", "new",
        "__inheritanceSettings",
        "inheritInto", "inheritFrom", "doNotInherit", "mergeOnInherit", "deepMergeOnInherit", "postInherited", "postInit", "_checkWellFormed", "checkWellFormed",
        "markPublic", "markDefinitionOnly",
    }

    for _, key in pairs(ClassFields) do
        assert(container.Class[key], "Class is missing key:", key)
        assert(container.SimpleClass[key], "SimpleClass is missing key:", key)
        assert(container.ClassDef[key], "ClassDef is missing key:", key)
        assert(container.SimpleClassDef[key], "SimpleClass is missing key:", key)
    end

    for _, key in pairs(SimpleClassDefOnlyFields) do
        assert(container.SimpleClassDef[key], "SimpleClassDef is missing key:", key)
        assert(not container.SimpleClass[key], "SimpleClass has key it shouldn't:", key)
    end

    for _, key in pairs(ClassDefFields) do
        assert(container.ClassDef[key], "ClassDef is missing key:", key)
        assert(container.Class[key], "Class is missing key (within ClassDef):", key)
    end

    for _, key in pairs(ClassDefOnlyFields) do
        assert(container.ClassDef[key], "ClassDef is missing key:", key)
        assert(not container.Class[key], "Class has key defined it shouldn't, key:", key)
    end
end)

return TestIClass
