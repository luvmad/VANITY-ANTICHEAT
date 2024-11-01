-- [[ VANITY-ANTICHEAT created by Luvmadison ]]
-- This script is strictly non-editable.
-- Any attempt to circumvent or modify this script may lead to sanctions.

local ANTI_CHEAT_NAME = "VANITY-ANTICHEAT"
local ANTI_CHEAT_AUTHOR = "Luvmadison"
local CURRENT_VERSION = "1.0"  -- Current version of the script
local REPO_URL = "https://api.github.com/repos/CassouBrxn/VANITY-ANTICHEAT/releases/latest"  -- Replace with your repository URL

print(ANTI_CHEAT_NAME .. " by " .. ANTI_CHEAT_AUTHOR .. " initialized")

-- ================================
--         Configuration
-- ================================

local DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/YOUR_WEBHOOK_URL"  -- Replace with your actual webhook URL
local SPEED_LIMIT = 50           -- Maximum allowed speed
local DAMAGE_THRESHOLD = 100     -- Maximum allowed damage
local TELEPORT_DISTANCE = 50     -- Maximum allowed teleport distance
local JUMP_HEIGHT_LIMIT = 100    -- Maximum allowed jump height
local GRAVITY = Workspace.Gravity -- Expected gravity in the game
local HEARTBEAT_INTERVAL = 5     -- Interval for heartbeat checks in seconds
local TRIGGER_THRESHOLD = 10     -- Max allowed trigger per second for critical actions
local BAN_DURATION = 30 * 24 * 3600  -- Ban duration in seconds (e.g., 30 days)

-- ================================
--        Version Check
-- ================================

local function checkForUpdates()
    local success, response = pcall(function()
        return HttpService:GetAsync(REPO_URL)
    end)

    if success then
        local data = HttpService:JSONDecode(response)
        local latestVersion = data.tag_name or "unknown"

        if latestVersion ~= CURRENT_VERSION then
            warn(ANTI_CHEAT_NAME .. ": A new version (" .. latestVersion .. ") is available! Please update.")
        else
            print(ANTI_CHEAT_NAME .. ": You are using the latest version (" .. CURRENT_VERSION .. ").")
        end
    else
        warn(ANTI_CHEAT_NAME .. ": Could not check for updates. " .. tostring(response))
    end
end

checkForUpdates()

-- ================================
--        Utility Functions
-- ================================

-- Generate a pseudo "HWID" based on available data
local function generateHWID(player)
    return tostring(player.UserId) .. "_" .. tostring(player.AccountAge)
end

-- Function to send log messages to Discord
local function sendToDiscord(player, reason)
    local data = {
        ["username"] = ANTI_CHEAT_NAME,
        ["embeds"] = {{
            ["title"] = "Suspicious Activity Detected",
            ["description"] = "Player: " .. player.Name .. "\nReason: " .. reason,
            ["color"] = 16711680,
            ["fields"] = {
                {["name"] = "Player ID", ["value"] = tostring(player.UserId), ["inline"] = true},
                {["name"] = "Timestamp", ["value"] = os.date("%Y-%m-%d %H:%M:%S"), ["inline"] = true}
            }
        }}
    }

    local jsonData = HttpService:JSONEncode(data)
    HttpService:PostAsync(DISCORD_WEBHOOK_URL, jsonData, Enum.HttpContentType.ApplicationJson)
end

-- Function to ban a player by storing their "HWID" or UserId in the DataStore
local function banPlayer(player, reason)
    local hwid = generateHWID(player)
    local banData = {
        reason = reason,
        bannedAt = os.time(),
        banDuration = BAN_DURATION
    }

    bannedPlayersStore:SetAsync("UserId_" .. player.UserId, banData)
    bannedPlayersStore:SetAsync("HWID_" .. hwid, banData)
end

