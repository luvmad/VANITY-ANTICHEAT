-- [[ VANITY-ANTICHEAT CONFIGURATION V2.5 ROBLOX ENHANCED ]]
-- This file contains all configurable parameters for the anti-cheat system.

local CONFIG = {}

-- Version Control
CONFIG.VERSION = "2.5"
CONFIG.LAST_UPDATED = os.date("%Y-%m-%d")

-- Seuils d'Anomalie
CONFIG.ANOMALY_THRESHOLD = 5.0           -- Seuil de base pour les anomalies
CONFIG.WARNING_ANOMALY_THRESHOLD = 7.5   -- Seuil pour les avertissements
CONFIG.CRITICAL_ANOMALY_THRESHOLD = 10.0 -- Seuil critique
CONFIG.ANOMALY_DECAY_RATE = 0.1         -- Taux de décroissance des scores d'anomalie
CONFIG.MAX_ANOMALY_SCORE = 20.0         -- Score maximum d'anomalie
CONFIG.ANOMALY_MULTIPLIER = 1.5         -- Multiplicateur pour les violations répétées

-- Seuils de Réputation
CONFIG.REPUTATION_MIN = -100
CONFIG.REPUTATION_MAX = 100
CONFIG.REPUTATION_DECAY_RATE = 0.05
CONFIG.REPUTATION_GAIN_RATE = 0.1
CONFIG.REPUTATION_PENALTY_MULTIPLIER = 1.2

-- Webhook URLs for Discord notifications
CONFIG.DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/YOUR_WEBHOOK_URL"  -- Replace with your actual webhook URL
CONFIG.DISCORD_ALERT_WEBHOOK_URL = "https://discord.com/api/webhooks/YOUR_ALERT_WEBHOOK_URL" -- For critical alerts
CONFIG.DISCORD_LOG_WEBHOOK_URL = "https://discord.com/api/webhooks/YOUR_LOG_WEBHOOK_URL" -- For general logging

-- Roblox-specific Anti-Cheat Settings
CONFIG.NOCLIP_DETECTION = true     -- Detect noclip attempts
CONFIG.WALLHACK_DETECTION = true   -- Detect wallhack attempts
CONFIG.AIMBOT_DETECTION = true     -- Detect aimbot usage
CONFIG.ESP_DETECTION = true        -- Detect ESP cheats
CONFIG.INFINITE_JUMP_DETECTION = true -- Detect infinite jump exploits
CONFIG.FLIGHT_DETECTION = true     -- Detect unauthorized flying
CONFIG.SPEED_DETECTION = true      -- Detect speed hacks
CONFIG.TELEPORT_DETECTION = true   -- Detect unauthorized teleports
CONFIG.KILL_AURA_DETECTION = true  -- Detect kill aura cheats
CONFIG.GOD_MODE_DETECTION = true   -- Detect god mode exploits

-- Speed and Movement Thresholds
CONFIG.SPEED_LIMIT = 50           -- Maximum allowed speed
CONFIG.DAMAGE_THRESHOLD = 100     -- Maximum allowed damage
CONFIG.SPEED_CHECK_INTERVAL = 0.1 -- How often to check player speed
CONFIG.SPEED_VIOLATION_THRESHOLD = 3 -- Violations before action
CONFIG.VERTICAL_SPEED_LIMIT = 100 -- Maximum vertical speed
CONFIG.ACCELERATION_LIMIT = 50    -- Maximum acceleration
CONFIG.ROTATION_SPEED_LIMIT = 720 -- Maximum rotation speed (degrees/sec)
CONFIG.MAX_TELEPORT_DISTANCE = 1000
CONFIG.POSITION_CHECK_INTERVAL = 0.1
CONFIG.VELOCITY_HISTORY_SIZE = 10
CONFIG.MAX_ACCELERATION = 100
CONFIG.MAX_DECELERATION = 100
CONFIG.MOVEMENT_PREDICTION_WINDOW = 0.5

