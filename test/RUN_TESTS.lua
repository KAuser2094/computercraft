local TestRunnerDef = require "common.Modules.Test.TestRunner"
local Dbg = require "common.Modules.Logger"
Dbg = Dbg.new()
-- Change the global level to fatal if you only want to see failing tests, none to be completely silent except the total results at the end
Dbg = Dbg:setOutputTerminal(term.current()):setGlobalLevel(Dbg.Levels.Verbose)

local TestRunner = TestRunnerDef.new({ Logger = Dbg })

-- Add Modules


-- Run tests
local _ = TestRunner:run()
