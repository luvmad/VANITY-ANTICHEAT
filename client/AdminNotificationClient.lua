local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CONFIG = require(script.Parent:WaitForChild("VANITY-ANTICHEAT-CONFIG"))

local notificationEvent = ReplicatedStorage:WaitForChild("AdminNotification")

-- Types de notifications améliorés
local NOTIFICATION_TYPES = {
    INFO = {
        COLOR = Color3.fromRGB(30, 144, 255),
        ICON = "ℹ️",
        SOUND = "rbxasset://sounds/info.mp3",
        PRIORITY = 1,
        DURATION = CONFIG.NOTIFICATION_DURATION
    },
    WARNING = {
        COLOR = Color3.fromRGB(255, 165, 0),
        ICON = "⚠️",
        SOUND = "rbxasset://sounds/warning.mp3",
        PRIORITY = 2,
        DURATION = CONFIG.NOTIFICATION_DURATION * 1.5
    },
    ERROR = {
        COLOR = Color3.fromRGB(255, 0, 0),
        ICON = "❌",
        SOUND = "rbxasset://sounds/error.mp3",
        PRIORITY = 3,
        DURATION = CONFIG.NOTIFICATION_DURATION * 2
    },
    SUCCESS = {
        COLOR = Color3.fromRGB(50, 205, 50),
        ICON = "✅",
        SOUND = "rbxasset://sounds/success.mp3",
        PRIORITY = 1,
        DURATION = CONFIG.NOTIFICATION_DURATION
    },
    CRITICAL = {
        COLOR = Color3.fromRGB(139, 0, 0),
        ICON = "🚨",
        SOUND = "rbxasset://sounds/critical.mp3",
        PRIORITY = 4,
        DURATION = CONFIG.CRITICAL_NOTIFICATION_DURATION,
        PERSISTENT = true
    },
    EXPLOIT = {
        COLOR = Color3.fromRGB(128, 0, 128),
        ICON = "⚡",
        SOUND = "rbxasset://sounds/exploit.mp3",
        PRIORITY = 5,
        DURATION = CONFIG.CRITICAL_NOTIFICATION_DURATION,
        PERSISTENT = true
    },
    ANOMALY = {
        COLOR = Color3.fromRGB(255, 0, 255),
        ICON = "🔍",
        SOUND = "rbxasset://sounds/anomaly.mp3",
        PRIORITY = 4,
        DURATION = CONFIG.NOTIFICATION_DURATION * 1.5
    },
    BEHAVIOR = {
        COLOR = Color3.fromRGB(255, 140, 0),
        ICON = "👁️",
        SOUND = "rbxasset://sounds/behavior.mp3",
        PRIORITY = 3,
        DURATION = CONFIG.NOTIFICATION_DURATION * 1.2
    },
    NETWORK = {
        COLOR = Color3.fromRGB(70, 130, 180),
        ICON = "🌐",
        SOUND = "rbxasset://sounds/network.mp3",
        PRIORITY = 2,
        DURATION = CONFIG.NOTIFICATION_DURATION
    }
}

-- Système de file d'attente amélioré
local notificationSystem = {
    queue = {},
    active = {},
    isProcessing = false,
    maxActive = CONFIG.MAX_NOTIFICATIONS,
    lastNotification = 0,
    throttleTime = CONFIG.NOTIFICATION_THROTTLE,
    history = {},
    maxHistory = 50
}

-- Effets sonores améliorés
local function playNotificationSound(soundId, volume, pitch)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = volume or 0.5
    sound.PlaybackSpeed = pitch or 1
    sound.Parent = SoundService
    sound:Play()
    game:GetService("Debris"):AddItem(sound, sound.TimeLength)
end

-- Effets visuels améliorés
local function createVisualEffects(container, notificationType)
    -- Effet de flou
    local blur = Instance.new("BlurEffect")
    blur.Size = 0
    blur.Parent = game.Lighting
    
    -- Animation du flou
    TweenService:Create(blur, 
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = 10}
    ):Play()
    
    -- Effet de brillance
    local glow = Instance.new("ImageLabel", container)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://131274595"
    glow.ImageColor3 = notificationType.COLOR
    glow.Size = UDim2.new(1.5, 0, 1.5, 0)
    glow.Position = UDim2.new(-0.25, 0, -0.25, 0)
    glow.ImageTransparency = 0.8
    
    -- Animation de la brillance
    TweenService:Create(glow,
        TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1),
        {ImageTransparency = 0.6, Rotation = 360}
    ):Play()
    
    return {blur = blur, glow = glow}
end

