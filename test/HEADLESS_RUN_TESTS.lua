--[[
    Is used by headless to run tests
]]

--- TODO: Fix Logger so that it either works properly with headless, or has a "headless" mode that can be set

local pretty = require "cc.pretty"
local TestRunnerDef = require "common.Modules.Test.TestRunner"
local Dbg = require "common.Modules.Logger"
Dbg = Dbg.new()
Dbg = Dbg.setGlobalPath("log/ALL_TESTS.txt")

local TestRunner = TestRunnerDef:new({ Logger = Dbg })
-- Add Modules
TestRunner:addTestModule(require("test.Class"))
TestRunner:addTestModule(require("test.Expect"))


-- Run tests
local results, doc, str = TestRunner:run()
print(str)
---[[
os.sleep(1)
os.shutdown()
--]]
