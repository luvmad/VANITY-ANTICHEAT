-- [[ VANITY-ANTICHEAT PHYSICS VALIDATOR V2.5 ROBLOX ENHANCED ]]
-- Module de validation de la physique du jeu

local CONFIG = require(script.Parent:WaitForChild("VANITY-ANTICHEAT-CONFIG"))
local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local PhysicsValidator = {}

-- Paramètres de validation
local PHYSICS_PARAMS = {
    CHECK_INTERVAL = 0.1,
    GRAVITY_TOLERANCE = 0.1,
    VELOCITY_CAP = 500,
    MAX_PART_VELOCITY = 1000,
    MIN_PART_SIZE = 0.05,
    MAX_COLLISION_GROUPS = 32,
    PHYSICS_THROTTLE = 0.05
}

-- État de la physique
local physicsState = {
    originalGravity = Workspace.Gravity,
    collisionGroups = {},
    partProperties = {},
    playerStates = {},
    violations = {}
}

-- Initialisation de la validation
function PhysicsValidator.initialize()
    -- Sauvegarder l'état initial de la physique
    physicsState.originalGravity = Workspace.Gravity
    
    -- Configuration des groupes de collision
    for i = 1, PHYSICS_PARAMS.MAX_COLLISION_GROUPS do
        local success = pcall(function()
            PhysicsService:CreateCollisionGroup("Group" .. i)
        end)
        if success then
            physicsState.collisionGroups["Group" .. i] = true
        end
    end
    
    -- Configuration de la validation des parties
    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            physicsState.partProperties[part] = {
                originalSize = part.Size,
                originalMass = part:GetMass(),
                originalCFrame = part.CFrame
            }
        end
    end
end

-- Validation de la gravité
function PhysicsValidator.validateGravity()
    local currentGravity = Workspace.Gravity
    local gravityDiff = math.abs(currentGravity - physicsState.originalGravity)
    local normalizedDiff = gravityDiff / physicsState.originalGravity
    
    if normalizedDiff > PHYSICS_PARAMS.GRAVITY_TOLERANCE then
        table.insert(physicsState.violations, {
            type = "GRAVITY_MODIFICATION",
            value = currentGravity,
            expected = physicsState.originalGravity,
            timestamp = os.time()
        })
        
        -- Restaurer la gravité
        Workspace.Gravity = physicsState.originalGravity
        return false
    end
    
    return true
end

-- Validation de la vélocité des parties
function PhysicsValidator.validatePartVelocity(part)
    if not part:IsA("BasePart") then return true end
    
    local velocity = part.Velocity.Magnitude
    if velocity > PHYSICS_PARAMS.MAX_PART_VELOCITY then
        table.insert(physicsState.violations, {
            type = "EXCESSIVE_VELOCITY",
            part = part,
            velocity = velocity,
            timestamp = os.time()
        })
        
        -- Réduire la vélocité
        part.Velocity = part.Velocity.Unit * PHYSICS_PARAMS.MAX_PART_VELOCITY
        return false
    end
    
    return true
end

-- Validation de la taille des parties
function PhysicsValidator.validatePartSize(part)
    if not part:IsA("BasePart") then return true end
    
    local originalProps = physicsState.partProperties[part]
    if not originalProps then
        physicsState.partProperties[part] = {
            originalSize = part.Size,
            originalMass = part:GetMass(),
            originalCFrame = part.CFrame
        }
        return true
    end
    
    -- Vérifier les modifications de taille
    local sizeDiff = (part.Size - originalProps.originalSize).Magnitude
    if sizeDiff > PHYSICS_PARAMS.MIN_PART_SIZE then
        table.insert(physicsState.violations, {
            type = "SIZE_MODIFICATION",
            part = part,
            originalSize = originalProps.originalSize,
            currentSize = part.Size,
            timestamp = os.time()
        })
        
        -- Restaurer la taille
        part.Size = originalProps.originalSize
        return false
    end
    
    return true
end

-- Validation des collisions
function PhysicsValidator.validateCollisions(part)
    if not part:IsA("BasePart") then return true end
    
    -- Vérifier les groupes de collision
    local collisionGroupId = PhysicsService:GetCollisionGroupId(part)
    if collisionGroupId < 0 or collisionGroupId >= PHYSICS_PARAMS.MAX_COLLISION_GROUPS then
        table.insert(physicsState.violations, {
            type = "INVALID_COLLISION_GROUP",
            part = part,
            groupId = collisionGroupId,
            timestamp = os.time()
        })
        
        -- Réinitialiser le groupe de collision
        PhysicsService:SetPartCollisionGroup(part, "Default")
        return false
    end
    
    return true
end

-- Validation de l'état physique d'un joueur
function PhysicsValidator.validatePlayerPhysics(player)
    if not player.Character then return true end
    
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return true end
    
    -- Vérifier la vélocité du joueur
    local velocity = humanoidRootPart.Velocity.Magnitude
    if velocity > PHYSICS_PARAMS.VELOCITY_CAP then
        table.insert(physicsState.violations, {
            type = "PLAYER_SPEED_VIOLATION",
            player = player,
            velocity = velocity,
            timestamp = os.time()
        })
        
        -- Réduire la vélocité
        humanoidRootPart.Velocity = humanoidRootPart.Velocity.Unit * PHYSICS_PARAMS.VELOCITY_CAP
        return false
    end
    
    -- Vérifier l'état de la physique du personnage
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if humanoid then
        if humanoid.JumpPower > CONFIG.MAX_JUMP_POWER then
            humanoid.JumpPower = CONFIG.MAX_JUMP_POWER
        end
        
        if humanoid.WalkSpeed > CONFIG.MAX_WALK_SPEED then
            humanoid.WalkSpeed = CONFIG.MAX_WALK_SPEED
        end
    end
    
    return true
end

-- Validation globale de la physique
function PhysicsValidator.validateAll()
    local violations = {}
    
    -- Valider la gravité
    if not PhysicsValidator.validateGravity() then
        table.insert(violations, "Gravity Modification")
    end
    
    -- Valider toutes les parties
    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            if not PhysicsValidator.validatePartVelocity(part) then
                table.insert(violations, "Excessive Part Velocity")
            end
            
            if not PhysicsValidator.validatePartSize(part) then
                table.insert(violations, "Invalid Part Size")
            end
            
            if not PhysicsValidator.validateCollisions(part) then
                table.insert(violations, "Invalid Collision Group")
            end
        end
    end
    
    -- Valider tous les joueurs
    for _, player in ipairs(Players:GetPlayers()) do
        if not PhysicsValidator.validatePlayerPhysics(player) then
            table.insert(violations, "Player Physics Violation")
        end
    end
    
    return #violations == 0, violations
end

-- Obtenir les violations
function PhysicsValidator.getViolations()
    return physicsState.violations
end

-- Nettoyage des violations
function PhysicsValidator.clearViolations()
    physicsState.violations = {}
end

-- Surveillance continue
RunService.Heartbeat:Connect(function()
    if os.clock() % PHYSICS_PARAMS.CHECK_INTERVAL < PHYSICS_PARAMS.PHYSICS_THROTTLE then
        PhysicsValidator.validateAll()
    end
end)

-- Initialisation
PhysicsValidator.initialize()

return PhysicsValidator 