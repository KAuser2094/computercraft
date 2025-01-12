local Dbg = require "common.Modules.Logger"
local utils = require "common.Modules.Class.utils"
local TAG = "CLASS_DEF"
Dbg = Dbg.singleton
Dbg = Dbg.setTagLevel(TAG, Dbg.Levels.Warning)

-- MAYBE: Separate local functions into a utils file?
-- MAYBE: Add a check to see if a class definition was attempted to be made with the same name as one already in the program
-- TODO: Default for settings (make a default table in the correct shape and deep merge it in), also let other classes add to their own default

local private = setmetatable({}, {__mode = 'k'}) -- Holds the private fields of a class, indexed by the instance reference

--- @type common.Class.ClassDefinition
local BASE_CLASS_DEFINITION

--- Returns an empty Class Definition (just in case you need to overwrite it)
--- @return common.Class.ClassDefinition
local function getBaseClassDefinition()
    return BASE_CLASS_DEFINITION
end

--- Creates A ClassDefinition Object
--- @param _className string The class name (try to make this unique within the program)
--- @param base? common.Class.ClassDefinition
--- @param ... common.Class.ClassDefinition
--- @return common.Class.ClassDefinition BaseDefinition The Base ClassDefinition Object you can add onto.
local function MakeClassDefinition(_className, base, ...)
    --- @type (common.Class.ClassDefinition?)[] -- NOTE: THIS COULD END UP BEING SPARSE
    local bases = { base, ... }
    Dbg.logI(TAG, "Creating ClassDef with name: " .. _className)
    local cls = {}
    --[[
        INHERITANCE (We do this first so we can set the values for later definition)
    ]]
    -- This is quite long...do not feel like seperating it though.
    --- @type _C_lass_D_efinition._private.__inheritanceSettings
    cls.__inheritanceSettings = {
        doNotCopy = {
            className = true,
            getClassName = true, -- These use the "className" up value, hence why we cannot copy them (technically could just not do that...)
            getAllClassNames = true,
            isClass = true,
            isExactClass = true,
            inheritsClass = true,
            _new = true,
            new = true,
            __inheritanceSettings = true, -- This is ALWAYS deep merged on inherit
            __instanceSettings = true, -- This is ALWAYS deep merged on inherit
            __otherSettings = true, -- This is ALWAYS deep merged on inherit, also deep merged with "default.__otherSettings"
            inherits = true,
            hooks = true,
        },
        merge = {
            inherits = true,

        },
        deepMerge = {
            hooks = true,
        },
    }

    --- @class _C_lass_D_efinition._private.__instanceSettings
    cls.__instanceSettings = {
        -- Only add functions that solely are called when defining/on definitions, not "private" methods.
        definitionOnly = { -- This check is implemented in the __index method.
            __inheritanceSettings = true,
            isAClassDefinition = true,
            inheritInto = true,
            inheritFrom = true,
            doNotInherit = true,
            mergeOnInherit = true,
            deepMergeOnInherit = true,
            postInherited = true,
            postInit = true,
            init = true,
            _new = true,
            new = true,
            _checkWellFormed = true,
            checkWellFormed = true,
            markPublic = true,
            markDefinitionOnly = true, -- Ironic
            getBaseClassDefinition = true,
            -- ... rest is to be done using the markDefinitionOnly function
        },
        public = {
            -- to be done with the markPublic function
        },
        effectiveKeys = {

        }
    }

    --- @class _C_lass_D_efinition._private.__otherSettings
    cls.__otherSettings = {
        protectEffectiveKeys = true,
    }

    cls.inheritInto = utils.inheritInto

    cls.inheritFrom = utils.inheritFrom

    cls.doNotInherit = utils.doNotInherit

    cls.mergeOnInherit = utils.mergeOnInherit

    cls.deepMergeOnInherit = utils.deepMergeOnInherit

    cls.postInherited = utils.postInherited

    --[[
        INSTANCE
    ]]
    cls.init = utils.init

    cls._new = function (...)
        return utils.new(cls, ...)
    end

    cls.new = function (...)
        return cls._new(...)
    end

    cls.postInit = utils.postInit

    cls._checkWellFormed = utils._checkWellFormed
    cls.checkWellFormed = utils.checkWellFormed

    cls.markPublic = utils.markPublic
    cls.markDefinitionOnly = utils.markDefinitionOnly

    --[[
        DEFINITION ONLY (ALso basically everything above is also DEFINITION ONLY)
    ]]
    cls.isAClassDefinition = true


    --[[
        PRIVATE FIELDS AND METHODS
    ]]
    cls.className = _className .. "_" .. tostring(utils.getNewClassDefinitionID())

    --- @type common._C_lass._private.inherits
    cls.inherits = { [cls.className] = cls } -- You technically inherit yourself

    --- PRIVATE

    cls.getPrivateTable = utils.getPrivateTable

    cls.getPrivate = utils.getPrivate

    cls.setPrivateTable = utils.setPrivateTable

    cls.setPrivate = utils.setPrivate

    -- Class definitions should have there own private table. (This is usually used for stuff that both need to be in inherited but not their contents, so we use getters and setters)
    cls:setPrivateTable({})

    --- KEY CONFLICTS

    --- Adds the key to effective keys
    --- @param key any
    function cls:setEffectiveKey(key)
        if self.isAClassDefinition then
            self.__instanceSettings.effectiveKeys[key] = true
        elseif self.isAClass then
            local p = self:getPrivateTable()
            p.__effectiveKeys = p.__effectiveKeys or {} -- Make the table just in case
            p.__effectiveKeys[key] = true
        end
    end

    --- Checks if the key is an effective key
    --- @param key any
    --- @return boolean
    function cls:isEffectiveKey(key)
        if self.__instanceSettings.effectiveKeys[key] then return true end
        if self.isAClass then
            local p = self:getPrivateTable()
            p.__effectiveKeys = p.__effectiveKeys or {} -- Make the table just in case
            if p.__effectiveKeys[key] then return true end
        end
        return false
    end

    --- PROTECTED KEYS


    function cls:addProtectionToKey(key)

    end

    --- METATABLE HOOKS AND OTHER

    cls.preIndex = utils.preIndex
    cls.postIndex = utils.postIndex
    cls.preNewIndex = utils.preNewIndex

    --[[
        PUBLIC FIELDS AND METHODS
    ]]

    --- Returns this exact class name
    --- @return string
    function cls.getClassName()
        return cls.className
    end

    cls:markPublic("getClassName")

    --- Returns all class names
    --- @return string[]
    function cls.getAllClassNames()
        local names = {}
        for klassName, _ in pairs(cls.inherits) do
            table.insert(names, klassName)
        end
        return names
    end

    cls:markPublic("getAllClassNames")

    --- Checks if thhe class inherits the given klass
    --- @param klass string | common.Class.ClassOrDefinition
    --- @return boolean
    function cls:inheritsClass(klass)
        local klassName = utils.getClassNameFromTypesWithIt(klass)
        if not klassName then return false end
        if klassName == cls.className then return false end -- Is Exact Class
        for baseName, _ in pairs(cls.inherits) do
            if baseName == klassName then return true end
        end
        return false
    end

    cls:markPublic("inheritsClass")

    --- Checks if thhe class is an exact instance of the given klass
    --- @param klass string | common.Class.ClassOrDefinition
    --- @return boolean
    function cls:isExactClass(klass)
        local klassName = utils.getClassNameFromTypesWithIt(klass)
        if not klassName then return false end
        if cls.className == klassName then return true end
        return false
    end

    cls:markPublic("isExactClass")

    --- Checks if thhe class is exactly or inherits from the given klass
    --- @param klass string | common.Class.ClassOrDefinition
    --- @return boolean
    function cls:isClass(klass)
        local klassName = utils.getClassNameFromTypesWithIt(klass)
        if not klassName then return false end
        Dbg.logI(TAG, "inherits = ",cls.inherits)
        for baseName, _ in pairs(cls.inherits) do
            Dbg.logV("Checking", baseName, "against:", klassName, ". Result:", baseName == klassName)
            if baseName == klassName then return true end
        end
        return false
    end

    cls:markPublic("isClass")

    --[[
        META METHODS
    ]]

    -- Own metamethod(s)
    setmetatable(cls, {
        __call = function(_, ...)
            return cls.new(...)
        end,
    })

    cls.__index = function (self, key)
        Dbg.logV(TAG, "trying to find:",key)
        -- Check instances private
        local try =  cls.getPrivate(self, key)
        if try ~= nil then return try end

        local rawDefinition = rawget(cls, key)
        Dbg.logV(TAG, "Found at definition: ", rawDefinition)
        try = utils._preIndex(cls, self, key)
        -- Do not return a definition only value
        -- (These checks check if the value was taken from the ClassDefinition, and if they did, to nil it if is is a definition only value)
        try = (type(try) ~= type(rawDefinition) or try ~= rawDefinition) and try or nil -- nil try if just got the same as rawget on the definition
        rawDefinition = not cls.__instanceSettings.definitionOnly[key] and rawDefinition or nil -- nil the rawget from definition if it is definition only
        Dbg.logV(TAG, "After def only check, found at definition is:", rawDefinition)
        local ret = try or rawDefinition or nil

        ret = utils._postIndex(cls, self, key, ret)
        return ret
    end

    cls.__newindex = function (self, key, value)
        -- Protection against key conflics
        if cls.__otherSettings.protectEffectiveKeys and cls.isEffectiveKey(self, key) then
            -- Key conflict
            local pretty = require "cc.pretty"
            local err = "KEY CONFLICT, the key: " ..  pretty.render(pretty.pretty(key)) .. " was already an effective key"
            Dbg.logE(TAG, err)
            error(err, 2) -- Level 2 is whatever caused __newindex to be called
        end

        -- Try and set with the hooks
        local set = utils._preNewIndex(cls, self, key, value)
        -- Otherwise use default
        if not set then
            rawset(self, key, value)
        end
    end

    cls.__expect = utils.__expect

    cls.__expectGetTypes = utils.__expectGetTypes

    -- This is a "just in case", idk if I will end up using it
    cls.getBaseClassDefinition = getBaseClassDefinition

    -- Inherit bases
    if next(bases) then -- Has any element
        cls:inheritFrom(table.unpack(bases))
    end

    return cls
end

BASE_CLASS_DEFINITION = MakeClassDefinition("") -- If require caches probably this is only called once

return MakeClassDefinition
