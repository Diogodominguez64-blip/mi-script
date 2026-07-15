-- ==========================================
-- DZ STORE V3 - Neon UI Redesign
-- Version: 3.1 (Aimbot, Name ESP, Silent Aim, Wall Check & FOV Slider)
-- ==========================================

-- Servicios de Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera or workspace:WaitForChild("Camera")
local LocalPlayer = Players.LocalPlayer

-- Paleta de Colores Neon (Diseño Modernizado)
local Theme = {
    Background = Color3.fromRGB(15, 15, 18),
    HeaderBg = Color3.fromRGB(25, 25, 30),
    NeonAccent = Color3.fromRGB(57, 255, 20), -- Verde Neón
    ElementBg = Color3.fromRGB(24, 24, 28),
    Text = Color3.fromRGB(245, 245, 245),
    TextDark = Color3.fromRGB(10, 10, 10),
    Inactive = Color3.fromRGB(40, 40, 48),
    SearchBg = Color3.fromRGB(30, 30, 35)
}

-- Configurations de las Funciones
local Aimbot = {
    enabled = true,
    fov = 150, -- FOV editable inicializado en 150
    smoothness = 0.3,
    aimKey = Enum.UserInputType.MouseButton2,
    teamCheck = false,
    wallCheck = false,
    showFov = true,
    fovColor = Theme.NeonAccent,
    fovTransparency = 0.8,
    bone = "Head",
    prediction = true,
    predictionAmount = 0.25,
    autoFire = false,
    instantLock = false,
    performanceMode = true,
    silentAim = false,
    silentAimPart = "Head"
}

local ESP = {
    nameEnabled = true,
    skeletonEnabled = true,
    lineEnabled = true,
    skeletonThickness = 1.5,
    skeletonColor = Color3.fromRGB(255, 255, 255),
    lineThickness = 1.5,
    lineColor = Theme.NeonAccent,
    maxDistance = 3000,
    teamCheck = false
}

-- Círculo visual del campo de visión (FOV)
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Aimbot.fovColor
fovCircle.Thickness = 1.5
fovCircle.NumSides = 64
fovCircle.Radius = Aimbot.fov
fovCircle.Filled = false
fovCircle.Transparency = Aimbot.fovTransparency
fovCircle.Visible = Aimbot.showFov

-- Detección del juego activa
local gameDetected = false
local detectedGame = ""

local function detectGame()
    if game.PlaceId == 1234567890 then 
        detectedGame = "Overkiller"
    else
        detectedGame = "Original Game"
    end
    gameDetected = true
    game.StarterGui:SetCore("SendNotification", {
        Title = "DZ STORE V3",
        Text = "Hacks cargados para: " .. detectedGame,
        Duration = 5
    })
end

detectGame()

-- ==========================================
-- VALIDACIONES PRINCIPALES Y COMPROBACIÓN DE PAREDES
-- ==========================================

local function IsBehindWall(targetPart)
    if not Aimbot.wallCheck then return false end
    
    local character = LocalPlayer.Character
    local origin = Camera.CFrame.Position
    
    if character and targetPart then
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {character}
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        
        local direction = (targetPart.Position - origin)
        local raycastResult = workspace:Raycast(origin, direction, raycastParams)
        
        if raycastResult and not raycastResult.Instance:IsDescendantOf(targetPart.Parent) then
            return true
        end
    end
    return false
end

local function IsValidTarget(player)
    if player == LocalPlayer then return false end
    local character = player.Character
    if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then 
        return false 
    end
    if Aimbot.teamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then 
        return false 
    end
    local targetBone = character:FindFirstChild(Aimbot.bone) or character:FindFirstChild("HumanoidRootPart")
    if targetBone and IsBehindWall(targetBone) then
        return false
    end
    return true
end

local function IsESPValid(player)
    if player == LocalPlayer then return false end
    if ESP.teamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then return false end
    local character = player.Character
    if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then
        return false
    end
    return true
end

-- ==========================================
-- LÓGICA DE APUNTADO SILENCIOSO (SILENT AIM)
-- ==========================================

local function FindClosestEnemyByDistance()
    local closestEnemy = nil
    local closestDistance = math.huge
    local character = LocalPlayer.Character
    local localRoot = character and character:FindFirstChild("HumanoidRootPart")
    
    if not localRoot then return nil end

    for _, player in pairs(Players:GetPlayers()) do
        if not IsValidTarget(player) then continue end
        local enemyPart = player.Character:FindFirstChild(Aimbot.silentAimPart)
        
        if enemyPart then
            local distance = (enemyPart.Position - localRoot.Position).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestEnemy = player
            end
        end
    end
    return closestEnemy
