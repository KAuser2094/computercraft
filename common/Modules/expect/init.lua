local Dbg = assert(require("common.Modules.Logger"))
Dbg = Dbg.singleton
local TAG = "EXPECT"
Dbg = Dbg.setTagLevel(TAG, Dbg.Levels.Warning)

--- @class common.expect
local expect = {} -- Don't really like this name but I want this to be a replacement to "cc.expect"

--- @alias _e_xpect.type_input _e_xpect.type_strings | common.Class.Class | common.Class.ClassDefinition | common.Class.SimpleClassDefinition

--- @enum _e_xpect.type_strings
expect.TYPES = {
    NIL = "nil",
    BOOLEAN = "boolean",
}

--- @type table<string, boolean>
local enabledTags = { [""] = true }

--- Logs out the error
--- @param tag string
--- @param index string | number
--- @param value any
--- @param types table
local function failedExpeect(tag, index, value, types)
    Dbg.logE(tag, index, ":", value, "does not have types from:", types)
end

--- Sets this tag's level for expects
--- @param tag string
--- @param level _L_ogger.LoggerLevel
--- @return common.expect self -- For chaining
function expect.setTagLevel(tag, level)
    Dbg.setTagLevel(tag, level)
    return expect
end

--- Enables expect for the tag (note: no tag is always enabled)
--- @param tag string
--- @return common.expect -- For chaining
function expect.enableTag(tag)
    enabledTags[tag] = true
    return expect
end

--- Does the same as `cc.expect` but also works if the table implements `IExpect`
--- `IExpect` is `__expect fun(self, type: any):boolean` and `__expectGetTypes fun(self):any[]`
--- Will log outputs at NoTag ("")
--- @generic T
--- @param index string | number
--- @param value `T`
--- @param type1 _e_xpect.type_input
--- @param ... _e_xpect.type_input
--- @return `T`? value Returns the value if success
function expect.expect(index, value, type1, ...)
    return expect.expectWithTag("", index, value, type1, ...)
end

--- Does the same as `cc.expect` but works for classes and anything that implements `__expect: fun(type: any): boolean` function
--- Will log outputs at `tag`
--- @generic T
--- @param tag string
--- @param index string | number
--- @param value `T`
--- @param type1 _e_xpect.type_input
--- @param ... _e_xpect.type_input
--- @return `T`? value Returns the value if success
function expect.expectWithTag(tag, index, value, type1, ...)
    if not enabledTags[tag] then return value end -- Not enabled
    local args = { type1, ... }
    local valueImplementsIExpect = not not value.__expect
    local valueType = type(value)
    for _, ty in pairs(args) do -- technically select would be more effecient...
        if valueType == ty then return value end -- We don't actually need to check if it is a base type
        if valueImplementsIExpect then
            if value:__expect(ty) then return value end
            if type(ty) == "table" and ty.__expectGetTypes then
                for _, ty2 in pairs(ty:__expectGetTypes()) do
                    if value:__expect(ty2) then return value end
                end
            end
        end
    end
    return failedExpeect(tag, index, value, args)
end

return {

}