-- Function to check if a player is banned by UserId or HWID
local function isPlayerBanned(player)
    local hwid = generateHWID(player)
    
    -- Check ban by UserId
    local banData = bannedPlayersStore:GetAsync("UserId_" .. player.UserId)
    if banData then
        if os.time() < (banData.bannedAt + banData.banDuration) then
            return true, banData.reason
        else
            bannedPlayersStore:RemoveAsync("UserId_" .. player.UserId)
        end
    end

    -- Check ban by HWID
    banData = bannedPlayersStore:GetAsync("HWID_" .. hwid)
    if banData then
        if os.time() < (banData.bannedAt + banData.banDuration) then
            return true, banData.reason
        else
            bannedPlayersStore:RemoveAsync("HWID_" .. hwid)
        end
    end

    return false, nil
end

-- ================================
--        Cheating Detection
-- ================================

-- Logs and bans player on repeated offenses
local function logAndHandleCheat(player, reason)
    sendToDiscord(player, reason)
    banPlayer(player, reason)
    player:Kick("You have been banned for cheating: " .. reason)
end

-- Anti-Executor Heartbeat with anti-interference detection
local function monitorHeartbeat(player)
    local lastHeartbeat = os.time()

    -- Heartbeat event
    player:WaitForChild("Heartbeat"):OnServerEvent:Connect(function()
        lastHeartbeat = os.time()
    end)

    spawn(function()
        while true do
            wait(HEARTBEAT_INTERVAL)
            if os.time() - lastHeartbeat > HEARTBEAT_INTERVAL * 2 then
                logAndHandleCheat(player, "Anti-Executor detection: Heartbeat interference")
            end
        end
    end)
end

-- Function to check player speed and jump height
local function monitorCharacter(player)
    local character = player.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")

        humanoidRootPart:GetPropertyChangedSignal("Velocity"):Connect(function()
            if humanoidRootPart.Velocity.Magnitude > SPEED_LIMIT then
                logAndHandleCheat(player, "Speed hacking")
            end
        end)

        humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
            if humanoid.JumpPower > JUMP_HEIGHT_LIMIT then
                logAndHandleCheat(player, "Jump power hacking")
            end
        end)
        
        humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if humanoid.Health > humanoid.MaxHealth then
                logAndHandleCheat(player, "Health manipulation detected")
            end
        end)
    end
end

-- Anti-Trigger for preventing excessive event triggering
local function monitorTriggers(player)
    local triggerCount = 0
    local resetTriggers = function()
        triggerCount = 0
    end

    player.DamageEvent.OnServerEvent:Connect(function()
        triggerCount = triggerCount + 1
        if triggerCount > TRIGGER_THRESHOLD then
            logAndHandleCheat(player, "Excessive event triggering detected (possible exploit)")
        end
    end)

    spawn(function()
        while true do
            wait(1)
            resetTriggers()
        end
    end)
end

-- Function to monitor unauthorized teleportation
local function monitorTeleportation(player)
    local character = player.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local lastPosition = humanoidRootPart.Position

        humanoidRootPart:GetPropertyChangedSignal("Position"):Connect(function()
            local currentPosition = humanoidRootPart.Position
            local distance = (currentPosition - lastPosition).Magnitude

            if distance > TELEPORT_DISTANCE then
                logAndHandleCheat(player, "Teleport hacking detected")
            end
            lastPosition = currentPosition
        end)
    end
end

-- Function to check if gravity is altered
local function monitorGravity()
    Workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
        if Workspace.Gravity ~= GRAVITY then
            Workspace.Gravity = GRAVITY -- Reset gravity to default
            warn("Anti-Cheat: Gravity manipulation detected. Resetting gravity.")
        end
    end)
end

monitorGravity()

-- ================================
--        Player Monitoring
-- ================================

-- Main player monitoring function
Players.PlayerAdded:Connect(function(player)
    local isBanned, banReason = isPlayerBanned(player)
    if isBanned then
        player:Kick("You are banned from this game. Reason: " .. banReason)
        return
    end

    monitorHeartbeat(player)

    player.CharacterAdded:Connect(function(character)
        monitorCharacter(player)
        monitorTeleportation(player)
    end)

    monitorTriggers(player)

    player.DamageEvent.OnServerEvent:Connect(function(_, damageAmount)
        if damageAmount > DAMAGE_THRESHOLD then
            logAndHandleCheat(player, "Unauthorized damage detected")
        end
    end)
end)

-- End of VANITY-ANTICHEAT created by Luvmadison