end

local function ExecuteSilentAim()
    if not Aimbot.silentAim then return end
    local closestEnemy = FindClosestEnemyByDistance()
    
    if closestEnemy and closestEnemy.Character then
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and Aimbot.silentAim then
        ExecuteSilentAim()
    end
end)

-- ==========================================
-- LÓGICA DEL AIMBOT PRINCIPAL
-- ==========================================

local function GetClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = Aimbot.fov
    
    for _, player in ipairs(Players:GetPlayers()) do
        if not IsValidTarget(player) then continue end
        local character = player.Character
        local targetBone = character:FindFirstChild(Aimbot.bone) or character:FindFirstChild("HumanoidRootPart")
        if not targetBone then continue end
        
        local vector, onScreen = Camera:WorldToViewportPoint(targetBone.Position)
        if not onScreen then continue end
        
        local mousePosition = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local bonePosition = Vector2.new(vector.X, vector.Y)
        local distance = (mousePosition - bonePosition).Magnitude
        
        if distance < shortestDistance then
            shortestDistance = distance
            closestPlayer = player
        end
    end
    return closestPlayer
end

local function GetPredictedPosition(target)
    if not Aimbot.prediction then return target.Position end
    local humanoid = target.Parent:FindFirstChild("Humanoid")
    if not humanoid then return target.Position end
    
    local velocity = humanoid.MoveDirection * humanoid.WalkSpeed
    if humanoid:FindFirstChild("BodyVelocity") then
        velocity = velocity + humanoid.BodyVelocity.Velocity
    end
    
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local distance = root and (root.Position - target.Position).Magnitude or (Camera.CFrame.Position - target.Position).Magnitude
    local timeToReach = distance / 2000
    
    return target.Position + (velocity * timeToReach * Aimbot.predictionAmount)
end

local function AimAt(target)
    if not target or not target.Character then return end
    local targetBone = target.Character:FindFirstChild(Aimbot.bone) or target.Character:FindFirstChild("HumanoidRootPart")
    if not targetBone then return end
    
    local targetPosition = GetPredictedPosition(targetBone)
    
    if Aimbot.instantLock then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
    else
        local currentLook = Camera.CFrame.LookVector
        local targetDir = (targetPosition - Camera.CFrame.Position).Unit
        local newLook = currentLook:Lerp(targetDir, 1 - Aimbot.smoothness)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + newLook)
    end
    
    if Aimbot.autoFire and UserInputService:IsMouseButtonPressed(Aimbot.aimKey) then
        if mouse1press then mouse1press() task.wait(0.05) mouse1release() end
    end
end

-- ==========================================
-- SISTEMA ESP (SKELETON, LINES & NAMES)
-- ==========================================

local ESP_Drawings = {}

local function createDrawings(player)
    local drawings = { Line = Drawing.new("Line"), Name = Drawing.new("Text"), Skeleton = {} }
    local bones = {
        {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"},
        {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"},
        {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"},
        {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}
    }
    
    for i = 1, #bones do
        local line = Drawing.new("Line")
        line.Thickness = ESP.skeletonThickness
        line.Color = ESP.skeletonColor
        line.Transparency = 1
        drawings.Skeleton[i] = {line = line, parts = bones[i]}
    end
    
    drawings.Line.Thickness = ESP.lineThickness
    drawings.Line.Color = ESP.lineColor
    drawings.Line.Transparency = 1
    
    drawings.Name.Size = 18
    drawings.Name.Color = ESP.lineColor
    drawings.Name.Outline = true
    drawings.Name.Center = true
    
    ESP_Drawings[player] = drawings
end

local function ClearPlayerESP(player)
    if ESP_Drawings[player] then
        ESP_Drawings[player].Line:Remove()
        ESP_Drawings[player].Name:Remove()
        for _, obj in pairs(ESP_Drawings[player].Skeleton) do obj.line:Remove() end
        ESP_Drawings[player] = nil
    end
end

Players.PlayerRemoving:Connect(ClearPlayerESP)

-- ==========================================
-- INTERFAZ DE USUARIO: DZ STORE V3 (DISEÑO NUEVO)
-- ==========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DZ_STORE_V3_GUI"
local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
ScreenGui.Parent = success and coreGui or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Marco Principal de la Interfaz
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 360, 0, 480)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -240)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BackgroundTransparency = 0.05
MainFrame.ClipsDescendants = true
MainFrame.Visible = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- Cabecera con Degradado Moderno
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 50)
Header.Position = UDim2.new(0, 0, 0, 0)
Header.BackgroundColor3 = Theme.HeaderBg
Header.BorderSizePixel = 0
Header.Parent = MainFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

