-- ==========================================
-- DZ STORE V1 - Neon UI Redesign
-- Version: 4.0 (Aimbot, ESP, Silent Aim)
-- ==========================================

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Theme Colors (Dark & Neon Green)
local Theme = {
    Background = Color3.fromRGB(15, 15, 18),
    NeonAccent = Color3.fromRGB(57, 255, 20), -- Neon Green matching the logo
    ElementBg = Color3.fromRGB(24, 24, 28),
    Text = Color3.fromRGB(245, 245, 245),
    TextDark = Color3.fromRGB(10, 10, 10),
    Inactive = Color3.fromRGB(40, 40, 48),
    GlowTransparency = 0.6
}

-- Configurations
local Aimbot = {
    enabled = true,
    fov = 150,
    smoothness = 0.3,
    aimKey = Enum.UserInputType.MouseButton2,
    teamCheck = false,
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
    skeletonEnabled = true,
    lineEnabled = true,
    skeletonThickness = 1.5,
    skeletonColor = Color3.fromRGB(255, 255, 255),
    lineThickness = 1.5,
    lineColor = Theme.NeonAccent,
    maxDistance = 3000,
    teamCheck = false
}

-- FOV Circle Graphic
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Aimbot.fovColor
fovCircle.Thickness = 1.5
fovCircle.NumSides = 64
fovCircle.Radius = Aimbot.fov
fovCircle.Filled = false
fovCircle.Transparency = Aimbot.fovTransparency
fovCircle.Visible = Aimbot.showFov

-- ==========================================
-- CORE VALIDATION FUNCTIONS
-- ==========================================

local function IsValidTarget(player)
    if player == LocalPlayer then return false end
    local character = player.Character
    if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then 
        return false 
    end
    if Aimbot.teamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then 
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
-- SILENT AIM (TOOL AUTO-SHOOT) LOGIC
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
        local enemyPart = closestEnemy.Character:FindFirstChild(Aimbot.silentAimPart)
        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if enemyPart and rootPart then
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {character}
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
            
            local direction = (enemyPart.Position - rootPart.Position).Unit * 500
            local raycastResult = workspace:Raycast(rootPart.Position, direction, raycastParams)
            
            if raycastResult and raycastResult.Instance:IsDescendantOf(closestEnemy.Character) then
                local tool = character:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                end
            end
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
-- BLATANT AIMBOT CORE LOGIC
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
    
    if Aimbot.autoFire and UserInputService:IsMouseButtonPressed(Aimbot.aimKey) and mouse1press then
        mouse1press()
        task.wait(0.05)
        mouse1release()
    end
end

-- ==========================================
-- STABLE SKELETON & LINE ESP LOGIC
-- ==========================================

local ESP_Drawings = {}

local function createDrawings(player)
    local drawings = { Line = Drawing.new("Line"), Skeleton = {} }
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
    
    ESP_Drawings[player] = drawings
end

local function ClearPlayerESP(player)
    if ESP_Drawings[player] then
        ESP_Drawings[player].Line:Remove()
        for _, obj in pairs(ESP_Drawings[player].Skeleton) do obj.line:Remove() end
        ESP_Drawings[player] = nil
    end
end

Players.PlayerRemoving:Connect(ClearPlayerESP)

-- ==========================================
-- MAIN TICK RUNNERS
-- ==========================================

local lastTargetTime = 0
local targetUpdateInterval = 0.016
local currentTarget = nil

RunService.Heartbeat:Connect(function()
    if Aimbot.silentAim then
        ExecuteSilentAim()
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
            else
                if UserInputService:IsMouseButtonPressed(Aimbot.aimKey) then
                    currentTarget = GetClosestPlayerToCursor()
                    AimAt(currentTarget)
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

    for _, player in pairs(Players:GetPlayers()) do
        if not IsESPValid(player) then
            ClearPlayerESP(player)
            continue
        end
        
        if not ESP_Drawings[player] then createDrawings(player) end
        
        local drawings = ESP_Drawings[player]
        local character = player.Character
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        
        if rootPart then
            local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local distance = localRoot and (localRoot.Position - rootPart.Position).Magnitude or (Camera.CFrame.Position - rootPart.Position).Magnitude
            
            if onScreen and distance < ESP.maxDistance then
                if ESP.lineEnabled then
                    drawings.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    drawings.Line.To = Vector2.new(rootPos.X, rootPos.Y)
                    drawings.Line.Visible = true
                else
                    drawings.Line.Visible = false
                end
                
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

-- ==========================================
-- MOD MENU GUI CREATION (NEON REDESIGN)
-- ==========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DZ_STORE_NEON"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Drag Frame
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 340, 0, 480)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -240)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- Neon Glow for Main Frame
local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = MainFrame
MainStroke.Color = Theme.NeonAccent
MainStroke.Thickness = 2
MainStroke.Transparency = 0.2

