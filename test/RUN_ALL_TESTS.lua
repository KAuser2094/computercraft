local TestRunnerDef = require "common.Modules.Test.TestRunner"
local Dbg = require "common.Modules.Logger"
Dbg = Dbg.new()
-- Change the global level to fatal if you only want to see failing tests, none to be completely silent except the total results at the end
Dbg = Dbg.setPath("log_all_tests.txt")

local TestRunner = TestRunnerDef.new({ Logger = Dbg })
TestRunner:setFailures():setShow(term.current())
-- Add Modules
TestRunner:addTestModule(require("test.IClass"))

-- Run tests
local _ = TestRunner:run()
