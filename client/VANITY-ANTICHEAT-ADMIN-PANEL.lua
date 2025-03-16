-- [[ VANITY-ANTICHEAT ADMIN PANEL V2.5 ROBLOX ENHANCED ]]
-- Interface administrateur pour le système anti-triche

local CONFIG = require(script.Parent:WaitForChild("VANITY-ANTICHEAT-CONFIG"))
local BehaviorAnalyzer = require(script.Parent:WaitForChild("VANITY-ANTICHEAT-BEHAVIOR-ANALYZER"))
local PhysicsValidator = require(script.Parent:WaitForChild("VANITY-ANTICHEAT-PHYSICS-VALIDATOR"))
local CombatMonitor = require(script.Parent:WaitForChild("VANITY-ANTICHEAT-COMBAT-MONITOR"))
local NetworkOptimizer = require(script.Parent:WaitForChild("VANITY-ANTICHEAT-NETWORK-OPTIMISER"))

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local AdminPanel = {}

-- État de l'interface
local panelState = {
    activeAdmins = {},
    openPanels = {},
    notifications = {},
    selectedPlayers = {},
    activeFilters = {},
    viewMode = "OVERVIEW"
}

-- Création de l'interface utilisateur
function AdminPanel.createUI(player)
    if not CONFIG.ADMIN_GROUPS[player:GetRoleInGroup(game.CreatorId)] then
        return
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "VanityAntiCheatAdmin"
    screenGui.ResetOnSpawn = false
    
    -- Panneau principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainPanel"
    mainFrame.Size = UDim2.new(0.8, 0, 0.8, 0)
    mainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.Parent = screenGui
    
    -- Coins arrondis
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 10)
    uiCorner.Parent = mainFrame
    
    -- Barre de titre
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0.08, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    titleBar.Parent = mainFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = "VANITY ANTI-CHEAT ADMIN PANEL v" .. CONFIG.VERSION
    titleLabel.Size = UDim2.new(0.8, 0, 1, 0)
    titleLabel.Position = UDim2.new(0.1, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextSize = 24
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = titleBar
    
    -- Menu latéral
    local sideMenu = Instance.new("Frame")
    sideMenu.Name = "SideMenu"
    sideMenu.Size = UDim2.new(0.2, 0, 0.92, 0)
    sideMenu.Position = UDim2.new(0, 0, 0.08, 0)
    sideMenu.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    sideMenu.Parent = mainFrame
    
    -- Contenu principal
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(0.8, 0, 0.92, 0)
    contentFrame.Position = UDim2.new(0.2, 0, 0.08, 0)
    contentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    contentFrame.Parent = mainFrame
    
    -- Créer les boutons du menu
    local menuButtons = {
        {name = "Vue d'ensemble", icon = "🔍", view = "OVERVIEW"},
        {name = "Joueurs", icon = "👥", view = "PLAYERS"},
        {name = "Violations", icon = "⚠️", view = "VIOLATIONS"},
        {name = "Statistiques", icon = "📊", view = "STATS"},
        {name = "Configuration", icon = "⚙️", view = "CONFIG"},
        {name = "Logs", icon = "📝", view = "LOGS"}
    }
    
    for i, button in ipairs(menuButtons) do
        local menuButton = Instance.new("TextButton")
        menuButton.Name = button.name
        menuButton.Size = UDim2.new(1, 0, 0.1, 0)
        menuButton.Position = UDim2.new(0, 0, 0.1 * (i-1), 0)
        menuButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        menuButton.Text = button.icon .. " " .. button.name
        menuButton.TextColor3 = Color3.new(1, 1, 1)
        menuButton.TextSize = 18
        menuButton.Font = Enum.Font.Gotham
        menuButton.Parent = sideMenu
        
        -- Effet de survol
        menuButton.MouseEnter:Connect(function()
            TweenService:Create(menuButton, 
                TweenInfo.new(0.3),
                {BackgroundColor3 = Color3.fromRGB(55, 55, 55)}
            ):Play()
        end)
        
        menuButton.MouseLeave:Connect(function()
            TweenService:Create(menuButton,
                TweenInfo.new(0.3),
                {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}
            ):Play()
        end)
        
        -- Changement de vue
        menuButton.MouseButton1Click:Connect(function()
            AdminPanel.switchView(contentFrame, button.view)
        end)
    end
    
    -- Initialiser la vue par défaut
    AdminPanel.switchView(contentFrame, "OVERVIEW")
    
    screenGui.Parent = player:WaitForChild("PlayerGui")
    panelState.openPanels[player.UserId] = screenGui
end

-- Changement de vue
function AdminPanel.switchView(contentFrame, view)
    -- Nettoyer la vue actuelle
    for _, child in ipairs(contentFrame:GetChildren()) do
        child:Destroy()
    end
    
    panelState.viewMode = view
    
    if view == "OVERVIEW" then
        AdminPanel.createOverviewView(contentFrame)
    elseif view == "PLAYERS" then
        AdminPanel.createPlayersView(contentFrame)
    elseif view == "VIOLATIONS" then
        AdminPanel.createViolationsView(contentFrame)
    elseif view == "STATS" then
        AdminPanel.createStatsView(contentFrame)
    elseif view == "CONFIG" then
        AdminPanel.createConfigView(contentFrame)
    elseif view == "LOGS" then
        AdminPanel.createLogsView(contentFrame)
    end
end

-- Vue d'ensemble
function AdminPanel.createOverviewView(parent)
    local statsContainer = Instance.new("Frame")
    statsContainer.Size = UDim2.new(1, 0, 1, 0)
    statsContainer.BackgroundTransparency = 1
    statsContainer.Parent = parent
    
    -- Statistiques générales
    local stats = {
        {name = "Joueurs actifs", value = #Players:GetPlayers(), icon = "👥"},
        {name = "Violations aujourd'hui", value = #PhysicsValidator.getViolations(), icon = "⚠️"},
        {name = "Activités suspectes", value = #CombatMonitor.getSuspiciousActivities(), icon = "🚨"},
        {name = "Score moyen d'anomalie", value = "0.0", icon = "📊"}
    }
    
    for i, stat in ipairs(stats) do
        local statFrame = Instance.new("Frame")
        statFrame.Size = UDim2.new(0.23, 0, 0.15, 0)
        statFrame.Position = UDim2.new(0.02 + (0.25 * (i-1)), 0, 0.05, 0)
        statFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        statFrame.Parent = statsContainer
        
        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(0, 8)
        uiCorner.Parent = statFrame
        
        local iconLabel = Instance.new("TextLabel")
        iconLabel.Size = UDim2.new(0.2, 0, 0.4, 0)
        iconLabel.Position = UDim2.new(0.4, 0, 0.1, 0)
        iconLabel.Text = stat.icon
        iconLabel.TextSize = 24
        iconLabel.BackgroundTransparency = 1
        iconLabel.Parent = statFrame
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.8, 0, 0.3, 0)
        nameLabel.Position = UDim2.new(0.1, 0, 0.5, 0)
        nameLabel.Text = stat.name
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.TextSize = 14
        nameLabel.BackgroundTransparency = 1
        nameLabel.Parent = statFrame
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0.8, 0, 0.2, 0)
        valueLabel.Position = UDim2.new(0.1, 0, 0.75, 0)
        valueLabel.Text = tostring(stat.value)
        valueLabel.TextColor3 = Color3.new(1, 1, 1)
        valueLabel.TextSize = 18
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.BackgroundTransparency = 1
        valueLabel.Parent = statFrame
    end
    
    -- Graphique des violations
    local graphFrame = Instance.new("Frame")
    graphFrame.Size = UDim2.new(0.96, 0, 0.4, 0)
    graphFrame.Position = UDim2.new(0.02, 0, 0.25, 0)
    graphFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    graphFrame.Parent = statsContainer
    
    local graphTitle = Instance.new("TextLabel")
    graphTitle.Size = UDim2.new(1, 0, 0.1, 0)
    graphTitle.Text = "Violations sur les dernières 24 heures"
    graphTitle.TextColor3 = Color3.new(1, 1, 1)
    graphTitle.TextSize = 16
    graphTitle.Font = Enum.Font.GothamBold
    graphTitle.BackgroundTransparency = 1
    graphTitle.Parent = graphFrame
    
    -- Liste des dernières activités
    local activityList = Instance.new("ScrollingFrame")
    activityList.Size = UDim2.new(0.96, 0, 0.25, 0)
    activityList.Position = UDim2.new(0.02, 0, 0.7, 0)
    activityList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    activityList.Parent = statsContainer
    
    local activityTitle = Instance.new("TextLabel")
    activityTitle.Size = UDim2.new(1, 0, 0.1, 0)
    activityTitle.Text = "Activités récentes"
    activityTitle.TextColor3 = Color3.new(1, 1, 1)
    activityTitle.TextSize = 16
    activityTitle.Font = Enum.Font.GothamBold
    activityTitle.BackgroundTransparency = 1
    activityTitle.Parent = activityList
end

-- Vue des joueurs
function AdminPanel.createPlayersView(parent)
    local playersContainer = Instance.new("Frame")
    playersContainer.Size = UDim2.new(1, 0, 1, 0)
    playersContainer.BackgroundTransparency = 1
    playersContainer.Parent = parent
    
    -- Barre de recherche
    local searchBar = Instance.new("TextBox")
    searchBar.Size = UDim2.new(0.3, 0, 0.05, 0)
    searchBar.Position = UDim2.new(0.02, 0, 0.02, 0)
    searchBar.PlaceholderText = "Rechercher un joueur..."
    searchBar.TextColor3 = Color3.new(1, 1, 1)
    searchBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    searchBar.Parent = playersContainer
    
    -- Liste des joueurs
    local playerList = Instance.new("ScrollingFrame")
    playerList.Size = UDim2.new(0.3, 0, 0.9, 0)
    playerList.Position = UDim2.new(0.02, 0, 0.08, 0)
    playerList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    playerList.Parent = playersContainer
    
    -- Détails du joueur
    local playerDetails = Instance.new("Frame")
    playerDetails.Size = UDim2.new(0.64, 0, 0.96, 0)
    playerDetails.Position = UDim2.new(0.34, 0, 0.02, 0)
    playerDetails.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    playerDetails.Parent = playersContainer
    
    -- Mettre à jour la liste des joueurs
    local function updatePlayerList()
        for _, child in ipairs(playerList:GetChildren()) do
            child:Destroy()
        end
        
        local yOffset = 0
        for _, player in ipairs(Players:GetPlayers()) do
            local playerButton = Instance.new("TextButton")
            playerButton.Size = UDim2.new(0.95, 0, 0.1, 0)
            playerButton.Position = UDim2.new(0.025, 0, 0, yOffset)
            playerButton.Text = player.Name
            playerButton.TextColor3 = Color3.new(1, 1, 1)
            playerButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            playerButton.Parent = playerList
            
            yOffset = yOffset + 0.12
            
            playerButton.MouseButton1Click:Connect(function()
                AdminPanel.showPlayerDetails(player, playerDetails)
            end)
        end
    end
    
    updatePlayerList()
    Players.PlayerAdded:Connect(updatePlayerList)
    Players.PlayerRemoving:Connect(updatePlayerList)
end

-- Afficher les détails d'un joueur
function AdminPanel.showPlayerDetails(player, container)
    for _, child in ipairs(container:GetChildren()) do
        child:Destroy()
    end
    
    -- En-tête
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0.1, 0)
    header.BackgroundTransparency = 1
    header.Parent = container
    
    local playerName = Instance.new("TextLabel")
    playerName.Size = UDim2.new(0.7, 0, 1, 0)
    playerName.Text = player.Name
    playerName.TextColor3 = Color3.new(1, 1, 1)
    playerName.TextSize = 24
    playerName.Font = Enum.Font.GothamBold
    playerName.BackgroundTransparency = 1
    playerName.Parent = header
    
    -- Actions
    local actionButtons = Instance.new("Frame")
    actionButtons.Size = UDim2.new(0.3, 0, 1, 0)
    actionButtons.Position = UDim2.new(0.7, 0, 0, 0)
    actionButtons.BackgroundTransparency = 1
    actionButtons.Parent = header
    
    local actions = {
        {name = "Kick", color = Color3.fromRGB(255, 165, 0)},
        {name = "Ban", color = Color3.fromRGB(255, 0, 0)},
        {name = "Reset", color = Color3.fromRGB(0, 255, 0)}
    }
    
    for i, action in ipairs(actions) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0.3, 0, 0.8, 0)
        button.Position = UDim2.new(0.33 * (i-1), 0, 0.1, 0)
        button.Text = action.name
        button.TextColor3 = Color3.new(1, 1, 1)
        button.BackgroundColor3 = action.color
        button.Parent = actionButtons
        
        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(0, 4)
        uiCorner.Parent = button
    end
    
    -- Statistiques du joueur
    local statsContainer = Instance.new("Frame")
    statsContainer.Size = UDim2.new(1, 0, 0.3, 0)
    statsContainer.Position = UDim2.new(0, 0, 0.12, 0)
    statsContainer.BackgroundTransparency = 1
    statsContainer.Parent = container
    
    local stats = {
        {name = "Score d'anomalie", value = BehaviorAnalyzer.getAnomalyScore(player)},
        {name = "Violations", value = #PhysicsValidator.getViolations()},
        {name = "Activités suspectes", value = #CombatMonitor.getSuspiciousActivities()},
        {name = "Temps de jeu", value = "0h"}
    }
    
    for i, stat in ipairs(stats) do
        local statFrame = Instance.new("Frame")
        statFrame.Size = UDim2.new(0.23, 0, 0.8, 0)
        statFrame.Position = UDim2.new(0.02 + (0.25 * (i-1)), 0, 0.1, 0)
        statFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        statFrame.Parent = statsContainer
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.9, 0, 0.4, 0)
        nameLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
        nameLabel.Text = stat.name
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.TextSize = 14
        nameLabel.BackgroundTransparency = 1
        nameLabel.Parent = statFrame
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0.9, 0, 0.4, 0)
        valueLabel.Position = UDim2.new(0.05, 0, 0.5, 0)
        valueLabel.Text = tostring(stat.value)
        valueLabel.TextColor3 = Color3.new(1, 1, 1)
        valueLabel.TextSize = 18
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.BackgroundTransparency = 1
        valueLabel.Parent = statFrame
    end
    
    -- Historique des violations
    local violationList = Instance.new("ScrollingFrame")
    violationList.Size = UDim2.new(0.96, 0, 0.5, 0)
    violationList.Position = UDim2.new(0.02, 0, 0.45, 0)
    violationList.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    violationList.Parent = container
    
    local violationTitle = Instance.new("TextLabel")
    violationTitle.Size = UDim2.new(1, 0, 0.1, 0)
    violationTitle.Text = "Historique des violations"
    violationTitle.TextColor3 = Color3.new(1, 1, 1)
    violationTitle.TextSize = 16
    violationTitle.Font = Enum.Font.GothamBold
    violationTitle.BackgroundTransparency = 1
    violationTitle.Parent = violationList