-- Texto Cabecera (DZ STORE V3)
local HeaderText = Instance.new("TextLabel")
HeaderText.Name = "HeaderText"
HeaderText.Text = "DZ STORE V3"
HeaderText.TextColor3 = Theme.NeonAccent
HeaderText.TextSize = 22
HeaderText.Font = Enum.Font.GothamBold
HeaderText.Size = UDim2.new(1, 0, 1, 0)
HeaderText.BackgroundTransparency = 1
HeaderText.Parent = Header

-- Barra de Búsqueda
local SearchBar = Instance.new("TextBox")
SearchBar.Name = "SearchBar"
SearchBar.Size = UDim2.new(0.9, 0, 0, 35)
SearchBar.Position = UDim2.new(0.05, 0, 0, 60)
SearchBar.BackgroundColor3 = Theme.SearchBg
SearchBar.TextColor3 = Theme.Text
SearchBar.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
SearchBar.TextSize = 14
SearchBar.Font = Enum.Font.SourceSans
SearchBar.PlaceholderText = "Buscar función..."
SearchBar.Text = ""
SearchBar.Parent = MainFrame
Instance.new("UICorner", SearchBar).CornerRadius = UDim.new(0, 8)

-- Contenedor de Elementos con Scroll
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -20, 1, -115)
ContentFrame.Position = UDim2.new(0, 10, 0, 105)
ContentFrame.BackgroundTransparency = 1
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.ScrollBarThickness = 4
ContentFrame.ScrollBarImageColor3 = Theme.NeonAccent
ContentFrame.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout", ContentFrame)
ListLayout.Padding = UDim.new(0, 8)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Ajustar tamaño del Canvas automáticamente
ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
end)

-- Botón Flotante Modernizado (Sin Ojo)
local MobileFloatingButton = Instance.new("TextButton")
MobileFloatingButton.Parent = ScreenGui
MobileFloatingButton.Size = UDim2.new(0, 50, 0, 50)
MobileFloatingButton.Position = UDim2.new(1, -70, 0, 30)
MobileFloatingButton.BackgroundColor3 = Theme.Background
MobileFloatingButton.Text = "V3"
MobileFloatingButton.Font = Enum.Font.GothamBlack
MobileFloatingButton.TextSize = 16
MobileFloatingButton.TextColor3 = Theme.NeonAccent
MobileFloatingButton.BorderSizePixel = 0
Instance.new("UICorner", MobileFloatingButton).CornerRadius = UDim.new(1, 0)

-- Efecto de borde neón para el botón flotante
local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 2
Stroke.Color = Theme.NeonAccent
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Stroke.Parent = MobileFloatingButton

-- Alternar visibilidad del menú
local function ToggleMenu()
    MainFrame.Visible = not MainFrame.Visible
end
MobileFloatingButton.MouseButton1Click:Connect(ToggleMenu)

-- Alternar visibilidad con la tecla "Insert"
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.Insert then
        ToggleMenu()
    end
end)

-- Arrastrar Menú (Drag System)
local dragging, dragInput, dragStart, startPos
local function updateInput(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateInput(input)
    end
end)

-- ==========================================
-- DISEÑO E INTERACCIONES DE INTERFAZ (HELPERS)
-- ==========================================

local function CreateSection(text)
    local label = Instance.new("TextLabel", ContentFrame)
    label.Size = UDim2.new(1, -10, 0, 30)
    label.Text = text:upper()
    label.TextColor3 = Theme.NeonAccent
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
end

