--- Class Req:
--- Able to put the public interface of the class into the main table, not the metatable.
--- Multiple inheritance
--- Ability to mark keys to be of a type, and/or to exist
--- Some key-values in the class definition should not be exposed (at all) to the instances
--- Allow for hooks after/before certain steps. (This is used to add functionality, which we can mixin with inheritance)

--- HOW:
--- Make class definitions with "mark" functions to mark keys for functionality, A new class does not directly have its class definition as its mt but a proxy that filters out class def only k-v pairs

local marker = require "common.Modules.Class.marker"
local hooks = require "common.Modules.Class.hooks"
local iterator = require "common.Modules.Class.iterator"
local inheritance = require "common.Modules.Class.inheritance"
local initialisation = require "common.Modules.Class.initialisation"
local typing = require "common.Modules.Class.typing"

local store = require "common.Modules.Class.store"

--- @alias common.Modules.Class.ClassOrDefinition common.Modules.Class.IClass | common.Modules.Class.Class | common.Modules.Class.ClassDefinition

--- Type for the public interface of the class object
--- @class common.Modules.Class.IClass
--- @field isAClass true
--- @field getClassName fun(): string
--- @field getAllClassNames fun(self: common.Modules.Class.ClassOrDefinition): string[]
--- @field isClass fun(self: common.Modules.Class.ClassOrDefinition, klass: string | common.Modules.Class.ClassOrDefinition): boolean
--- @field isExactClass fun(self: common.Modules.Class.ClassOrDefinition, klass: string | common.Modules.Class.ClassOrDefinition): boolean
--- @field inheritsClass fun(self: common.Modules.Class.ClassOrDefinition, klass: string | common.Modules.Class.ClassOrDefinition): boolean

--- Type for instances FULL object
--- @class common.Modules.Class.Class : common.Modules.Class.IClass
--- @field __expect fun(self: common.Modules.Class.ClassOrDefinition, type: any):boolean -- IExpect implementation
--- @field __expectGetTypes fun(self: common.Modules.Class.ClassOrDefinition):any[] -- IExpect implementation


