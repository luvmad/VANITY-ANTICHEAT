# VANITY-ANTICHEAT v2.5

<div align="center">
  <a href="https://discord.gg/madison">
    <img alt="Discord" src="https://img.shields.io/discord/1215429092598349945?color=%237289da&label=DISCORD&logo=Discord&style=for-the-badge">
  </a>
  <a href="https://github.com/luvmad/VANITY-ANTICHEAT/releases/latest">
    <img alt="GitHub tag (latest by date)" src="https://img.shields.io/github/v/tag/luvmad/VANITY-ANTICHEAT?color=F05A7A&label=RELEASE&style=for-the-badge">
  </a>
  <img alt="GitHub all releases" src="https://img.shields.io/github/downloads/luvmad/VANITY-ANTICHEAT/total?style=for-the-badge">
</div>

## Overview

VANITY-ANTICHEAT is a comprehensive and advanced anti-cheat system for Roblox games, featuring behavior analysis, combat monitoring, network optimization, and physics validation. It effectively detects and prevents cheating by monitoring player behaviors such as speed hacking, teleportation, health manipulation, and excessive damage.

**Developer:** Luvmadison  
**Version:** 2.5  
**License:** Proprietary software - Unauthorized modification, distribution, or use is strictly prohibited.

## Features

### Core Features
- Real-time behavior analysis and player monitoring
- Combat monitoring and validation
- Network traffic optimization
- Physics engine validation
- Admin notification system
- Customizable configuration
- Advanced detection algorithms
- Secure remote event handling
- Automatic banning system
- Discord integration for notifications
- Reputation system
- Network optimization
- External script detection

### Security Features
- Aimbot detection
- Speed hack detection
- Noclip detection
- Wallhack detection
- ESP detection
- Infinite jump detection
- Flight detection
- Kill aura detection
- God mode detection
- Teleport detection
- Gravity enforcement
- Health manipulation detection

## Installation

### Prerequisites
1. Roblox Studio
2. Discord webhook URL (for notifications)
3. Administrative access to your game

### Setup Steps
1. Import all files into your Roblox game:
   - Place server scripts in `ServerScriptService`
   - Place client scripts in `StarterPlayerScripts`
   - Place shared modules in `ReplicatedStorage`

2. Update the Discord webhook URLs in `VANITY-ANTICHEAT-CONFIG.lua`
3. Configure admin groups and security settings
4. Test the system in a private server before deploying

### File Structure
```
ServerScriptService/
├── server/
│   ├── init.lua
│   ├── start.server.lua
│   └── VANITY-ANTICHEAT.lua
StarterPlayerScripts/
├── client/
│   ├── init.lua
│   ├── start.client.lua
│   ├── AdminNotificationClient.lua
│   └── VANITY-ANTICHEAT-ADMIN-PANEL.lua
ReplicatedStorage/
└── src/
    ├── init.lua
    ├── VANITY-ANTICHEAT-CONFIG.lua
    ├── VANITY-ANTICHEAT-BEHAVIOR-ANALYZER.lua
    ├── VANITY-ANTICHEAT-COMBAT-MONITOR.lua
    ├── VANITY-ANTICHEAT-NETWORK-OPTIMISER.lua
    └── VANITY-ANTICHEAT-PHYSICS-VALIDATOR.lua
```

## Configuration

### Basic Configuration
```lua
-- In VANITY-ANTICHEAT-CONFIG.lua
CONFIG.SECURITY_LEVEL = "HIGH"           -- Security level (LOW, MEDIUM, HIGH)
CONFIG.STRICT_MODE = true                -- Enable strict checking
CONFIG.AUTO_BAN = true                   -- Enable automatic banning
CONFIG.AUTO_KICK = true                  -- Enable automatic kicking
CONFIG.WARNING_SYSTEM = true             -- Enable warning system
```

### Admin Configuration
```lua
CONFIG.ADMIN_GROUPS = {
    ["GameAdmins"] = true,
    ["Moderators"] = true,
    ["Developers"] = true
}
```

### Discord Integration
```lua
CONFIG.DISCORD_WEBHOOK_URL = "your_webhook_url"
CONFIG.DISCORD_ALERT_WEBHOOK_URL = "your_alert_webhook_url"
CONFIG.DISCORD_LOG_WEBHOOK_URL = "your_log_webhook_url"
```

## Core Modules Documentation

