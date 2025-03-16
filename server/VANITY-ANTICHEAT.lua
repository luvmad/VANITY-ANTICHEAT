-- [[ VANITY-ANTICHEAT V2.5 ENHANCED SECURITY created by Luvmadison ]]
-- This script is strictly non-editable.
-- Any attempt to circumvent or modify this script may lead to sanctions.

local CONFIG = require(script.Parent:WaitForChild("VANITY-ANTICHEAT-CONFIG"))
local NetworkOptimizer = require(script.Parent:WaitForChild("VANITY-ANTICHEAT-NETWORK-OPTIMISER"))

local ANTI_CHEAT_NAME = "VANITY-ANTICHEAT"
local ANTI_CHEAT_AUTHOR = "Luvmadison"
local CURRENT_VERSION = "2.5"

-- Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local MemoryStoreService = game:GetService("MemoryStoreService")

-- DataStores avec redondance
local function getDataStore(name)
    local success, store = pcall(function()
        return DataStoreService:GetDataStore(name)
    end)
    if not success then
        warn("DataStore access failed for " .. name .. ". Using backup store.")
        return DataStoreService:GetDataStore(name .. "_backup")
    end
    return store
end

local bannedPlayersStore = getDataStore("BannedPlayers")
local reputationStore = getDataStore("PlayerReputation")
local violationStore = getDataStore("ViolationHistory")

-- MemoryStore pour la détection en temps réel
local realtimeViolations = MemoryStoreService:GetSortedMap("RealtimeViolations")
local exploitPatterns = MemoryStoreService:GetSortedMap("ExploitPatterns")

-- Statistiques avancées
local stats = {
    totalDetections = 0,
    activeMonitoring = 0,
    bannedPlayers = 0,
    suspendedPlayers = 0,
    totalViolations = 0,
    exploitAttempts = 0,
    falsePositives = 0,
    serverUptime = os.time(),
    lastOptimization = os.time(),
    detectionRates = {},
    serverLoad = 0
}

-- Système de détection amélioré
local detectionSystem = {
    patterns = {},
    knownExploits = {},
    suspiciousPatterns = {},
    behaviorHistory = {},
    recentActions = {},
    anomalyScores = {}
}

-- Seuils de violation avec adaptation dynamique
local violationTracking = {
    players = {},
    thresholds = {
        SPEED = {base = 3, multiplier = 1},
        TELEPORT = {base = 2, multiplier = 1},
        DAMAGE = {base = 3, multiplier = 1},
        HEALTH = {base = 2, multiplier = 1},
        TOOL = {base = 3, multiplier = 1},
        GRAVITY = {base = 1, multiplier = 1},
        ANIMATION = {base = 2, multiplier = 1},
        COLLISION = {base = 2, multiplier = 1},
        REMOTE_SPAM = {base = 4, multiplier = 1},
        PHYSICS = {base = 2, multiplier = 1}
    }
}

-- Système de vérification d'intégrité
local function verifyScriptIntegrity()
    local scriptHash = HttpService:GenerateGUID(false)
    local expectedHash = "YOUR_EXPECTED_HASH" -- À remplacer par le hash réel
    
    if scriptHash ~= expectedHash then
        warn("CRITICAL: Script integrity compromised!")
        -- Notification aux administrateurs
        alertAdmins("CRITICAL: Anti-cheat integrity compromised!", "CRITICAL")
    end
end

-- Initialisation améliorée du suivi des violations
local function initializeViolationTracking(player)
    local playerData = {
        violations = {},
        warnings = 0,
        lastViolation = 0,
        monitoringLevel = 1,
        anomalyScore = 0,
        recentActions = {},
        behaviorPattern = {},
        suspiciousActivities = {},
        lastPositions = {},
        lastVelocities = {},
        healthHistory = {},
        toolUseHistory = {},
        remoteCallHistory = {},
        physicsStates = {}
    }
    
    violationTracking.players[player.UserId] = playerData
    detectionSystem.behaviorHistory[player.UserId] = {}
    detectionSystem.recentActions[player.UserId] = {}
    detectionSystem.anomalyScores[player.UserId] = 0
