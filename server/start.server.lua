-- [[ VANITY-ANTICHEAT STARTUP SCRIPT V2.5 ROBLOX ENHANCED ]]

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for services to be ready
local vanityAntiCheatServer = require(script.Parent)
local vanityAntiCheat = ReplicatedStorage:WaitForChild("VANITY-ANTICHEAT")

-- Initialize anti-cheat
vanityAntiCheatServer.init()

print("[VANITY-ANTICHEAT] Anti-cheat system started and operational!") 