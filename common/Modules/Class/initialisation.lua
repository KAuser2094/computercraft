
local proxy = require "common.Modules.Class2.proxy"
local TAG_INVARIANT = "INVARIANT CHECK"
local Dbg = require "common.Modules.Logger".singleton
Dbg.getTagSettings(TAG_INVARIANT):setLevel(Dbg.Levels.Warning)
local pc = require "common.Modules.expect"
pc.enableTag(TAG_INVARIANT)
local initialisation = {}

--- @param definition common.Modules.Class.ClassDefinition
--- @param instance common.Modules.Class.Class
local function checkInvariants(definition, instance)
    -- EXPECT: Requires fields to be accessable
    for k, _ in ipairs(definition.__definitionSettings.INVARIANT_EXPECT) do
        Dbg.assertWithTag(TAG_INVARIANT, instance[k] ~= nil, Dbg.buildString(definition.__className, " failed class invariant, instance does not have field: ", k))
    end
    -- TYPES: Requires fields to have certain types
    for k, types in pairs(definition.__definitionSettings.INVARIANT_TYPES) do
        local typeArr = {}
        for _k, _ in pairs(types) do
            table.insert(typeArr, _k)
        end
        Dbg.assertWithTag(TAG_INVARIANT, pc.isType(instance[k], table.unpack(typeArr)), Dbg.buildString(definition.__className, " failed class invariant, instance at ", k, " could not match types:", types))
    end
    -- OVERLOAD: Requires the function to not match the signatures/references given
    for k, virtuals in pairs(definition.__definitionSettings.INVARIANT_OVERLOAD) do
        local virtualArr = {}
        for _k, _ in pairs(virtuals) do
            table.insert(virtualArr, _k)
        end
        Dbg.assertWithTag(TAG_INVARIANT,
            type(instance[k]) == "function",
            Dbg.buildString(definition.__className, " failed class invariant, instance does not have overloaded function (no function at all) at:", k))
        for _, virtual in ipairs(virtuals) do
            Dbg.assertWithTag(TAG_INVARIANT,
                instance[k] ~= virtual,
                Dbg.buildString(definition.__className, " failed class invariant, function to overload at: ", k, " matched a virtual function: ", virtual))
        end
    end
end

--- Is ran after the instance is made. In this case you SHOULD include calls to the "init" of classes you are inheriting. (Unless they defined preInit and postInit so you do not need to)
--- @param self common.Modules.Class.ClassDefinition
--- @param instance common.Modules.Class.Class
--- @param ... any
function initialisation.init(self, instance, ...) end

--- The actual code that creates a new instance, the default "new" simply is there for type casting
--- @param definition common.Modules.Class.ClassDefinition
--- @param ... any
--- @return common.Modules.Class.Class
function initialisation.rawnew(definition, ...)
    local this = {}

    -- Expose fields and methods marked as public to the instance table
    for key,_ in pairs(definition.__definitionSettings.PUBLIC) do
        this[key] = definition[key]
    end
    -- Get and set the proxy
    local defProxy = proxy.createProxy(definition, this)

    setmetatable(this, defProxy)

    -- Run init code
    for base in definition:forInheritsBottomUp(true) do
        base:preInit(this, ...)
    end
    definition:preInit(this, ...)

    definition:init(this, ...)

    for base in definition:forInheritsBottomUp(true) do
        base:postInit(this, ...)
    end
    definition:postInit(this, ...)

    -- Run check invariant (class validity ) check
    for base in definition:forInheritsBottomUp(true) do
        base:preCheckInvariant(this)
    end
    definition:preCheckInvariant(this)

    checkInvariants(definition, this)

    for base in definition:forInheritsBottomUp(true) do
        base:postCheckInvariant(this)
    end
    definition:postCheckInvariant(this)

    return this
end

--- OVERLOAD TIHS AND CAST THE TYPES SO LUA LS CAN RECOGNISE THE SPECIFIC CLASS INSTANCE, AND YOU CAN SPECIFY EXPECTED ARGS
--- @param definition common.Modules.Class.ClassDefinition
--- @param ... any
--- @return common.Modules.Class.Class
function initialisation.new(definition, ...)
    return definition:rawnew(...)
end

return initialisation