end

-- Vue des violations
function AdminPanel.createViolationsView(parent)
    local violationsContainer = Instance.new("Frame")
    violationsContainer.Size = UDim2.new(1, 0, 1, 0)
    violationsContainer.BackgroundTransparency = 1
    violationsContainer.Parent = parent
    
    -- Filtres
    local filterFrame = Instance.new("Frame")
    filterFrame.Size = UDim2.new(1, 0, 0.1, 0)
    filterFrame.BackgroundTransparency = 1
    filterFrame.Parent = violationsContainer
    
    local filters = {"Tous", "Physique", "Combat", "Réseau", "Comportement"}
    
    for i, filter in ipairs(filters) do
        local filterButton = Instance.new("TextButton")
        filterButton.Size = UDim2.new(0.18, 0, 0.8, 0)
        filterButton.Position = UDim2.new(0.02 + (0.2 * (i-1)), 0, 0.1, 0)
        filterButton.Text = filter
        filterButton.TextColor3 = Color3.new(1, 1, 1)
        filterButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        filterButton.Parent = filterFrame
    end
    
    -- Liste des violations
    local violationList = Instance.new("ScrollingFrame")
    violationList.Size = UDim2.new(1, 0, 0.88, 0)
    violationList.Position = UDim2.new(0, 0, 0.12, 0)
    violationList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    violationList.Parent = violationsContainer
