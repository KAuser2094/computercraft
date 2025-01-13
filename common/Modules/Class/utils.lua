local Dbg = require "common.Modules.Logger"
local TAG = "CLASS_DEF_UTILS"
Dbg = Dbg.singleton
Dbg = Dbg.setTagLevel(TAG, Dbg.Levels.Warning)

--- @class _C_lass.utils
local utils = {}

local private = setmetatable({}, {__mode = 'k'}) -- Holds the private fields of a class, indexed by the instance reference

local ClassDefinitionID = -1 -- Will get incrememnted when first called

--[[
    HERE IS EVERYTHING NEEDED FOR CLASS
]]

function utils.getNewClassDefinitionID()
    ClassDefinitionID = ClassDefinitionID + 1
    return ClassDefinitionID
end

--- Gets the string className from the valid types
--- @param klass string | common.Class.ClassOrDefinition
--- @return string | nil  klassName Returns nil if not a valid type
function utils.getClassNameFromTypesWithIt(klass)
    Dbg.logV(TAG, "Getting ClassName from:",klass)
    if type(klass) == "string" then return klass end
    if klass.isAClassDefinition or klass.isAClass then return klass.getClassName() end

    Dbg.logE(TAG, "SOMEHOW GOT NIL GIVE KLASS, klass, type, isAClass/Definition", klass, type(klass), klass.isAClassDefinition or klass.isAClass)
end


--- Shallow merges
--- @param tbl table
--- @param other table
function utils.shallowMerge(tbl, other)
    for k,v in pairs(other) do
        tbl[k] = v
    end
end

--- Shallow merges, skipping any key in the preserve table
--- @param tbl table
--- @param other table
--- @param preserve? string[]
function utils.shallowMergeWithPreserve(tbl, other, preserve)
    for k,v in pairs(other) do
        if not preserve then
            tbl[k] = v
        elseif not preserve[k] then
            tbl[k] = v
        end
    end
end

--- Deep Merges
--- @param tbl table
--- @param other table
function utils.deepMerge(tbl, other)
    for k, v in pairs(other) do
        if type(v) == "table" then
            tbl[k] = tbl[k] or {} -- Presumes same shape of tables (ignoring other types)
            utils.deepMerge(tbl[k], v)
        else
            tbl[k] = v
        end
    end
end

--[[
    INHERITANCE
]]

--- Default inheritance into another definition
--- @param self common.Class.ClassDefinition
--- @param klass common.Class.ClassDefinition
function utils._basicInheritInto(self, klass)
    utils.deepMerge(klass.__inheritanceSettings, self.__inheritanceSettings)
    utils.deepMerge(klass.__instanceSettings, self.__instanceSettings)
    utils.deepMerge(klass.__otherSettings, self.__otherSettings) -- This COULD mess up some settings
    utils.shallowMergeWithPreserve(klass, self, klass.__inheritanceSettings.doNotCopy)

    for k, v in pairs(klass.__inheritanceSettings.merge) do
        if v then -- Just in case someone set to false
            klass[k] = klass[k] and klass[k] or {}
            self[k] = self[k] and self[k] or {}
            utils.shallowMerge(klass[k],self[k])
        end
    end
    -- klass.inherits[self:getClassName()] = self -- When you create a new ClassDefinition you are inheriting yourself already

    for k, v in pairs(klass.__inheritanceSettings.deepMerge) do
        if v then -- Just in case someone set to false
            klass[k] = klass[k] and klass[k] or {}
            self[k] = self[k] and self[k] or {}
            utils.deepMerge(klass[k],self[k])
        end
    end

    self:postInherited(klass)
end

--- Runs after self inherits INTO (is inherited by) a klass
--- @param self common.Class.ClassDefinition
--- @param klass common.Class.ClassDefinition
function utils.postInherited(self, klass) end

 --- inherits this into the given class definition as a base class
--- @param self common.Class.ClassDefinition
 --- @param klass common.Class.ClassDefinition
function utils.inheritInto(self, klass)
    utils._basicInheritInto(self, klass)
end

--- Inherits from the given classes, goes from last given to first.
--- @param self common.Class.ClassDefinition
--- @param klass? common.Class.ClassDefinition Base class to inherit from
--- @param ... common.Class.ClassDefinition ...
function utils.inheritFrom(self, klass, ...)
    local count = select("#", klass, ...) -- I *BELIEVE* that CC Tweaks lua  would actually allow for tables CONSTRUCTED with nils to not terminate the # operator.
    local klasses = { klass, ... }
    for i=count, 1, -1 do
        local kls = klasses[i]
        if kls then
            kls:inheritInto(self)
        end
    end
end

--- Makes it so the key will not be inherited
--- @param self common.Class.ClassDefinition
--- @param key any
function utils.doNotInherit(self, key)
    if not self[key] then
        Dbg.logW(TAG, "Set a key", key, "that isn't set to 'doNotInhert' in class", self:getClassName())
    end
    self.__inheritanceSettings.doNotCopy[key] = true
end

--- Makes it so the key will merged up (used for tables)
--- @param self common.Class.ClassDefinition
--- @param key any
function utils.mergeOnInherit(self, key)
    if not self[key] then
        Dbg.logW(TAG, "Set a key", key, "that isn't set to 'merge' in class", self:getClassName())
    end
    self.__inheritanceSettings.doNotCopy[key] = true
    self.__inheritanceSettings.merge[key] = true
end

--- Makes it so the key will deep-merged up (used for tables)
--- @param self common.Class.ClassDefinition
--- @param key any
function utils.deepMergeOnInherit(self, key)
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
--- @param self common.Class.Class
--- @param ... any The parameters
function utils.init(self, ...) end

