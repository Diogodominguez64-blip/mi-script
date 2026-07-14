-- ==========================================
-- DZ STORE V1 - Enhanced Aimbot & ESP
-- Version: 3.0 (Mobile Supported & Modern UI)
-- ==========================================

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Configurations
local Aimbot = {
    enabled = true,
    fov = 150,
    smoothness = 0.3,
    aimKey = Enum.UserInputType.MouseButton2,
    teamCheck = false,
    showFov = true,
    fovColor = Color3.fromRGB(255, 50, 75),
    fovTransparency = 0.5,
    bone = "Head",
    prediction = true,
    predictionAmount = 0.25,
    autoFire = false,
    instantLock = false,
    performanceMode = true
}

local ESP = {
    skeletonEnabled = false,
    lineEnabled = false,
    skeletonThickness = 1.5,
    skeletonColor = Color3.fromRGB(255, 255, 255),
    lineThickness = 1.5,
    lineColor = Color3.fromRGB(255, 50, 75),
    maxDistance = 2000
}

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Aimbot.fovColor
fovCircle.Thickness = 1.5
fovCircle.NumSides = 64
fovCircle.Radius = Aimbot.fov
fovCircle.Filled = false
fovCircle.Transparency = Aimbot.fovTransparency
fovCircle.Visible = Aimbot.showFov

-- ==========================================
-- CORE LOGIC (AIMBOT & ESP)
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

-- ESP Drawings Manager
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

-- Main Loop
local lastTargetTime = 0
local targetUpdateInterval = 0.016
local currentTarget = nil

RunService.RenderStepped:Connect(function()
    -- 1. FOV Update
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    fovCircle.Radius = Aimbot.fov
    fovCircle.Visible = Aimbot.enabled and Aimbot.showFov

    -- 2. Aimbot Loop
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

    -- 3. ESP Loop
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
                -- Tracers
                if ESP.lineEnabled then
                    drawings.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    drawings.Line.To = Vector2.new(rootPos.X, rootPos.Y)
                    drawings.Line.Visible = true
                else
                    drawings.Line.Visible = false
                end
                
                -- Skeleton
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
-- MOD MENU GUI (DZ STORE V1)
-- ==========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DZ_STORE_V1"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Color Palette
local Colors = {
    Background = Color3.fromRGB(20, 20, 25),
    Accent = Color3.fromRGB(255, 50, 75),
    DarkElement = Color3.fromRGB(30, 30, 35),
    Text = Color3.fromRGB(240, 240, 240),
    Active = Color3.fromRGB(255, 50, 75),
    Inactive = Color3.fromRGB(50, 50, 60)
}

-- Mobile Open Button (Floating)
local OpenButton = Instance.new("TextButton")
OpenButton.Parent = ScreenGui
OpenButton.Size = UDim2.new(0, 45, 0, 45)
OpenButton.Position = UDim2.new(1, -60, 0, 20)
OpenButton.BackgroundColor3 = Colors.Accent
OpenButton.Text = "DZ"
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.TextSize = 18
OpenButton.BorderSizePixel = 0
Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(1, 0)
OpenButton.Active = true
OpenButton.Draggable = true -- Allows mobile users to move the floating button

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 320, 0, 450)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -225)
MainFrame.BackgroundColor3 = Colors.Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
MainFrame.Visible = false -- Starts hidden

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Parent = MainFrame
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Colors.Accent
TitleBar.BorderSizePixel = 0
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar
local TitleBottomCover = Instance.new("Frame")
TitleBottomCover.Parent = TitleBar
TitleBottomCover.Size = UDim2.new(1, 0, 0, 10)
TitleBottomCover.Position = UDim2.new(0, 0, 1, -10)
TitleBottomCover.BackgroundColor3 = Colors.Accent
TitleBottomCover.BorderSizePixel = 0

local Title = Instance.new("TextLabel")
Title.Parent = TitleBar
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "DZ STORE V1"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBlack
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Close Button (Inside Menu)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TitleBar
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0.5, -15)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16

-- Toggle Menu Logic
OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenButton.Visible = false
end)
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenButton.Visible = true
end)
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
        OpenButton.Visible = not MainFrame.Visible
    end
end)