end

-- Système de détection d'anomalies amélioré
local function updateAnomalyScore(player, actionType, value)
    local playerData = violationTracking.players[player.UserId]
    if not playerData then return end
    
    local baseScore = 0
    local multiplier = 1
    
    -- Calcul du score d'anomalie basé sur différents facteurs
    if actionType == "SPEED" then
        baseScore = value > CONFIG.SPEED_LIMIT and (value / CONFIG.SPEED_LIMIT) or 0
    elseif actionType == "TELEPORT" then
        baseScore = value > CONFIG.MAX_TELEPORT_DISTANCE and (value / CONFIG.MAX_TELEPORT_DISTANCE) or 0
    elseif actionType == "DAMAGE" then
        baseScore = value > CONFIG.MAX_DAMAGE_PER_SECOND and (value / CONFIG.MAX_DAMAGE_PER_SECOND) or 0
    end
    
    -- Ajustement du multiplicateur basé sur l'historique
    if #playerData.violations > 0 then
        multiplier = multiplier + (#playerData.violations * 0.1)
    end
    
    -- Mise à jour du score d'anomalie
    playerData.anomalyScore = playerData.anomalyScore + (baseScore * multiplier)
    
    -- Décroissance naturelle du score
    playerData.anomalyScore = math.max(0, playerData.anomalyScore - 0.1)
    
    -- Vérification du seuil d'anomalie
    if playerData.anomalyScore > CONFIG.ANOMALY_THRESHOLD then
        handleAnomalyDetection(player)
    end
end

-- Gestion des anomalies détectées
local function handleAnomalyDetection(player)
    local playerData = violationTracking.players[player.UserId]
    
    -- Enregistrement de l'anomalie
    table.insert(playerData.suspiciousActivities, {
        timestamp = os.time(),
        score = playerData.anomalyScore,
        type = "ANOMALY"
    })
    
    -- Notification aux administrateurs
    alertAdmins(string.format(
        "Anomalie détectée pour %s (Score: %.2f)",
        player.Name,
        playerData.anomalyScore
    ), "WARNING")
    
    -- Actions basées sur le score d'anomalie
    if playerData.anomalyScore > CONFIG.CRITICAL_ANOMALY_THRESHOLD then
        banPlayer(player, "Comportement hautement suspect détecté")
    elseif playerData.anomalyScore > CONFIG.WARNING_ANOMALY_THRESHOLD then
        warnPlayer(player, "Comportement suspect détecté")
    end
end

-- Système de surveillance en temps réel amélioré
local function monitorPlayer(player)
    local playerData = violationTracking.players[player.UserId]
    if not playerData then return end
    
    -- Ajustement dynamique de l'intervalle de surveillance
    local monitoringInterval = 1 / (playerData.monitoringLevel + playerData.anomalyScore/10)
    
    if player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and humanoidRootPart then
            -- Vérification de la vitesse avec prédiction de mouvement
            local currentVelocity = humanoidRootPart.Velocity
            table.insert(playerData.lastVelocities, currentVelocity)
            if #playerData.lastVelocities > 10 then
                table.remove(playerData.lastVelocities, 1)
            end
            
            -- Détection d'accélération anormale
            local acceleration = (currentVelocity - (playerData.lastVelocities[1] or Vector3.new())).magnitude
            if acceleration > CONFIG.MAX_ACCELERATION then
                recordViolation(player, "SPEED", {
                    acceleration = acceleration,
                    velocity = currentVelocity.magnitude,
                    position = humanoidRootPart.Position
                })
            end
            
            -- Vérification de la santé avec historique
            local currentHealth = humanoid.Health
            table.insert(playerData.healthHistory, {
                health = currentHealth,
                timestamp = os.time()
            })
            if #playerData.healthHistory > 20 then
                table.remove(playerData.healthHistory, 1)
            end
            
            -- Détection de régénération de santé suspecte
            local healthChange = currentHealth - (playerData.healthHistory[1] and playerData.healthHistory[1].health or currentHealth)
            if healthChange > CONFIG.MAX_HEALTH_REGEN_RATE then
                recordViolation(player, "HEALTH", {
                    healthChange = healthChange,
                    timeFrame = os.time() - (playerData.healthHistory[1] and playerData.healthHistory[1].timestamp or os.time())
                })
            end
            
            -- Vérification des outils avec analyse comportementale
            for _, tool in ipairs(player.Character:GetChildren()) do
                if tool:IsA("Tool") then
                    local handle = tool:FindFirstChild("Handle")
                    if handle then
                        local toolDistance = (handle.Position - humanoidRootPart.Position).magnitude
                        table.insert(playerData.toolUseHistory, {
                            tool = tool.Name,
                            distance = toolDistance,
                            timestamp = os.time()
                        })
                        
                        -- Nettoyage de l'historique ancien
                        while #playerData.toolUseHistory > 50 do
                            table.remove(playerData.toolUseHistory, 1)
                        end
                        
                        -- Analyse des patterns d'utilisation d'outils
                        analyzeToolUsagePatterns(player, tool)
                    end
                end
            end
        end
    end
end

-- Système de réputation amélioré
local function updateReputation(player, change)
    pcall(function()
        local currentReputation = reputationStore:GetAsync(player.UserId) or 0
        local newReputation = math.clamp(
            currentReputation + change,
            CONFIG.REPUTATION_MIN,
            CONFIG.REPUTATION_MAX
        )
        
        -- Facteurs d'ajustement de réputation
        local timeFactor = math.min(1, (os.time() - stats.serverUptime) / (24 * 3600))
        local violationFactor = #violationTracking.players[player.UserId].violations
        local anomalyFactor = detectionSystem.anomalyScores[player.UserId]
        
        -- Ajustement final de la réputation
        newReputation = newReputation * (1 - (violationFactor * 0.1)) * (1 - (anomalyFactor * 0.05))
        
        reputationStore:SetAsync(player.UserId, newReputation)
        
        -- Mise à jour du niveau de surveillance
        local playerData = violationTracking.players[player.UserId]
        if playerData then
            if newReputation > 75 then
                playerData.monitoringLevel = 1
            elseif newReputation > 25 then
                playerData.monitoringLevel = 2
            else
                playerData.monitoringLevel = 3
            end
        end
    end)
end

-- Système de bannissement amélioré
local function banPlayer(player, reason)
    local banData = {
        userId = player.UserId,
        username = player.Name,
        reason = reason,
        bannedAt = os.time(),
        banDuration = CONFIG.BAN_DURATION,
        violations = violationTracking.players[player.UserId].violations,
        anomalyScore = detectionSystem.anomalyScores[player.UserId],
        deviceInfo = {
            platform = player.DeviceType,
            id = player.DeviceId
        }
    }
    
    -- Stockage redondant des données de bannissement
    pcall(function()
        bannedPlayersStore:SetAsync(player.UserId, banData)
        -- Backup dans un second DataStore
        DataStoreService:GetDataStore("BannedPlayers_Backup"):SetAsync(player.UserId, banData)
        
        stats.bannedPlayers = stats.bannedPlayers + 1
        
        -- Notification aux administrateurs avec détails
        alertAdmins(string.format(
            "BANNISSEMENT: %s\nRaison: %s\nScore d'anomalie: %.2f\nViolations totales: %d",
            player.Name,
            reason,
            detectionSystem.anomalyScores[player.UserId],
            #violationTracking.players[player.UserId].violations
        ), "CRITICAL")
        
        -- Envoi des données à Discord si configuré
        if CONFIG.DISCORD_WEBHOOK_URL ~= "" then
            sendToDiscord(player, "BAN", banData)
        end
        
        -- Bannissement du joueur avec message détaillé
        player:Kick(string.format(
            [[Vous avez été banni.
            Raison: %s
            Durée: %d jours
            Délai d'appel: %d jours
            ID de bannissement: %s]],
            reason,
            CONFIG.BAN_DURATION / 86400,
            CONFIG.BAN_APPEAL_COOLDOWN / 86400,
            HttpService:GenerateGUID(false)
        ))
    end)
end

-- Gestionnaire de connexion des joueurs amélioré
Players.PlayerAdded:Connect(function(player)
    -- Vérification multi-niveaux du bannissement
    local banData = bannedPlayersStore:GetAsync(player.UserId)
    local backupBanData = DataStoreService:GetDataStore("BannedPlayers_Backup"):GetAsync(player.UserId)
    
    if banData or backupBanData then
        local activeBan = banData or backupBanData
        local timeRemaining = (activeBan.bannedAt + activeBan.banDuration) - os.time()
        
        if timeRemaining > 0 then
            player:Kick(string.format(
                [[Bannissement actif:
                Temps restant: %d jours
                Raison: %s
                ID de bannissement: %s]],
                timeRemaining / 86400,
                activeBan.reason,
                activeBan.banId or "N/A"
            ))
            return
        else
            -- Nettoyage des données de bannissement expirées
            pcall(function()
                bannedPlayersStore:RemoveAsync(player.UserId)
                DataStoreService:GetDataStore("BannedPlayers_Backup"):RemoveAsync(player.UserId)
            end)
        end
    end
    
    -- Initialisation du suivi
    initializeViolationTracking(player)
    stats.activeMonitoring = stats.activeMonitoring + 1
    
    -- Configuration du suivi du personnage
    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("Humanoid")
        character:WaitForChild("HumanoidRootPart")
        
        -- Surveillance continue
        RunService.Heartbeat:Connect(function()
            if player and player.Parent then
                monitorPlayer(player)
                updateAnomalyScore(player, "PERIODIC", 0)
            end
        end)
    end)
end)

