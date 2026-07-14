-- DZ STORE Script para Roblox Fluxo PvP (Blatant Aimbot Integrado)
-- Version: 2.0 - Enhanced Performance + ESP

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ==========================================
-- CONFIGURACIONES
-- ==========================================
local Aimbot = {
    enabled = false,
    silentAim = false,  -- Desactivado para modo blatant
    fov = 999,          -- Maximum FOV for blatant targeting
    smoothness = 0,     -- No smoothing for instant lock-on
    aimKey = Enum.UserInputType.MouseButton2,
    teamCheck = false,  -- Target everyone
    showFov = false,    -- Hide FOV for stealth
    fovColor = Color3.fromRGB(255, 0, 0),
    fovTransparency = 0.1,
    bone = "Head",      -- Always aim for head
    maxDistance = 10000,-- Maximum distance
    prediction = true,
    predictionAmount = 0.25, -- Increased prediction
    autoFire = false,   -- Toggleable en el menú
    instantLock = true,
    performanceMode = true
}

local ESP = {
    skeletonEnabled = false,
    lineEnabled = false,
    teamCheck = false,
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
    ToggleAutoFire = Enum.KeyCode.C,  -- Activar/Desactivar Auto-Fire
    ToggleSkeleton = Enum.KeyCode.X,  -- Activar/Desactivar Skeleton ESP
    ToggleLine = Enum.KeyCode.Z       -- Activar/Desactivar Line ESP
}

-- Performance optimization variables
local lastTargetTime = 0
local targetUpdateInterval = 0.016  -- ~60 FPS update rate
local currentTarget = nil

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
Title.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "DZ STORE - Blatant Mode"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

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

local AimbotButton = createButton("AimbotButton", "Blatant Aim [V]: OFF", UDim2.new(0.05, 0, 0.2, 0))
local AutoFireButton = createButton("AutoFireButton", "Auto-Fire [C]: OFF", UDim2.new(0.55, 0, 0.2, 0))
local ESPButton = createButton("ESPButton", "Skeleton ESP [X]: OFF", UDim2.new(0.05, 0, 0.35, 0))
local LineButton = createButton("LineButton", "Line ESP [Z]: OFF", UDim2.new(0.55, 0, 0.35, 0))

-- Lógica de arrastre
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
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

local function UpdateUIStates()
    AimbotButton.Text = Aimbot.enabled and "Blatant Aim [V]: ON" or "Blatant Aim [V]: OFF"
    AimbotButton.BackgroundColor3 = Aimbot.enabled and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(45, 45, 55)
    
    AutoFireButton.Text = Aimbot.autoFire and "Auto-Fire [C]: ON" or "Auto-Fire [C]: OFF"
    AutoFireButton.BackgroundColor3 = Aimbot.autoFire and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(45, 45, 55)
    
    ESPButton.Text = ESP.skeletonEnabled and "Skeleton ESP [X]: ON" or "Skeleton ESP [X]: OFF"
    ESPButton.BackgroundColor3 = ESP.skeletonEnabled and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(45, 45, 55)
    
    LineButton.Text = ESP.lineEnabled and "Line ESP [Z]: ON" or "Line ESP [Z]: OFF"
    LineButton.BackgroundColor3 = ESP.lineEnabled and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(45, 45, 55)
end

AimbotButton.MouseButton1Click:Connect(function() Aimbot.enabled = not Aimbot.enabled; UpdateUIStates() end)
AutoFireButton.MouseButton1Click:Connect(function() Aimbot.autoFire = not Aimbot.autoFire; UpdateUIStates() end)
ESPButton.MouseButton1Click:Connect(function() ESP.skeletonEnabled = not ESP.skeletonEnabled; UpdateUIStates() end)
LineButton.MouseButton1Click:Connect(function() ESP.lineEnabled = not ESP.lineEnabled; UpdateUIStates() end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Keybinds.Menu then MainFrame.Visible = not MainFrame.Visible
    elseif input.KeyCode == Keybinds.ToggleAimbot then Aimbot.enabled = not Aimbot.enabled; UpdateUIStates()
    elseif input.KeyCode == Keybinds.ToggleAutoFire then Aimbot.autoFire = not Aimbot.autoFire; UpdateUIStates()
    elseif input.KeyCode == Keybinds.ToggleSkeleton then ESP.skeletonEnabled = not ESP.skeletonEnabled; UpdateUIStates()
    elseif input.KeyCode == Keybinds.ToggleLine then ESP.lineEnabled = not ESP.lineEnabled; UpdateUIStates()
    elseif input.KeyCode == Enum.KeyCode.F1 then Aimbot.enabled = not Aimbot.enabled; UpdateUIStates() -- Atajo extra solicitado
    end
end)

