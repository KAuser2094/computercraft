local Dbg = assert(require("common.Modules.Logger")).singleton
local TAG = "EXPECT"
Dbg.getTagSettings(TAG):setLevel(Dbg.Levels.Warning)

local pretty = assert(require("cc.pretty"))

--- @class common.expect
local expect = {} -- Don't really like this name but I want this to be a replacement to "cc.expect"

-- Types to add:
-- Postive, Negative, Zero.

--- @enum
expect.TYPES = {
    ["nil"] = "nil",
    boolean = "boolean",
    string = "string",
    number = "number",
    ["function"] = "function",
    table = "table,",
    thread = "thread",
    userdata = "userdata", -- This one basically doesn't exist, but I will add for completion's sake
    -- Extra types
    integer = "integer",
    callable = "callable",
    wrappedPeripheral = "wrappedPeripheral",
    Class = "Class",
    ClassDefinition = "ClassDefinition",
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
    local err = pretty.render(pretty.concat( "TAG:", pretty.pretty(tag), pretty.space, "ID:", pretty.pretty(index),  pretty.space, "VALUE:", pretty.pretty(value), pretty.space, "TYPES:", pretty.pretty(types)))
    err = err:gsub('"', "*")
    error(err)
end

--- Sets this tag's level for expects (This just sets the tags level in the singleton, arguably should be doing that yourself directly)
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

--- Disables expect for the tag (note: no tag is always enabled)
--- @param tag string
--- @return common.expect -- For chaining
function expect.disableTag(tag)
    enabledTags[tag] = false
    return expect
end


--- Does the same as `cc.expect` but also works if the table implements `IExpect`
--- `IExpect` is `__expect fun(self, type: any):boolean` and `__expectGetTypes fun(self):any[]`
--- Will log outputs at NoTag ("")
--- @generic T
--- @param index string | number
--- @param value `T`
--- @param type1 any
--- @param ... any
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
--- @param type1 any
--- @param ... any
--- @return `T`? value Returns the value if success
function expect.expectWithTag(tag, index, value, type1, ...)
    if not enabledTags[tag] then return value end -- Not enabled
    local ret, matchedNil = expect.isType(value, type1, ...)
    if ret ~= nil or matchedNil then return ret end
    failedExpeect(tag, index, value, { type1, ... })
end

--- @generic T
--- @param value `T`
--- @param type1 any
--- @param ... any
--- @return `T`? value Returns the value if success
--- @return boolean? matchedNil Will return true if the `value` was nil and the type "nil" was provided
function expect.isType(value, type1, ...)
    local args = { type1, ... }
    local valueType = type(value)
    local valueImplementsIExpect = valueType == "table" and not not value.__expect
    for _, ty in pairs(args) do -- technically select would be more effecient...
        -- Base + Custom Base types
        if type(ty) == expect.TYPES.string then
            -- Base types
            if valueType == ty then return value, ty == "nil" end
            -- Custom Base types
            if ty == expect.TYPES.integer then
                if valueType == "number" and value % 1 == 0 then return value end
            elseif ty == expect.TYPES.callable then
                if valueType == "function" or (valueType == "table" and getmetatable(value).__call) then return value end
            elseif ty == expect.TYPES.wrappedPeripheral and valueType == "table" then
                local mt = getmetatable(value)
                if mt and mt.__name == "peripheral" then return value end
            elseif ty == expect.TYPES.Class then
                if valueType == "table" and value.isAClass then return value end
            elseif ty == expect.TYPES.ClassDefinition then
                if valueType == "table" and value.isAClassDefinition then return value end
            end
        end
        -- Class specific types
        if valueImplementsIExpect then
            if value:__expect(ty) then return value end
            if type(ty) == "table" and ty.__expectGetTypes then
                for _, ty2 in pairs(ty:__expectGetTypes()) do
                    if value:__expect(ty2) then return value end
                end
            end
        end
    end
    return nil
end

return expect