-- Nettoyage des données lors du départ d'un joueur
Players.PlayerRemoving:Connect(function(player)
    local playerData = violationTracking.players[player.UserId]
    if playerData then
        -- Sauvegarde des données importantes
        pcall(function()
            violationStore:SetAsync(player.UserId .. "_" .. os.time(), {
                violations = playerData.violations,
                anomalyScore = detectionSystem.anomalyScores[player.UserId],
                lastSeen = os.time()
            })
        end)
    end
    
    -- Nettoyage des données en mémoire
    violationTracking.players[player.UserId] = nil
    detectionSystem.behaviorHistory[player.UserId] = nil
    detectionSystem.recentActions[player.UserId] = nil
    detectionSystem.anomalyScores[player.UserId] = nil
    stats.activeMonitoring = stats.activeMonitoring - 1
end)

-- Interface d'administration sécurisée
return {
    getStats = function()
        return {
            totalDetections = stats.totalDetections,
            activeMonitoring = stats.activeMonitoring,
            bannedPlayers = stats.bannedPlayers,
            suspendedPlayers = stats.suspendedPlayers,
            totalViolations = stats.totalViolations,
            exploitAttempts = stats.exploitAttempts,
            falsePositives = stats.falsePositives,
            serverUptime = os.time() - stats.serverUptime,
            detectionRates = stats.detectionRates,
            serverLoad = stats.serverLoad
        }
    end,
    getPlayerViolations = function(userId)
        return violationTracking.players[userId] and violationTracking.players[userId].violations or {}
    end,
    getAnomalyScore = function(userId)
        return detectionSystem.anomalyScores[userId] or 0
    end,
    banPlayer = banPlayer,
    getNetworkStats = NetworkOptimizer.getNetworkStats,
    verifyIntegrity = verifyScriptIntegrity
}