local function CreateToggle(name, tableRef, configKey)
    local container = Instance.new("Frame", ContentFrame)
    container.Size = UDim2.new(1, -10, 0, 44)
    container.BackgroundColor3 = Theme.ElementBg
    container.BorderSizePixel = 0
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 14
    
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(0, 60, 0, 26)
    btn.Position = UDim2.new(1, -72, 0.5, -13)
    btn.Text = tableRef[configKey] and "ON" or "OFF"
    btn.BackgroundColor3 = tableRef[configKey] and Theme.NeonAccent or Theme.Inactive
    btn.TextColor3 = tableRef[configKey] and Theme.TextDark or Theme.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    -- Efecto visual hover dinámico
    local hoverEffect = TweenService:Create(container, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(34, 34, 40) })
    
    container.MouseEnter:Connect(function()
        hoverEffect:Play()
    end)
    container.MouseLeave:Connect(function()
        hoverEffect:Cancel()
        container.BackgroundColor3 = Theme.ElementBg
    end)

    btn.MouseButton1Click:Connect(function()
        tableRef[configKey] = not tableRef[configKey]
        btn.Text = tableRef[configKey] and "ON" or "OFF"
        
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = tableRef[configKey] and Theme.NeonAccent or Theme.Inactive,
            TextColor3 = tableRef[configKey] and Theme.TextDark or Theme.Text
        }):Play()
        
        if configKey == "showFov" or configKey == "enabled" then
            fovCircle.Visible = Aimbot.enabled and Aimbot.showFov
        end
    end)
end

-- ==========================================
-- NUEVA FUNCIÓN: SLIDER DE FOV EDITABLE
-- ==========================================
local function CreateSlider(name, tableRef, configKey, min, max)
    local container = Instance.new("Frame", ContentFrame)
    container.Size = UDim2.new(1, -10, 0, 65) -- Alto extendido para slider
    container.BackgroundColor3 = Theme.ElementBg
    container.BorderSizePixel = 0
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(1, -24, 0, 25)
    label.Position = UDim2.new(0, 12, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. tostring(tableRef[configKey])
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 14

    local sliderBar = Instance.new("TextButton", container)
    sliderBar.Size = UDim2.new(1, -24, 0, 8)
    sliderBar.Position = UDim2.new(0, 12, 0, 38)
    sliderBar.BackgroundColor3 = Theme.Inactive
    sliderBar.BorderSizePixel = 0
    sliderBar.Text = ""
    Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(0, 4)

    local sliderFill = Instance.new("Frame", sliderBar)
    sliderFill.Size = UDim2.new((tableRef[configKey] - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Theme.NeonAccent
    sliderFill.BorderSizePixel = 0
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0, 4)

    local sliderButton = Instance.new("TextButton", sliderBar)
    sliderButton.Size = UDim2.new(0, 16, 0, 16)
    sliderButton.Position = UDim2.new((tableRef[configKey] - min) / (max - min), -8, 0.5, -8)
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderButton.BorderSizePixel = 0
    sliderButton.Text = ""
    Instance.new("UICorner", sliderButton).CornerRadius = UDim.new(1, 0)

    local isSliding = false

    local function updateSliderValue()
        local mousePos = UserInputService:GetMouseLocation()
        local relativeX = mousePos.X - sliderBar.AbsolutePosition.X
        local percentage = math.clamp(relativeX / sliderBar.AbsoluteSize.X, 0, 1)

        sliderButton.Position = UDim2.new(percentage, -8, 0.5, -8)
        sliderFill.Size = UDim2.new(percentage, 0, 1, 0)

        local value = math.floor(min + (percentage * (max - min)))
        tableRef[configKey] = value
        label.Text = name .. ": " .. tostring(value)

        -- Actualizar FOV dinámicamente si es la propiedad del Aimbot
        if configKey == "fov" then
            fovCircle.Radius = value
        end
    end

    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSliderValue()
        end
    end)

    -- Hover suave
    local hoverEffect = TweenService:Create(container, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(34, 34, 40) })
    container.MouseEnter:Connect(function() hoverEffect:Play() end)
    container.MouseLeave:Connect(function() hoverEffect:Cancel(); container.BackgroundColor3 = Theme.ElementBg end)
end

-- Lógica funcional de la Barra de Búsqueda (Incluye soporte para sliders)
SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
    local query = SearchBar.Text:lower()
    for _, child in ipairs(ContentFrame:GetChildren()) do
        if child:IsA("Frame") then
            local textLabel = child:FindFirstChildOfClass("TextLabel")
            if textLabel then
                local text = textLabel.Text:lower()
                child.Visible = string.find(text, query) ~= nil
            end
        elseif child:IsA("TextLabel") then
            local text = child.Text:lower()
            child.Visible = string.find(text, query) ~= nil or query == ""
        end
    end
end)

