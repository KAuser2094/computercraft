local Dbg = require "common.Modules.Logger"
local TAG = "CLASS_DEF"
Dbg = Dbg.new()
Dbg = Dbg.setOutputTerminal(term.current()).setTagLevel(TAG, Dbg.Levels.Warning)

--- Is used to define a class

--- Gets the string className from the valid types
--- @param klass string | ClassDefinition | Class
--- @return string | nil  klassName Returns nil if not a valid type
local function getClassNameFromTypesWithIt(klass)
    Dbg.logV(TAG, "Getting ClassName from:",klass)
    if type(klass) == "string" then return klass end
    if klass.isAClassDefinition or klass.isAClass then return klass.getClassName() end

    Dbg.logE(TAG, "SOMEHOW GOT NIL GIVE KLASS, klass, type, isAClass/Definition", klass, type(klass), klass.isAClassDefinition or klass.isAClass)
end

--- Shallow merges
--- @param tbl table
--- @param other table
local function shallowMerge(tbl, other)
    for k,v in pairs(other) do
        tbl[k] = v
    end
end

--- Shallow merges, skipping any key in the preserve table
--- @param tbl table
--- @param other table
--- @param preserve? string[]
local function shallowMergeWithPreserve(tbl, other, preserve)
    for k,v in pairs(other) do
        if (preserve and preserve[k]) then -- Case: Preserve
            -- print("Preserved " .. k)
        else -- Case: Overwrite
            tbl[k] = v
        end
    end
end

--- Deep Merges
--- @param tbl table
--- @param other table
local function deepMerge(tbl, other)
    for k, v in pairs(other) do
        if type(v) == "table" then
            tbl[k] = tbl[k] or {} -- Presumes same shape of tables (ignoring other types)
            deepMerge(tbl[k], v)
        else
            tbl[k] = v
        end
    end
end

local private = setmetatable({}, {__mode = 'k'}) -- Holds the private fields of a class, indexed by the instance reference

--[[
    INHERITANCE
]]

--- Default inheritance into another definition
--- @param self ClassDefinition
--- @param klass ClassDefinition
local function _basicInheritInto(self, klass)
    deepMerge(klass.__inheritanceSettings, self.__inheritanceSettings)
    deepMerge(klass.__instanceSettings, self.__instanceSettings)
    deepMerge(klass.__otherSettings, self.__otherSettings) -- This COULD mess up some settings

    shallowMergeWithPreserve(klass, self, klass.__inheritanceSettings.doNotCopy)

    for k, v in pairs(klass.__inheritanceSettings.merge) do
        if v then -- Just in case someone set to false
            klass[k] = klass[k] and klass[k] or {}
            self[k] = self[k] and self[k] or {}
            shallowMerge(klass[k],self[k])
        end
    end
    -- klass.inherits[self:getClassName()] = self -- When you create a new ClassDefinition you are inheriting yourself already

    for k, v in pairs(klass.__inheritanceSettings.deepMerge) do
        if v then -- Just in case someone set to false
            klass[k] = klass[k] and klass[k] or {}
            self[k] = self[k] and self[k] or {}
            deepMerge(klass[k],self[k])
        end
    end

    -- TODO: Execute hook
    self:postInherited(klass)
end

--- Runs after self inherits INTO (is inherited by) a klass
--- @param self ClassDefinition
--- @param klass ClassDefinition
local function postInherited(self, klass) end

 --- inherits this into the given class definition as a base class
--- @param self ClassDefinition
 --- @param klass ClassDefinition
local function inheritInto(self, klass)
    _basicInheritInto(self, klass)
end

--- Inherits from the given classes, goes from last given to first.
--- @param self ClassDefinition
--- @param klass ClassDefinition Base class to inherit from
--- @param ... ClassDefinition ...
local function inheritFrom(self, klass, ...)
    local klasses = { ... }
    for i=#klasses, 1, -1 do
        local kls = klasses[i]
        kls:inheritInto(self)
    end
    klass:inheritInto(self)
end

--- Makes it so the key will not be inherited
--- @param self ClassDefinition
--- @param key any
local function doNotInherit(self, key)
    if not self[key] then
        Dbg.logW(TAG, "Set a key", key, "that isn't set to 'doNotInhert' in class", self:getClassName())
    end
    self.__inheritanceSettings.doNotCopy[key] = true
end

--- Makes it so the key will merged up (used for tables)
--- @param self ClassDefinition
--- @param key any
local function mergeOnInherit(self, key)
    if not self[key] then
        Dbg.logW(TAG, "Set a key", key, "that isn't set to 'merge' in class", self:getClassName())
    end
    self.__inheritanceSettings.doNotCopy[key] = true
    self.__inheritanceSettings.merge[key] = true