-- ==========================================
-- BLATANT AIMBOT LOGIC
-- ==========================================
local function IsValidTarget(player)
    if player == LocalPlayer then return false end
    if Aimbot.teamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then return false end
    
    local character = player.Character
    if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then 
        return false 
    end
    return true
end

local function GetClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = Aimbot.fov
    
    for _, player in ipairs(Players:GetPlayers()) do
        if not IsValidTarget(player) then continue end
        
        local character = player.Character
        local targetBone = character:FindFirstChild(Aimbot.bone) or character:FindFirstChild("HumanoidRootPart")
        if not targetBone then continue end
        
        local vector, onScreen = Camera:WorldToViewportPoint(targetBone.Position)
        if not onScreen and Aimbot.fov < 999 then continue end -- Si es 999 FOV, ignora si está en pantalla
        
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
    
    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - target.Position).Magnitude
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
        local dir = (targetPosition - Camera.CFrame.Position).Unit
        local newLook = currentLook:Lerp(dir, 1 - Aimbot.smoothness)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + newLook)
    end
    
    if Aimbot.autoFire and UserInputService:IsMouseButtonPressed(Aimbot.aimKey) then
        if mouse1press then
            mouse1press()
            task.wait(0.1)
            mouse1release()
        end
    end
end

-- ==========================================
-- ESP LOGIC
-- ==========================================
local ESP_Drawings = {}

local function createDrawings(player)
    local drawings = { Line = Drawing.new("Line"), Skeleton = {} }
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

Players.PlayerRemoving:Connect(function(player)
    if ESP_Drawings[player] then
        ESP_Drawings[player].Line:Remove()
        for _, obj in pairs(ESP_Drawings[player].Skeleton) do obj.line:Remove() end
        ESP_Drawings[player] = nil
    end
end)

-- ==========================================
-- MAIN LOOP (RENDERING & AIMBOT)
-- ==========================================
RunService.RenderStepped:Connect(function()
    -- 1. BLATANT AIMBOT LOOP
    if Aimbot.enabled then
        local currentTime = tick()
        if not Aimbot.performanceMode or (currentTime - lastTargetTime) > targetUpdateInterval then
            lastTargetTime = currentTime
            
            if Aimbot.instantLock then
                local target = GetClosestPlayerToCursor()
                if target then
                    currentTarget = target
                    AimAt(target)
                else
                    currentTarget = nil
                end
            else
                if UserInputService:IsMouseButtonPressed(Aimbot.aimKey) then
                    local target = GetClosestPlayerToCursor()
                    if target then
                        currentTarget = target
                        AimAt(target)
                    else
                        currentTarget = nil
                    end
                else
                    currentTarget = nil
                end
            end
        else
            if currentTarget and IsValidTarget(currentTarget) then
                AimAt(currentTarget)
            else
                currentTarget = nil
            end
        end
    end

    -- 2. ESP LOOP
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        if not ESP_Drawings[player] then createDrawings(player) end
        
        local drawings = ESP_Drawings[player]
        local isEnemy = IsValidTarget(player) 
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        local shouldDraw = isEnemy and (ESP.skeletonEnabled or ESP.lineEnabled)
        
        if shouldDraw and rootPart then
            local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
            
            if onScreen and distance < ESP.maxDistance then
                -- Tracers (Line ESP)
                if ESP.lineEnabled then
                    drawings.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
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
