-- [[ VANITY-ANTICHEAT created by Luvmadison ]]
-- This script is strictly non-editable.
-- Any attempt to circumvent or modify this script may lead to sanctions.

local CONFIG = require(script.Parent:WaitForChild("VANITY-ANTICHEAT-CONFIG")) -- Load configuration

local ANTI_CHEAT_NAME = "VANITY-ANTICHEAT"
local ANTI_CHEAT_AUTHOR = "Luvmadison"
local CURRENT_VERSION = "1.0"  -- Current version of the script
local REPO_URL = "https://api.github.com/repos/CassouBrxn/VANITY-ANTICHEAT/releases/latest"  -- Replace with your repository URL

print(ANTI_CHEAT_NAME .. " by " .. ANTI_CHEAT_AUTHOR .. " initialized")

-- ================================
--         Configuration
-- ================================

local DISCORD_WEBHOOK_URL = CONFIG.DISCORD_WEBHOOK_URL
local SPEED_LIMIT = CONFIG.SPEED_LIMIT
local DAMAGE_THRESHOLD = CONFIG.DAMAGE_THRESHOLD
local TELEPORT_DISTANCE = CONFIG.TELEPORT_DISTANCE
local JUMP_HEIGHT_LIMIT = CONFIG.JUMP_HEIGHT_LIMIT
local GRAVITY = CONFIG.GRAVITY
local HEARTBEAT_INTERVAL = CONFIG.HEARTBEAT_INTERVAL
local TRIGGER_THRESHOLD = CONFIG.TRIGGER_THRESHOLD
local BAN_DURATION = CONFIG.BAN_DURATION
local REPUTATION_MAX = CONFIG.REPUTATION_MAX
local REPUTATION_MIN = CONFIG.REPUTATION_MIN

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

-- Function to log events to a file
local function logToFile(message)
    local logFile = Instance.new("File", game.ServerStorage) -- Create a file in ServerStorage
    logFile.Name = "AntiCheatLog.txt"
    local logData = os.date("%Y-%m-%d %H:%M:%S") .. " - " .. message .. "\n"
    logFile:Write(logData) -- Write the message to the file
end

-- Generate a pseudo "HWID" based on available data
local function generateHWID(player)
    return tostring(player.UserId) .. "_" .. tostring(player.AccountAge)
end

-- Function to alert administrators
local function alertAdmins(message)
    local adminUserIds = {12345678, 87654321} -- Replace with the UserIds of the administrators
    for _, adminId in ipairs(adminUserIds) do
        local admin = Players:GetPlayerByUserId(adminId)
        if admin then
            sendToDiscord(admin, message) -- Send a message to the administrator
            -- Send a real-time notification
            notificationEvent:FireClient(admin, message)
        end
    end
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
    local success, response = pcall(function()
        HttpService:PostAsync(DISCORD_WEBHOOK_URL, jsonData, Enum.HttpContentType.ApplicationJson)
    end)

    if not success then
        logEvent("Failed to send log to Discord: " .. tostring(response))  -- Log the error
    end
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
--        Reputation System
-- ================================

local reputationStore = game:GetService("DataStoreService"):GetDataStore("PlayerReputation")

-- Function to get a player's reputation
local function getReputation(player)
    local success, reputation = pcall(function()
        return reputationStore:GetAsync("Player_" .. player.UserId)
    end)
    return success and reputation or 0 -- Default value if no reputation is found
end

-- Function to update a player's reputation
local function updateReputation(player, change)
    local currentReputation = getReputation(player)
    local newReputation = math.clamp(currentReputation + change, REPUTATION_MIN, REPUTATION_MAX) -- Limit reputation

    local success, errorMessage = pcall(function()
        reputationStore:SetAsync("Player_" .. player.UserId, newReputation)
    end)

    if not success then
        logEvent("Failed to update reputation for player " .. player.Name .. ": " .. errorMessage)
    end
end

-- ================================
--        Temporary Ban System
-- ================================

local function temporaryBanPlayer(player, reason, duration)
    local banData = {
        reason = reason,
        bannedAt = os.time(),
        banDuration = duration
    }

    -- Register the temporary ban in the DataStore
    bannedPlayersStore:SetAsync("TempBan_" .. player.UserId, banData)

    -- Ban the player
    player:Kick("You have been temporarily banned for: " .. reason .. ". Duration: " .. duration .. " seconds.")

    -- Reinstate the player after the ban duration
    wait(duration)
    bannedPlayersStore:RemoveAsync("TempBan_" .. player.UserId) -- Remove the ban after the duration
end

-- ================================
--        Cheating Detection
-- ================================

