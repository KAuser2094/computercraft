--- Functions called at certain events, allows for class specific functionality

local hooks = {}

--[[
    INHERITANCE. Note: Due to how inheritance is done, you will need to define both.
]]

-- Runs just before a class is inheriting into another
--- @param self common.Modules.Class.ClassDefinition -- The definition itself or one that inherits it
--- @param klass common.Modules.Class.ClassDefinition
function hooks.preInheritInto(self, klass) end

-- Runs after this inherits into another class another
--- @param self common.Modules.Class.ClassDefinition
--- @param klass common.Modules.Class.ClassDefinition
function hooks.postInheritInto(self, klass) end

--[[
    INITIALISATION (TODO: Typing for isntance)
]]

-- Runs just before "init" is called (this one is mostly useless)
--- @param self common.Modules.Class.ClassDefinition
--- @param instance common.Modules.Class.Class
function hooks.preInit(self, instance, ...) end

-- Runs just after "init" is called
--- @param self common.Modules.Class.ClassDefinition
--- @param instance common.Modules.Class.Class
function hooks.postInit(self, instance, ...) end

--[[
    WELLFORMEDNESS ETC ETC. Also, for this one there arguably should only be one hook...
]]

-- Runs just before the invariants are to be checked
--- @param self common.Modules.Class.ClassDefinition
--- @param instance common.Modules.Class.Class
function hooks.preCheckInvariant(self, instance) end

-- Runs just after all the invariants have been checked
--- @param self common.Modules.Class.ClassDefinition
--- @param instance common.Modules.Class.Class
function hooks.postCheckInvariant(self, instance) end

--[[
    METATABLE FUNCTIONS
]]

-- Runs on "__index", note that this is not guarenteed to run if another class finds a value first.
--- @param self common.Modules.Class.ClassDefinition
--- @param instance common.Modules.Class.Class
--- @param key notNil
--- @return any value
function hooks.preIndex(self, instance, key) end

-- Runs WHENEVER a value is found (so not the most accurate name), and will return either the value (if it is valid) or nil (if it is not)
--- @param self common.Modules.Class.ClassDefinition
--- @param instance common.Modules.Class.Class
--- @param key notNil
--- @param value any
--- @return any valueOrNil
function hooks.postIndex(self, instance, key, value) return value end

--- Runs immediately when "__newindex" is called. NOTE: The order is not guarenteed and an early return may happen.
--- If returns true, then will immediately return. This may be because the set call was invalid or this function dealt with the set call itself.
--- @param self common.Modules.Class.ClassDefinition
--- @param instance common.Modules.Class.Class
--- @param key notNil
--- @param value any
--- @return boolean? returnEarly
function hooks.preNewIndex(self, instance, key, value) end

return hooks
