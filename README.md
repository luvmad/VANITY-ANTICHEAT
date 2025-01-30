# VANITY-ANTICHEAT

![Alt text](https://cdn.discordapp.com/attachments/1280308180148158485/1301972617821032498/vanity.png?ex=67266bfd&is=67251a7d&hm=16f8dcac7142ecbc7751d4b937569943cdd9badb15f508621e1ddd0e6f069f8c&)

<div align="center">
  <a href="https://discord.gg/madison">
    <img alt="Discord" src="https://img.shields.io/discord/1215429092598349945?color=%237289da&label=DISCORD&logo=Discord&style=for-the-badge">
  </a>
  <a href="https://github.com/CassouBrxn/VANITY-ANTICHEAT/releases/latest">
    <img alt="GitHub tag (latest by date)" src="https://img.shields.io/github/v/tag/CassouBrxn/VANITY-ANTICHEAT?color=F05A7A&label=RELEASE&style=for-the-badge">
  </a>
  <img alt="GitHub all releases" src="https://img.shields.io/github/downloads/CassouBrxn/VANITY-ANTICHEAT/total?style=for-the-badge">
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