end

-- Vue des statistiques
function AdminPanel.createStatsView(parent)
    local statsContainer = Instance.new("Frame")
    statsContainer.Size = UDim2.new(1, 0, 1, 0)
    statsContainer.BackgroundTransparency = 1
    statsContainer.Parent = parent
    
    -- Graphiques
    local graphs = {
        {name = "Violations par heure", type = "LINE"},
        {name = "Types de violations", type = "PIE"},
        {name = "Joueurs actifs", type = "LINE"},
        {name = "Performance serveur", type = "LINE"}
    }
    
    for i, graph in ipairs(graphs) do
        local graphFrame = Instance.new("Frame")
        graphFrame.Size = UDim2.new(0.48, 0, 0.48, 0)
        graphFrame.Position = UDim2.new(
            0.02 + (0.5 * ((i-1) % 2)),
            0,
            0.02 + (0.5 * math.floor((i-1) / 2)),
            0
        )
        graphFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        graphFrame.Parent = statsContainer
        
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, 0, 0.1, 0)
        titleLabel.Text = graph.name
        titleLabel.TextColor3 = Color3.new(1, 1, 1)
        titleLabel.TextSize = 16
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.BackgroundTransparency = 1
        titleLabel.Parent = graphFrame
    end
end

-- Vue de la configuration
function AdminPanel.createConfigView(parent)
    local configContainer = Instance.new("Frame")
    configContainer.Size = UDim2.new(1, 0, 1, 0)
    configContainer.BackgroundTransparency = 1
    configContainer.Parent = parent
    
    -- Catégories de configuration
    local categories = {
        {name = "Général", icon = "⚙️"},
        {name = "Détection", icon = "🔍"},
        {name = "Punitions", icon = "⚠️"},
        {name = "Réseau", icon = "🌐"},
        {name = "Notifications", icon = "🔔"},
        {name = "Sécurité", icon = "🔒"}
    }
    
    -- Menu des catégories
    local categoryMenu = Instance.new("Frame")
    categoryMenu.Size = UDim2.new(0.2, 0, 1, 0)
    categoryMenu.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    categoryMenu.Parent = configContainer
    
    for i, category in ipairs(categories) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0.9, 0, 0.08, 0)
        button.Position = UDim2.new(0.05, 0, 0.02 + (0.1 * (i-1)), 0)
        button.Text = category.icon .. " " .. category.name
        button.TextColor3 = Color3.new(1, 1, 1)
        button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        button.Parent = categoryMenu
    end
    
    -- Zone de configuration
    local configArea = Instance.new("ScrollingFrame")
    configArea.Size = UDim2.new(0.78, 0, 0.98, 0)
    configArea.Position = UDim2.new(0.21, 0, 0.01, 0)
    configArea.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    configArea.Parent = configContainer
