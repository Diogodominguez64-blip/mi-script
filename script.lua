-- DZ STORE V3 - Neon UI Redesign (Optimized)
-- Version: 3.4 (Aimbot, Name ESP, Silent Aim, Wall Check, FOV & Smoothness Slider, Teleportation Fix + Mobile Button)
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera or workspace:WaitForChild("Camera")
local LocalPlayer = Players.LocalPlayer

local Theme = {
    Background = Color3.fromRGB(15, 15, 18),
    HeaderBg = Color3.fromRGB(25, 25, 30),
    NeonAccent = Color3.fromRGB(57, 255, 20),
    ElementBg = Color3.fromRGB(24, 24, 28),
    Text = Color3.fromRGB(245, 245, 245),
    TextDark = Color3.fromRGB(10, 10, 10),
    Inactive = Color3.fromRGB(40, 40, 48),
    SearchBg = Color3.fromRGB(30, 30, 35)
}

local Aimbot = {
    enabled = true,
    fov = 150,
    smoothness = 70, -- 1 = Agresivo/Instantáneo, 100 = Muy Suave/Legit
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

local NoRecoil = { enabled = false }
local Teleportation = { enabled = false, maxDistance = 200 }

-- FOV Circle setup
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Aimbot.fovColor
fovCircle.Thickness = 1.5
fovCircle.NumSides = 64
fovCircle.Radius = Aimbot.fov
fovCircle.Filled = false
fovCircle.Transparency = Aimbot.fovTransparency
fovCircle.Visible = Aimbot.showFov

-- Notify User
game.StarterGui:SetCore("SendNotification", {
    Title = "DZ STORE V3",
    Text = "Hacks cargados con éxito.",
    Duration = 5
})

-- ==========================================
-- VALIDATION UTILITIES
-- ==========================================

local function IsBehindWall(targetPart)
    if not Aimbot.wallCheck then return false end
    local char = LocalPlayer.Character
    if char and targetPart then
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {char}
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        local direction = (targetPart.Position - Camera.CFrame.Position)
        local raycastResult = workspace:Raycast(Camera.CFrame.Position, direction, raycastParams)
        if raycastResult and not raycastResult.Instance:IsDescendantOf(targetPart.Parent) then
            return true
        end
    end
    return false
end

local function IsValidTarget(player)
    if player == LocalPlayer then return false end
    local char = player.Character
    if not char or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then return false end
    if Aimbot.teamCheck and player.Team == LocalPlayer.Team then return false end
    local targetBone = char:FindFirstChild(Aimbot.bone) or char:FindFirstChild("HumanoidRootPart")
    if targetBone and IsBehindWall(targetBone) then return false end
    return true
end

local function IsESPValid(player)
    if player == LocalPlayer then return false end
    if ESP.teamCheck and player.Team == LocalPlayer.Team then return false end
    local char = player.Character
    return char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0
end

-- ==========================================
-- AIMBOT & SILENT AIM LOGIC
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
    return closestPlayer, shortestDistance
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
    
    local lerpStep = 1 - ((Aimbot.smoothness - 1) / 99)
    lerpStep = math.clamp(lerpStep, 0.01, 1)

    if Aimbot.instantLock or Aimbot.smoothness == 1 then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
    else
        local currentLook = Camera.CFrame.LookVector
        local targetDir = (targetPosition - Camera.CFrame.Position).Unit
        local newLook = currentLook:Lerp(targetDir, lerpStep)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + newLook)
    end
end

-- Silent Aim Auxiliar functions (Restaurado 100% como pediste + Fix del Error de Sintaxis)
local function isAimingAtEnemy(player)
    local character = player.Character
    if not character then return false end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end

    local camera = workspace.CurrentCamera
    local cameraCFrame = camera.CFrame

    -- Línea original restaurada
    local aimDirection = (cameraCFrame.LookVector * 1000) + cameraCFrame.Position

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    local result = workspace:Raycast(cameraCFrame.Position, cameraCFrame.LookVector * 1000, raycastParams)
    if result and result.Instance and result.Instance:IsA("BasePart") then
        local enemy = result.Instance:FindFirstAncestorOfClass("Model")
        if enemy and enemy:IsA("Model") and enemy:FindFirstChildOfClass("Humanoid") then
            return true, enemy
        end
    end

    return false, nil
end

local function simulateHit(player, enemy)
    local humanoid = enemy:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local fakeHit = Instance.new("RemoteEvent")
        fakeHit.Name = "FakeHit"
        fakeHit.Parent = player
        fakeHit:FireServer(enemy, humanoid)
    end
end

local function ExecuteSilentAim()
    if not Aimbot.silentAim then return end
    local closestEnemy = GetClosestPlayerToCursor()
    if closestEnemy and closestEnemy.Character then
        local enemyPart = closestEnemy.Character:FindFirstChild(Aimbot.silentAimPart)
        if enemyPart then
            simulateHit(LocalPlayer, closestEnemy.Character)
        end
    end
