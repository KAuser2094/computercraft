--- @diagnostic disable: inject-field, undefined-field
local Class = require "common.Modules.Class"
local TestModule = require "common.Modules.Test.Test"
local ExampleFields = require "test.container_fields"

--- @class test.ClassTests : common.Modules.Test.TestModuleDefinition
local ClassTests = Class("CLASS TESTS", TestModule)

function ClassTests:init(this, kwargs)
    TestModule.init(self, this, kwargs)
end

function ClassTests.testInit(this, c)
    c.ClassName = ExampleFields.BASE_CLASS_NAME
    c.ClassDef =  ExampleFields.BASE_CLASS_DEFINITION
    c.Class = ExampleFields.BASE_CLASS_INSTANCE

    c.SubClassName = ExampleFields.SUB_CLASS_NAME
    c.SubClassDef = ExampleFields.SUB_CLASS_DEFINITION
    c.SubClass = ExampleFields.SUB_CLASS_INSTANCE
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

    -- Inheritance of fields check

    Dbg.assertWithTag(TAG, container.Class.baseField, "Sanity Check: BaseClass instance has baseField")
    Dbg.assertWithTag(TAG, container.ClassDef.baseField, "Sanity Check: BaseClassDef has baseField")
    Dbg.assertWithTag(TAG, container.SubClass.baseField, "Inheritance Check: SubBaseClass instance should have baseField")
    Dbg.assertWithTag(TAG, container.SubClassDef.baseField, "Inheritance Check: SubBaseClassDef should have baseField")

    Dbg.assertWithTag(TAG, container.SubClass.subField, "Sanity Check: SubBaseClass instance has subField")
    Dbg.assertWithTag(TAG, container.SubClassDef.subField, "Sanity Check: SubBaseClassDef has subField")
    Dbg.assertWithTag(TAG, not container.Class.subField, "Inheritance Check: BaseClass instance should NOT have subField")
    Dbg.assertWithTag(TAG, not container.ClassDef.subField, "Inheritance Check: BaseClassDef should NOT have subField")

    -- TODO: Add a check on what fields are in proxy vs in the class instance itself
end)
--]]

---[[
ClassTests:addTest("CLASS NAME/TYPE FUNCTIONALITY", function (container)
    --- @cast container test.ClassTests.container
    local TAG = container.TAG
    local Dbg = container.Logger
    ---

    --- Sanity, their names do match what we expect
    Dbg.assertWithTag(TAG,
    container.Class:getClassName() == container.ClassName,
    "Class' name somehow does not match the name used to define: " .. container.Class.getClassName() .. " vs " .. container.ClassName)
    -- (These are just here to stop the auto indent being weird)
    Dbg.assertWithTag(TAG,
    container.ClassDef:getClassName() == container.ClassName,
    "ClassDef's name somehow does not match the name used to define: " .. container.ClassDef.getClassName() .. " vs " .. container.ClassName)
    --
    Dbg.assertWithTag(TAG,
    container.SubClass:getClassName() == container.SubClassName,
    "SubClass' name somehow does not match the name used to define: " .. container.SubClass.getClassName() .. " vs " .. container.SubClassName)
    --
    Dbg.assertWithTag(TAG,
    container.SubClassDef:getClassName() == container.SubClassName,
    "SubClassDef's name somehow does not match the name used to define: " .. container.SubClassDef.getClassName() .. " vs " .. container.SubClassName)
    --

    -- TODO: Add check for getAllClassNames() as well

    -- Check isClass
    Dbg.assertWithTag(TAG, container.SubClass:isClass(container.SubClassName), "Did not match isClass with name")
    Dbg.assertWithTag(TAG, container.SubClass:isClass(container.SubClass), "Did not match isClass with instance")
    Dbg.assertWithTag(TAG, container.SubClass:isClass(container.SubClassDef), "Did not match isClass with definition")
    Dbg.assertWithTag(TAG, container.SubClass:isClass(container.ClassName), "Did not match isClass with base name")
    Dbg.assertWithTag(TAG, container.SubClass:isClass(container.Class), "Did not match isClass with base instance")
    Dbg.assertWithTag(TAG, container.SubClass:isClass(container.ClassDef), "Did not match isClass with base definition")

    -- Check inherits
    Dbg.assertWithTag(TAG, not container.SubClass:inheritsClass(container.SubClassName), "Did not NOT match inheritsClass with name")
    Dbg.assertWithTag(TAG, not container.SubClass:inheritsClass(container.SubClass), "Did not NOT match inheritsClass with instance")
    Dbg.assertWithTag(TAG, not container.SubClass:inheritsClass(container.SubClassDef), "Did not NOT match inheritsClass with definition")
    Dbg.assertWithTag(TAG, container.SubClass:inheritsClass(container.ClassName), "Did not match inheritsClass with base name")
    Dbg.assertWithTag(TAG, container.SubClass:inheritsClass(container.Class), "Did not match inheritsClass with base instance")
    Dbg.assertWithTag(TAG, container.SubClass:inheritsClass(container.ClassDef), "Did not match inheritsClass with base definition")

    -- Check exact
    Dbg.assertWithTag(TAG, container.SubClass:isExactClass(container.SubClassName), "Did not match isExactClass with name")
    Dbg.assertWithTag(TAG, container.SubClass:isExactClass(container.SubClass), "Did not match isExactClass with instance")
    Dbg.assertWithTag(TAG, container.SubClass:isExactClass(container.SubClassDef), "Did not match isExactClass with definition")
    Dbg.assertWithTag(TAG, not container.SubClass:isExactClass(container.ClassName), "Did not NOT match isExactClass with base name")
    Dbg.assertWithTag(TAG, not container.SubClass:isExactClass(container.Class), "Did not NOT match isExactClass with base instance")
    Dbg.assertWithTag(TAG, not container.SubClass:isExactClass(container.ClassDef), "Did not NOT match isExactClass with base definition")

end)
--]]

return ClassTests
