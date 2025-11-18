--- @diagnostic disable: inject-field, undefined-field
local TestModule = require "common.Modules.Test.Test"
local DEBUGGER = require "common.Modules.Logger".singleton -- Let's not spam create loggers


local REPLACE_ME = TestModule:new("REPLACE_ME", DEBUGGER)

--- Test Specific initialisation of test context
--- @param ctx table
--- @return common.Modules.Test.BaseContext ctx
function REPLACE_ME:testInitialise(ctx)
    ctx = TestModule.testInitialise(self, ctx)
    --- Cast ctx to appropriate if needed:

    return ctx
end

function REPLACE_ME:testCleanUp(ctx) end

---[[

REPLACE_ME:addTest("TEST_NAME", function (ctx)
    --- @cast ctx common.Modules.Test.BaseContext
    local tag = ctx.TAG
    local dbg = ctx.debugger
end)

--]]


return REPLACE_ME
