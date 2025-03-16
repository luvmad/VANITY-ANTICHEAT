-- [[ VANITY-ANTICHEAT COMBAT MONITOR V2.5 ROBLOX ENHANCED ]]
-- Module de surveillance des combats

local CONFIG = require(script.Parent:WaitForChild("VANITY-ANTICHEAT-CONFIG"))
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local CombatMonitor = {}

-- Combat parameters
local COMBAT_PARAMS = {
    HIT_DETECTION_RADIUS = 10,
    MAX_HITS_PER_SECOND = 5,
    DAMAGE_CHECK_INTERVAL = 0.1,
    COMBAT_LOG_DURATION = 300, -- 5 minutes
    MAX_DAMAGE_MULTIPLIER = 1.5,
    MIN_HIT_INTERVAL = 0.2,
    MAX_RANGE_MULTIPLIER = 1.2
}

-- État du combat
local combatState = {
    playerCombatLogs = {},
    weaponStats = {},
    damageHistory = {},
    hitDetection = {},
    combatPatterns = {},
    suspiciousActivities = {}
}

-- Initialisation du moniteur de combat
function CombatMonitor.initializePlayer(player)
    combatState.playerCombatLogs[player.UserId] = {
        hits = {},
        damage = {},
        kills = {},
        deaths = {},
        lastHit = 0,
        hitStreak = 0,
        accuracy = 0,
        totalShots = 0,
        successfulHits = 0,
        suspiciousHits = 0,
        lastPosition = Vector3.new(0, 0, 0),
        weaponUsage = {}
    }
end

-- Enregistrement des statistiques d'arme
function CombatMonitor.registerWeapon(weaponName, stats)
    combatState.weaponStats[weaponName] = {
        baseDamage = stats.damage or 10,
        range = stats.range or 10,
        fireRate = stats.fireRate or 1,
        accuracy = stats.accuracy or 1,
        criticalMultiplier = stats.criticalMultiplier or 1.5,
        projectileSpeed = stats.projectileSpeed or 100,
        lastUse = {}
    }
end

-- Validation des dégâts
function CombatMonitor.validateDamage(attacker, victim, weapon, damage)
    if not attacker or not victim then return false end
    
    local attackerLog = combatState.playerCombatLogs[attacker.UserId]
    if not attackerLog then return false end
    
    local weaponStats = combatState.weaponStats[weapon]
    if not weaponStats then return false end
    
    -- Vérification de l'intervalle entre les coups
    local now = os.time()
    local timeSinceLastHit = now - attackerLog.lastHit
    if timeSinceLastHit < COMBAT_PARAMS.MIN_HIT_INTERVAL then
        table.insert(combatState.suspiciousActivities, {
            type = "RAPID_FIRE",
            player = attacker,
            weapon = weapon,
            interval = timeSinceLastHit,
            timestamp = now
        })
        return false
    end
    
    -- Vérification de la distance
    local distance = (victim.Character.HumanoidRootPart.Position - attacker.Character.HumanoidRootPart.Position).Magnitude
    if distance > weaponStats.range * COMBAT_PARAMS.MAX_RANGE_MULTIPLIER then
        table.insert(combatState.suspiciousActivities, {
            type = "RANGE_HACK",
            player = attacker,
            weapon = weapon,
            distance = distance,
            maxRange = weaponStats.range * COMBAT_PARAMS.MAX_RANGE_MULTIPLIER,
            timestamp = now
        })
        return false
    end
    
    -- Vérification des dégâts
    local maxDamage = weaponStats.baseDamage * COMBAT_PARAMS.MAX_DAMAGE_MULTIPLIER
    if damage > maxDamage then
        table.insert(combatState.suspiciousActivities, {
            type = "DAMAGE_HACK",
            player = attacker,
            weapon = weapon,
            damage = damage,
            maxDamage = maxDamage,
            timestamp = now
        })
        return false
    end
    
    -- Mise à jour des statistiques
    attackerLog.lastHit = now
    attackerLog.hitStreak = attackerLog.hitStreak + 1
    attackerLog.successfulHits = attackerLog.successfulHits + 1
    attackerLog.accuracy = attackerLog.successfulHits / attackerLog.totalShots
    
    -- Enregistrement du coup
    table.insert(attackerLog.hits, {
        victim = victim,
        weapon = weapon,
        damage = damage,
        distance = distance,
        timestamp = now
    })
    
    -- Nettoyage des anciens logs
    while #attackerLog.hits > 100 do
        table.remove(attackerLog.hits, 1)
    end
    
    return true
