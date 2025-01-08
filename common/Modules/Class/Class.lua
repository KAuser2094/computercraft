local Dbg = require "Modules.Logger"
Dbg = Dbg.new():setOutputTerminal(term.current()):setPath("/log/Class.txt")
local TAG = "CLASS_DEF"

--- Is used to define a class

--- Gets the string className from the valid types
--- @param klass string | IClassDefinition | IClass
--- @return string | nil  klassName Returns nil if not a valid type
local function getClassNameFromTypesWithIt(klass)
    if type(klass) == "string" then return klass end

    if klass.isAClassDefinition or klass.isAClass then klass.getClassName() end
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
--- @param self IClassDefinition
--- @param klass IClassDefinition
local function _basicInheritInto(self, klass)
    deepMerge(klass.__inheritanceSettings, self.__inheritanceSettings)
    deepMerge(klass.__instanceSettings, self.__instanceSettings)

    shallowMergeWithPreserve(klass, self, klass.__inheritanceSettings.doNotCopy)

    for k, v in pairs(klass.__inheritanceSettings.merge) do
        if v then -- Just in case someone set to false
            klass[k] = klass[k] and klass[k] or {}
            self[k] = self[k] and self[k] or {}
            shallowMerge(klass[k],self[k])
        end
    end
    klass.inherits[self:getClassName()] = self

    for k, v in pairs(klass.__inheritanceSettings.deepMerge) do
        if v then -- Just in case someone set to false
            klass[k] = klass[k] and klass[k] or {}
            self[k] = self[k] and self[k] or {}
            deepMerge(klass[k],self[k])
        end
    end

    -- TODO: Execute hook
    -- self:postInherited(klass)
end

--- Runs after self inherits INTO (is inherited by) a klass
--- @param self IClassDefinition
--- @param klass IClassDefinition
local function postInherited(self, klass)

end

 --- inherits this into the given class definition as a base class
--- @param self IClassDefinition
 --- @param klass IClassDefinition
local function inheritsInto(self, klass)
    _basicInheritInto(self, klass)
end

--- Inherits from the given classes, goes from last given to first.
--- @param self IClassDefinition
--- @param klass IClassDefinition Base class to inherit from
--- @param ... IClassDefinition ...
local function inheritsFrom(self, klass, ...)
    local klasses = { ... }
    for i=#klasses, 1, -1 do
        local kls = klasses[i]
        kls:inheritInto(self)
    end
    klass:inheritInto(self)
end

--- Makes it so the key will not be inherited
--- @param self IClassDefinition
--- @param key any
local function doNotInherit(self, key)
    if not self[key] then
        Dbg.logW(TAG, "Set a key", key, "that isn't set to 'doNotInhert' in class", self:getClassName())
    end
    self.__inheritanceSettings.doNotCopy[key] = true
end

--- Makes it so the key will merged up (used for tables)
--- @param self IClassDefinition
--- @param key any
local function mergeOnInherit(self, key)
    if not self[key] then
        Dbg.logW(TAG, "Set a key", key, "that isn't set to 'merge' in class", self:getClassName())
    end
    self.__inheritanceSettings.doNotCopy[key] = true
    self.__inheritanceSettings.merge[key] = true
end

--- Makes it so the key will deep-merged up (used for tables)
--- @param self IClassDefinition
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
--- @param self IClass
--- @param ... any The parameters
local function init(self, ...) end