--- Creates an instance given a definition
--- @param definition common.Class.ClassDefinition
--- @param ... any The parameters to pass into the `init` function
--- @return common.Class.Class instance
function utils.new(definition, ...)
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

    if definition.init then -- It should always exist...even if it does nothing
        definition.init(this, ...)
    end
    for _, base in pairs(definition.inherits) do
        base:postInit(this)
    end
    definition:checkWellFormed(this)

    return this
end

--- Is ran after the initialisation of a class for the given definition
--- @param self common.Class.ClassDefinition
--- @param instance common.Class.Class
function utils.postInit(self, instance) end

--- Is ran after ALL initialisation, extra checks on wellformedness
--- @param self common.Class.ClassDefinition
--- @param instance common.Class.Class
function utils._checkWellFormed(self, instance) --[[Implemented in Interface class.]] end

--- Is ran after ALL initialisation, extra checks on wellformednesz
--- @param self common.Class.ClassDefinition
--- @param instance common.Class.Class
function utils.checkWellFormed(self, instance) self._checkWellFormed(self, instance) end

--- Is ran after ALL initialisation, extra checks on wellformedness, extra wellformedness checks that can be defined for this class
--- @param self common.Class.ClassDefinition
--- @param instance common.Class.Class
function utils.postCheckWellFormed(self, instance) end

--- Makes a the key-value at key public so the user can see the fields in the class
--- @param self common.Class.ClassDefinition
--- @param key string
function utils.markPublic(self, key)
    if not self[key] then
        Dbg.logW(TAG, "Set a key", key, "that isn't set to 'public' in class", self:getClassName())
    end
    self.__instanceSettings.public[key] = true
end

--- Makes a the key-value at key public so the user can see the fields in the class
--- @param self common.Class.ClassDefinition
--- @param key string
function utils.markDefinitionOnly(self, key)
    if not self[key] then
        Dbg.logW(TAG, "Set a key", key, "that isn't set to 'definitionOnly' in class", self:getClassName())
    end
    self.__instanceSettings.definitionOnly[key] = true
end

--[[
    METAMETHOD HOOKS AND OTHER STUFF
]]

-- INDEX

--- @param cls common.Class.ClassDefinition
--- @param this common.Class.Class
--- @param key any
--- @return any value
function utils._preIndex(cls, this, key)
    local ret
    for _, base in pairs(cls.inherits) do
        ret = base:preIndex(this, key)
        if ret ~= nil then return ret end
    end
end

--- @param cls common.Class.ClassDefinition
--- @param this common.Class.Class
--- @param key any
--- @return any value
function utils.preIndex(cls, this, key) end

--- @param cls common.Class.ClassDefinition
--- @param this common.Class.Class
--- @param key any
--- @param retValue any
function utils._postIndex(cls, this, key, retValue)
    for _, base in pairs(cls.inherits) do
        retValue = cls:postIndex(this, key, retValue)
    end
    return retValue
end

--- @param cls common.Class.ClassDefinition
--- @param this common.Class.Class
--- @param key any
--- @param retValue any
function utils.postIndex(cls, this, key, retValue) return retValue end

-- NEW INDEX

--- @param cls common.Class.ClassDefinition
--- @param this common.Class.Class
--- @param key any
--- @param value any
function utils._preNewIndex(cls, this, key, value) end

--- @param cls common.Class.ClassDefinition
--- @param this common.Class.Class
--- @param key any
--- @param value any
function utils.preNewIndex(cls, this, key, value) end

--- PRIVATE

--- Gets the private table for the instance
--- @param self common.Class.ClassOrDefinition
--- @return table
function utils.getPrivateTable(self)
    return private[self] -- If we are holding a reference to the table, then the key still exists
end

--- Gets the private table for the instance
--- @param self common.Class.ClassOrDefinition
--- @param key any Gets the private instance value at the key (This is already added to __index so you likely do not need to use this)
function utils.getPrivate(self, key)
    if not (self.isAClass or self.isAClassDefinition) then return end
    return private[self][key]
end

--- Completely replaces the private instance table (Sometimes it is easier to get the whole table, do work, and set it back)
--- @param self common.Class.ClassOrDefinition
--- @param tbl table
function utils.setPrivateTable(self, tbl)
    if not (self.isAClass or self.isAClassDefinition) then return end
    private[self] = tbl
end

--- Sets a private instance key-value pair (user won't be able to see it in the instance table)
--- @param self common.Class.ClassOrDefinition
--- @param key any
--- @param value any
function utils.setPrivate(self, key, value)
    if not (self.isAClass or self.isAClassDefinition) then return end
    private[self][key] = value
end

--- IExpect Implementation

--- Takes in an object and returns if this is that type
--- @param self common.Class.ClassOrDefinition
--- @param ty any
--- @return boolean
function utils.__expect(self, ty)
    if not (type(ty) == "string" or ty.isAClass or ty.isAClassDefinition) then return false end
    return self:isClass(ty)
end

--- Returns all types (all class names)
--- @param self common.Class.ClassOrDefinition
--- @return string[]
function utils.__expectGetTypes(self)
    return { self:getClassName() } -- We only want to consider the top level type, any shared inheritance should be checked using that type not this
end

--[[
    STUFF SPECIFIC TO SIMPLE CLASS
]]

--- Creates an instance given a definition
--- @param definition common.Class.SimpleClassDefinition
--- @param ... any The parameters to pass into the `init` function
--- @return common.Class.Class instance
function utils.simpleNew(definition, ...)
    local this = {}

    private[this] = {} -- Add a private instance variable table (Let's you hide instance fields, call getPrivateTable() to get the table back)

    this.isAClass = true

    setmetatable(this, definition)

    if definition.init then -- It should always exist...
        definition.init(this, ...)
    end

    return this
end

return utils