end

-- Analyse des patterns de combat
function CombatMonitor.analyzeCombatPattern(player)
    local playerLog = combatState.playerCombatLogs[player.UserId]
    if not playerLog then return end
    
    -- Analyse de la précision
    if playerLog.accuracy > 0.95 and playerLog.totalShots > 50 then
        table.insert(combatState.suspiciousActivities, {
            type = "AIMBOT_SUSPECTED",
            player = player,
            accuracy = playerLog.accuracy,
            totalShots = playerLog.totalShots,
            timestamp = os.time()
        })
    end
    
    -- Analyse des séquences de coups
    local hitSequence = {}
    for _, hit in ipairs(playerLog.hits) do
        if os.time() - hit.timestamp < 10 then -- Dernières 10 secondes
            table.insert(hitSequence, {
                damage = hit.damage,
                distance = hit.distance,
                interval = hit.timestamp - (hitSequence[#hitSequence] and hitSequence[#hitSequence].timestamp or hit.timestamp)
            })
        end
    end
    
    -- Détection de patterns suspects
    if #hitSequence > 5 then
        local consistentDamage = true
        local consistentInterval = true
        local baseInterval = hitSequence[2].interval
        local baseDamage = hitSequence[1].damage
        
        for i = 2, #hitSequence do
            if math.abs(hitSequence[i].damage - baseDamage) > 0.1 then
                consistentDamage = false
            end
            if math.abs(hitSequence[i].interval - baseInterval) > 0.01 then
                consistentInterval = false
            end
        end
        
        if consistentDamage and consistentInterval then
            table.insert(combatState.suspiciousActivities, {
                type = "AUTOMATED_COMBAT",
                player = player,
                pattern = {
                    damage = baseDamage,
                    interval = baseInterval
                },
                timestamp = os.time()
            })
        end
    end
end

-- Validation des coups critiques
function CombatMonitor.validateCriticalHit(attacker, weapon, multiplier)
    local weaponStats = combatState.weaponStats[weapon]
    if not weaponStats then return false end
    
    if multiplier > weaponStats.criticalMultiplier then
        table.insert(combatState.suspiciousActivities, {
            type = "INVALID_CRITICAL",
            player = attacker,
            weapon = weapon,
            multiplier = multiplier,
            maxMultiplier = weaponStats.criticalMultiplier,
            timestamp = os.time()
        })
        return false
    end
    
    return true
end

-- Validation de la trajectoire des projectiles
function CombatMonitor.validateProjectile(attacker, startPos, endPos, weapon)
    local weaponStats = combatState.weaponStats[weapon]
    if not weaponStats then return false end
    
    -- Vérification de la distance
    local distance = (endPos - startPos).Magnitude
    if distance > weaponStats.range * COMBAT_PARAMS.MAX_RANGE_MULTIPLIER then
        table.insert(combatState.suspiciousActivities, {
            type = "INVALID_PROJECTILE",
            player = attacker,
            weapon = weapon,
            distance = distance,
            maxRange = weaponStats.range * COMBAT_PARAMS.MAX_RANGE_MULTIPLIER,
            timestamp = os.time()
        })
        return false
    end
    
    -- Vérification de la vitesse du projectile
    local expectedTime = distance / weaponStats.projectileSpeed
    local actualTime = os.time() - combatState.playerCombatLogs[attacker.UserId].lastHit
    
    if actualTime < expectedTime * 0.5 then
        table.insert(combatState.suspiciousActivities, {
            type = "PROJECTILE_SPEED_HACK",
            player = attacker,
            weapon = weapon,
            expectedTime = expectedTime,
            actualTime = actualTime,
            timestamp = os.time()
        })
        return false
    end
    
    return true
end

-- Obtenir les activités suspectes
function CombatMonitor.getSuspiciousActivities()
    return combatState.suspiciousActivities
end

-- Nettoyage des données
function CombatMonitor.cleanup(player)
    combatState.playerCombatLogs[player.UserId] = nil
end

-- Surveillance continue
RunService.Heartbeat:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if combatState.playerCombatLogs[player.UserId] then
            CombatMonitor.analyzeCombatPattern(player)
        end
    end
end)

return CombatMonitor 