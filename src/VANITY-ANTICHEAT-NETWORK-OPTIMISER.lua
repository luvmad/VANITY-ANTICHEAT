-- [[ NETWORK OPTIMIZATION SCRIPT FOR VANITY-ANTICHEAT V2.5 ROBLOX ENHANCED ]]
-- This script optimizes communication between server and client scripts

local CONFIG = require(script.Parent:WaitForChild("VANITY-ANTICHEAT-CONFIG")) -- Load configuration

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local PhysicsService = game:GetService("PhysicsService")

-- Network Statistics
local networkStats = {
    totalRequests = 0,
    failedRequests = 0,
    averageLatency = 0,
    latencyHistory = {},
    bandwidthUsage = 0,
    lastOptimization = os.time(),
    exploitAttempts = 0,
    suspiciousActivities = {},
    blockedRemotes = {},
    rateLimitedPlayers = {}
}

-- Security Settings
local SECURITY = {
    MAX_PACKET_SIZE = 1024 * 100, -- 100KB
    MIN_REQUEST_INTERVAL = 0.1,    -- 100ms
    ENCRYPTION_KEY = HttpService:GenerateGUID(false),
    CHECKSUM_SALT = HttpService:GenerateGUID(false),
    REMOTE_TIMEOUT = 5,            -- 5 seconds
    MAX_ARGS_LENGTH = 1000,        -- Maximum length of remote arguments
    BANNED_STRINGS = {
        "require", "getfenv", "setfenv", "loadstring", "pcall",
        "spawn", "Instance.new", "game:GetService"
    }
}

-- Create RemoteEvents with security wrapper
local function createSecureRemoteEvent(name)
    local remote = Instance.new("RemoteEvent")
    remote.Name = name
    
    -- Add security attributes
    remote:SetAttribute("SecureChannel", true)
    remote:SetAttribute("CreatedAt", os.time())
    remote:SetAttribute("LastValidated", os.time())
    
    return remote
end

-- Create secure remote events
local remoteEvents = {
    request = createSecureRemoteEvent("Request"),
    response = createSecureRemoteEvent("Response"),
    notification = createSecureRemoteEvent("Notification"),
    heartbeat = createSecureRemoteEvent("Heartbeat"),
    sync = createSecureRemoteEvent("Sync")
}

-- Initialize RemoteEvents with security
for name, event in pairs(remoteEvents) do
    event.Parent = ReplicatedStorage
end

