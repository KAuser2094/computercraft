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

TestIClass:addTest("Class and ClassDef has fields", function (container)
    --- @cast container TestIClass.container

    assert(container.Class.isAClass, "Class does not have isAClass")
    assert(not container.Class.isAClassDefinition, "Class should not have isAClassDefinition")
    assert(container.ClassDef.isAClassDefinition) -- I already got lazy to make the messages
    assert(not container.ClassDef.isAClass, "How did ClassDef get isAClass")

    
end)

return TestIClass