### Behavior Analyzer
```lua
BehaviorAnalyzer.analyzeMovement(player, position, velocity)
BehaviorAnalyzer.analyzeAction(player, actionType, actionData)
BehaviorAnalyzer.analyzeCombat(player, target, damage, distance)
BehaviorAnalyzer.analyzeToolUsage(player, tool, action)
BehaviorAnalyzer.getAnomalyScore(player)
```

### Combat Monitor
```lua
CombatMonitor.validateDamage(attacker, victim, weapon, damage)
CombatMonitor.validateCriticalHit(attacker, weapon, multiplier)
CombatMonitor.validateProjectile(attacker, startPos, endPos, weapon)
CombatMonitor.getSuspiciousActivities()
```

### Network Optimizer
```lua
NetworkOptimizer.getNetworkStats()
NetworkOptimizer.handleSecureCommunication(player, requestType, data)
NetworkOptimizer.optimizeNetwork()
```

### Physics Validator
```lua
PhysicsValidator.validateGravity()
PhysicsValidator.validatePartVelocity(part)
PhysicsValidator.validatePartSize(part)
PhysicsValidator.validateCollisions(part)
PhysicsValidator.validatePlayerPhysics(player)
PhysicsValidator.validateAll()
PhysicsValidator.getViolations()
```

### Admin Notification System
```lua
AdminNotificationClient.queueNotification(message, notificationType, metadata)
```

Available notification types:
- INFO
- WARNING
- ERROR
- SUCCESS
- CRITICAL
- EXPLOIT
- ANOMALY
- BEHAVIOR
- NETWORK

## Security Settings

### Movement Thresholds
```lua
CONFIG.SPEED_LIMIT = 50
CONFIG.VERTICAL_SPEED_LIMIT = 100
CONFIG.ACCELERATION_LIMIT = 50
CONFIG.ROTATION_SPEED_LIMIT = 720
CONFIG.MAX_TELEPORT_DISTANCE = 1000
```

### Combat Thresholds
```lua
CONFIG.MAX_DAMAGE_PER_SECOND = 200
CONFIG.MIN_HIT_INTERVAL = 0.1
CONFIG.MAX_HITS_PER_SECOND = 10
CONFIG.MAX_RANGE_MULTIPLIER = 1.5
```

### Network Thresholds
```lua
CONFIG.RATE_LIMIT_WINDOW = 60
CONFIG.MAX_PACKET_SIZE = 1024 * 100
CONFIG.MIN_REQUEST_INTERVAL = 0.1
CONFIG.NETWORK_TIMEOUT = 5
CONFIG.MAX_CONCURRENT_REQUESTS = 10
```

## Admin Panel Interface

### Overview Tab
- Active players count
- Violations today
- Suspicious activities
- Average anomaly score
- 24-hour violation graph
- Recent activities log

### Players Tab
- Player search
- Player list
- Detailed player statistics
- Action buttons (Kick, Ban, Reset)
- Violation history

### Violations Tab
- Filter by type
- Detailed violation information
- Timestamp and context
- Action history

### Statistics Tab
- Violations per hour
- Types of violations
- Active players graph
- Server performance metrics

### Configuration Tab
- Security settings
- Detection thresholds
- Punishment configuration
- Network settings

### Logs Tab
- Detailed activity logs
- Filter by severity
- Search functionality
- Export capabilities

## Ban System

### Ban Duration Settings
```lua
CONFIG.BAN_DURATION = 7 * 24 * 3600        -- 7 days
CONFIG.TEMP_BAN_DURATION = 24 * 3600       -- 24 hours
CONFIG.BAN_APPEAL_COOLDOWN = 14 * 24 * 3600 -- 14 days
```

### Warning System
```lua
CONFIG.MAX_WARNINGS_BEFORE_BAN = 3
CONFIG.WARNING_EXPIRY = 7 * 24 * 3600      -- 7 days
```

## Performance Optimization

### Server Settings
```lua
CONFIG.ASYNC_PROCESSING = true
CONFIG.BATCH_PROCESSING = true
CONFIG.OPTIMIZATION_LEVEL = "HIGH"
CONFIG.MAX_CHECKS_PER_FRAME = 20
CONFIG.LOAD_BALANCING = true
```

### Memory Management
```lua
CONFIG.MEMORY_THRESHOLD = 0.9
CONFIG.CPU_THRESHOLD = 0.8
CONFIG.MAX_CONCURRENT_MONITORS = 50
CONFIG.BATCH_SIZE = 10
```