-- Scrolling Content
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Parent = MainFrame
ContentFrame.Size = UDim2.new(1, -16, 1, -50)
ContentFrame.Position = UDim2.new(0, 8, 0, 45)
ContentFrame.BackgroundColor3 = Colors.Background
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 4
ContentFrame.ScrollBarImageColor3 = Colors.Accent
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 420)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ContentFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local layoutOrder = 0

-- Custom Toggle Component
local function CreateToggle(name, tableRef, configKey)
    layoutOrder = layoutOrder + 1
    local container = Instance.new("Frame")
    container.Parent = ContentFrame
    container.Size = UDim2.new(1, 0, 0, 35)
    container.BackgroundColor3 = Colors.DarkElement
    container.LayoutOrder = layoutOrder
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Parent = container
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Colors.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13

    local btn = Instance.new("TextButton")
    btn.Parent = container
    btn.Size = UDim2.new(0, 50, 0, 22)
    btn.Position = UDim2.new(1, -60, 0.5, -11)
    btn.BackgroundColor3 = tableRef[configKey] and Colors.Active or Colors.Inactive
    btn.Text = tableRef[configKey] and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    btn.MouseButton1Click:Connect(function()
        tableRef[configKey] = not tableRef[configKey]
        btn.BackgroundColor3 = tableRef[configKey] and Colors.Active or Colors.Inactive
        btn.Text = tableRef[configKey] and "ON" or "OFF"
    end)
end

-- Custom Slider Component
local function CreateSlider(name, tableRef, configKey, min, max, isDecimal)
    layoutOrder = layoutOrder + 1
    local container = Instance.new("Frame")
    container.Parent = ContentFrame
    container.Size = UDim2.new(1, 0, 0, 50)
    container.BackgroundColor3 = Colors.DarkElement
    container.LayoutOrder = layoutOrder
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Parent = container
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = string.format("%s: %s", name, tostring(tableRef[configKey]))
    label.TextColor3 = Colors.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13

    local sliderBg = Instance.new("Frame")
    sliderBg.Parent = container
    sliderBg.Size = UDim2.new(1, -20, 0, 6)
    sliderBg.Position = UDim2.new(0, 10, 0, 30)
    sliderBg.BackgroundColor3 = Colors.Inactive
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Parent = sliderBg
    fill.Size = UDim2.new((tableRef[configKey] - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Colors.Active
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local btn = Instance.new("TextButton")
    btn.Parent = sliderBg
    btn.Size = UDim2.new(1, 0, 1, 20)
    btn.Position = UDim2.new(0, 0, 0, -10)
    btn.BackgroundTransparency = 1
    btn.Text = ""

    local isSliding = false
    btn.InputBegan:Connect(function(input)
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
            local relativeX = math.clamp(input.Position.X - sliderBg.AbsolutePosition.X, 0, sliderBg.AbsoluteSize.X)
            local percentage = relativeX / sliderBg.AbsoluteSize.X
            fill.Size = UDim2.new(percentage, 0, 1, 0)
            
            local value = min + ((max - min) * percentage)
            if not isDecimal then value = math.floor(value) else value = math.floor(value * 100) / 100 end
            
            tableRef[configKey] = value
            label.Text = string.format("%s: %s", name, tostring(value))
            
            -- If FOV, visually update color immediately
            if configKey == "fov" then fovCircle.Radius = value end
        end
    end)
end

local function CreateSection(text)
    layoutOrder = layoutOrder + 1
    local label = Instance.new("TextLabel")
    label.Parent = ContentFrame
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Colors.Accent
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.LayoutOrder = layoutOrder
end

-- ==========================================
-- POPULATE MENU
-- ==========================================
CreateSection("AIMBOT")
CreateToggle("Enable Aimbot", Aimbot, "enabled")
CreateToggle("Instant Lock", Aimbot, "instantLock")
CreateToggle("Auto Fire", Aimbot, "autoFire")
CreateToggle("Team Check", Aimbot, "teamCheck")
CreateToggle("Show FOV Circle", Aimbot, "showFov")

CreateSection("AIMBOT SETTINGS")
CreateSlider("FOV Radius", Aimbot, "fov", 10, 800, false)
CreateSlider("Smoothness", Aimbot, "smoothness", 0, 0.99, true)

CreateSection("ESP")
CreateToggle("Skeleton ESP", ESP, "skeletonEnabled")
CreateToggle("Line Tracers ESP", ESP, "lineEnabled")
