--- @diagnostic disable: inject-field, undefined-field
local Class = require "common.Modules.Class"
local TestModule = require "common.Modules.Test.Test"
local ExampleFields = require "test.container_fields"


--- @class test.EmptyTests : common.Modules.Test.TestModuleDefinition
local EmptyTests = Class("CLASS TESTS", TestModule)

function EmptyTests:init(this, kwargs)
    TestModule.init(self, this, kwargs)
end

function EmptyTests.testInit(this, c)
end

--- @class test.EmptyTests.container : common.Modules.Test.TestModule.container

--[[
EmptyTests:addTest("CHANGEME", function (container)
    --- @cast container test.EmptyTests.container
    local TAG = container.TAG
    local Dbg = container.Logger
    ---

end)
--]]

---[[
EmptyTests:addTest("CHANGEME", function (container)
    --- @cast container test.EmptyTests.container
    local TAG = container.TAG
    local Dbg = container.Logger
    ---

end)
--]]

return EmptyTests
