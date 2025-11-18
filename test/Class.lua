--- @diagnostic disable: inject-field, undefined-field
local TestModule = require "common.Modules.Test.Test"
local DEBUGGER = require "common.Modules.Logger".singleton -- Let's not spam create loggers

local Class = require "common.Modules.Class"
local ExampleFields = require "test.contexts.Class"

local ClassTest = TestModule:new("Class Test", DEBUGGER)

--- @class test.ClassTests.Context : common.Modules.Test.BaseContext
--- @field ClassName string
--- @field ClassDef common.Modules.Class.ClassDefinition
--- @field Class common.Modules.Class.Class
--- @field SubClassName string
--- @field SubClassDef common.Modules.Class.ClassDefinition
--- @field SubClass common.Modules.Class.Class

--- Test Specific initialisation of test context
--- @param ctx table
--- @return test.ClassTests.Context ctx
function ClassTest:testInitialise(ctx)
    ctx = TestModule.testInitialise(self, ctx)
    --- Cast ctx to appropriate if needed:
    --- @cast ctx test.ClassTests.Context
    ctx.ClassName = ExampleFields.BASE_CLASS_NAME
    ctx.ClassDef =  ExampleFields.BASE_CLASS_DEFINITION
    ctx.Class = ExampleFields.BASE_CLASS_INSTANCE

    ctx.SubClassName = ExampleFields.SUB_CLASS_NAME
    ctx.SubClassDef = ExampleFields.SUB_CLASS_DEFINITION
    ctx.SubClass = ExampleFields.SUB_CLASS_INSTANCE
    return ctx
end

function ClassTest:testCleanUp(ctx) end

--[[

ClassTest:addTest("TEST_NAME", function (ctx)
    --- @cast ctx test.ClassTests.Context
    local tag = ctx.TAG
    local dbg = ctx.debugger

end)

--]]

ClassTest:addTest("CHECK CLASS FIELDS", function (ctx)
    --- @cast ctx test.ClassTests.Context
    local TAG = ctx.TAG
    local dbg = ctx.debugger

    --- Class Instance only (not making a loop for this)
    dbg.assertWithTag(TAG, ctx.Class["isAClass"] ~= nil, "Class is missing field: " .. "isAClass")
    dbg.assertWithTag(TAG, ctx.ClassDef["isAClass"] == nil, "ClassDef has field it shouldn't " .. "isAClass")
    dbg.assertWithTag(TAG, ctx.SubClass["isAClass"] ~= nil, "SubClass is missing field: " .. "isAClass")
    dbg.assertWithTag(TAG, ctx.SubClassDef["isAClass"] == nil, "SubClassDef has field it shouldn't " .. "isAClass")

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
        dbg.assertWithTag(TAG, ctx.Class[key] ~= nil, "Class is missing field: " .. key)
        dbg.assertWithTag(TAG, ctx.ClassDef[key] ~= nil, "ClassDef is missing field: " .. key)

        dbg.assertWithTag(TAG, ctx.SubClass[key] ~= nil, "SubClass is missing field: " .. key)
        dbg.assertWithTag(TAG, ctx.SubClassDef[key] ~= nil, "SubClassDef is missing field: " .. key)
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
        dbg.assertWithTag(TAG, ctx.ClassDef[key] ~= nil, "ClassDef is missing field: " .. key)
        dbg.assertWithTag(TAG, ctx.Class[key] == nil, "Class has ClassDefOnly field: " .. key)

        dbg.assertWithTag(TAG, ctx.SubClassDef[key] ~= nil, "SubClassDef is missing field: " .. key)
        dbg.assertWithTag(TAG, ctx.SubClass[key] == nil, "SubClass has SubClassDefOnly field: " .. key)
    end

    -- Inheritance of fields check

    dbg.assertWithTag(TAG, ctx.Class.baseField, "Sanity Check: BaseClass instance has baseField")
    dbg.assertWithTag(TAG, ctx.ClassDef.baseField, "Sanity Check: BaseClassDef has baseField")
    dbg.assertWithTag(TAG, ctx.SubClass.baseField, "Inheritance Check: SubBaseClass instance should have baseField")
    dbg.assertWithTag(TAG, ctx.SubClassDef.baseField, "Inheritance Check: SubBaseClassDef should have baseField")

    dbg.assertWithTag(TAG, ctx.SubClass.subField, "Sanity Check: SubBaseClass instance has subField")
    dbg.assertWithTag(TAG, ctx.SubClassDef.subField, "Sanity Check: SubBaseClassDef has subField")
    dbg.assertWithTag(TAG, not ctx.Class.subField, "Inheritance Check: BaseClass instance should NOT have subField")
    dbg.assertWithTag(TAG, not ctx.ClassDef.subField, "Inheritance Check: BaseClassDef should NOT have subField")

    -- TODO: Add a check on what fields are in proxy vs in the class instance itself
end)

