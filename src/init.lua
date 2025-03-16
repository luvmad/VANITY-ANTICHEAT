-- [[ VANITY-ANTICHEAT INITIALIZATION V2.5 ROBLOX ENHANCED ]]

local VanityAntiCheat = {}

-- Loading modules
VanityAntiCheat.Config = require(script:WaitForChild("VANITY-ANTICHEAT-CONFIG"))
VanityAntiCheat.BehaviorAnalyzer = require(script:WaitForChild("VANITY-ANTICHEAT-BEHAVIOR-ANALYZER"))
VanityAntiCheat.CombatMonitor = require(script:WaitForChild("VANITY-ANTICHEAT-COMBAT-MONITOR"))
VanityAntiCheat.NetworkOptimizer = require(script:WaitForChild("VANITY-ANTICHEAT-NETWORK-OPTIMISER"))
VanityAntiCheat.PhysicsValidator = require(script:WaitForChild("VANITY-ANTICHEAT-PHYSICS-VALIDATOR"))

-- Version info
VanityAntiCheat.VERSION = "2.5"
VanityAntiCheat.AUTHOR = "Luvmadison"
VanityAntiCheat.LAST_UPDATED = os.date("%Y-%m-%d")

function VanityAntiCheat.init()
    print("[VANITY-ANTICHEAT] Initializing...")
    
    VanityAntiCheat.BehaviorAnalyzer.initialize()
    VanityAntiCheat.PhysicsValidator.initialize()
    VanityAntiCheat.NetworkOptimizer.initialize()
    VanityAntiCheat.CombatMonitor.initialize()
    
    print("[VANITY-ANTICHEAT] Version " .. VanityAntiCheat.VERSION .. " initialized successfully!")
end

return VanityAntiCheat 