-- Combat and Damage Settings
CONFIG.MAX_DAMAGE_PER_SECOND = 200    -- Maximum damage per second
CONFIG.MIN_HIT_INTERVAL = 0.1         -- Minimum time between hits
CONFIG.MAX_HITS_PER_SECOND = 10       -- Maximum hits per second
CONFIG.MAX_RANGE_MULTIPLIER = 1.5     -- Maximum weapon range multiplier
CONFIG.DAMAGE_VERIFICATION = true      -- Enable server-side damage verification
CONFIG.COMBAT_LOG_RETENTION = 300     -- Combat log retention time (seconds)
CONFIG.MAX_HEALTH_MULTIPLIER = 1.5
CONFIG.MAX_HEALTH_REGEN_RATE = 10
CONFIG.HEALTH_CHECK_INTERVAL = 0.2
CONFIG.HEALTH_HISTORY_SIZE = 20
CONFIG.MAX_DAMAGE_DISTANCE = 100

-- Anti-Exploit Protection
CONFIG.REMOTE_EVENT_THROTTLING = true -- Throttle remote event calls
CONFIG.MAX_REMOTE_CALLS = 100        -- Maximum remote calls per second
CONFIG.INSTANCE_CREATION_LIMIT = 50  -- Max instances created per second
CONFIG.PROPERTY_CHANGE_LIMIT = 100   -- Max property changes per second
CONFIG.ANTI_REMOTE_SPAM = true       -- Prevent remote event spamming
CONFIG.SECURE_INSTANCE_CHECK = true  -- Check for unauthorized instances

-- Physics and Movement Validation
CONFIG.PHYSICS_VALIDATION = true     -- Enable physics validation
CONFIG.GRAVITY_CHECK = true          -- Check for gravity modifications
CONFIG.COLLISION_CHECK = true        -- Check for collision modifications
CONFIG.CAMERA_LIMITS = true          -- Enable camera movement limits
CONFIG.POSITION_VALIDATION = true    -- Validate player positions
CONFIG.TELEPORT_VALIDATION = true    -- Validate teleport requests

-- Advanced Detection Settings
CONFIG.PATTERN_DETECTION = true      -- Enable pattern-based detection
CONFIG.BEHAVIOR_ANALYSIS = true      -- Enable behavior analysis
CONFIG.MACHINE_LEARNING = false      -- Enable ML-based detection (future)
CONFIG.SIGNATURE_DETECTION = true    -- Detect known cheat signatures
CONFIG.MEMORY_SCANNING = true        -- Scan for memory modifications
CONFIG.HASH_VERIFICATION = true      -- Verify file hashes

-- Punishment Settings
CONFIG.AUTO_BAN = true               -- Enable automatic banning
CONFIG.AUTO_KICK = true              -- Enable automatic kicking
CONFIG.WARNING_SYSTEM = true         -- Enable warning system
CONFIG.PROGRESSIVE_PUNISHMENT = true  -- Increase punishment severity
CONFIG.PUNISHMENT_DECAY = 7 * 24 * 3600 -- Punishment decay time (7 days)
CONFIG.MAX_WARNINGS = 3              -- Maximum warnings before ban

-- Logging and Monitoring
CONFIG.LOG_LEVEL = "DETAILED"        -- Logging detail level
CONFIG.LOG_RETENTION = 30 * 24 * 3600 -- Log retention period (30 days)
CONFIG.MONITOR_CHAT = true           -- Monitor chat for exploit attempts
CONFIG.MONITOR_TOOLS = true          -- Monitor tool usage
CONFIG.MONITOR_REMOTES = true        -- Monitor remote events
CONFIG.MONITOR_INSTANCES = true      -- Monitor instance creation/deletion

-- Performance Optimization
CONFIG.ASYNC_PROCESSING = true       -- Use async processing
CONFIG.BATCH_PROCESSING = true       -- Enable batch processing
CONFIG.OPTIMIZATION_LEVEL = "HIGH"   -- Performance optimization level
CONFIG.MAX_CHECKS_PER_FRAME = 20    -- Maximum checks per frame
CONFIG.LOAD_BALANCING = true        -- Enable load balancing
CONFIG.OPTIMIZATION_INTERVAL = 60
CONFIG.MEMORY_THRESHOLD = 0.9
CONFIG.CPU_THRESHOLD = 0.8
CONFIG.MAX_CONCURRENT_MONITORS = 50
CONFIG.BATCH_SIZE = 10

-- Security Levels
CONFIG.SECURITY_LEVEL = "HIGH"       -- Overall security level
CONFIG.STRICT_MODE = true           -- Enable strict checking
CONFIG.PARANOID_MODE = false        -- Enable extreme security (high CPU)
CONFIG.LEARNING_MODE = false        -- Enable learning mode