-- Enhanced encryption utilities
local function encrypt(data)
    if type(data) ~= "string" then
        data = HttpService:JSONEncode(data)
    end
    
    -- Simple XOR encryption (can be enhanced)
    local encrypted = ""
    for i = 1, #data do
        local byte = string.byte(data, i)
        local keyByte = string.byte(SECURITY.ENCRYPTION_KEY, (i % #SECURITY.ENCRYPTION_KEY) + 1)
        encrypted = encrypted .. string.char(bit32.bxor(byte, keyByte))
    end
    
    return encrypted
end

local function decrypt(data)
    if type(data) ~= "string" then return data end
    
    -- Decrypt XOR
    local decrypted = ""
    for i = 1, #data do
        local byte = string.byte(data, i)
        local keyByte = string.byte(SECURITY.ENCRYPTION_KEY, (i % #SECURITY.ENCRYPTION_KEY) + 1)
        decrypted = decrypted .. string.char(bit32.bxor(byte, keyByte))
    end
    
    -- Try to decode JSON
    local success, result = pcall(function()
        return HttpService:JSONDecode(decrypted)
    end)
    
    return success and result or decrypted
end

-- Enhanced security checks
local function validateRemoteRequest(player, requestType, data)
    -- Check for rate limiting
    if networkStats.rateLimitedPlayers[player.UserId] then
        local timeLeft = networkStats.rateLimitedPlayers[player.UserId] - os.time()
        if timeLeft > 0 then
            return false, "Rate limited for " .. timeLeft .. " seconds"
        else
            networkStats.rateLimitedPlayers[player.UserId] = nil
        end
    end
    
    -- Validate data size
    local dataSize = #HttpService:JSONEncode(data or {})
    if dataSize > SECURITY.MAX_PACKET_SIZE then
        networkStats.exploitAttempts = networkStats.exploitAttempts + 1
        return false, "Packet size exceeds limit"
    end
    
    -- Check for suspicious strings
    local dataString = HttpService:JSONEncode(data or {})
    for _, bannedString in ipairs(SECURITY.BANNED_STRINGS) do
        if string.find(dataString:lower(), bannedString:lower()) then
            networkStats.exploitAttempts = networkStats.exploitAttempts + 1
            return false, "Suspicious content detected"
        end
    end
    
    -- Validate request type
    if not remoteEvents[requestType:lower()] then
        return false, "Invalid request type"
    end
    
    return true
end

-- Enhanced rate limiting
local function isRateLimited(player)
    local now = os.time()
    rateLimiter.requests[player.UserId] = rateLimiter.requests[player.UserId] or {
        count = 0,
        firstRequest = now,
        warnings = 0,
        blocked = false
    }
    
    local playerData = rateLimiter.requests[player.UserId]
    
    -- Reset counter if window has passed
    if now - playerData.firstRequest >= CONFIG.RATE_LIMIT_WINDOW then
        playerData.count = 0
        playerData.firstRequest = now
    end
    
    -- Increment counter
    playerData.count = playerData.count + 1
    
    -- Check if rate limited
    if playerData.count > CONFIG.MAX_REMOTE_CALLS then
        playerData.warnings = playerData.warnings + 1
        
        -- Apply progressive rate limiting
        if playerData.warnings >= 3 then
            playerData.blocked = true
            networkStats.rateLimitedPlayers[player.UserId] = now + 300 -- 5 minutes block
            return true, "Excessive requests - blocked for 5 minutes"
        end
        
        return true, "Rate limit exceeded"
    end
    
    return false
end

-- Enhanced secure communication
local function handleSecureCommunication(player, requestType, data)
    -- Validate request
    local isValid, errorMessage = validateRemoteRequest(player, requestType, data)
    if not isValid then
        return false, errorMessage
    end
    
    -- Check rate limiting
    local isLimited, limitMessage = isRateLimited(player)
    if isLimited then
        return false, limitMessage
    end
    
    -- Process request
    local success, response = pcall(function()
        if requestType == "ping" then
            return {
                pong = true,
                timestamp = os.time(),
                serverTime = os.time(),
                ping = player:GetNetworkPing()
            }
        elseif requestType == "getPlayerData" then
            -- Validate and sanitize player data
            local character = player.Character
            local position = character and character:FindFirstChild("HumanoidRootPart") and
                           character.HumanoidRootPart.Position or Vector3.new(0, 0, 0)
            
            return {
                userId = player.UserId,
                name = player.Name,
                position = position,
                timestamp = os.time()
            }
        elseif requestType == "sync" then
            return {
                serverTime = os.time(),
                config = {
                    maxRequests = CONFIG.MAX_REMOTE_CALLS,
                    windowSize = CONFIG.RATE_LIMIT_WINDOW
                },
                stats = {
                    ping = player:GetNetworkPing(),
                    fps = Stats.HeartbeatTimeMs
                }
            }
        end
    end)
    
    if not success then
        networkStats.failedRequests = networkStats.failedRequests + 1
        return false, "Internal error"
    end
    
    return true, encrypt(response)
end

-- Event handlers with security
remoteEvents.request.OnServerEvent:Connect(function(player, requestType, data)
    local success, response = handleSecureCommunication(player, requestType, data)
    remoteEvents.response:FireClient(player, success, response)
end)

-- Enhanced heartbeat monitoring
remoteEvents.heartbeat.OnServerEvent:Connect(function(player)
    local now = os.time()
    local playerPing = player:GetNetworkPing()
    
    -- Monitor for suspicious network behavior
    if playerPing > 1 then -- High ping threshold
        networkStats.suspiciousActivities[player.UserId] = networkStats.suspiciousActivities[player.UserId] or {
            count = 0,
            firstDetection = now
        }
        
        local data = networkStats.suspiciousActivities[player.UserId]
        data.count = data.count + 1
        
        if data.count > 10 then -- Threshold for suspicious activity
            -- Log suspicious activity
            warn(string.format("Suspicious network activity detected for player %s (UserId: %d)", 
                player.Name, player.UserId))
        end
    end
end)

-- Network optimization with security
local function optimizeNetwork()
    if os.time() - networkStats.lastOptimization < 60 then return end
    
    -- Implement dynamic security measures
    local averageServerLoad = Stats.HeartbeatTimeMs
    if averageServerLoad > 50 then -- High server load
        CONFIG.MAX_REMOTE_CALLS = math.max(50, CONFIG.MAX_REMOTE_CALLS - 10)
    else
        CONFIG.MAX_REMOTE_CALLS = math.min(200, CONFIG.MAX_REMOTE_CALLS + 5)
    end
    
    -- Clean up old data
    for userId, data in pairs(networkStats.suspiciousActivities) do
        if os.time() - data.firstDetection > 3600 then -- 1 hour
            networkStats.suspiciousActivities[userId] = nil
        end
    end
    
    networkStats.lastOptimization = os.time()
end

-- Network monitoring
RunService.Heartbeat:Connect(function()
    updateBandwidthUsage()
    optimizeNetwork()
end)

-- Player cleanup with security
Players.PlayerRemoving:Connect(function(player)
    rateLimiter.requests[player.UserId] = nil
    networkStats.suspiciousActivities[player.UserId] = nil
    networkStats.rateLimitedPlayers[player.UserId] = nil
end)

-- Export secure interface
return {
    getNetworkStats = function()
        -- Return sanitized network stats
        return {
            totalRequests = networkStats.totalRequests,
            failedRequests = networkStats.failedRequests,
            averageLatency = networkStats.averageLatency,
            bandwidthUsage = networkStats.bandwidthUsage,
            activeConnections = #Players:GetPlayers(),
            maxRequestsPerSecond = CONFIG.MAX_REMOTE_CALLS,
            exploitAttempts = networkStats.exploitAttempts
        }
    end,
    remoteEvents = remoteEvents
}
