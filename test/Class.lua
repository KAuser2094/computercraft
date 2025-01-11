--- @diagnostic disable: undefined-field
--- Tests the implentation of the basic Class from SimpleClass and Class.
local SimpleClass = assert(require "common.Modules.Class.Simple")
local TestModule = assert(require "common.Modules.Test.Test")

local _ClassName = "Test_Class"
local _ClassDef = assert(require("common.Modules.Class")(_ClassName))
local _Class = assert(_ClassDef.new())
local _SimpleClassName = "Test_SimpleClass"
local _SimpleClassDef = assert(require("common.Modules.Class.Simple")(_SimpleClassName))
local _SimpleClass = assert(_SimpleClassDef.new())

--- @class test.TestClassDefinition : common.TestModuleDefinition
local TestClass = SimpleClass("Test_Class", TestModule)

function TestClass.init(this, kwargs)
    TestModule.init(this, kwargs)
end

function TestClass.testInit(this, c)
    c.ClassName = _ClassName
    c.ClassDef = _ClassDef
    c.Class = _Class
    c.SimpleClassName = _SimpleClassName
    c.SimpleClassDef = _SimpleClassDef
    c.SimpleClass = _SimpleClass
end

--- @class TestClass.container : _T_est_M_odule.container
--- @field ClassName string
--- @field ClassDef common.Class.ClassDefinition
--- @field Class common.Class.Class
--- @field SimpleClassName string
--- @field SimpleClassDef common.Class.SimpleClassDefinition
--- @field SimpleClass common.Class.Class

-- This is only here as the "Interface" Class does not exist for them -_-
TestClass:addTest("Check has fields", function (container)
    --- @cast container TestClass.container

    local TAG = container.TAG
    local Dbg = container.Logger

    Dbg.assertWithTag(TAG, container.Class.isAClass, "Class does not have isAClass")
    Dbg.assertWithTag(TAG, container.SimpleClass.isAClass)
    Dbg.assertWithTag(TAG, not container.Class.isAClassDefinition, "Class should not have isAClassDefinition")
    Dbg.assertWithTag(TAG, not container.SimpleClass.isAClassDefinition)
    Dbg.assertWithTag(TAG, container.ClassDef.isAClassDefinition) -- I already got lazy to make the messages
    Dbg.assertWithTag(TAG, container.SimpleClassDef.isAClassDefinition)
    Dbg.assertWithTag(TAG, not container.SimpleClassDef.isAClass)
    Dbg.assertWithTag(TAG, not container.ClassDef.isAClass, "How did ClassDef get isAClass")

    local ClassFields = {
        "getClassName", "getAllClassNames", "inheritsClass", "isExactClass", "isClass",
        "className", "inherits", "getPrivateTable", "getPrivate", "setPrivateTable", "setPrivate"
    }

    local SimpleClassDefOnlyFields = { --  Due to how SimpleClass works, its private fields are just the definition only fields (as we strip out everything else)
        "init", "_new", "new", "getBaseClassDefinition"
    }

    local ClassDefFields = { -- For fields that Class will technically also have
        "__instanceSettings", "__otherSettings",
        "preIndex", "postIndex", "preNewIndex"
    }

    local ClassDefOnlyFields = {
        "init", "_new", "new", "getBaseClassDefinition",
        "__inheritanceSettings",
        "inheritInto", "inheritFrom", "doNotInherit", "mergeOnInherit", "deepMergeOnInherit", "postInherited", "postInit", "_checkWellFormed", "checkWellFormed",
        "markPublic", "markDefinitionOnly",
    }

    for _, key in pairs(ClassFields) do
        Dbg.assertWithTag(TAG, container.Class[key], "Class is missing key: " .. key)
        Dbg.assertWithTag(TAG, container.SimpleClass[key], "SimpleClass is missing key: " .. key)
        Dbg.assertWithTag(TAG, container.ClassDef[key], "ClassDef is missing key:" ..  key)
        Dbg.assertWithTag(TAG, container.SimpleClassDef[key], "SimpleClass is missing key: " .. key)
    end

    for _, key in pairs(SimpleClassDefOnlyFields) do
        Dbg.assertWithTag(TAG, container.SimpleClassDef[key], "SimpleClassDef is missing key: " .. key)
        Dbg.assertWithTag(TAG, not container.SimpleClass[key], "SimpleClass has key it shouldn't: " .. key)
    end

    for _, key in pairs(ClassDefFields) do
        Dbg.assertWithTag(TAG, container.ClassDef[key], "ClassDef is missing key: " .. key)
        Dbg.assertWithTag(TAG, container.Class[key], "Class is missing key (within ClassDef): " .. key)
    end

    for _, key in pairs(ClassDefOnlyFields) do
        Dbg.assertWithTag(TAG, container.ClassDef[key], "ClassDef is missing key: " .. key)
        Dbg.assertWithTag(TAG, not container.Class[key], "Class has key defined it shouldn't, key: " .. key)
    end
end)

