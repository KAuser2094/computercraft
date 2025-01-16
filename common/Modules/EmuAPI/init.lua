--[[
    This module is used to provide a better api to craftOS-PC's api's, especially for periphemu
]]

--- @module "common.Types.craftOS"


local module = {}

function module.inEmulator()
    return not not periphemu -- Check if the api exists, if it does then we are in an emulator
end

--[[
    periphemu
]]

--- Remove a peripheral at the given side
--- @param side string
--- @return boolean removed
function module.removePeripheral(side)
    return periphemu.remove(side)
end

--- Creates a chest peripheral onto the network
--- @param side string
--- @param doubleChest? boolean
--- @return boolean created
function module.createChestPeripheral(side, doubleChest)
    return periphemu.create(side, "chest", doubleChest)
end

--- Creates a tank peripheral onto the network
--- @param side string
--- @param noTanks? integer
--- @param types? string[]
--- @return boolean created
function module.createTankPeripheral(side, noTanks, types)
    return periphemu.create(side, "tank", noTanks, types)
end

--- Creates a tank peripheral onto the network
--- @param side string
--- @param maxEnergy? integer
--- @param types? string[]
--- @return boolean created
function module.createEnergyPeripheral(side, maxEnergy, types)
    return periphemu.create(side, "energy", maxEnergy, types)
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

return module
