-- [[ VANITY-ANTICHEAT BEHAVIOR ANALYZER V2.5 ROBLOX ENHANCED ]]
-- Module d'analyse comportementale avancée

local CONFIG = require(script.Parent:WaitForChild("VANITY-ANTICHEAT-CONFIG"))
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local BehaviorAnalyzer = {}

-- Behavior data
local behaviorData = {
    playerPatterns = {},
    movementHistory = {},
    actionSequences = {},
    anomalyScores = {},
    recentBehaviors = {}
}

-- Analysis parameters
local ANALYSIS_PARAMS = {
    MOVEMENT_SAMPLE_RATE = 0.1,
    PATTERN_WINDOW_SIZE = 50,
    ANOMALY_THRESHOLD = 0.75,
    SEQUENCE_MAX_LENGTH = 100,
    DECAY_RATE = 0.05
}

-- Initialisation du suivi comportemental
function BehaviorAnalyzer.initializePlayer(player)
    behaviorData.playerPatterns[player.UserId] = {
        movements = {},
        actions = {},
        combatPatterns = {},
        toolUsage = {},
        lastUpdate = os.time(),
        anomalyScore = 0
    }
end

-- Analyse des mouvements
function BehaviorAnalyzer.analyzeMovement(player, position, velocity)
    local playerData = behaviorData.playerPatterns[player.UserId]
    if not playerData then return end
    
    -- Enregistrement du mouvement
    table.insert(playerData.movements, {
        position = position,
        velocity = velocity,
        timestamp = os.time()
    })
    
    -- Limiter la taille de l'historique
    while #playerData.movements > ANALYSIS_PARAMS.PATTERN_WINDOW_SIZE do
        table.remove(playerData.movements, 1)
    end
    
    -- Analyse des patterns de mouvement
    local anomalyScore = 0
    local lastMovements = playerData.movements
    
    -- Vérification des accélérations impossibles
    for i = 2, #lastMovements do
        local timeDiff = lastMovements[i].timestamp - lastMovements[i-1].timestamp
        if timeDiff > 0 then
            local acceleration = (lastMovements[i].velocity - lastMovements[i-1].velocity).magnitude / timeDiff
            if acceleration > CONFIG.MAX_ACCELERATION then
                anomalyScore = anomalyScore + (acceleration / CONFIG.MAX_ACCELERATION)
            end
        end
    end
    
    -- Mise à jour du score d'anomalie
    playerData.anomalyScore = playerData.anomalyScore * (1 - ANALYSIS_PARAMS.DECAY_RATE) + anomalyScore
    
    return playerData.anomalyScore
end

-- Analyse des actions
function BehaviorAnalyzer.analyzeAction(player, actionType, actionData)
    local playerData = behaviorData.playerPatterns[player.UserId]
    if not playerData then return end
    
    -- Enregistrement de l'action
    table.insert(playerData.actions, {
        type = actionType,
        data = actionData,
        timestamp = os.time()
    })
    
    -- Limiter la taille de l'historique
    while #playerData.actions > ANALYSIS_PARAMS.SEQUENCE_MAX_LENGTH do
        table.remove(playerData.actions, 1)
    end
    
    -- Analyse des séquences d'actions
    local anomalyScore = 0
    local actionSequence = {}
    
    -- Construction de la séquence d'actions
    for _, action in ipairs(playerData.actions) do
        table.insert(actionSequence, action.type)
    end
    
    -- Détection de patterns suspects
    local suspiciousPatterns = {
        {"JUMP", "JUMP", "JUMP", "JUMP"}, -- Sauts multiples rapides
        {"ATTACK", "ATTACK", "ATTACK", "ATTACK"}, -- Attaques rapides
        {"TOOL_SWITCH", "ATTACK", "TOOL_SWITCH", "ATTACK"} -- Switch d'armes rapide
    }
    
    -- Vérification des patterns
    for _, pattern in ipairs(suspiciousPatterns) do
        local matches = 0
        for i = 1, #actionSequence - #pattern + 1 do
            local match = true
            for j = 1, #pattern do
                if actionSequence[i + j - 1] ~= pattern[j] then
                    match = false
                    break
                end
            end
            if match then
                matches = matches + 1
            end
        end
        anomalyScore = anomalyScore + (matches * 0.5)
    end
    
    -- Mise à jour du score d'anomalie
    playerData.anomalyScore = playerData.anomalyScore * (1 - ANALYSIS_PARAMS.DECAY_RATE) + anomalyScore
    
    return playerData.anomalyScore
