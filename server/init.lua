-- [[ VANITY-ANTICHEAT SERVER INITIALIZATION V2.5 ROBLOX ENHANCED ]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local VanityAntiCheatServer = {}

-- Loading modules
local vanityAntiCheat = ReplicatedStorage:WaitForChild("VANITY-ANTICHEAT")
VanityAntiCheatServer.Config = require(vanityAntiCheat:WaitForChild("VANITY-ANTICHEAT-CONFIG"))
VanityAntiCheatServer.Core = require(script:WaitForChild("VANITY-ANTICHEAT"))

function VanityAntiCheatServer.init()
    print("[VANITY-ANTICHEAT-SERVER] Initializing...")
    
    VanityAntiCheatServer.Core.init()
    
    print("[VANITY-ANTICHEAT-SERVER] Initialized successfully!")
end

return VanityAntiCheatServer 