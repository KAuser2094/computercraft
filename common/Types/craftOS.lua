--- @diagnostic disable: lowercase-global, missing-return
--- Use the below code in a file to add periphemu and other craftOS api's to the global space
--[[
--- @module "common.Types.craftOS"
--]]

--- https://www.craftos-pc.cc/docs/periphemu

periphemu = {}

--- @alias craftOS.periphemu.types
--- | "drive"
--- | "modem"
--- | "monitor"
--- | "printer"
--- | "speaker"
--- | "computer"
--- | "debugger"
--- | "debug_adapter"
--- | "chest"
--- | "minecraft:chest"
--- | "energy"
--- | "tank"

--- Creates and attaches peripheral at `side` with type `ty` (should match a type from `periphemu.names()`), using optional parameter where it applies
--- @param side string -- Side to attach to (Yes the names here can be whatever)
--- @param ty craftOS.periphemu.types -- Types which needs to be within periphemu.names()
--- @param ... any -- Optional depending on type of peripheral
--- @return boolean attached -- Did it attach?
function periphemu.create(side, ty, ...) end

--- Removes and detaches peripheral at `side`
--- @param side string -- Side to attach to (Yes the names here can be whatever)
--- @return boolean detached -- Did it attach?
function periphemu.remove(side) end

--- Returns valid peripheral type names that can be used to in `periphemu.create(...)`
--- @return string[]
function periphemu.names() end

--- https://www.craftos-pc.cc/docs/mounter

mounter = {}

--- Returns whether the mounting at `name` is read only
--- @param name string
--- @return boolean readOnly
function mounter.isReadOnly(name) end

--- Returns a table of { ...<local_path>=<absolute_path>... }, in the case of multimount it will be a list of <absolute_path>(s) instead.
function mounter.list() end

--- Will mount from absolute `path` to local `name`, marking it as readOnly if `readOnly` is set to true (otherwise default set via config)
--- @param name string The local directory to mount to
--- @param path string The absolute directory to mount from
--- @param readOnly? boolean Whether the mount should be read-only
--- @return boolean mounted -- Whether it mounted or not
function mounter.mount(name, path, readOnly) end

--- Unmounts the local `name` path
--- @param name string
--- @return boolean unmounted -- Whether it unmounted or not
function mounter.unmount(name) end

--- https://www.craftos-pc.cc/docs/screenshot

term = _G.term

--- It takes a screenshot! -_-
function term.screenshot() end

-- TODO: Debugger (omg)
--- https://www.craftos-pc.cc/docs/debugger
