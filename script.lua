-- DZ STORE Script para Roblox Fluxo PvP (Actualizado con Aimbot y ESP Avanzados)
-- Creado para proporcionar ventajas competitivas en el juego

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ==========================================
-- CONFIGURACIONES DEL MOD MENU
-- ==========================================
local Aimbot = {
    enabled = false,
    silentAim = false,
    fov = 50,
    smoothness = 0.2,
    aimKey = Enum.UserInputType.MouseButton2,
    teamCheck = true,
    showFov = false,
    fovColor = Color3.fromRGB(255, 0, 100),
    fovTransparency = 0.8,
    bone = "Head",
    prediction = true,
    predictionAmount = 0.15
}

local ESP = {
    skeletonEnabled = false,
    lineEnabled = false,
    teamCheck = true,
    boxThickness = 1.5,
    boxColor = Color3.fromRGB(255, 0, 100),
    skeletonThickness = 1.5,
    skeletonColor = Color3.fromRGB(255, 255, 255),
    lineThickness = 1.5,
    lineColor = Color3.fromRGB(255, 0, 100),
    maxDistance = 1000
}

-- ATAJOS DE TECLADO (Keybinds)
local Keybinds = {
    Menu = Enum.KeyCode.Insert,       -- Mostrar/Ocultar Menú
    ToggleAimbot = Enum.KeyCode.V,    -- Activar/Desactivar Aimbot
    ToggleSilent = Enum.KeyCode.C,    -- Activar/Desactivar Silent Aim
    ToggleSkeleton = Enum.KeyCode.X,  -- Activar/Desactivar Skeleton ESP
    ToggleLine = Enum.KeyCode.Z       -- Activar/Desactivar Line ESP
}

