-- A HEAVILY stripped down ClassDefinition that provides enough that it can still provide a @type Class
-- "Simple" compared to normal Class, obviously this is still quite complicated compared to other class implementations
local utils = require "common.Modules.Class.utils"

local Dbg = require "common.Modules.Logger"
local TAG = "SIMPLE_CLASS_DEF"
Dbg = Dbg.singleton
Dbg = Dbg.setTagLevel(TAG, Dbg.Levels.Warning)

--- @type common.Class.SimpleClassDefinition
local BASE_CLASS_DEFINITION

--- Returns an empty Class Definition (just in case you need to overwrite it)
--- @return common.Class.SimpleClassDefinition
local function getBaseClassDefinition()
    return BASE_CLASS_DEFINITION
end

--- Gets the string className from the valid types
--- @param klass string | common.Class.ClassDefinition | common.Class.Class
--- @return string | nil  klassName Returns nil if not a valid type
local function getClassNameFromTypesWithIt(klass)
    Dbg.logV(TAG, "Getting ClassName from:",klass)
    if type(klass) == "string" then return klass end
    if klass.isAClassDefinition or klass.isAClass then return klass.getClassName() end

    Dbg.logE(TAG, "SOMEHOW GOT NIL GIVE KLASS, klass, type, isAClass/Definition", klass, type(klass), klass.isAClassDefinition or klass.isAClass)
end

local classDefOnly = {
    isAClassDefinition = true,
    init = true,
    _new = true,
    new = true,
    getBaseClassDefinition = true,
}

local doNotInherit = {
    className = true,
}

--- Returns a simplified class definition
--- @param className string
--- @param base? common.Class.SimpleClassDefinition
--- @param ... common.Class.SimpleClassDefinition
--- @return common.Class.SimpleClassDefinition
local function MakeSimpleClassDefinition(className, base, ...)
    --- @type (common.Class.SimpleClassDefinition?)[] -- NOTE: THIS COULD END UP BEING SPARSE
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

    cls.getPrivateTable = utils.getPrivateTable

    cls.getPrivate = utils.getPrivate

    cls.setPrivateTable = utils.setPrivateTable

    cls.setPrivate = utils.setPrivate


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
    --- @param klass string | common.Class.ClassDefinition | common.Class.Class
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
    --- @param klass string | common.Class.ClassDefinition | common.Class.Class
    --- @return boolean
    function cls:isExactClass(klass)
        local klassName = getClassNameFromTypesWithIt(klass)
        if not klassName then return false end
        if cls.className == klassName then return true end
        return false
    end

    --- Checks if thhe class is exactly or inherits from the given klass
    --- @param klass string | common.Class.ClassDefinition | common.Class.Class
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

    cls.init = utils.init

    cls._new = function (...)
        return utils.simpleNew(cls, ...)
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
    cls.__expect = utils.__expect

    cls.__expectGetTypes = utils.__expectGetTypes

    cls.getBaseClassDefinition = getBaseClassDefinition


    return cls
end

BASE_CLASS_DEFINITION = MakeSimpleClassDefinition(" ") -- "" is used for the normal Class, so " " it is

return MakeSimpleClassDefinition