end

--- Makes it so the key will deep-merged up (used for tables)
--- @param self ClassDefinition
--- @param key any
local function deepMergeOnInherit(self, key)
    if not self[key] then
        Dbg.logW(TAG, "Set a key", key, "that isn't set to 'deepMerge' in class", self:getClassName())
    end
    self.__inheritanceSettings.doNotCopy[key] = true
    self.__inheritanceSettings.deepMerge[key] = true
end

--[[
    INSTANCE
]]

--- Called when creating an instance
--- @param self Class
--- @param ... any The parameters
local function init(self, ...) end

--- Creates an instance given a definition
--- @param definition ClassDefinition
--- @param ... any The parameters to pass into the `init` function
--- @return Class instance
local function new(definition, ...)
    local this = {}

    private[this] = {} -- Add a private instance variable table (Let's you hide instance fields, call getPrivateTable() to get the table back)

    this.isAClass = true

    -- Makes certain functions and values public
    for key, v in pairs(definition.__instanceSettings.public) do
        if v then -- Check in case v got set to false
            this[key] = definition[key]
        end
    end

    setmetatable(this, definition)

    if definition.init then -- It should always exist...
        definition.init(this, ...)
    end

    definition:postInit(this)
    definition:_checkWellFormed(this)

    return this
end

--- Is ran after the initialisation of a class for the given definition
--- @param self ClassDefinition
--- @param instance Class
local function postInit(self, instance) end

--- Is ran after ALL initialisation, extra checks on wellformedness
--- @param self ClassDefinition
--- @param instance Class
local function _checkWellFormed(self, instance) --[[Implemented in Interface class.]] end

--- Is ran after ALL initialisation, extra checks on wellformedness, extra wellformedness checks that can be defined
--- @param self ClassDefinition
--- @param instance Class
local function checkWellFormed(self, instance) --[[Implemented in Interface class.]] end

--- Makes a the key-value at key public so the user can see the fields in the class
--- @param self ClassDefinition
--- @param key string
local function markPublic(self, key)
    if not self[key] then
        Dbg.logW(TAG, "Set a key", key, "that isn't set to 'public' in class", self:getClassName())
    end
    self.__instanceSettings.public[key] = true
end

--- Makes a the key-value at key public so the user can see the fields in the class
--- @param self ClassDefinition
--- @param key string
local function markDefinitionOnly(self, key)
    if not self[key] then
        Dbg.logW(TAG, "Set a key", key, "that isn't set to 'definitionOnly' in class", self:getClassName())
    end
    self.__instanceSettings.definitionOnly[key] = true
end

--[[
    METAMETHOD HOOKS AND OTHER STUFF
]]

-- INDEX

--- @param cls ClassDefinition
--- @param this Class
--- @param key any
--- @return any value
local function _preIndex(cls, this, key)
    local ret
    for _, base in pairs(cls.inherits) do
        ret = base:preIndex(this, key)
        if ret ~= nil then return ret end
    end
end

--- @param cls ClassDefinition
--- @param this Class
--- @param key any
--- @return any value
local function preIndex(cls, this, key) end

--- @param cls ClassDefinition
--- @param this Class
--- @param key any
--- @param retValue any
local function _postIndex(cls, this, key, retValue)
    for _, base in pairs(cls.inherits) do
        retValue = cls:postIndex(this, key, retValue)
    end
    return retValue
end

--- @param cls ClassDefinition
--- @param this Class
--- @param key any
--- @param retValue any
local function postIndex(cls, this, key, retValue) return retValue end

-- NEW INDEX

--- @param cls ClassDefinition
--- @param this Class
--- @param key any
--- @param value any
local function _preNewIndex(cls, this, key, value) end

--- @param cls ClassDefinition
--- @param this Class
--- @param key any
--- @param value any
local function preNewIndex(cls, this, key, value) end



--[[
    CLASS DEFINITION PROPER
]]

--- Creates A ClassDefinition Object
--- @param className string The class name (try to make this unique within the program)
--- @return ClassDefinition BaseDefinition The Base ClassDefinition Object you can add onto.
local function MakeClassDefinition(className)
    Dbg.logI(TAG, "Creating ClassDef with name: " .. className)
    local cls = {}
    --[[
        INHERITANCE (We do this first so we can set the values for later definition)
    ]]
    -- This is quite long...do not feel like seperating it though.
    --- @type _C_lass_D_efinition._private.__inheritanceSettings
    cls.__inheritanceSettings = {
        doNotCopy = {
            className = true,
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
            markDefinitionOnly = true -- Ironic
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

    cls.inheritInto = inheritInto

    cls.inheritFrom = inheritFrom

    cls.doNotInherit = doNotInherit

    cls.mergeOnInherit = mergeOnInherit

    cls.deepMergeOnInherit = deepMergeOnInherit

    cls.postInherited = postInherited

    --[[
        INSTANCE
    ]]
    cls.init = init

    cls._new = function (...)
        return new(cls, ...)
    end

    cls.new = function (...)
        return cls._new(...)
    end

    cls.postInit = postInit

    cls._checkWellFormed = _checkWellFormed
    cls.checkWellFormed = checkWellFormed

    cls.markPublic = markPublic
    cls.markDefinitionOnly = markDefinitionOnly

    --[[
        DEFINITION ONLY (ALso basically everything above is also DEFINITION ONLY)
    ]]
    cls.isAClassDefinition = true


    --[[
        PRIVATE FIELDS AND METHODS
    ]]
    cls.className = className

    --- @type _C_lass._private.inherits
    cls.inherits = { [cls.className] = cls } -- You technically inherit yourself

    --- PRIVATE

    --- Gets the private table for the instance
    --- @param self Class
    --- @return table
    function cls.getPrivateTable(self)
        return private[self] -- If we are holding a reference to the table, then the key still exists
    end

    --- Gets the private table for the instance
    --- @param self Class
    --- @param key any Gets the private instance value at the key (This is already added to __index so you likely do not need to use this)
    function cls.getPrivate(self, key)
        if not self.isAClass then return end
        return private[self][key]
    end

    --- Completely replaces the private instance table (Sometimes it is easier to get the whole table, do work, and set it back)
    --- @param self Class
    --- @param tbl table
    function cls.setPrivateTable(self, tbl)
        if not self.isAClass then return end
        private[self] = tbl
    end

    --- Sets a private instance key-value pair (user won't be able to see it in the instance table)
    --- @param self Class
    --- @param key any
    --- @param value any
    function cls.setPrivate(self, key, value)
        if not self.isAClass then return end
        private[self][key] = value
    end

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

    cls.preIndex = preIndex
    cls.postIndex = postIndex
    cls.preNewIndex = preNewIndex

    --[[
        PUBLIC FIELDS AND METHODS
    ]]
    function cls.getClassName()
        return cls.className
    end

    cls:markPublic("getClassName")

    function cls.getAllClassNames()
        local names = {}
        for klassName, _ in pairs(cls.inherits) do
            table.insert(names, klassName)
        end
        return names
    end

    cls:markPublic("getAllClassNames")

    --- Checks if thhe class inherits the given klass
    --- @param klass string | ClassDefinition | Class
    --- @return boolean
    function cls:inheritsClass(klass)
        local klassName = getClassNameFromTypesWithIt(klass)
        if not klassName then return false end
        if klassName == className then return false end -- Is Exact Class
        for baseName, _ in pairs(cls.inherits) do
            if baseName == klassName then return true end
        end
        return false
    end

    cls:markPublic("inheritsClass")

    --- Checks if thhe class is an exact instance of the given klass
    --- @param klass string | ClassDefinition | Class
    --- @return boolean
    function cls:isExactClass(klass)
        local klassName = getClassNameFromTypesWithIt(klass)
        if not klassName then return false end
        if cls.className == klassName then return true end
        return false
    end

    cls:markPublic("isExactClass")

    --- Checks if thhe class is exactly or inherits from the given klass
    --- @param klass string | ClassDefinition | Class
    --- @return boolean
    function cls:isClass(klass)
        local klassName = getClassNameFromTypesWithIt(klass)
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
        try = _preIndex(cls, self, key)
        -- Do not return a definition only value
        -- (These checks check if the value was taken from the ClassDefinition, and if they did, to nil it if is is a definition only value)
        try = (type(try) ~= type(rawDefinition) or try ~= rawDefinition) and try or nil -- nil try if just got the same as rawget on the definition
        rawDefinition = not cls.__instanceSettings.definitionOnly[key] and rawDefinition or nil -- nil the rawget from definition if it is definition only
        Dbg.logV(TAG, "After def only check, found at definition is:", rawDefinition)
        local ret = try or rawDefinition or nil

        ret = _postIndex(cls, self, key, ret)
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
        local set = _preNewIndex(cls, self, key, value)
        -- Otherwise use default
        if not set then
            rawset(self, key, value)
        end
    end

    return cls
end

return MakeClassDefinition
--- TODO:
--- Default for settings (make a default table in the correct shape and deep merge it in), also let other classes add to their own default