--- Creates an instance given a definition
--- @param definition IClassDefinition
--- @param ... any The parameters to pass into the `init` function
--- @return IClass instance
local function new(definition, ...)
    local this = {}

    private[this] = {} -- Add a private instance variable table (Let's you hide instance fields, call getPrivateTable() to get the table back)

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

    -- TODO: PostInit Hooks
    -- definition:postInit(this)
    -- definition:_checkWellFormed(this)

    return this
end

--- Is ran after the initialisation of a class for the given definition
--- @param self IClassDefinition
--- @param instance IClass
local function postInit(self, instance)

end

--- Is ran after ALL initialisation, extra checks on wellformedness
--- @param self IClassDefinition
--- @param instance IClass
local function _checkWellFormed(self, instance)
    -- Implemented in Interface class.
end

--- Is ran after ALL initialisation, extra checks on wellformedness, extra wellformedness checks that can be defined
--- @param self IClassDefinition
--- @param instance IClass
local function checkWellFormed(self, instance)
    -- Implemented in Interface class.
end

--- Makes a the key-value at key public so the user can see the fields in the class
--- @param self IClassDefinition
--- @param key string
local function markPublic(self, key)
    if not self[key] then
        Dbg.logW(TAG, "Set a key", key, "that isn't set to 'public' in class", self:getClassName())
    end
    self.__instanceSettings.public[key] = true
end

--- Makes a the key-value at key public so the user can see the fields in the class
--- @param self IClassDefinition
--- @param key string
local function markDefinitionOnly(self, key)
    if not self[key] then
        Dbg.logW(TAG, "Set a key", key, "that isn't set to 'definitionOnly' in class", self:getClassName())
    end
    self.__instanceSettings.definitionOnly[key] = true
end

--[[
    CLASS DEFINITION PROPER
]]

--- Creates A ClassDefinition Object
--- @param className string The class name (try to make this unique within the program)
--- @return IClassDefinition BaseDefinition The Base ClassDefinition Object you can add onto.
local function MakeClassDefinition(className)
    Dbg.logI(TAG, "Creating ClassDef with name: " .. className)
    local cls = {}
    --[[
        INHERITANCE (We do this first so we can set the values for later definition)
    ]]
    -- This is quite long...do not feel like seperating it though.
    --- @type IClassDefinition._private.__inheritanceSettings
    cls.__inheritanceSettings = {
        doNotCopy = {
            className = true,
            __inheritanceSettings = true, -- This is ALWAYS deep merged on inherit
            __instanceSettings = true, -- This is ALWAYS deep merged on inherit
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

    --- @class IClassDefinition._private.__instanceSettings
    cls.__instanceSettings = {
        -- Only add functions that solely are called when defining/on definitions, not "private" methods.
        definitionOnly = { -- This check is implemented in the __index method.
            __inheritanceSettings = true,
            isAClassDefinition = true,
            inheritsInto = true,
            inheritsFrom = true,
            doNotInherit = true,
            mergeOnInherit = true,
            deepMergeOnInherit = true,
            init = true,
            new = true,
            _checkWellFormed = true,
            checkWellFormed = true,
            markPublic = true,
            markDefinitionOnly = true -- Ironic
            -- ... rest is to be done using the markDefinitionOnly function
        },
        public = {
            -- to be done with the markPublic function
        }
    }

    cls.inheritsInto = inheritsInto

    cls.inheritsFrom = inheritsFrom

    cls.doNotInherit = doNotInherit

    cls.mergeOnInherit = mergeOnInherit

    cls.deepMergeOnInherit = deepMergeOnInherit

    cls.postInherited = postInherited

    --[[
        INSTANCE
    ]]
    cls.init = init

    cls.new = function (...)
        return new(cls, ...)
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

    --- @type IClass._private.inherits
    cls.inherits = {}

    --- Gets the private table for the instance
    --- @param self IClass
    --- @return table
    function cls:getPrivateTable()
        return private[self] -- If we are holding a reference to the table, then the key still exists
    end

    --- Gets the private table for the instance
    --- @param self IClass
    --- @param key any Gets the private instance value at the key (This is already added to __index so you likely do not need to use this)
    function cls:getPrivate(key)
        return private[self][key]
    end

    --- Completely replaces the private instance table (Sometimes it is easier to get the whole table, do work, and set it back)
    --- @param self IClass
    --- @param tbl table
    function cls:setPrivateTable(tbl)
        private[self] = tbl
    end

    --- Sets a private instance key-value pair (user won't be able to see it in the instance table)
    --- @param self IClass
    --- @param key any
    --- @param value any
    function cls:setPrivate(key, value)
        private[self][key] = value
    end

    --[[
        PUBLIC FIELDS AND METHODS
    ]]
    function cls.getClassName()
        return cls.className
    end

    cls:markPublic("getClassName")

    function cls.getAllClassNames()
        local names = {}
        table.insert(names, cls.className)
        for klassName, _ in pairs(cls.inherits) do
            table.insert(names, klassName)
        end
        return names
    end

    cls:markPublic("getAllClassNames")

    --- Checks if thhe class inherits the given klass
    --- @param klass string | IClassDefinition | IClass
    --- @return boolean
    function cls:inheritsClass(klass)
        local klassName = getClassNameFromTypesWithIt(klass)
        if not klassName then return false end
        for baseName, _ in pairs(cls.inherits) do
            if baseName == klassName then return true end
        end
        return false
    end

    cls:markPublic("inheritsClass")

    --- Checks if thhe class is an exact instance of the given klass
    --- @param klass string | IClassDefinition | IClass
    --- @return boolean
    function cls:isExactClass(klass)
        local klassName = getClassNameFromTypesWithIt(klass)
        if not klassName then return false end
        if cls.className == klassName then return true end
        return false
    end

    cls:markPublic("isExactClass")

    --- Checks if thhe class is exactly or inherits from the given klass
    --- @param klass string | IClassDefinition | IClass
    --- @return boolean
    function cls:isClass(klass)
        if cls:isExactClass(klass) then return true end
        if cls:inheritsClass(klass) then return true end
        return false
    end

    cls:markPublic("isClass")

    return cls
end

return MakeClassDefinition