-- Mobile Floating Button
local MobileFloatingButton = Instance.new("TextButton")
MobileFloatingButton.Parent = ScreenGui
MobileFloatingButton.Size = UDim2.new(0, 56, 0, 56)
MobileFloatingButton.Position = UDim2.new(1, -70, 0, 30)
MobileFloatingButton.BackgroundColor3 = Theme.Background
MobileFloatingButton.Text = "DZ"
MobileFloatingButton.Font = Enum.Font.GothamBlack
MobileFloatingButton.TextColor3 = Theme.NeonAccent
MobileFloatingButton.TextSize = 20
MobileFloatingButton.BorderSizePixel = 0
MobileFloatingButton.Active = true
MobileFloatingButton.Draggable = true
Instance.new("UICorner", MobileFloatingButton).CornerRadius = UDim.new(1, 0)

-- Floating Button Neon Stroke
local FloatStroke = Instance.new("UIStroke")
FloatStroke.Parent = MobileFloatingButton
FloatStroke.Color = Theme.NeonAccent
FloatStroke.Thickness = 2.5
FloatStroke.Transparency = 0.1

-- Top Header / Logo Container
local HeaderFrame = Instance.new("Frame")
HeaderFrame.Parent = MainFrame
HeaderFrame.Size = UDim2.new(1, 0, 0, 100)
HeaderFrame.BackgroundColor3 = Theme.Background
HeaderFrame.BorderSizePixel = 0
Instance.new("UICorner", HeaderFrame).CornerRadius = UDim.new(0, 12)
local HeaderBottomCover = Instance.new("Frame")
HeaderBottomCover.Parent = HeaderFrame
HeaderBottomCover.Size = UDim2.new(1, 0, 0, 12)
HeaderBottomCover.Position = UDim2.new(0, 0, 1, -12)
HeaderBottomCover.BackgroundColor3 = Theme.Background
HeaderBottomCover.BorderSizePixel = 0

-- Custom Logo Image
local LogoImage = Instance.new("ImageLabel")
LogoImage.Parent = HeaderFrame
LogoImage.Size = UDim2.new(1, -40, 1, -10)
LogoImage.Position = UDim2.new(0, 20, 0, 5)
LogoImage.BackgroundTransparency = 1
LogoImage.Image = "logo.png"
LogoImage.ScaleType = Enum.ScaleType.Fit

-- Separator Line under Logo
local Separator = Instance.new("Frame")
Separator.Parent = MainFrame
Separator.Size = UDim2.new(1, -30, 0, 1)
Separator.Position = UDim2.new(0, 15, 0, 100)
Separator.BackgroundColor3 = Theme.NeonAccent
Separator.BorderSizePixel = 0
Separator.Transparency = 0.5

-- Close Button (Top Right)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = MainFrame
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 10)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Theme.NeonAccent
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18

-- Toggling Logic
local function ToggleMenu() MainFrame.Visible = not MainFrame.Visible end
MobileFloatingButton.MouseButton1Click:Connect(ToggleMenu)
CloseBtn.MouseButton1Click:Connect(ToggleMenu)
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then ToggleMenu() end
end)

-- Scrolling Content Window
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Parent = MainFrame
ContentFrame.Size = UDim2.new(1, -20, 1, -115)
ContentFrame.Position = UDim2.new(0, 10, 0, 105)
ContentFrame.BackgroundColor3 = Theme.Background
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 3
ContentFrame.ScrollBarImageColor3 = Theme.NeonAccent
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 600)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ContentFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local layoutOrder = 0

-- UI Component Generators
local function CreateSection(text)
    layoutOrder = layoutOrder + 1
    local label = Instance.new("TextLabel")
    label.Parent = ContentFrame
    label.Size = UDim2.new(1, -10, 0, 26)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.NeonAccent
    label.Font = Enum.Font.GothamBlack
    label.TextSize = 13
    label.LayoutOrder = layoutOrder
    label.TextXAlignment = Enum.TextXAlignment.Left
