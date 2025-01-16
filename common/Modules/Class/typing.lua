local store = require "common.Modules.Class.store"

local types = {}

--- @param self common.Modules.Class.Class | common.Modules.Class.ClassDefinition
function types.getAllClassNames(self)
    local definition = store.getDefinition(self)
    assert(definition, "Class store did not have definition for name" .. self.getClassName()) -- TODO: Change this to dbg
    local names = {definition.__className}
    for base in definition:forInheritsTopDown(true) do
        table.insert(names, base.__className)
    end
    return names
end

--- @param self common.Modules.Class.Class | common.Modules.Class.ClassDefinition
--- @param klass string | common.Modules.Class.Class | common.Modules.Class.ClassDefinition
--- @return boolean selfInheritsFromKlass
function types.inheritsClass(self, klass)
    local definition = store.getDefinition(self)
    local klassName = type(klass) == "string" and klass or klass.getClassName()
    assert(definition, "Class store did not have definition for name" .. self.getClassName()) -- TODO: Change this to dbg
    if definition.__className == klassName then return false end
    return not not definition.__inherits[klassName]
end

--- @param self common.Modules.Class.Class | common.Modules.Class.ClassDefinition
--- @param klass string | common.Modules.Class.Class | common.Modules.Class.ClassDefinition
--- @return boolean selfIsInstanceOfExactlyKlass
function types.isExactClass(self, klass)
    local klassName = type(klass) == "string" and klass or klass.getClassName()
    return self.getClassName() == klassName
end

--- @param self common.Modules.Class.Class | common.Modules.Class.ClassDefinition
--- @param klass string | common.Modules.Class.Class | common.Modules.Class.ClassDefinition
--- @return boolean selfIsInstanceOfKlass
function types.isClass(self, klass)
    local definition = store.getDefinition(self)
    local klassName = type(klass) == "string" and klass or klass.getClassName()
    assert(definition, "Class store did not have definition for name" .. self.getClassName()) -- TODO: Change this to a log
    return not not definition.__inherits[klassName]
end

--- Takes in an object and returns if this is that type
--- @param self common.Modules.Class.ClassOrDefinition
--- @param ty any
--- @return boolean
function types.__expect(self, ty)
    if not (type(ty) == "string" or ty.isAClass or ty.isAClassDefinition) then return false end
    return self:isClass(ty)
end

--- Returns all types (top level class name)
--- @param self common.Modules.Class.ClassOrDefinition
--- @return string[]
function types.__expectGetTypes(self)
    return { self:getClassName() } -- We only want to consider the top level type, any shared inheritance should be checked using that type not this
end

return types
