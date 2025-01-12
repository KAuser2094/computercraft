--- @meta _
--- We define the Class and ClassDefinition as a type here instead of an interface as we have yet to create the Interface Base Class yet.
--[[
    Field Classes and Aliases
]]
--- @class _C_lass_D_efinition._private.__inheritanceSettings
--- @field doNotCopy truthSet
--- @field merge truthSet
--- @field deepMerge truthSet

--- @class _C_lass_D_efinition._private.__instanceSettings
--- @field definitionOnly truthSet -- What keys should not be copied over to instance
--- @field public truthSet -- What keys should be displayed to the user so they can see what the Class does
--- @field effectiveKeys truthSet -- Holds the effective keys of the definition

--- @class _C_lass_D_efinition._private.__otherSettings
--- @field protectEffectiveKeys boolean -- Toggle whether we error if the class tries to set a key that would overwrite an effective key


--- @alias common._C_lass._private.inherits table<string, common.Class.ClassDefinition>

--[[
    The fields and methods we want public to the user
]]
--- @class _C_lass._public
--- @field getClassName fun(): string -- Returns the classname of the class from its defintion
--- @field getAllClassNames fun(): string[] -- Retirms all classNames from the class and its bases
--- @field inheritsClass fun(self: common.Class.ClassOrDefinition, klass: common.Class.ClassOrDefinition | string): boolean -- Checks if the passed in class is one it inherits
--- @field isExactClass fun(self: common.Class.ClassOrDefinition, klass: common.Class.ClassOrDefinition| string): boolean -- Checks if top level class is the passed in class
--- @field isClass fun(self: common.Class.ClassOrDefinition, klass: common.Class.ClassOrDefinition | string): boolean -- Checks if the passed in class matches the current of inherited
local Class__public = {}

--[[
    The fields and methods that (could) be used by the class and we don't want visible in the instance table
]]
--- @class _C_lass._private : common.Modules.expect.IExpect -- The fields and methods we want private to the user (Hidden using __index)
--- @field className string -- Throws an error if same program tries to define the same className twice. (MAYBE: change to just add increasing digits after)
--- @field inherits common._C_lass._private.inherits -- Holds all the className's this inherits from
--- @field getPrivateTable fun(self: common.Class.ClassOrDefinition): table -- Gets the instances private table
--- @field getPrivate fun(self: common.Class.ClassOrDefinition, key: any): any -- Gets the value at the instances private table using the key
--- @field setPrivateTable fun(self: common.Class.ClassOrDefinition, tbl: table) -- Replaces the instance's private table with the given
--- @field setPrivate fun(self: common.Class.ClassOrDefinition, key: any, value: any) -- Sets the key-value to the instnace's private table
local Class__private = {}

--[[
    Fields and mehods that STRICTLY only apply/are run on SimpleClassDefinition
]]

--- @class _S_imple_C_lass_D_efinition._private
--- @field init fun(self: common.Class.Class, args...?: any) -- Specific initialisation steps for the ClassDefinition
--- @field _new fun(args...?: any): common.Class.Class -- Creates an instance of the class according to own definition
--- @field new fun(args...?: any): common.Class.Class -- Creates an instance of the class according to own definition
--- @field isAClassDefinition true -- For checks
local SimpleClassDefinition__private = {}

--[[
    Fields and methods that STRICTLY only apply/are run on ClassDefinitions
]]
--- @class _C_lass_D_efinition._private : _S_imple_C_lass_D_efinition._private -- The fields and methods exculsive to the ClassDefinition (They are thrown away by Class when called __ndex)
--- @field __inheritanceSettings _C_lass_D_efinition._private.__inheritanceSettings -- Holds settings for inheritance
--- @field __instanceSettings _C_lass_D_efinition._private.__instanceSettings -- Holds settings for creating instances
--- @field __otherSettings _C_lass_D_efinition._private.__otherSettings -- Holds any other settings for the definition
--- @field inheritInto fun(self: common.Class.ClassDefinition, klass: common.Class.ClassDefinition) -- Use yourself as base ClassDefition and inherit
--- @field inheritFrom fun(self: common.Class.ClassDefinition, klass: common.Class.ClassDefinition, ...?: common.Class.ClassDefinition) -- taken in multiple base ClassDefinitions and inherit in backwards
--- @field doNotInherit fun(self: common.Class.ClassDefinition, key: any) -- Sets the key to not be inherited
--- @field mergeOnInherit fun(self: common.Class.ClassDefinition, key: any) -- Sets the key to be merged on inherit
--- @field deepMergeOnInherit fun(self: common.Class.ClassDefinition, key: any) -- Sets the key to be deep merged on inherit
--- @field postInherited fun(self: common.Class.ClassDefinition, klass: common.Class.ClassDefinition) -- Runs after `self` inherits INTO `klass`
--- @field postInit fun(self: common.Class.ClassDefinition, instance: common.Class.Class) -- Ran after the main initalisation is done
--- @field _checkWellFormed fun(self: common.Class.ClassDefinition, instance: common.Class.Class) -- Ran after WHOLE initialisation is done (Including postInit)
--- @field checkWellFormed fun(self: common.Class.ClassDefinition, instance: common.Class.Class) -- Ran after normal WellFormed Check, allowing each base class to run extra checks
--- @field markPublic fun(self: common.Class.ClassDefinition, key: any) -- Sets the key to be public (included in the instance table)
--- @field markDefinitionOnly fun(self: common.Class.ClassDefinition, key: any) -- Sets the key to only exist in the defintion (it is discarded during __index)
--- @field preIndex fun(self: common.Class.ClassDefinition, this: common.Class.Class, key: any): any -- Attempts to overwrite the __index. Note that it is not guarenteed to run if a previous base class foudn a value
--- @field postIndex fun(self: common.Class.ClassDefinition, this: common.Class.Class, key: any, retValue: any): any -- Applies checks to the value to be returned and may change it. The changed value will be passed into the next base class
--- @field preNewIndex fun(self: common.Class.ClassDefinition, this: common.Class.Class, key: any): table | nil -- Tries to override and set a new index.Once again not guarenteed to actually run if other base classes set first
local ClassDefinition__private = {}

--[[
    Actual Classes
]]
--- @class common.Class.ClassDefinition : _C_lass_D_efinition._private, _C_lass._public, _C_lass._private
--- @field getBaseClassDefinition fun(): common.Class.ClassDefinition -- Gets an unchanged base definition
local ClassDefinition = {}

--- @class common.Class.SimpleClassDefinition : _S_imple_C_lass_D_efinition._private, _C_lass._public, _C_lass._private
--- @field getBaseClassDefinition fun(): common.Class.SimpleClassDefinition -- Gets an unchanged base simple definition
local SimpleClassDefinition = {}

--- @class common.Class.IClass : _C_lass._public
--- @field isAClass true
local IClass = {}

--- @class common.Class.Class : common.Class.IClass, _C_lass._private
local Class = {}

--- @alias common.Class.ClassOrDefinition common.Class.Class | common.Class.SimpleClassDefinition | common.Class.ClassDefinition