end

-- Analyse des combats
function BehaviorAnalyzer.analyzeCombat(player, target, damage, distance)
    local playerData = behaviorData.playerPatterns[player.UserId]
    if not playerData then return end
    
    -- Enregistrement du combat
    table.insert(playerData.combatPatterns, {
        target = target,
        damage = damage,
        distance = distance,
        timestamp = os.time()
    })
    
    -- Limiter la taille de l'historique
    while #playerData.combatPatterns > ANALYSIS_PARAMS.PATTERN_WINDOW_SIZE do
        table.remove(playerData.combatPatterns, 1)
    end
    
    -- Analyse des patterns de combat
    local anomalyScore = 0
    
    -- Vérification de la distance d'attaque
    if distance > CONFIG.MAX_DAMAGE_DISTANCE then
        anomalyScore = anomalyScore + (distance / CONFIG.MAX_DAMAGE_DISTANCE)
    end
    
    -- Vérification des dégâts
    if damage > CONFIG.MAX_DAMAGE_PER_SECOND then
        anomalyScore = anomalyScore + (damage / CONFIG.MAX_DAMAGE_PER_SECOND)
    end
    
    -- Analyse de la précision
    local hits = 0
    local attempts = 0
    for _, combat in ipairs(playerData.combatPatterns) do
        if combat.damage > 0 then
            hits = hits + 1
        end
        attempts = attempts + 1
    end
    
    local accuracy = hits / attempts
    if accuracy > 0.95 then -- Précision suspecte
        anomalyScore = anomalyScore + (accuracy * 2)
    end
    
    -- Mise à jour du score d'anomalie
    playerData.anomalyScore = playerData.anomalyScore * (1 - ANALYSIS_PARAMS.DECAY_RATE) + anomalyScore
    
    return playerData.anomalyScore
end

-- Analyse de l'utilisation des outils
function BehaviorAnalyzer.analyzeToolUsage(player, tool, action)
    local playerData = behaviorData.playerPatterns[player.UserId]
    if not playerData then return end
    
    -- Enregistrement de l'utilisation d'outil
    table.insert(playerData.toolUsage, {
        tool = tool,
        action = action,
        timestamp = os.time()
    })
    
    -- Limiter la taille de l'historique
    while #playerData.toolUsage > ANALYSIS_PARAMS.PATTERN_WINDOW_SIZE do
        table.remove(playerData.toolUsage, 1)
    end
    
    -- Analyse des patterns d'utilisation d'outils
    local anomalyScore = 0
    local toolActions = playerData.toolUsage
    
    -- Vérification de la fréquence d'utilisation
    local actionCounts = {}
    for _, usage in ipairs(toolActions) do
        actionCounts[usage.action] = (actionCounts[usage.action] or 0) + 1
    end
    
    -- Détection d'utilisation excessive
    for action, count in pairs(actionCounts) do
        if count > CONFIG.MAX_TOOL_ACTIONS_PER_SECOND * ANALYSIS_PARAMS.PATTERN_WINDOW_SIZE then
            anomalyScore = anomalyScore + (count / (CONFIG.MAX_TOOL_ACTIONS_PER_SECOND * ANALYSIS_PARAMS.PATTERN_WINDOW_SIZE))
        end
    end
    
    -- Mise à jour du score d'anomalie
    playerData.anomalyScore = playerData.anomalyScore * (1 - ANALYSIS_PARAMS.DECAY_RATE) + anomalyScore
    
    return playerData.anomalyScore
end

-- Obtenir le score d'anomalie
function BehaviorAnalyzer.getAnomalyScore(player)
    local playerData = behaviorData.playerPatterns[player.UserId]
    return playerData and playerData.anomalyScore or 0
end

-- Nettoyage des données
function BehaviorAnalyzer.cleanup(player)
    behaviorData.playerPatterns[player.UserId] = nil
end

-- Surveillance continue
RunService.Heartbeat:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                BehaviorAnalyzer.analyzeMovement(
                    player,
                    humanoidRootPart.Position,
                    humanoidRootPart.Velocity
                )
            end
        end
    end
end)

return BehaviorAnalyzer 