end

-- ==========================================
-- USER INTERFACE DESIGN & BOTONES FLOTANTES
-- ==========================================

local function create(className, properties, parent)
   local obj = Instance.new(className)
    for prop, val in pairs(properties) do obj[prop] = val end
    if parent then obj.Parent = parent end
    return obj
end

local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
local ScreenGui = create("ScreenGui", { Name = "DZ_STORE_V3_GUI", ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, success and coreGui or LocalPlayer:WaitForChild("PlayerGui"))

local MainFrame = create("Frame", {
    Name = "MainFrame", Size = UDim2.new(0, 360, 0, 480), Position = UDim2.new(0.5, -180, 0.5, -240),
    BackgroundColor3 = Theme.Background, BackgroundTransparency = 0.05, ClipsDescendants = true, Visible = true
}, ScreenGui)
create("UICorner", { CornerRadius = UDim.new(0, 12) }, MainFrame)

local Header = create("Frame", { Name = "Header", Size = UDim2.new(1, 0, 0, 65), BackgroundColor3 = Theme.HeaderBg, BorderSizePixel = 0 }, MainFrame)
create("UICorner", { CornerRadius = UDim.new(0, 12) }, Header)

local LogoImage = create("ImageLabel", {
    Name = "LogoImage", Size = UDim2.new(1, -40, 1, -10), Position = UDim2.new(0, 20, 0, 5),
    BackgroundTransparency = 1, Image = "logo.png", ScaleType = Enum.ScaleType.Fit
}, Header)

local FallbackText = create("TextLabel", {
    Name = "HeaderText", Text = "DZ STORE V3", TextColor3 = Theme.NeonAccent, TextSize = 22,
    Font = Enum.Font.GothamBold, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false
}, Header)

LogoImage:GetPropertyChangedSignal("IsLoaded"):Connect(function()
    if not LogoImage.IsLoaded then
        LogoImage.Visible = false
        FallbackText.Visible = true
    end
end)

local SearchBar = create("TextBox", {
    Name = "SearchBar", Size = UDim2.new(0.9, 0, 0, 35), Position = UDim2.new(0.05, 0, 0, 75),
    BackgroundColor3 = Theme.SearchBg, TextColor3 = Theme.Text, PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
    TextSize = 14, Font = Enum.Font.SourceSans, PlaceholderText = "Buscar función...", Text = ""
}, MainFrame)
create("UICorner", { CornerRadius = UDim.new(0, 8) }, SearchBar)

local ContentFrame = create("ScrollingFrame", {
    Name = "ContentFrame", Size = UDim2.new(1, -20, 1, -135), Position = UDim2.new(0, 10, 0, 120),
    BackgroundTransparency = 1, CanvasSize = UDim2.new(0, 0, 0, 0), ScrollBarThickness = 4, ScrollBarImageColor3 = Theme.NeonAccent
}, MainFrame)

local ListLayout = create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, ContentFrame)
ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
end)

