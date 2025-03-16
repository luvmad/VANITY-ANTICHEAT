-- [[ VANITY-ANTICHEAT CLIENT INITIALIZATION V2.5 ROBLOX ENHANCED ]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local VanityAntiCheatClient = {}

-- Loading modules
local vanityAntiCheat = ReplicatedStorage:WaitForChild("VANITY-ANTICHEAT")
VanityAntiCheatClient.Config = require(vanityAntiCheat:WaitForChild("VANITY-ANTICHEAT-CONFIG"))
VanityAntiCheatClient.AdminPanel = require(script:WaitForChild("VANITY-ANTICHEAT-ADMIN-PANEL"))
VanityAntiCheatClient.Notifications = require(script:WaitForChild("AdminNotificationClient"))

-- Initialisation
function VanityAntiCheatClient.init()
    print("[VANITY-ANTICHEAT-CLIENT] Initializing...")
    
    -- Check if player is an administrator
    local player = Players.LocalPlayer
    if VanityAntiCheatClient.Config.ADMIN_GROUPS[player:GetRoleInGroup(game.CreatorId)] then
        -- Initialize admin panel
        VanityAntiCheatClient.AdminPanel.createUI(player)
    end
    
    print("[VANITY-ANTICHEAT-CLIENT] Initialized successfully!")
end

return VanityAntiCheatClient 