end

local function CreateToggle(name, tableRef, configKey)
    layoutOrder = layoutOrder + 1
    local container = Instance.new("Frame")
    container.Parent = ContentFrame
    container.Size = UDim2.new(1, -10, 0, 42)
    container.BackgroundColor3 = Theme.ElementBg
    container.LayoutOrder = layoutOrder
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Parent = container
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13

    local btn = Instance.new("TextButton")
    btn.Parent = container
    btn.Size = UDim2.new(0, 56, 0, 26)
    btn.Position = UDim2.new(1, -70, 0.5, -13)
    btn.BackgroundColor3 = tableRef[configKey] and Theme.NeonAccent or Theme.Inactive
    btn.Text = tableRef[configKey] and "ON" or "OFF"
    btn.TextColor3 = tableRef[configKey] and Theme.TextDark or Theme.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        tableRef[configKey] = not tableRef[configKey]
        btn.BackgroundColor3 = tableRef[configKey] and Theme.NeonAccent or Theme.Inactive
        btn.Text = tableRef[configKey] and "ON" or "OFF"
        btn.TextColor3 = tableRef[configKey] and Theme.TextDark or Theme.Text
    end)
end

local function CreateSlider(name, tableRef, configKey, min, max, isDecimal)
    layoutOrder = layoutOrder + 1
    local container = Instance.new("Frame")
    container.Parent = ContentFrame
    container.Size = UDim2.new(1, -10, 0, 56)
    container.BackgroundColor3 = Theme.ElementBg
    container.LayoutOrder = layoutOrder
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Parent = container
    label.Size = UDim2.new(1, -30, 0, 22)
    label.Position = UDim2.new(0, 15, 0, 6)
    label.BackgroundTransparency = 1
    label.Text = string.format("%s: %s", name, tostring(tableRef[configKey]))
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13

    local sliderBg = Instance.new("Frame")
    sliderBg.Parent = container
    sliderBg.Size = UDim2.new(1, -30, 0, 8)
    sliderBg.Position = UDim2.new(0, 15, 0, 36)
    sliderBg.BackgroundColor3 = Theme.Inactive
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Parent = sliderBg
    fill.Size = UDim2.new((tableRef[configKey] - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.NeonAccent
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    -- Glow on slider fill
    local fillStroke = Instance.new("UIStroke")
    fillStroke.Parent = fill
    fillStroke.Color = Theme.NeonAccent
    fillStroke.Thickness = 1
    fillStroke.Transparency = 0.5

    local btn = Instance.new("TextButton")
    btn.Parent = sliderBg
    btn.Size = UDim2.new(1, 0, 1, 20)
    btn.Position = UDim2.new(0, 0, 0, -10)
    btn.BackgroundTransparency = 1
    btn.Text = ""

    local isSliding = false
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isSliding = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isSliding = false end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relativeX = math.clamp(input.Position.X - sliderBg.AbsolutePosition.X, 0, sliderBg.AbsoluteSize.X)
            local percentage = relativeX / sliderBg.AbsoluteSize.X
            fill.Size = UDim2.new(percentage, 0, 1, 0)
            
            local value = min + ((max - min) * percentage)
            if not isDecimal then value = math.floor(value) else value = math.floor(value * 100) / 100 end
            
            tableRef[configKey] = value
            label.Text = string.format("%s: %s", name, tostring(value))
        end
    end)
end

-- ==========================================
-- POPULATE NEON MENU
-- ==========================================
CreateSection("AIMBOT SYSTEM")
CreateToggle("Enable Aimbot", Aimbot, "enabled")
CreateToggle("Instant Lock", Aimbot, "instantLock")
CreateToggle("Auto Fire", Aimbot, "autoFire")
CreateToggle("Show FOV Circle", Aimbot, "showFov")
CreateSlider("FOV Radius", Aimbot, "fov", 10, 800, false)
CreateSlider("Smoothness", Aimbot, "smoothness", 0, 0.99, true)

CreateSection("SILENT AIM")
CreateToggle("Enable Silent Aim (Tools)", Aimbot, "silentAim")

CreateSection("VISUAL METRICS")
CreateToggle("Skeleton ESP", ESP, "skeletonEnabled")
CreateToggle("Snaplines", ESP, "lineEnabled")
CreateToggle("Team Check", ESP, "teamCheck")
CreateSlider("Max Distance", ESP, "maxDistance", 100, 10000, false)
