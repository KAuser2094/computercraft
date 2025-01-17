--- @meta _

--- For ccTweaked userdata mostly doesn't exist (In fact I think it just doesn't)
--- @alias notNil boolean | string | number | function | table | thread

-- This is technically just Set<notNil> but this is used enough to have its own thing. Also isn't actually "Any" since we use notNil. The LuaLS is dumb enough to not realise that a nil key won't exist...
-- ...so we use notNil to force it to recognise it so.
--- @alias AnySet { [notNil]: true }

--- @alias Set<T> { [T]: true } -- Is a set, uses keys to store the values and "true" so that Set[Value] will return true if it is in the set.

--- @alias ArraySet<T> { [T]: true } | T[] -- Is a combination of a set and an array, allowing the use of ipairs to iterate and ArraySet[value] to quickly check existence
