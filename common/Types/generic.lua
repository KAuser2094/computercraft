--- @meta _

-- TIPS:
--[[
REALLY cursed way to make language server forcably recognise a variable as a certain type
--- @type Class
klass = klass --[[@as Class]]
--]]
--[[
Alternatively, just:
local check
check = klass.isAClass and klass.isAClass() -- Simply returns itself or nil
if check then <do whatever requires it to be the class> end
]]

--- @alias notNil boolean | string | number | function | table

--- @alias filePath string

--- @alias truthSet table<notNil, boolean>
