

--- @type table<string, common.Modules.Class.ClassDefinition>
local definitions = {}

local store = {}

--- @param definition common.Modules.Class.ClassDefinition
function store.storeDefinition(definition)
    definitions[definition.__className] = definition
end

--- @param someNameForm string | common.Modules.Class.Class | common.Modules.Class.ClassDefinition
--- @return common.Modules.Class.ClassDefinition? definition
function store.getDefinition(someNameForm)
    if type(someNameForm) == "string" then return definitions[someNameForm] end
    if someNameForm.isAClass then return definitions[someNameForm.getClassName()] end
    --- @cast someNameForm common.Modules.Class.ClassDefinition
    if someNameForm.isAClassDefinition then return someNameForm end
end

return store