-- Construcción ordenada de la UI con el nuevo Slider de FOV
CreateSection("SISTEMA AIMBOT")
CreateToggle("Habilitar Aimbot", Aimbot, "enabled")
CreateToggle("Mostrar Circulo FOV", Aimbot, "showFov")
CreateSlider("Radio del FOV", Aimbot, "fov", 10, 600) -- FOV Editable (Rango: 10 a 600)
CreateToggle("Verificación de Paredes", Aimbot, "wallCheck")
CreateToggle("Comprobación de Equipo", Aimbot, "teamCheck")
CreateToggle("Predicción de Movimiento", Aimbot, "prediction")

CreateSection("SILENT AIM")
CreateToggle("Habilitar Silent Aim", Aimbot, "silentAim")

CreateSection("SISTEMA VISUAL (ESP)")
CreateToggle("ESP Nombre y Distancia", ESP, "nameEnabled")
CreateToggle("ESP Esqueleto", ESP, "skeletonEnabled")
CreateToggle("ESP Snaplines (Líneas)", ESP, "lineEnabled")

-- ==========================================
-- EJECUCIÓN CONTINUA (HEARTBEAT & RENDERSTEPPED)
-- ==========================================

local lastTargetTime = 0
local targetUpdateInterval = 0.016
local currentTarget = nil

RunService.Heartbeat:Connect(function()
    if Aimbot.silentAim then ExecuteSilentAim() end
end)

RunService.RenderStepped:Connect(function()
    -- Centrar círculo FOV
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    fovCircle.Radius = Aimbot.fov
    fovCircle.Visible = Aimbot.enabled and Aimbot.showFov

    -- Procesamiento de Aimbot
    if Aimbot.enabled then
        local currentTime = tick()
        if not Aimbot.performanceMode or (currentTime - lastTargetTime) > targetUpdateInterval then
            lastTargetTime = currentTime
            if Aimbot.instantLock then
                currentTarget = GetClosestPlayerToCursor()
                AimAt(currentTarget)
            elseif UserInputService:IsMouseButtonPressed(Aimbot.aimKey) then
                currentTarget = GetClosestPlayerToCursor()
                AimAt(currentTarget)
            else
                currentTarget = nil
            end
        elseif currentTarget and IsValidTarget(currentTarget) then
            AimAt(currentTarget)
        else
            currentTarget = nil
        end
    end

    -- Renderizado del ESP
    for _, player in pairs(Players:GetPlayers()) do
        if not IsESPValid(player) then
            ClearPlayerESP(player)
            continue
        end
        if not ESP_Drawings[player] then createDrawings(player) end
        
        local drawings = ESP_Drawings[player]
        local character = player.Character
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local headPart = character:FindFirstChild("Head")
        
        if rootPart and headPart then
            local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            local headPos = Camera:WorldToViewportPoint(headPart.Position + Vector3.new(0, 1.5, 0))
            local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local distance = localRoot and (localRoot.Position - rootPart.Position).Magnitude or (Camera.CFrame.Position - rootPart.Position).Magnitude
            
            if onScreen and distance < ESP.maxDistance then
                if ESP.lineEnabled then
                    drawings.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    drawings.Line.To = Vector2.new(rootPos.X, rootPos.Y)
                    drawings.Line.Visible = true
                else drawings.Line.Visible = false end
                
                if ESP.nameEnabled then
                    drawings.Name.Text = string.format("[%s] [%dm]", player.Name, math.floor(distance))
                    drawings.Name.Position = Vector2.new(headPos.X, headPos.Y - 20)
                    drawings.Name.Visible = true
                else drawings.Name.Visible = false end
                
                if ESP.skeletonEnabled then
                    for _, boneData in pairs(drawings.Skeleton) do
                        local part1 = character:FindFirstChild(boneData.parts[1]) or character:FindFirstChild("Torso")
                        local part2 = character:FindFirstChild(boneData.parts[2]) or character:FindFirstChild("Torso")
                        if part1 and part2 then
                            local pos1, vis1 = Camera:WorldToViewportPoint(part1.Position)
                            local pos2, vis2 = Camera:WorldToViewportPoint(part2.Position)
                            if vis1 or vis2 then
                                boneData.line.From = Vector2.new(pos1.X, pos1.Y)
                                boneData.line.To = Vector2.new(pos2.X, pos2.Y)
                                boneData.line.Visible = true
                            else boneData.line.Visible = false end
                        else boneData.line.Visible = false end
                    end
                else for _, boneData in pairs(drawings.Skeleton) do boneData.line.Visible = false end end
            else
                drawings.Line.Visible = false
                drawings.Name.Visible = false
                for _, boneData in pairs(drawings.Skeleton) do boneData.line.Visible = false end
            end
        end
    end
end)