TestClass:addTest("Class functionality", function (container)
    --- @cast container TestClass.container
    local TAG = container.TAG
    local Dbg = container.Logger

    Dbg.assertWithTag(TAG, container.ClassName == container.Class:getClassName(), "Class:getClassName()")
    Dbg.assertWithTag(TAG, container.SimpleClassName == container.SimpleClass:getClassName(), "SimpleClass:getClassName()")

    Dbg.assertWithTag(TAG, container.ClassName == container.Class:getAllClassNames()[1], "Class:getAllClassNames()")
    Dbg.assertWithTag(TAG, container.SimpleClassName == container.SimpleClass:getAllClassNames()[1], "SimpleClass:getAllClassNames()")

    Dbg.assertWithTag(TAG, next(container.Class.inherits) == container.Class:getClassName(), "Class.inherits")
    Dbg.assertWithTag(TAG, next(container.SimpleClass.inherits) == container.SimpleClass:getClassName(), "SimpleClass.inherits")

    Dbg.assertWithTag(TAG, not container.Class:inheritsClass(container.Class), "not Class:inheritsClass(Class)")
    Dbg.assertWithTag(TAG, not container.SimpleClass:inheritsClass(container.SimpleClass), "not SimpleClass:inheritsClass(SimpleClass)")

    Dbg.assertWithTag(TAG, container.Class:isExactClass(container.Class), "Class:isExactClass(Class)")
    Dbg.assertWithTag(TAG, container.SimpleClass:isExactClass(container.SimpleClass), "SimpleClass:isExactClass(SimpleClass)")

    Dbg.assertWithTag(TAG, container.Class:getPrivateTable() and next(container.Class:getPrivateTable()) == nil, "Class:getPrivateTable()")
    Dbg.assertWithTag(TAG, container.SimpleClass:getPrivateTable() and next(container.SimpleClass:getPrivateTable()) == nil, "SimpleClass:getPrivateTable*()")

    Dbg.assertFunctionRunsWithTag(TAG, container.Class.setPrivate, { container.Class, "key", "value" }, "Class:setPrivate('key', 'value')")
    Dbg.assertFunctionRunsWithTag(TAG, container.SimpleClass.setPrivate, { container.SimpleClass, "key", "value" }, "SimpleClass:setPrivate('key', 'value')")

    Dbg.assertWithTag(TAG, container.Class:getPrivate("key") == "value", "Class:getPrivate(key)")
    Dbg.assertWithTag(TAG, container.SimpleClass:getPrivate("key") == "value", "SimpleClass:getPrivate(key)")

    Dbg.assertWithTag(TAG, container.Class:getPrivateTable()["key"] == "value", "Class:getPrivateTable()")
    Dbg.assertWithTag(TAG, container.SimpleClass:getPrivateTable()["key"] == "value", "SimpleClass:getPrivateTable()")
end)

-- TestClass:addTest("Purposeful Fail", function (container) container.Logger.assertWithTag(container.TAG, false, "THIS IS A PURPOSEFUL FAIL") end)

return TestClass
