local TAG = "INTERFACE"
local Dbg = require "common.Modules.Logger".singleton
Dbg.getTagSettings(TAG):setLevel(Dbg.Levels.Warning)
local pc = require "common.Modules.expect"
pc.enableTag(TAG)
local cdm = require "common.Modules.Class"


--- @class common.Class.Interface : common.Class.ClassDefinition
local Interface = cdm("INTERFACE")

--- @class _I_nterface.__interfaceSettings
Interface.__interfaceSettings = {
    defaultProvided = {}, --- @type table<string, truthSet> --- First key is the className of the interface, the next is the actual keys set
    requireFields = {}, --- @type table<string, notNil[]> -- ClassName and then an array of the keys that are required
    expectType = {} --- @type table<string, table<notNil, notNil[]>> -- { ...(ClassName = { ...(keyName, Types) } }
}

Interface:deepMergeOnInherit("__interfaceSettings")
Interface:markDefinitionOnly("__interfaceSettings")

--- Runs test to check required fields are defined (and if marked abstract they they have been overloaded)
--- @param self common.Class.Interface
--- @param this common.Class.Class
function Interface._checkWellFormed(self, this)
    for interfaceName, keys in pairs(self.__interfaceSettings.requireFields) do
        -- Basic check that all keys needed are defined
        for _, k in ipairs(keys) do
            if this[k] == nil then Dbg.errorWithTag(TAG, Dbg.buildString("Class:", this:getClassName(), ".", k, " is not defined")) end
            -- Override Needed and done check
            if not self.__interfaceSettings.defaultProvided[interfaceName] or not self.__interfaceSettings.defaultProvided[interfaceName][k] then -- If default is not provided
                local virtual = this.inherits[interfaceName][k] -- Grab the value the key is defined to in the interface
                -- If equal they point to the same reference. (This should really only be used for functions, I won't make a check that it is though)
                if virtual == k then Dbg.errorWithTag(TAG, Dbg.buildString("Class:", this:getClassName(), ".", k, " needs to be overloaded"))  end
            end
        end
        -- Type check
        if self.__interfaceSettings.expectType[interfaceName] then -- Interface defined a type check
            for k, types in pairs(self.__interfaceSettings.expectType[interfaceName]) do
                if not pc.isType(this[k], table.unpack(types)) then Dbg.errorWithTag(TAG, Dbg.buildString("Class:", this:getClassName(), ".", k, " could not match type among: ", types))  end
            end
        end
    end
    for _, base in pairs(self.inherits) do
        base:postCheckWellFormed(this)
    end
end

--- @param self common.Class.Interface
local function initInterfaceSettingsRequireField(self)
    self.__interfaceSettings.requireFields[self:getClassName()] = self.__interfaceSettings.requireFields[self:getClassName()] or {}
end

--- @param self common.Class.Interface
local function initInterfaceSettingsDefaultProvided(self)
    self.__interfaceSettings.defaultProvided[self:getClassName()] = self.__interfaceSettings.defaultProvided[self:getClassName()] or {}
end

--- @param self common.Class.Interface
local function initInterfaceSettingsExpectType(self)
    self.__interfaceSettings.expectType[self:getClassName()] = self.__interfaceSettings.expectType[self:getClassName()] or {}
end

--- Marks a key as an abstract field with the given types
--- @param key any
--- @param ty1? any
--- @param ... any
function Interface:markAbstractField(key, ty1, ...)
    initInterfaceSettingsRequireField(self)
    table.insert(self.__interfaceSettings.requireFields[self:getClassName()], key)

    local types = { ty1, ... }
    local typeGiven = next(types)
    if typeGiven then
        initInterfaceSettingsExpectType(self)
        self.__interfaceSettings.expectType[self:getClassName()][key] = types
    end
end

--- Marks a key as an abstract function
--- @param key any
function Interface:markAbstractFunction(key)
    self:markAbstractField(key, "function")
end

--- Marks a key as an abstract field with the given types, and mark that a default is provided
--- @param key any
--- @param ty1? any
--- @param ... any
function Interface:markAbstractFieldDefaultProvided(key, ty1, ...)
    self:markAbstractField(key, ty1, ...)
    initInterfaceSettingsDefaultProvided(self)
    self.__interfaceSettings.defaultProvided[self:getClassName()][key] = true
end

--- Marks a key as an abstract function, with a default provided (so no need to overload)
--- @param key any
function Interface:markAbstractFunctionDefaultProvided(key)
    self:markAbstractFieldDefaultProvided(key, "function")
end

--- HOWTO:
---
--- postCheckWellFormed(self, instance) can be defined to have custom checks

return Interface
--- TODO:
--- Add alias for inherits that is "implements"
