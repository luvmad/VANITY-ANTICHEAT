-- [[ VANITY-ANTICHEAT STARTUP SCRIPT V2.5 ROBLOX ENHANCED ]]

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for services to be ready
local success, vanityAntiCheatServer = pcall(function()
    return require(script.Parent) -- Assurez-vous que cela pointe vers le bon module
end)

if not success then
    warn("Failed to load VANITY-ANTICHEAT: " .. tostring(vanityAntiCheatServer))
    return
end

local vanityAntiCheat = ReplicatedStorage:WaitForChild("VANITY-ANTICHEAT")

-- Initialize anti-cheat
vanityAntiCheatServer.init()

print("[VANITY-ANTICHEAT] Anti-cheat system started and operational!") 