-- A HEAVILY stripped down ClassDefinition that provides enough that it can still provide a @type IClass
-- "Simple" compared to normal Class, obviously this is still quite complicated compared to other class implementations

local Dbg = require "common.Modules.Logger"
local TAG = "SIMPLE_CLASS_DEF"
Dbg = Dbg.new()
Dbg = Dbg.setOutputTerminal(term.current()).setTagLevel(TAG, Dbg.Levels.Warning)

--- Gets the string className from the valid types
--- @param klass string | IClassDefinition | IClass
--- @return string | nil  klassName Returns nil if not a valid type
local function getClassNameFromTypesWithIt(klass)
    Dbg.logV(TAG, "Getting ClassName from:",klass)
    if type(klass) == "string" then return klass end
    if klass.isAClassDefinition or klass.isAClass then return klass.getClassName() end

    Dbg.logE(TAG, "SOMEHOW GOT NIL GIVE KLASS, klass, type, isAClass/Definition", klass, type(klass), klass.isAClassDefinition or klass.isAClass)
end

local private = setmetatable({}, {__mode = 'k'})

local classDefOnly = {
    isAClassDefinition = true,
    init = true,
    _new = true,
    new = true,
}

local doNotInherit = {
    className = true,
}

--- Called when creating an instance
--- @param self IClass
--- @param ... any The parameters
local function init(self, ...) end

--- Creates an instance given a definition
--- @param definition ISimpleClassDefinition
--- @param ... any The parameters to pass into the `init` function
--- @return IClass instance
local function new(definition, ...)
    local this = {}

    private[this] = {} -- Add a private instance variable table (Let's you hide instance fields, call getPrivateTable() to get the table back)

    this.isAClass = true

    setmetatable(this, definition)

    if definition.init then -- It should always exist...
        definition.init(this, ...)
    end

    return this
end

--- Returns a simplified class definition
--- @param className string
--- @param base? ISimpleClassDefinition
--- @param ... ISimpleClassDefinition
--- @return ISimpleClassDefinition
local function MakeSimpleClassDefinition(className, base, ...)
    --- @type (ISimpleClassDefinition?)[] -- NOTE: THIS COULD END UP BEING SPARSE
    local bases = { base, ... }
    Dbg.logI(TAG, "Creating ClassDef with name: " .. className)
    local cls = {}

    cls.className = className

    cls.inherits = { [cls.className] = cls }

    -- Inheritance in a SimpleClass is just a dumb shallow copy
    for _, b in pairs(bases) do -- Cannot use ipairs due to maybe being sparse
        cls.inherits[b:getClassName()] = b
        for k,v in pairs(b) do
            if not doNotInherit[k] then
                cls[k] = v
            end
        end
    end

    cls.isAClassDefinition = true

    --- PRIVATE

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
        if not self.isAClass then return end
        return private[self][key]
    end

    --- Completely replaces the private instance table (Sometimes it is easier to get the whole table, do work, and set it back)
    --- @param self IClass
    --- @param tbl table
    function cls:setPrivateTable(tbl)
        if not self.isAClass then return end
        private[self] = tbl
    end

    --- Sets a private instance key-value pair (user won't be able to see it in the instance table)
    --- @param self IClass
    --- @param key any
    --- @param value any
    function cls:setPrivate(key, value)
        if not self.isAClass then return end
        private[self][key] = value
    end

    --- CLASS NAME / TYPE CHECKS AND OTHER

    function cls.getClassName()
        return cls.className
    end

    function cls.getAllClassNames()
        local names = {}
        for klassName, _ in pairs(cls.inherits) do
            table.insert(names, klassName)
        end
        return names
    end

    --- Checks if thhe class inherits the given klass
    --- @param klass string | IClassDefinition | IClass
    --- @return boolean
    function cls:inheritsClass(klass)
        local klassName = getClassNameFromTypesWithIt(klass)
        if not klassName then return false end
        if klassName == cls.className then return false end -- Is Exact Class
        for baseName, _ in pairs(cls.inherits) do
            if baseName == klassName then return true end
        end
        return false
    end

    --- Checks if thhe class is an exact instance of the given klass
    --- @param klass string | IClassDefinition | IClass
    --- @return boolean
    function cls:isExactClass(klass)
        local klassName = getClassNameFromTypesWithIt(klass)
        if not klassName then return false end
        if cls.className == klassName then return true end
        return false
    end

    --- Checks if thhe class is exactly or inherits from the given klass
    --- @param klass string | IClassDefinition | IClass
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

    --- INITIALISATION

    cls.init = init

    cls._new = function (...)
        return new(cls, ...)
    end

    cls.new = function (...)
        return cls._new(...)
    end

    --- METAMETHODS

    setmetatable(cls, {
    __call = function(_, ...)
        return cls.new(...)
    end,
    })

    cls.__index = function (self, key)
        local try =  cls.getPrivate(self, key)
        if try ~= nil then return try end

        if classDefOnly[key] then return nil end -- Don't give access to this class def's class def only values

        return rawget(cls, key)
    end

    return cls
end

return MakeSimpleClassDefinition
