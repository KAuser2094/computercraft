--[[
    This module is used to provide a better api to craftOS-PC's api's, especially for periphemu
]]

--- @module "common.Types.craftOS"

-- Unused
--[[

local native_peripheral = {} -- COPY (not same reference) of the native peripheral api

for k, v in pairs(_G.peripheral) do
    native_peripheral[k] = v
end

--]]

local peripheral = _G.peripheral -- Reference to the peripheral api (which may or may not be overloaded)

local periphemu = _G.periphemu

local module = {}

module.SIDES = {
    TOP = "top",
    BOTTOM = "bottom",
    LEFT = "left",
    RIGHT = "right",
    BACK = "back",
    FRONT = "front",
}

function module.inEmulator()
    return not not periphemu -- Check if the api exists, if it does then we are in an emulator
end

--[[
    periphemu
]]

--- Remove a peripheral at the given side
--- @param side string
--- @return boolean detached
function module.detachPeripheral(side)
    return periphemu.remove(side)
end

--- Detaches all peripherals
--- @return integer detachCount -- Amount this detached
function module.detachAll()
    local count = 0
    for _, name in ipairs(_G.peripheral.getNames()) do
        if periphemu.remove(name) then count = count + 1 end
    end
    return count
end

local lastChestID = -1
--- Creates a chest peripheral onto the network
--- @param side? string | integer
--- @param doubleChest? boolean
--- @return boolean attached
function module.attachChestPeripheral(side, doubleChest)
    if not side then
        lastChestID = lastChestID + 1
        side = "chest_" .. tostring(lastChestID)
        while peripheral.isPresent(side) do
            lastChestID = lastChestID + 1
            side = "chest_" .. tostring(lastChestID)
        end
    end
    return periphemu.create(side, "chest", doubleChest)
end

local lastTankID = -1
--- Creates a tank peripheral onto the network
--- @param side? string | integer
--- @param noTanks? integer
--- @param types? string[]
--- @return boolean attached
function module.attachTankPeripheral(side, noTanks, types)
    if not side then
        lastTankID = lastTankID + 1
        side = "tank_" .. tostring(lastTankID)
        while peripheral.isPresent(side) do
            lastTankID = lastTankID + 1
            side = "tank_" .. tostring(lastTankID)
        end
    end
    return periphemu.create(side, "tank", noTanks, types)
end

local lastEnergyID = -1
--- Creates a tank peripheral onto the network
--- @param side? string | integer
--- @param maxEnergy? integer
--- @param types? string[]
--- @return boolean attached
function module.attachEnergyPeripheral(side, maxEnergy, types)
    if not side then
        lastEnergyID = lastEnergyID + 1
        side = "energy_" .. tostring(lastEnergyID)
        while peripheral.isPresent(side) do
            lastEnergyID = lastEnergyID + 1
            side = "energy_" .. tostring(lastEnergyID)
        end
    end
    return periphemu.create(side, "energy", maxEnergy, types)
end

local lastModemID = -1
--- Creates a modem peripheral onto the network
--- @param side? string | integer
--- @param networkID? integer -- NOTE: I don't think this actually works?
--- @return boolean attached
function module.attachModemPeripheral(side, networkID)
    if not side then
        lastModemID = lastModemID + 1
        side = "modem_" .. tostring(lastModemID)
        while peripheral.isPresent(side) do
            lastModemID = lastModemID + 1
            side = "modem_" .. tostring(lastModemID)
        end
    end
    return periphemu.create(side, "modem", networkID)
end

-- TODO: Other periphemu create functions

--[[
    mounter
]]

--- Mounts into the cc computer from the outside computer
--- @param ccPath string path within the computer
--- @param absPath string path in your file system
--- @param readOnly? boolean mark the mount as readonly
--- @return boolean mounted
function module.mount(ccPath, absPath, readOnly)
    return mounter.mount(ccPath, absPath, readOnly)
end

--- Unmounts at the path in cc computer
--- @param ccPath string path within the computer
--- @return boolean unmounted
function module.unmount(ccPath)
    return mounter.unmount(ccPath)
end

--[[
    Overload functions maybe?
]]

local overloaded = false

function module.overloadIfNeeded()

    -- Just attach a modem peripheral to a side on the computer (Took way too long to figure this out, even though you have to do that in an actual ccTweaked computer as well)

    --[[
    if module.inEmulator() and not overloaded then
        -- We need to have at least 1 modem on the network to connect make getNames() to work
        local workaroundName = "NETWORK CONNECTING WORKAROUND 239802352342304"
        module.attachModemPeripheral(workaroundName) -- reasonably should not be a network ID in use

        --- @diagnostic disable-next-line: duplicate-set-field
        _G.peripheral.getNames = function () -- Redefine using an emulated modem to work like expected
            local names = _G.peripheral.call(workaroundName, "getNamesRemote")

            -- Remove itself from the list. (We want to act as if the workaround modem doesn't exist, since by default only modems explictly wrapped show)
            local index = -1
            for i, v in ipairs(names) do
                if index == -1 then
                    if v == workaroundName then index = i end
                end
            end
            table.remove(names, index)

            return names
        end

        --- @diagnostic disable-next-line: duplicate-set-field
        _G.peripheral.find = function (peripheralType, filter)
            local found = {}
            local names = _G.peripheral.getNames() -- Get ALL names (excludes workaround)
            for _, nameToCheck in ipairs(names) do
                if native_peripheral.hasType(nameToCheck, peripheralType) then
                    local wrappedToCheck = assert(native_peripheral.wrap(nameToCheck), "Somehow `getNames()` returned a peripheral name that was not actually on the network: " .. nameToCheck)
                    if filter == nil or filter(nameToCheck, wrappedToCheck) then
                        table.insert(found, wrappedToCheck)
                    end
                end
            end
            return table.unpack(found)
        end

        overloaded = true
    end
    --]]
end

module.overloadIfNeeded() -- Idk why I put this in a seperate function...

return module