end

-- Vue des logs
function AdminPanel.createLogsView(parent)
    local logsContainer = Instance.new("Frame")
    logsContainer.Size = UDim2.new(1, 0, 1, 0)
    logsContainer.BackgroundTransparency = 1
    logsContainer.Parent = parent
    
    -- Filtres de logs
    local filterFrame = Instance.new("Frame")
    filterFrame.Size = UDim2.new(1, 0, 0.1, 0)
    filterFrame.BackgroundTransparency = 1
    filterFrame.Parent = logsContainer
    
    local filters = {"Tous", "Erreurs", "Avertissements", "Info", "Debug"}
    
    for i, filter in ipairs(filters) do
        local filterButton = Instance.new("TextButton")
        filterButton.Size = UDim2.new(0.18, 0, 0.8, 0)
        filterButton.Position = UDim2.new(0.02 + (0.2 * (i-1)), 0, 0.1, 0)
        filterButton.Text = filter
        filterButton.TextColor3 = Color3.new(1, 1, 1)
        filterButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        filterButton.Parent = filterFrame
    end
    
    -- Liste des logs
    local logList = Instance.new("ScrollingFrame")
    logList.Size = UDim2.new(1, 0, 0.88, 0)
    logList.Position = UDim2.new(0, 0, 0.12, 0)
    logList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    logList.Parent = logsContainer
end

-- Gestionnaire d'événements pour les joueurs
Players.PlayerAdded:Connect(function(player)
    if CONFIG.ADMIN_GROUPS[player:GetRoleInGroup(game.CreatorId)] then
        AdminPanel.createUI(player)
    end
end)

return AdminPanel 