## Support and Contact

For support or inquiries about VANITY-ANTICHEAT, please contact:
- Developer: Luvmadison
- Discord: [Join our Discord server](https://discord.gg/madison)
- Version: 2.5
- Last Updated: [2025-03-17]

## License

This anti-cheat system is proprietary software. Any unauthorized modification, distribution, or use is strictly prohibited and may result in legal action.

<p align="center">
<div align="center">
  <a href="https://discord.gg/madison">
    <img alt="Discord" src="https://img.shields.io/discord/1215429092598349945?color=%237289da&label=DISCORD&logo=Discord&style=for-the-badge">
  </a>
  <a href="https://github.com/luvmad/VANITY-ANTICHEAT/releases/latest">
    <img alt="GitHub tag (latest by date)" src="https://img.shields.io/github/v/tag/luvmad/VANITY-ANTICHEAT?color=F05A7A&label=RELEASE&style=for-the-badge">
  </a>
  <img alt="GitHub all releases" src="https://img.shields.io/github/downloads/luvmad/VANITY-ANTICHEAT/total?style=for-the-badge">
</div>
<br>

**Created by:** Luvmadison  
**Version:** 2.0.0  
**License:** Non-modifiable

## Description

`VANITY-ANTICHEAT` is a powerful anti-cheat script designed for the Roblox platform. It effectively detects and prevents cheating by monitoring player behaviors such as speed hacking, teleportation, health manipulation, and excessive damage. This ensures a fair gaming experience for all players.

## Features

- **Real-time Player Monitoring**: Continuously tracks player actions to identify potential cheating.
- **Automatic Banning**: Players caught cheating are automatically banned, and their information is stored in a data store for future reference.
- **Discord Notifications**: Sends alerts to a specified Discord webhook when suspicious activities are detected.
- **Customizable Configuration**: Easily adjustable parameters for speed limits, damage thresholds, jump heights, and more.
- **Gravity Enforcement**: Monitors and resets game gravity to prevent unauthorized changes.
- **Reputation System**: Tracks player reputation and adjusts it based on behavior, allowing for dynamic responses to player actions.
- **Network Optimization**: Measures latency and optimizes player connections to ensure a smooth gaming experience.
- **External Script Detection**: Monitors for the use of external scripts and injectors, alerting administrators if detected.

## Installation

1. Copy the script into your Roblox game's server-side code.
2. Update the `DISCORD_WEBHOOK_URL` variable in `VANITY-ANTICHEAT-CONFIG.lua` with your actual Discord webhook URL to enable logging.
3. Adjust configuration settings as needed:
   - `SPEED_LIMIT`: Maximum allowed player speed.
   - `DAMAGE_THRESHOLD`: Maximum damage allowed.
   - `TELEPORT_DISTANCE`: Maximum allowed teleport distance.
   - `JUMP_HEIGHT_LIMIT`: Maximum allowed jump height.
   - `BAN_DURATION`: Duration for which a player will be banned (default is 30 days).
   - `REPUTATION_MAX`: Maximum reputation value.
   - `REPUTATION_MIN`: Minimum reputation value.

## Usage

- This script is **strictly non-modifiable**. Any attempts to circumvent or modify the script will lead to penalties.
- Upon initialization, the script will monitor players as they join the game.
- If cheating is detected, the script will:
  - Log the incident and notify the specified Discord channel.
  - Ban the player by storing their User ID or generated HWID in the banned players' data store.
  - Kick the player from the game with a message detailing the reason for the ban.

## Monitoring Functions

- **Heartbeat Monitoring**: Detects interference in heartbeat events, indicating possible exploits.
- **Character Monitoring**: Checks for excessive speed, jump height, and health manipulation.
- **Teleportation Monitoring**: Flags unauthorized teleportation by measuring movement distances.
- **Trigger Monitoring**: Prevents excessive triggering of critical actions to thwart exploits.
- **Gravity Monitoring**: Resets game gravity if any changes are detected.
- **Latency Monitoring**: Measures player latency and alerts administrators if it exceeds acceptable thresholds.

## Support

For any issues or questions regarding the `VANITY-ANTICHEAT` script, please reach out to the author: **Luvmadison**.

<p align="center">
        <img src="https://raw.githubusercontent.com/mayhemantt/mayhemantt/Update/svg/Bottom.svg" alt="Github Stats" />
</p>


