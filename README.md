# VANITY-ANTICHEAT

**Created by:** Luvmadison  
**Version:** 1.0.2
**License:** Non-modifiable

## Description

`VANITY-ANTICHEAT` is a powerful anti-cheat script designed for the Roblox platform. It effectively detects and prevents cheating by monitoring player behaviors such as speed hacking, teleportation, health manipulation, and excessive damage. This ensures a fair gaming experience for all players.

## Features

- **Real-time Player Monitoring**: Continuously tracks player actions to identify potential cheating.
- **Automatic Banning**: Players caught cheating are automatically banned, and their information is stored in a data store for future reference.
- **Discord Notifications**: Sends alerts to a specified Discord webhook when suspicious activities are detected.
- **Customizable Configuration**: Easily adjustable parameters for speed limits, damage thresholds, jump heights, and more.
- **Gravity Enforcement**: Monitors and resets game gravity to prevent unauthorized changes.

## Installation

1. Copy the script into your Roblox game’s server-side code.
2. Update the `DISCORD_WEBHOOK_URL` variable with your actual Discord webhook URL to enable logging.
3. Adjust configuration settings as needed:
   - `SPEED_LIMIT`: Maximum allowed player speed.
   - `DAMAGE_THRESHOLD`: Maximum damage allowed.
   - `TELEPORT_DISTANCE`: Maximum allowed teleport distance.
   - `JUMP_HEIGHT_LIMIT`: Maximum allowed jump height.
   - `BAN_DURATION`: Duration for which a player will be banned (default is 30 days).

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

## Support

For any issues or questions regarding the `VANITY-ANTICHEAT` script, please reach out to the author: **Luvmadison**.

https://raw.githubusercontent.com/mayhemantt/mayhemantt/Update/svg/Bottom.svg
