--- NOTE: Move this to (or just require this from) the root
local TestRunnerDef = require "common.Modules.Test.TestRunner"
local Dbg = require "common.Modules.Logger"
Dbg = Dbg.new()
-- Change the global level to fatal if you only want to see failing tests, none to be completely silent except the total results at the end
Dbg = Dbg.setGlobalPath("log/ALL_TESTS.txt")

local TestRunner = TestRunnerDef:new({ Logger = Dbg })
TestRunner:setVerbose():setShow(term.current())
-- Add Modules
TestRunner:addTestModule(require("test.Class"))
TestRunner:addTestModule(require("test.Expect"))


-- Run tests
local _ = TestRunner:run()