-- Botón Flotante V3 (Menú)
local MobileFloatingButton = create("TextButton", {
    Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(1, -70, 0, 30), BackgroundColor3 = Theme.Background,
    Text = "V3", Font = Enum.Font.GothamBlack, TextSize = 16, TextColor3 = Theme.NeonAccent, BorderSizePixel = 0
}, ScreenGui)
create("UICorner", { CornerRadius = UDim.new(1, 0) }, MobileFloatingButton)
create("UIStroke", { Thickness = 2, Color = Theme.NeonAccent, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, MobileFloatingButton)

-- Botón Flotante para TP
local TPMobileButton = create("TextButton", {
    Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(1, -70, 0, 90), BackgroundColor3 = Theme.Background,
    Text = "TP\nOFF", Font = Enum.Font.GothamBlack, TextSize = 13, TextColor3 = Theme.Text, BorderSizePixel = 0
}, ScreenGui)
create("UICorner", { CornerRadius = UDim.new(1, 0) }, TPMobileButton)
local TPStroke = create("UIStroke", { Thickness = 2, Color = Theme.Inactive, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, TPMobileButton)

local function UpdateTPVisuals()
    if Teleportation.enabled then
        TPMobileButton.Text = "TP\nON"
        TPMobileButton.TextColor3 = Theme.NeonAccent
        TPStroke.Color = Theme.NeonAccent
    else
        TPMobileButton.Text = "TP\nOFF"
        TPMobileButton.TextColor3 = Theme.Text
        TPStroke.Color = Theme.Inactive
    end
end

TPMobileButton.MouseButton1Click:Connect(function()
    Teleportation.enabled = not Teleportation.enabled
    UpdateTPVisuals()
end)

local function ToggleMenu() MainFrame.Visible = not MainFrame.Visible end
MobileFloatingButton.MouseButton1Click:Connect(ToggleMenu)

local dragging, dragInput, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ==========================================
-- GUI CREATION HELPERS
-- ==========================================

local function CreateSection(text)
    create("TextLabel", {
        Size = UDim2.new(1, -10, 0, 30), Text = text:upper(), TextColor3 = Theme.NeonAccent,
        Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1
    }, ContentFrame)
end

local function CreateToggle(name, tableRef, configKey)
    local container = create("Frame", { Size = UDim2.new(1, -10, 0, 44), BackgroundColor3 = Theme.ElementBg, BorderSizePixel = 0 }, ContentFrame)
    create("UICorner", { CornerRadius = UDim.new(0, 8) }, container)

    create("TextLabel", {
        Size = UDim2.new(0.6, 0, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1,
        Text = name, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.GothamSemibold, TextSize = 14
    }, container)

    local btn = create("TextButton", {
        Size = UDim2.new(0, 60, 0, 26), Position = UDim2.new(1, -72, 0.5, -13), Text = tableRef[configKey] and "ON" or "OFF",
        BackgroundColor3 = tableRef[configKey] and Theme.NeonAccent or Theme.Inactive,
        TextColor3 = tableRef[configKey] and Theme.TextDark or Theme.Text,
        Font = Enum.Font.GothamBold, TextSize = 12, BorderSizePixel = 0
    }, container)
    create("UICorner", { CornerRadius = UDim.new(0, 6) }, btn)

    btn.MouseButton1Click:Connect(function()
        tableRef[configKey] = not tableRef[configKey]
        btn.Text = tableRef[configKey] and "ON" or "OFF"
        TweenService:Create(btn, TweenInfo.new(0.2), { BackgroundColor3 = tableRef[configKey] and Theme.NeonAccent or Theme.Inactive, TextColor3 = tableRef[configKey] and Theme.TextDark or Theme.Text }):Play()
        if configKey == "showFov" or configKey == "enabled" then fovCircle.Visible = Aimbot.enabled and Aimbot.showFov end
        if configKey == "enabled" and tableRef == Teleportation then UpdateTPVisuals() end -- Sincronizar botón de menú con el flotante
    end)
end

local function CreateSlider(name, tableRef, configKey, min, max)
    local container = create("Frame", { Size = UDim2.new(1, -10, 0, 65), BackgroundColor3 = Theme.ElementBg, BorderSizePixel = 0 }, ContentFrame)
    create("UICorner", { CornerRadius = UDim.new(0, 8) }, container)

    local label = create("TextLabel", {
        Size = UDim2.new(1, -24, 0, 25), Position = UDim2.new(0, 12, 0, 4), BackgroundTransparency = 1,
        Text = name .. ": " .. tostring(tableRef[configKey]), TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.GothamSemibold, TextSize = 14
    }, container)

    local sliderBar = create("TextButton", { Size = UDim2.new(1, -24, 0, 8), Position = UDim2.new(0, 12, 0, 38), BackgroundColor3 = Theme.Inactive, BorderSizePixel = 0, Text = "" }, container)
    create("UICorner", { CornerRadius = UDim.new(0, 4) }, sliderBar)

    local valRatio = (tableRef[configKey] - min) / (max - min)
    local sliderFill = create("Frame", { Size = UDim2.new(valRatio, 0, 1, 0), BackgroundColor3 = Theme.NeonAccent, BorderSizePixel = 0 }, sliderBar)
    create("UICorner", { CornerRadius = UDim.new(0, 4) }, sliderFill)

    local sliderButton = create("TextButton", { Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(valRatio, -8, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, Text = "" }, sliderBar)
    create("UICorner", { CornerRadius = UDim.new(1, 0) }, sliderButton)

    local isSliding = false
    local function updateSliderValue()
        local relativeX = UserInputService:GetMouseLocation().X - sliderBar.AbsolutePosition.X
        local percentage = math.clamp(relativeX / sliderBar.AbsoluteSize.X, 0, 1)
        sliderButton.Position = UDim2.new(percentage, -8, 0.5, -8)
        sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        local value = math.floor(min + (percentage * (max - min)))
        tableRef[configKey] = value
        label.Text = name .. ": " .. tostring(value)
        if configKey == "fov" then fovCircle.Radius = value end
    end

    sliderButton.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isSliding = true end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isSliding = false end end)
    UserInputService.InputChanged:Connect(function(input) if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSliderValue() end end)
end

SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
    local query = SearchBar.Text:lower()
    for _, child in ipairs(ContentFrame:GetChildren()) do
        if child:IsA("Frame") then
            local label = child:FindFirstChildOfClass("TextLabel")
            child.Visible = label and string.find(label.Text:lower(), query) ~= nil
        elseif child:IsA("TextLabel") then
            child.Visible = string.find(child.Text:lower(), query) ~= nil or query == ""
        end
    end
end)

CreateToggle("Comprobación de Equipo", Aimbot, "teamCheck")
CreateToggle("Predicción de Movimiento", Aimbot, "prediction")
CreateSection("SILENT AIM")
CreateToggle("Habilitar Silent Aim", Aimbot, "silentAim")
CreateSection("SISTEMA VISUAL (ESP)")
CreateToggle("ESP Nombre y Distancia", ESP, "nameEnabled")
CreateToggle("ESP Esqueleto", ESP, "skeletonEnabled")
CreateToggle("ESP Snaplines (Líneas)", ESP, "lineEnabled")
CreateSection("NO RECOIL")
CreateToggle("Habilitar No Recoil", NoRecoil, "enabled")
CreateSection("TELEPORTACIÓN")
CreateToggle("Habilitar Teleportación", Teleportation, "enabled")
CreateSlider("Distancia Máxima de Teleportación (metros)", Teleportation, "maxDistance", 100, 500)

-- ==========================================
-- KEYBINDS
-- ==========================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then ToggleMenu() end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local player = Players.LocalPlayer
        local isAiming, enemy = isAimingAtEnemy(player)
        if isAiming then simulateHit(player, enemy) end
    end
    if input.KeyCode == Enum.KeyCode.T then
        Teleportation.enabled = not Teleportation.enabled
        UpdateTPVisuals()
        game.StarterGui:SetCore("SendNotification", { Title = "TP Status", Text = "Teleportación: " .. (Teleportation.enabled and "ACTIVADA" or "DESACTIVADA"), Duration = 2 })
    end
end)

-- ==========================================
-- RUN LOOPS AND CONTINUOUS EXECUTION
-- ==========================================

local lastTargetTime, targetUpdateInterval, currentTarget = 0, 0.016, nil

RunService.Heartbeat:Connect(function()
    if Aimbot.silentAim then ExecuteSilentAim() end
    
    if NoRecoil.enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        local handle = tool and tool:FindFirstChildOfClass("BasePart")
        if handle then handle.CFrame = CFrame.new(handle.CFrame.Position, LocalPlayer:GetMouse().Hit.Position) end
    end
    
    -- LÓGICA DE TP CORREGIDA Y CON PRINTS ORIGINALES RESTAURADOS
    if Teleportation.enabled then
        local closestPlayer, _ = GetClosestPlayerToCursor()
        if closestPlayer then
            local targetCharacter = closestPlayer.Character
            local myHumanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if targetCharacter and myHumanoidRootPart then
                local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
                if targetRootPart then
                    -- Calculamos la distancia REAL en metros en el mundo 3D
                    local distance3D = (myHumanoidRootPart.Position - targetRootPart.Position).Magnitude
                    
                    if distance3D <= Teleportation.maxDistance then
                        -- El offset * CFrame.new(0, 0, 3) evita que te buguees/choques contra el enemigo
                        myHumanoidRootPart.CFrame = targetRootPart.CFrame * CFrame.new(0, 0, 3)
                        myHumanoidRootPart.Velocity = Vector3.new(0,0,0) -- Evitar que el personaje salga volando
                        print("Teleported to " .. closestPlayer.Name .. " at a distance of " .. distance3D .. " meters.")
                    else
                        print("No players were found within " .. Teleportation.maxDistance .. " meters.")
                    end
                end
            else
                print("No valid players found.")
            end
        else
            print("No players were found within " .. Teleportation.maxDistance .. " meters.")
        end
    end
end)

RunService.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    fovCircle.Radius = Aimbot.fov
    fovCircle.Visible = Aimbot.enabled and Aimbot.showFov

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

    -- Render ESP Draw calls
    for _, player in ipairs(Players:GetPlayers()) do
        if not IsESPValid(player) then
            ClearPlayerESP(player)
            continue
        end
        if not ESP_Drawings[player] then createDrawings(player) end
        
        local drawings = ESP_Drawings[player]
        local char = player.Character
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        local headPart = char:FindFirstChild("Head")
        
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
                    for _, boneData in ipairs(drawings.Skeleton) do
                        local part1 = char:FindFirstChild(boneData.parts[1]) or char:FindFirstChild("Torso")
                        local part2 = char:FindFirstChild(boneData.parts[2]) or char:FindFirstChild("Torso")
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
                else for _, boneData in ipairs(drawings.Skeleton) do boneData.line.Visible = false end end
            else
                drawings.Line.Visible = false
                drawings.Name.Visible = false
                for _, boneData in ipairs(drawings.Skeleton) do boneData.line.Visible = false end
            end
        end
    end
end)
