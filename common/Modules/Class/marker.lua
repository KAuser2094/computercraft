--[[
    Holds the functions that mark keys to the settings
]]

local marker = {}

--- Marks a key to be blocked by the proxy between instance and definition
--- @param self common.Modules.Class.ClassDefinition
--- @param key notNil
function marker.markDefinitionOnly(self, key)
    self.__definitionSettings.CLASS_DEFINITION_ONLY[key] = true
end

--[[
    INHERITANCE
]]
--- Marks a key to not be inherited
--- @param self common.Modules.Class.ClassDefinition
--- @param key notNil
function marker.markDoNotInherit(self, key)
    self.__definitionSettings.INHERIT_DO_NOT_COPY[key] = true
end

--- Marks a key to merged when inheriting (nil == {} for this)
--- @param self common.Modules.Class.ClassDefinition
--- @param key notNil
function marker.markMergeOnInherit(self, key)
    marker.markDoNotInherit(self, key)
    self.__definitionSettings.INHERIT_MERGE[key] = true
end

--- Marks a key to deep-merged when inheriting (nil == {} for this)
--- @param self common.Modules.Class.ClassDefinition
--- @param key notNil
function marker.markDeepMergeOnInherit(self, key)
    marker.markDoNotInherit(self, key)
    self.__definitionSettings.INHERIT_DEEP_MERGE[key] = true
end

--- Marks a key to appened when inheriting (nil == {} for this)
--- @param self common.Modules.Class.ClassDefinition
--- @param key notNil
function marker.markAppendOnInherit(self, key)
    marker.markDoNotInherit(self, key)
    self.__definitionSettings.INHERIT_APPEND[key] = true
end

--[[
    INITIALISATION
]]

--- Marks a key to be moved over to the instance's proxy table on initialisation
--- @param self common.Modules.Class.ClassDefinition
--- @param key notNil
function marker.markProxy(self, key)
    self.__definitionSettings.PROXY[key] = true
end

--- Marks a key to be moved over to the instance table on initialisation
--- @param self common.Modules.Class.ClassDefinition
--- @param key notNil
function marker.markPublic(self, key)
    self.__definitionSettings.PUBLIC[key] = true
end

--[[
    INTERFACING AND VALIDNESS AND TYPE CHECKING AND WELLFORMEDNESS ETC ETC ETC (lol)
]]

--- Marks a key to have the expected types (If a key is optional or may be nil, make sure to include "nil"). This uses the custom expect module
--- @param self common.Modules.Class.ClassDefinition
--- @param key notNil
--- @param ty1? notNil -- Type(s) the field needs to be
--- @param ... notNil -- Type(s) the field needs to be
function marker.markTypesExpected(self, key, ty1, ...)
    local types = { ty1, ... }
    local typesGiven = next(types)
    if typesGiven then
        self.__definitionSettings.INVARIANT_TYPES[key] = {}
        for _, ty in pairs(types) do
            self.__definitionSettings.INVARIANT_TYPES[key][ty] = true
        end
    end
end

--- @param self common.Modules.Class.ClassDefinition
--- @param key notNil
--- @param ty1? notNil -- Type(s) the field needs to be
--- @param ... notNil -- Type(s) the field needs to be
function marker.markAbstractField(self, key, ty1, ...)
    self.__definitionSettings.INVARIANT_EXPECT[key] = true

    marker.markTypesExpected(self, key, ty1, ...)
end

--- @param self common.Modules.Class.ClassDefinition
--- @param key notNil
function marker.markAbstractMethod(self, key)
    marker.markAbstractField(self, key, "function")
end


return marker
