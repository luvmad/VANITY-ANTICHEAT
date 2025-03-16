-- [[ VANITY-ANTICHEAT CLIENT STARTUP SCRIPT V2.5 ROBLOX ENHANCED ]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for services to be ready
local vanityAntiCheatClient = require(script.Parent)
local vanityAntiCheat = ReplicatedStorage:WaitForChild("VANITY-ANTICHEAT")

-- Initialize client
vanityAntiCheatClient.init()

print("[VANITY-ANTICHEAT-CLIENT] Anti-cheat client started!") 