-- Appeal System
CONFIG.APPEAL_SYSTEM = true          -- Enable appeal system
CONFIG.APPEAL_COOLDOWN = 7 * 24 * 3600 -- Appeal cooldown (7 days)
CONFIG.MAX_APPEALS = 3               -- Maximum appeals per player
CONFIG.APPEAL_REVIEW_TIME = 48 * 3600 -- Appeal review time (48 hours)
CONFIG.AUTO_APPEAL_THRESHOLD = 0.2
CONFIG.APPEAL_EVIDENCE_REQUIRED = true

-- Admin Settings
CONFIG.ADMIN_IMMUNITY = true         -- Admins bypass anti-cheat
CONFIG.ADMIN_LOGGING = true          -- Log admin actions
CONFIG.ADMIN_NOTIFICATION = true     -- Notify admins of violations
CONFIG.ADMIN_OVERRIDE = true         -- Allow admin override
CONFIG.ADMIN_COMMANDS = true         -- Enable admin commands
CONFIG.ADMIN_GROUPS = {
    ["GameAdmins"] = true,
    ["Moderators"] = true,
    ["Developers"] = true
}
CONFIG.ADMIN_NOTIFICATION_LEVEL = "ALL"
CONFIG.ADMIN_OVERRIDE_COOLDOWN = 300
CONFIG.ADMIN_ACTION_LOGGING = true

-- Whitelist Settings
CONFIG.WHITELIST_ENABLED = true      -- Enable whitelist system
CONFIG.WHITELIST_GROUPS = {          -- Whitelisted groups
    ["GameAdmins"] = true,
    ["Moderators"] = true,
    ["Developers"] = true
}

-- Report System
CONFIG.REPORT_SYSTEM = true          -- Enable player reporting
CONFIG.MAX_REPORTS = 10              -- Max reports per hour
CONFIG.REPORT_COOLDOWN = 300         -- Report cooldown (5 minutes)
CONFIG.AUTO_REPORT_REVIEW = true     -- Auto-review frequent reports

-- Système de Bannissement
CONFIG.BAN_DURATION = 7 * 24 * 3600
CONFIG.TEMP_BAN_DURATION = 24 * 3600
CONFIG.BAN_APPEAL_COOLDOWN = 14 * 24 * 3600
CONFIG.MAX_WARNINGS_BEFORE_BAN = 3
CONFIG.WARNING_EXPIRY = 7 * 24 * 3600
CONFIG.BAN_DATA_BACKUP_INTERVAL = 3600

-- Surveillance Réseau
CONFIG.RATE_LIMIT_WINDOW = 60
CONFIG.MAX_PACKET_SIZE = 1024 * 100
CONFIG.MIN_REQUEST_INTERVAL = 0.1
CONFIG.NETWORK_TIMEOUT = 5
CONFIG.MAX_CONCURRENT_REQUESTS = 10
CONFIG.NETWORK_ANOMALY_THRESHOLD = 0.8

-- Stockage de Données
CONFIG.DATA_STORE_RETRY_ATTEMPTS = 3
CONFIG.DATA_STORE_RETRY_DELAY = 2
CONFIG.BACKUP_STORE_SUFFIX = "_backup"
CONFIG.DATA_CLEANUP_INTERVAL = 24 * 3600
CONFIG.MAX_STORED_VIOLATIONS = 1000
CONFIG.MAX_STORED_ACTIONS = 500

-- Surveillance Comportementale
CONFIG.BEHAVIOR_ANALYSIS_INTERVAL = 1
CONFIG.PATTERN_MATCH_TOLERANCE = 0.2

-- Surveillance des Instances
CONFIG.INSTANCE_CHECK_INTERVAL = 0.5
CONFIG.SUSPICIOUS_INSTANCES = {
    "LocalScript",
    "RemoteEvent",
    "RemoteFunction",
    "ModuleScript"
}
CONFIG.PROTECTED_INSTANCES = {
    "Workspace",
    "Players",
    "ReplicatedStorage"
}

-- Système de Notification
CONFIG.NOTIFICATION_THROTTLE = 1
CONFIG.MAX_NOTIFICATIONS = 5
CONFIG.NOTIFICATION_DURATION = 5
CONFIG.NOTIFICATION_FADE = 0.5
CONFIG.CRITICAL_NOTIFICATION_DURATION = 10
CONFIG.NOTIFICATION_QUEUE_SIZE = 20

return CONFIG
