-- [[ VANITY-ANTICHEAT CONFIGURATION ]]
-- This file contains all configurable parameters for the anti-cheat system.

local CONFIG = {}

-- Webhook URL for Discord notifications
CONFIG.DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/YOUR_WEBHOOK_URL"  -- Replace with your actual webhook URL

-- Speed and damage thresholds
CONFIG.SPEED_LIMIT = 50           -- Maximum allowed speed
CONFIG.DAMAGE_THRESHOLD = 100     -- Maximum allowed damage

-- Teleportation and jump limits
CONFIG.TELEPORT_DISTANCE = 50     -- Maximum allowed teleport distance
CONFIG.JUMP_HEIGHT_LIMIT = 100    -- Maximum allowed jump height

-- Game physics settings
CONFIG.GRAVITY = workspace.Gravity -- Expected gravity in the game

-- Timing settings
CONFIG.HEARTBEAT_INTERVAL = 5     -- Interval for heartbeat checks in seconds
CONFIG.TRIGGER_THRESHOLD = 10     -- Max allowed trigger per second for critical actions

-- Ban settings
CONFIG.BAN_DURATION = 30 * 24 * 3600  -- Ban duration in seconds (e.g., 30 days)

-- Reputation settings
CONFIG.REPUTATION_MAX = 100        -- Maximum reputation value
CONFIG.REPUTATION_MIN = -100       -- Minimum reputation value

return CONFIG