--- @class common.Modules.Class.ClassDefinition : common.Modules.Class.Class
--- @field __className string -- Defined later
--- @field __directlyInherits string[] -- Defined later, includes the top level class this inherits (NOT including itself).
--- @field __inherits table<string, common.Modules.Class.ClassDefinition> -- Defined later, holds all classes used to define this (INCLUDING ITSELF)
local BaseClassDefinition = {}
do -- "do" block is just here because I didn't like how it looked with no indentation -_-

    BaseClassDefinition.isAClassDefinition = true

    -- We define settings first as it will hold all the "marks" and possibly other stuff.
    --- @class common.Modules.Class.ClassDefinition.settings
    BaseClassDefinition.__definitionSettings = { -- NOTE: This should be copied over as it needs to be definition specific
        CLASS_DEFINITION_ONLY = {}, --- @type truthSet -- Set of keys that should be filtered out be proxy
        -- Instance
        PUBLIC = {}, --- @type truthSet -- Holds keys to be public in the instance
        PROXY = {}, --- @type truthSet -- Holds keys to be put into the proxy table of instance
        -- Wellformedness / Class validness / Invariants (Note these apply to the INSTANCE not the definition)
        INVARIANT_EXPECT = {}, --- @type truthSet -- Keys that MUST exist for an instance to be valid/wellformed
        INVARIANT_TYPES = {}, --- @type table<notNil, truthSet> -- Key is the key to check, the value is an array of valid types, technically nil may be in this array, they are just skipped over.
        INVARIANT_OVERLOAD = {}, --- @type table<notNil, table<function, true>> -- Key needed to have a function that ISN'T from the ones provided
        -- Inheritance
        INHERIT_DO_NOT_COPY = {}, --- @type truthSet -- Set of keys not to copy over when inheriting
        INHERIT_MERGE = {}, --- @type truthSet -- Set of keys to shallow merge when inheriting (if nil, then will set to {} before merging)
        INHERIT_DEEP_MERGE = {}, --- @type truthSet -- Set of keys to deep merge when inheriting (if nil, then will set to {} before merging)
        INHERIT_APPEND = {}, --- @type truthSet -- Set of keys to append when inheriting (if then then will set to {} before appending)
    }
    -- Next we define the mark functions and mark the settings and the functions themselves. (And continue to do so later)
    BaseClassDefinition.markDefinitionOnly = marker.markDefinitionOnly
    BaseClassDefinition.markPublic = marker.markPublic
    BaseClassDefinition.markProxy = marker.markProxy
    BaseClassDefinition.markDoNotInherit = marker.markDoNotInherit
    BaseClassDefinition.markMergeOnInherit = marker.markMergeOnInherit
    BaseClassDefinition.markDeepMergeOnInherit = marker.markDeepMergeOnInherit
    BaseClassDefinition.markAppendOnInherit = marker.markAppendOnInherit
    BaseClassDefinition.markTypesExpected = marker.markTypesExpected
    BaseClassDefinition.markAbstractField = marker.markAbstractField
    BaseClassDefinition.markAbstractMethod = marker.markAbstractMethod
    -- NOTE: We don't need to mark values that aren't copied over into the actual definition for inherit (They are presumed static and never get inherited or changed)
    -- We do however, need to do so for invariants (if you want, to reduce processing I will presume the base class definition is correct), and,
    -- for "ClassDefinitionOnly", which we mark as we go as it would be a pain otherwise
    local marks = {
        "markDefinitionOnly",
        "markPublic",
        "markProxy",
        "markDoNotInherit",
        "markMergeOnInherit",
        "markDeepMergeOnInherit",
        "markAppendOnInherit",
        "markTypesExpected",
        "markAbstractField",
        "markAbstractMethod",
    }

    for _, mark in ipairs(marks) do
        BaseClassDefinition:markDefinitionOnly(mark)
    end

    BaseClassDefinition:markDefinitionOnly("isAClassDefinition")
    BaseClassDefinition:markDoNotInherit("__className")
    BaseClassDefinition:markDefinitionOnly("__className")
    BaseClassDefinition:markMergeOnInherit("__inherits")
    BaseClassDefinition:markDefinitionOnly("__inherits")
    BaseClassDefinition:markDefinitionOnly("__directlyInherits")
    -- NOTE: "__definitionSettings" has its own custom inheritance method that is in the function
    BaseClassDefinition:markDefinitionOnly("__definitionSettings")

    -- Next we define the hook functions (which should all just be empty signatures)
    BaseClassDefinition.preInheritInto = hooks.preInheritInto
    BaseClassDefinition.postInheritInto = hooks.postInheritInto
    BaseClassDefinition.preInit = hooks.preInit
    BaseClassDefinition.postInit = hooks.postInit
    BaseClassDefinition.preCheckInvariant = hooks.preCheckInvariant
    BaseClassDefinition.postCheckInvariant = hooks.postCheckInvariant
    BaseClassDefinition.preIndex = hooks.preIndex
    BaseClassDefinition.postIndex = hooks.postIndex
    BaseClassDefinition.preNewIndex = hooks.preNewIndex

    local _hooks = {
        "preInheritInto",
        "postInheritInto",
        "preInit",
        "postInit",
        "preCheckInvariant",
        "postCheckInvariant",
        "preIndex",
        "postIndex",
        "preNewIndex",
    }
    for _, _hook in ipairs(_hooks) do
        BaseClassDefinition:markDefinitionOnly(_hook)
        BaseClassDefinition:markDoNotInherit(_hook) -- NOTE: this is for when the definition overloads. The hooks here are just empty and don't get inherited anyway
    end

    -- Next we define the interator functions
    BaseClassDefinition.forInheritsBottomUp = iterator.forInheritsBottomUp
    BaseClassDefinition:markDefinitionOnly("forInheritsBottomUp")
    BaseClassDefinition.forInheritsTopDown = iterator.forInheritsTopDown
    BaseClassDefinition:markDefinitionOnly("forInheritsTopDown")

    -- Next we define the inheritance functions (which should use the appropriate hooks)
    BaseClassDefinition.inheritInto = inheritance.inheritInto
    BaseClassDefinition:markDefinitionOnly("inheritInto")
    BaseClassDefinition.inheritFrom = inheritance.inheritFrom
    BaseClassDefinition:markDefinitionOnly("inheritFrom")

    -- Next we define the initialisation functions (which once again, use appropriate hooks)
    BaseClassDefinition.init = initialisation.init
    BaseClassDefinition:markDefinitionOnly("init")
    BaseClassDefinition.rawnew = initialisation.rawnew
    BaseClassDefinition:markDefinitionOnly("rawnew")
    BaseClassDefinition.new = initialisation.new
    BaseClassDefinition:markDefinitionOnly("new")

    -- Next we define generic class functionality (like type checking against other classes)
    BaseClassDefinition.getAllClassNames = typing.getAllClassNames
    BaseClassDefinition.inheritsClass = typing.inheritsClass
    BaseClassDefinition.isExactClass = typing.isExactClass
    BaseClassDefinition.isClass = typing.isClass

    local typing_methods = {
        "getAllClassNames",
        "inheritsClass",
        "isExactClass",
        "isClass",
    }

    for _, method in ipairs(typing_methods) do
        BaseClassDefinition:markPublic(method)
    end

    -- Next, set metamethod for definition to be able to use this (and other functions)
    local doNotIndex = {
        __definitionSettings = true,
    }

    BaseClassDefinition.__index = function (tbl, k)
        if doNotIndex[k] then return end
        return rawget(BaseClassDefinition, k)
    end
    BaseClassDefinition.__call = function (self, ...)
        self:new(...)
    end
end

local function makeClassDefinition(className, base1, ...)

    --- @type common.Modules.Class.ClassDefinition
    local cls = setmetatable({}, BaseClassDefinition)
    --- MAYBE: Ensure that className given is unique (frankly, you probably can just presume the user is smart enough to not do that)
    cls.__className = className


    cls.__directlyInherits = {}

    cls.__inherits = { [cls.__className] = cls}

    cls.__definitionSettings = BaseClassDefinition.__definitionSettings

    --- Returns the (unique) class name of this class
    function cls.getClassName() return className end
    cls:markPublic("getClassName")
    cls:markDoNotInherit("getClassName")

    store.storeDefinition(cls)

    cls.__expect = typing.__expect
    cls:markProxy("__expect")
    cls.__expectGetTypes = typing.__expectGetTypes
    cls:markProxy("__expectGetTypes")

    cls:inheritFrom(base1, ...)

    return cls
end

return makeClassDefinition