-- Interface de notification améliorée
local function createNotificationUI(message, notificationType, metadata)
    local type = NOTIFICATION_TYPES[notificationType] or NOTIFICATION_TYPES.INFO
    
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local ScreenGui = Instance.new("ScreenGui", playerGui)
    ScreenGui.Name = "AdminNotification"
    ScreenGui.DisplayOrder = 999
    
    -- Conteneur principal avec effets
    local Container = Instance.new("Frame", ScreenGui)
    Container.Size = UDim2.new(0.3, 0, 0.15, 0)
    Container.Position = UDim2.new(0.35, 0, -0.2, 0)
    Container.BackgroundTransparency = 1
    Container.AnchorPoint = Vector2.new(0.5, 0)
    
    -- Arrière-plan avec effets avancés
    local Background = Instance.new("Frame", Container)
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = type.COLOR
    Background.BackgroundTransparency = 0.1
    
    -- Coins arrondis
    local UICorner = Instance.new("UICorner", Background)
    UICorner.CornerRadius = UDim.new(0, 8)
    
    -- Gradient amélioré
    local UIGradient = Instance.new("UIGradient", Background)
    UIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, type.COLOR),
        ColorSequenceKeypoint.new(0.5, type.COLOR:Lerp(Color3.new(1,1,1), 0.2)),
        ColorSequenceKeypoint.new(1, type.COLOR:Lerp(Color3.new(0,0,0), 0.3))
    })
    UIGradient.Rotation = 45
    
    -- Conteneur d'icône amélioré
    local IconContainer = Instance.new("Frame", Container)
    IconContainer.Size = UDim2.new(0.15, 0, 1, 0)
    IconContainer.BackgroundTransparency = 1
    
    -- Icône avec animation
    local IconLabel = Instance.new("TextLabel", IconContainer)
    IconLabel.Size = UDim2.new(1, 0, 1, 0)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = type.ICON
    IconLabel.TextScaled = true
    IconLabel.TextColor3 = Color3.new(1, 1, 1)
    
    -- Animation de l'icône
    TweenService:Create(IconLabel,
        TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1),
        {Rotation = 360}
    ):Play()
    
    -- Conteneur de contenu amélioré
    local ContentContainer = Instance.new("Frame", Container)
    ContentContainer.Size = UDim2.new(0.85, 0, 1, 0)
    ContentContainer.Position = UDim2.new(0.15, 0, 0, 0)
    ContentContainer.BackgroundTransparency = 1
    
    -- Titre avec effets
    local Title = Instance.new("TextLabel", ContentContainer)
    Title.Size = UDim2.new(1, 0, 0.3, 0)
    Title.BackgroundTransparency = 1
    Title.Text = notificationType
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.TextScaled = true
    Title.Font = Enum.Font.GothamBold
    
    -- Message avec formatage avancé
    local MessageLabel = Instance.new("TextLabel", ContentContainer)
    MessageLabel.Size = UDim2.new(1, 0, 0.7, 0)
    MessageLabel.Position = UDim2.new(0, 0, 0.3, 0)
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.Text = message
    MessageLabel.TextColor3 = Color3.new(1, 1, 1)
    MessageLabel.TextScaled = true
    MessageLabel.TextWrapped = true
    MessageLabel.Font = Enum.Font.Gotham
    
    -- Barre de progression améliorée
    local ProgressBarContainer = Instance.new("Frame", Container)
    ProgressBarContainer.Size = UDim2.new(1, 0, 0.05, 0)
    ProgressBarContainer.Position = UDim2.new(0, 0, 0.95, 0)
    ProgressBarContainer.BackgroundColor3 = Color3.new(1, 1, 1)
    ProgressBarContainer.BackgroundTransparency = 0.8
    
    local ProgressBar = Instance.new("Frame", ProgressBarContainer)
    ProgressBar.Size = UDim2.new(1, 0, 1, 0)
    ProgressBar.BackgroundColor3 = Color3.new(1, 1, 1)
    ProgressBar.BackgroundTransparency = 0.5
    
    -- Bouton de fermeture amélioré
    local CloseButton = Instance.new("TextButton", Container)
    CloseButton.Size = UDim2.new(0.1, 0, 0.2, 0)
    CloseButton.Position = UDim2.new(0.9, 0, 0, 0)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.TextScaled = true
    CloseButton.ZIndex = 2
    
    -- Gestionnaires d'interaction améliorés
    local isDragging = false
    local dragStart
    local startPos
    
    Container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            startPos = Container.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Container.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    -- Ajout aux notifications actives avec métadonnées
    table.insert(notificationSystem.active, {
        gui = ScreenGui,
        container = Container,
        priority = type.PRIORITY,
        timestamp = os.time(),
        type = notificationType,
        metadata = metadata,
        persistent = type.PERSISTENT
    })
    
    -- Ajout à l'historique
    table.insert(notificationSystem.history, {
        message = message,
        type = notificationType,
        timestamp = os.time(),
        metadata = metadata
    })
    
    -- Limiter l'historique
    while #notificationSystem.history > notificationSystem.maxHistory do
        table.remove(notificationSystem.history, 1)
    end
    
    return Container, ScreenGui, ProgressBar