-- ==========================================
-- INTERFAZ GRÁFICA (GUI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DZ_STORE_GUI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Visible = true

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", MainFrame)
Title.Name = "Title"
Title.BackgroundColor3 = Color3.fromRGB(255, 0, 100)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "DZ STORE - Fluxo PvP"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

-- Función para crear botones estándar
local function createButton(name, text, pos)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Name = name
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    btn.Position = pos
    btn.Size = UDim2.new(0.4, 0, 0, 30)
    btn.Font = Enum.Font.Gotham
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    return btn
end

local AimbotButton = createButton("AimbotButton", "Aimbot [V]: OFF", UDim2.new(0.05, 0, 0.2, 0))
local SilentAimButton = createButton("SilentAimButton", "Silent Aim [C]: OFF", UDim2.new(0.55, 0, 0.2, 0))
local ESPButton = createButton("ESPButton", "Skeleton ESP [X]: OFF", UDim2.new(0.05, 0, 0.35, 0))
local LineButton = createButton("LineButton", "Line ESP [Z]: OFF", UDim2.new(0.55, 0, 0.35, 0))

local RadiusLabel = Instance.new("TextLabel", MainFrame)
RadiusLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
RadiusLabel.Position = UDim2.new(0.05, 0, 0.5, 0)
RadiusLabel.Size = UDim2.new(0.9, 0, 0, 25)
RadiusLabel.Font = Enum.Font.Gotham
RadiusLabel.Text = "Aim Radius: 50"
RadiusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
RadiusLabel.TextSize = 14
Instance.new("UICorner", RadiusLabel).CornerRadius = UDim.new(0, 5)

local RadiusSlider = Instance.new("TextButton", MainFrame)
RadiusSlider.BackgroundColor3 = Color3.fromRGB(255, 0, 100)
RadiusSlider.Position = UDim2.new(0.05, 0, 0.65, 0)
RadiusSlider.Size = UDim2.new(0.9, 0, 0, 10)
RadiusSlider.AutoButtonColor = false
RadiusSlider.Text = ""
Instance.new("UICorner", RadiusSlider).CornerRadius = UDim.new(0, 5)

local SliderButton = Instance.new("TextButton", RadiusSlider)
SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderButton.Position = UDim2.new(0.16, -10, 0.5, -10) -- 50/300 inicial
SliderButton.Size = UDim2.new(0, 20, 0, 20)
SliderButton.AutoButtonColor = false
SliderButton.Text = ""
Instance.new("UICorner", SliderButton).CornerRadius = UDim.new(0, 10)

-- Lógica de arrastre para el menú principal
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Círculo visual del campo de visión (FOV)
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1.5
fovCircle.Color = Aimbot.fovColor
fovCircle.Transparency = Aimbot.fovTransparency
fovCircle.Filled = false
fovCircle.Radius = Aimbot.fov
fovCircle.Visible = false

-- ==========================================
-- ACTUALIZACIÓN DE BOTONES Y VARIABLES
-- ==========================================
local function UpdateUIStates()
    AimbotButton.Text = Aimbot.enabled and "Aimbot [V]: ON" or "Aimbot [V]: OFF"
    AimbotButton.BackgroundColor3 = Aimbot.enabled and Color3.fromRGB(255, 0, 100) or Color3.fromRGB(45, 45, 55)
    
    SilentAimButton.Text = Aimbot.silentAim and "Silent Aim [C]: ON" or "Silent Aim [C]: OFF"
    SilentAimButton.BackgroundColor3 = Aimbot.silentAim and Color3.fromRGB(255, 0, 100) or Color3.fromRGB(45, 45, 55)
    
    ESPButton.Text = ESP.skeletonEnabled and "Skeleton ESP [X]: ON" or "Skeleton ESP [X]: OFF"
    ESPButton.BackgroundColor3 = ESP.skeletonEnabled and Color3.fromRGB(255, 0, 100) or Color3.fromRGB(45, 45, 55)
    
    LineButton.Text = ESP.lineEnabled and "Line ESP [Z]: ON" or "Line ESP [Z]: OFF"
    LineButton.BackgroundColor3 = ESP.lineEnabled and Color3.fromRGB(255, 0, 100) or Color3.fromRGB(45, 45, 55)
    
    Aimbot.showFov = (Aimbot.enabled or Aimbot.silentAim)
    fovCircle.Visible = Aimbot.showFov
end

AimbotButton.MouseButton1Click:Connect(function() Aimbot.enabled = not Aimbot.enabled; UpdateUIStates() end)
SilentAimButton.MouseButton1Click:Connect(function() Aimbot.silentAim = not Aimbot.silentAim; UpdateUIStates() end)
ESPButton.MouseButton1Click:Connect(function() ESP.skeletonEnabled = not ESP.skeletonEnabled; UpdateUIStates() end)
LineButton.MouseButton1Click:Connect(function() ESP.lineEnabled = not ESP.lineEnabled; UpdateUIStates() end)

-- Lógica del Slider de Radio (FOV)
local isSliding = false
SliderButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then isSliding = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then isSliding = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if isSliding and input.UserInputType == Enum.UserInputType.MouseMovement then
        local relativeX = input.Position.X - RadiusSlider.AbsolutePosition.X
        local percentage = math.clamp(relativeX / RadiusSlider.AbsoluteSize.X, 0, 1)
        SliderButton.Position = UDim2.new(percentage, -10, 0.5, -10)
        Aimbot.fov = math.floor(percentage * 300)
        RadiusLabel.Text = "Aim Radius: " .. tostring(Aimbot.fov)
        fovCircle.Radius = Aimbot.fov
    end
end)

-- Sistema de Atajos (Keybinds)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Keybinds.Menu then
        MainFrame.Visible = not MainFrame.Visible
    elseif input.KeyCode == Keybinds.ToggleAimbot then
        Aimbot.enabled = not Aimbot.enabled; UpdateUIStates()
    elseif input.KeyCode == Keybinds.ToggleSilent then
        Aimbot.silentAim = not Aimbot.silentAim; UpdateUIStates()
    elseif input.KeyCode == Keybinds.ToggleSkeleton then
        ESP.skeletonEnabled = not ESP.skeletonEnabled; UpdateUIStates()
    elseif input.KeyCode == Keybinds.ToggleLine then
        ESP.lineEnabled = not ESP.lineEnabled; UpdateUIStates()
    end
end)


-- ==========================================
-- LÓGICA CORE: AIMBOT & SILENT AIM
-- ==========================================
local function IsEnemy(player)
    if not Aimbot.teamCheck then return true end
    if player.Team and LocalPlayer.Team then
        return player.Team ~= LocalPlayer.Team
    end
    return true
end