-- Logs and bans player on repeated offenses
local function logAndHandleCheat(player, reason)
    local message = "Player " .. player.Name .. " detected for: " .. reason
    logEvent(message)  -- Log the event
    logToFile(message)  -- Log to the file
    sendToDiscord(player, reason)
    alertAdmins("Suspicious activity detected from player: " .. player.Name .. " for reason: " .. reason) -- Alert admins

    -- Apply a temporary ban for minor infractions
    if reason == "Unauthorized damage detected" then
        temporaryBanPlayer(player, reason, 60) -- Ban for 60 seconds
    else
        banPlayer(player, reason) -- Permanent ban for serious infractions
    end
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
    workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
        if workspace.Gravity ~= GRAVITY then
            workspace.Gravity = GRAVITY -- Reset gravity to default
            warn("Anti-Cheat: Gravity manipulation detected. Resetting gravity.")
        end
    end)
end

monitorGravity()

-- ================================
--        External Script Detection
-- ================================

local function detectExternalScripts(player)
    local character = player.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

        -- Vérification de la vitesse du joueur
        humanoidRootPart:GetPropertyChangedSignal("Velocity"):Connect(function()
            if humanoidRootPart.Velocity.Magnitude > SPEED_LIMIT then
                logAndHandleCheat(player, "Speed hacking detected (external script suspected)")
            end
        end)

        -- Vérification de la position du joueur
        humanoidRootPart:GetPropertyChangedSignal("Position"):Connect(function()
            local currentPosition = humanoidRootPart.Position
            -- Implémentez une logique pour vérifier si la position est anormale
            if currentPosition.Y > 1000 then -- Exemple de vérification
                logAndHandleCheat(player, "Unusual position detected (external script suspected)")
            end
        end)

        -- Vérification des RemoteEvents
        player.DamageEvent.OnServerEvent:Connect(function()
            logEvent("RemoteEvent called by player: " .. player.Name)
        end)
    end
end

-- ================================
--        Player Monitoring
-- ================================

Players.PlayerAdded:Connect(function(player)
    logEvent("Player " .. player.Name .. " has joined the game.")  -- Connection notification
    local isBanned, banReason = isPlayerBanned(player)
    if isBanned then
        player:Kick("You are banned from this game. Reason: " .. banReason)
        return
    end

    monitorHeartbeat(player)
    monitorPlayerActions(player)  -- Monitor player actions
    detectExternalScripts(player)  -- Detect external scripts

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

-- ================================
--        Admin Commands
-- ================================

local function banPlayerByAdmin(admin, playerName, reason)
    local player = Players:FindFirstChild(playerName)
    if player then
        banPlayer(player, reason)
        logEvent("Admin " .. admin.Name .. " has banned player: " .. player.Name .. " for reason: " .. reason)
    else
        logEvent("Player " .. playerName .. " not found for admin " .. admin.Name)
    end
end

local function unbanPlayerByAdmin(admin, playerName)
    logEvent("Admin " .. admin.Name .. " has unbanned player: " .. playerName)
end

-- ================================
--        Player Action Logging
-- ================================

-- Function to log player actions
local function logPlayerAction(player, action)
    local message = "Player " .. player.Name .. " performed action: " .. action
    logEvent(message)  -- Log to console
    logToFile(message)  -- Log to file
end

-- Example of logging movements
local function monitorPlayerActions(player)
    local character = player.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

        humanoidRootPart:GetPropertyChangedSignal("Position"):Connect(function()
            logPlayerAction(player, "Moved to position: " .. tostring(humanoidRootPart.Position))
        end)

        humanoidRootPart:GetPropertyChangedSignal("Velocity"):Connect(function()
            logPlayerAction(player, "Velocity changed to: " .. tostring(humanoidRootPart.Velocity))
        end)

        -- Add other events to monitor here
    end
end

-- ================================
--        Data Integrity Check
-- ================================

-- Function to check player data integrity
local function checkDataIntegrity(player)
    logEvent("Checking data integrity for player: " .. player.Name)
    -- Implement specific checks here
end

-- Create RemoteEvent for notifications
local notificationEvent = Instance.new("RemoteEvent")
notificationEvent.Name = "AdminNotification"
notificationEvent.Parent = ReplicatedStorage

-- ================================
--        Advanced Moderation Commands
-- ================================

local function monitorPlayer(admin, playerName)
    local player = Players:FindFirstChild(playerName)
    if player then
        logEvent("Admin " .. admin.Name .. " is monitoring player: " .. player.Name)
    else
        logEvent("Player " .. playerName .. " not found for admin " .. admin.Name)
    end
end

local function suspendPlayer(admin, playerName, duration)
    local player = Players:FindFirstChild(playerName)
    if player then
        logEvent("Admin " .. admin.Name .. " has suspended player: " .. player.Name .. " for " .. duration .. " seconds.")
        player:Kick("You have been temporarily suspended by an admin for " .. duration .. " seconds.")
        wait(duration) -- Wait for the duration of the suspension
    else
        logEvent("Player " .. playerName .. " not found for admin " .. admin.Name)
    end
end

-- End of VANITY-ANTICHEAT created by Luvmadison