end

-- Système d'animation amélioré
local function animateNotification(container, screenGui, progressBar, notificationType)
    local type = NOTIFICATION_TYPES[notificationType]
    local duration = type.DURATION or CONFIG.NOTIFICATION_DURATION
    
    -- Effets visuels
    local effects = createVisualEffects(container, type)
    
    -- Animation d'apparition
    local appearTween = TweenService:Create(container, 
        TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
        {Position = UDim2.new(0.35, 0, 0, 0)}
    )
    appearTween:Play()
    
    -- Animation de la barre de progression
    local progressTween = TweenService:Create(progressBar,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {Size = UDim2.new(0, 0, 1, 0)}
    )
    progressTween:Play()
    
    -- Attendre la durée d'affichage
    if not type.PERSISTENT then
        wait(duration)
        
        -- Animation de disparition
        local disappearTween = TweenService:Create(container,
            TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            {Position = UDim2.new(0.35, 0, -0.2, 0)}
        )
        disappearTween:Play()
        
        -- Nettoyage
        disappearTween.Completed:Connect(function()
            -- Supprimer des notifications actives
            for i, notification in ipairs(notificationSystem.active) do
                if notification.gui == screenGui then
                    table.remove(notificationSystem.active, i)
                    break
                end
            end
            
            -- Nettoyer les effets
            effects.blur:Destroy()
            screenGui:Destroy()
        end)
    end
end

-- Gestion de la file d'attente améliorée
local function processQueue()
    if notificationSystem.isProcessing then return end
    notificationSystem.isProcessing = true
    
    while #notificationSystem.queue > 0 do
        -- Vérifier le throttling
        local now = os.time()
        if now - notificationSystem.lastNotification < notificationSystem.throttleTime then
            wait(notificationSystem.throttleTime)
        end
        
        -- Trier les notifications actives par priorité
        table.sort(notificationSystem.active, function(a, b)
            return a.priority > b.priority
        end)
        
        -- Supprimer les notifications en excès
        while #notificationSystem.active >= notificationSystem.maxActive do
            local oldest = notificationSystem.active[#notificationSystem.active]
            if not oldest.persistent then
                oldest.gui:Destroy()
                table.remove(notificationSystem.active)
            else
                break
            end
        end
        
        -- Traiter la prochaine notification
        local notification = table.remove(notificationSystem.queue, 1)
        local container, screenGui, progressBar = createNotificationUI(
            notification.message,
            notification.type,
            notification.metadata
        )
        
        -- Jouer l'effet sonore
        local notificationType = NOTIFICATION_TYPES[notification.type]
        if notificationType and notificationType.SOUND then
            playNotificationSound(
                notificationType.SOUND,
                notification.volume,
                notification.pitch
            )
        end
        
        animateNotification(container, screenGui, progressBar, notification.type)
        notificationSystem.lastNotification = now
        
        wait(0.5) -- Délai entre les notifications
    end
    
    notificationSystem.isProcessing = false
end

-- File d'attente des notifications améliorée
local function queueNotification(message, notificationType, metadata)
    -- Validation du type de notification
    if not NOTIFICATION_TYPES[notificationType] then
        notificationType = "INFO"
    end
    
    -- Ajouter à la file d'attente
    table.insert(notificationSystem.queue, {
        message = message,
        type = notificationType,
        metadata = metadata or {},
        timestamp = os.time(),
        volume = metadata and metadata.volume or 0.5,
        pitch = metadata and metadata.pitch or 1
    })
    
    -- Traiter la file d'attente
    processQueue()
end

-- Gestionnaire d'événements
notificationEvent.OnClientEvent:Connect(function(message, notificationType, metadata)
    queueNotification(message, notificationType, metadata)
end)

-- Interface exportée
return {
    queueNotification = queueNotification,
    NOTIFICATION_TYPES = NOTIFICATION_TYPES,
    getNotificationHistory = function()
        return notificationSystem.history
    end,
    clearHistory = function()
        notificationSystem.history = {}
    end,
    getActiveNotifications = function()
        return notificationSystem.active
    end
} 