ClassTest:addTest("CHECK INHERITANCE", function (ctx)
    --- @cast ctx test.ClassTests.Context
    local TAG = ctx.TAG
    local dbg = ctx.debugger
    ---

    --- Sanity, their names do match what we expect
    dbg.assertWithTag(TAG,
    ctx.Class:getClassName() == ctx.ClassName,
    "Class' name somehow does not match the name used to define: " .. ctx.Class.getClassName() .. " vs " .. ctx.ClassName)
    -- (These are just here to stop the auto indent being weird)
    dbg.assertWithTag(TAG,
    ctx.ClassDef:getClassName() == ctx.ClassName,
    "ClassDef's name somehow does not match the name used to define: " .. ctx.ClassDef.getClassName() .. " vs " .. ctx.ClassName)
    --
    dbg.assertWithTag(TAG,
    ctx.SubClass:getClassName() == ctx.SubClassName,
    "SubClass' name somehow does not match the name used to define: " .. ctx.SubClass.getClassName() .. " vs " .. ctx.SubClassName)
    --
    dbg.assertWithTag(TAG,
    ctx.SubClassDef:getClassName() == ctx.SubClassName,
    "SubClassDef's name somehow does not match the name used to define: " .. ctx.SubClassDef.getClassName() .. " vs " .. ctx.SubClassName)
    --

    -- TODO: Add check for getAllClassNames() as well

    -- Check isClass
    dbg.assertWithTag(TAG, ctx.SubClass:isClass(ctx.SubClassName), "Did not match isClass with name")
    dbg.assertWithTag(TAG, ctx.SubClass:isClass(ctx.SubClass), "Did not match isClass with instance")
    dbg.assertWithTag(TAG, ctx.SubClass:isClass(ctx.SubClassDef), "Did not match isClass with definition")
    dbg.assertWithTag(TAG, ctx.SubClass:isClass(ctx.ClassName), "Did not match isClass with base name")
    dbg.assertWithTag(TAG, ctx.SubClass:isClass(ctx.Class), "Did not match isClass with base instance")
    dbg.assertWithTag(TAG, ctx.SubClass:isClass(ctx.ClassDef), "Did not match isClass with base definition")

    -- Check inherits
    dbg.assertWithTag(TAG, not ctx.SubClass:inheritsClass(ctx.SubClassName), "Did not NOT match inheritsClass with name")
    dbg.assertWithTag(TAG, not ctx.SubClass:inheritsClass(ctx.SubClass), "Did not NOT match inheritsClass with instance")
    dbg.assertWithTag(TAG, not ctx.SubClass:inheritsClass(ctx.SubClassDef), "Did not NOT match inheritsClass with definition")
    dbg.assertWithTag(TAG, ctx.SubClass:inheritsClass(ctx.ClassName), "Did not match inheritsClass with base name")
    dbg.assertWithTag(TAG, ctx.SubClass:inheritsClass(ctx.Class), "Did not match inheritsClass with base instance")
    dbg.assertWithTag(TAG, ctx.SubClass:inheritsClass(ctx.ClassDef), "Did not match inheritsClass with base definition")

    -- Check exact
    dbg.assertWithTag(TAG, ctx.SubClass:isExactClass(ctx.SubClassName), "Did not match isExactClass with name")
    dbg.assertWithTag(TAG, ctx.SubClass:isExactClass(ctx.SubClass), "Did not match isExactClass with instance")
    dbg.assertWithTag(TAG, ctx.SubClass:isExactClass(ctx.SubClassDef), "Did not match isExactClass with definition")
    dbg.assertWithTag(TAG, not ctx.SubClass:isExactClass(ctx.ClassName), "Did not NOT match isExactClass with base name")
    dbg.assertWithTag(TAG, not ctx.SubClass:isExactClass(ctx.Class), "Did not NOT match isExactClass with base instance")
    dbg.assertWithTag(TAG, not ctx.SubClass:isExactClass(ctx.ClassDef), "Did not NOT match isExactClass with base definition")

end)

return ClassTest