local function GetClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = Aimbot.fov
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer or not IsEnemy(player) then continue end
        
        local character = player.Character
        if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then continue end
        
        local targetBone = character:FindFirstChild(Aimbot.bone) or character:FindFirstChild("HumanoidRootPart")
        if not targetBone then continue end
        
        local vector, onScreen = Camera:WorldToViewportPoint(targetBone.Position)
        if not onScreen then continue end
        
        local mousePosition = UserInputService:GetMouseLocation()
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
    local distance = (Camera.CFrame.Position - target.Position).Magnitude
    local timeToReach = distance / 1000
    
    return target.Position + (velocity * timeToReach * Aimbot.predictionAmount)
end

local function SetSilentAim(targetPosition)
    local character = LocalPlayer.Character
    if not character then return end
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return end
    
    -- Modifica la dirección de la herramienta (típico para hitbox extensor o proyectiles directos)
    if tool:FindFirstChild("Handle") then
        tool.Handle.CFrame = CFrame.new(tool.Handle.Position, targetPosition)
    end
end

-- ==========================================
-- LÓGICA CORE: ESP (SKELETON & LINES)
-- ==========================================
local ESP_Drawings = {}

local function createDrawings(player)
    local drawings = {
        Line = Drawing.new("Line"),
        Skeleton = {}
    }
    
    -- Conexiones típicas para un esqueleto R15/R6
    local bones = {
        {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
        {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
        {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
        {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"}
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
    
    ESP_Drawings[player] = drawings
end

local function removeDrawings(player)
    if ESP_Drawings[player] then
        ESP_Drawings[player].Line:Remove()
        for _, obj in pairs(ESP_Drawings[player].Skeleton) do
            obj.line:Remove()
        end
        ESP_Drawings[player] = nil
    end
end

Players.PlayerRemoving:Connect(removeDrawings)

-- BUCLE PRINCIPAL (RENDER STEPPED)
RunService.RenderStepped:Connect(function()
    -- Actualizar FOV UI
    local mouseLocation = UserInputService:GetMouseLocation()
    fovCircle.Position = mouseLocation

    -- 1. AIMBOT LÓGICA
    if (Aimbot.enabled or Aimbot.silentAim) and UserInputService:IsMouseButtonPressed(Aimbot.aimKey) then
        local target = GetClosestPlayerToCursor()
        if target and target.Character then
            local targetBone = target.Character:FindFirstChild(Aimbot.bone) or target.Character:FindFirstChild("HumanoidRootPart")
            if targetBone then
                local targetPosition = GetPredictedPosition(targetBone)
                
                if Aimbot.silentAim then
                    SetSilentAim(targetPosition)
                elseif Aimbot.enabled then
                    local currentLook = Camera.CFrame.LookVector
                    local targetDir = (targetPosition - Camera.CFrame.Position).Unit
                    local newLook = currentLook:Lerp(targetDir, Aimbot.smoothness)
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + newLook)
                end
            end
        end
    end

    -- 2. ESP LÓGICA
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        if not ESP_Drawings[player] then
            createDrawings(player)
        end
        
        local drawings = ESP_Drawings[player]
        local isEnemy = IsEnemy(player)
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local isAlive = character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0
        
        local shouldDraw = isAlive and isEnemy and (ESP.skeletonEnabled or ESP.lineEnabled)
        
        if shouldDraw and rootPart then
            local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
            
            if onScreen and distance < ESP.maxDistance then
                -- Tracers (Line ESP)
                if ESP.lineEnabled then
                    drawings.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y) -- Desde abajo al centro
                    drawings.Line.To = Vector2.new(rootPos.X, rootPos.Y)
                    drawings.Line.Visible = true
                else
                    drawings.Line.Visible = false
                end
                
                -- Skeleton ESP
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
                            else
                                boneData.line.Visible = false
                            end
                        else
                            boneData.line.Visible = false
                        end
                    end
                else
                    for _, boneData in pairs(drawings.Skeleton) do boneData.line.Visible = false end
                end
            else
                drawings.Line.Visible = false
                for _, boneData in pairs(drawings.Skeleton) do boneData.line.Visible = false end
            end
        else
            drawings.Line.Visible = false
            for _, boneData in pairs(drawings.Skeleton) do boneData.line.Visible = false end
        end
    end
end)
