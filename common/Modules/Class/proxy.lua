--[[
    We use a proxy to filter out definition only keys and to hold private data for the instance
]]

--- @class common.Modules.Class.proxy
--- @field isAClass true

--- @type table<common.Modules.Class.Class, common.Modules.Class.proxy>
local proxies = setmetatable({},{ __mode = 'k' }) -- If a class has no other reference, we drop its proxy

--- Runs postIndex to validate value
--- @param definition common.Modules.Class.ClassDefinition
--- @param tbl table
--- @param key notNil
--- @param value any
--- @return any? value
local function validateValue(definition, tbl, key, value)
    for baseAgain in definition:forInheritsBottomUp(true) do
        value = baseAgain:postIndex(tbl, key, value)
    end
    value = definition:postIndex(tbl, key, value)

    return value
end

local proxyProtect = {
    isAClass = true,
    __index = true,
    __newindex = true,
}

local proxy = {}

--- Creates a proxy between an instance and a definition, this does filtering and other work and can hold private values for the instance
--- @param definition common.Modules.Class.ClassDefinition
--- @param instance common.Modules.Class.Class
function proxy.createProxy(definition, instance)
    local p = {}
    p.isAClass = true

    -- yes this would make key accessed even more expensive, for functionality! (That I probably won't use -_-)
    function p.__index(inst, key)
        --- Proxy filters
        if definition.__definitionSettings.CLASS_DEFINITION_ONLY[key] then
            return nil
        end
        local value

        --- Class specific
        for base in definition:forInheritsBottomUp(true) do
            value = base:preIndex(inst, key)
            validateValue(definition, inst, key, value)
            if value ~= nil then return value end
        end
        value = definition:preIndex(inst, key)
        value = validateValue(definition, inst, key, value)
        if value ~= nil then return value end

        -- Access the proxy
        value = p[key]
        value = validateValue(definition, inst, key, value)
        if value ~= nil then return value end

        --- Actually access the definition
        value = definition[key]
        value = validateValue(definition, inst, key, value)
        return value
    end

    function p.__newindex(inst, key, value)
        local returnEarly
        for base in definition:forInheritsBottomUp(true) do
            returnEarly = base:preNewIndex(inst, key, value)
            if returnEarly then return end
        end
        returnEarly = definition:preNewIndex(inst, key, value)
        if returnEarly then return end

        -- Proxy value (we use proxy as a private variable store), so setting a private variable shouldn't be setting in instance table
        if not proxyProtect[key] and rawget(p, key) then
            rawset(p, key, value)
            return
        end

        rawset(inst, key, value)
    end

    -- Copy over values (usually metamethods) to proxy
    for key, _ in pairs(definition.__definitionSettings.PROXY) do
        p[key] = definition[key]
    end

    proxies[instance] = p

    return p
end

return proxy
