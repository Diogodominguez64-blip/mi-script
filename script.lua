-- ==========================================
-- DZ STORE V1 - Enhanced Blatant Aimbot & ESP
-- Optimized for Performance & High FPS
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
    maxDistance = 10000,
    prediction = true,
    predictionAmount = 0.25,
    autoFire = false,
    instantLock = false,
    performanceMode = true
}

local ESP = {
    enabled = true,
    skeleton = true,
    box = true,
    health = true,
    line = true,
    teamCheck = false,
    distanceCheck = 10000,
    boxColor = Color3.fromRGB(255, 50, 75),
    boxTransparency = 0.6,
    lineColor = Color3.fromRGB(255, 255, 255),
    lineTransparency = 0.5,
    healthBarColor = Color3.fromRGB(0, 255, 100),
    healthBarTransparency = 0.7,
    healthBarHeight = 5,
    healthBarWidth = 50,
    performanceMode = true
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

-- Caching tables for performance optimization
local activePlayers = {}
local lastTargetTime = 0
local targetUpdateInterval = 0.016
local currentTarget = nil

-- ==========================================
-- CORE UTILITIES & VALIDATION
-- ==========================================

local function IsValidTarget(player)
    if player == LocalPlayer then return false end
    
    local character = player.Character
    if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then 
        return false 
    end
    
    return true
end

local function IsESPValidTarget(player)
    if player == LocalPlayer then return false end
    if ESP.teamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then return false end
    
    local character = player.Character
    if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then
        return false
    end
    return true
end

-- ==========================================
-- BLATANT AIMBOT CORE LOGIC
-- ==========================================

local function GetClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = Aimbot.fov
    
    for _, player in ipairs(Players:GetPlayers()) do
        if not IsValidTarget(player) then continue end
        if Aimbot.teamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then continue end
        
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
-- ADVANCED ADVANCED ESP CORE LOGIC
-- ==========================================

local function ClearPlayerESP(player)
    if activePlayers[player] then
        local data = activePlayers[player]
        if data.box then data.box:Remove() end
        if data.line then data.line:Remove() end
        if data.healthBar then data.healthBar:Remove() end
        if data.skeleton then
            for _, boneLine in pairs(data.skeleton) do
                boneLine:Remove()
            end
        end
        activePlayers[player] = nil
    end
end

local function UpdatePlayerESP(player)
    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChild("Humanoid")
    local head = character:FindFirstChild("Head")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not head or not rootPart then return end

    local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local distance = localRoot and (rootPart.Position - localRoot.Position).Magnitude or (Camera.CFrame.Position - rootPart.Position).Magnitude
    
    if distance > ESP.distanceCheck then 
        ClearPlayerESP(player)
        return 
    end

    if not activePlayers[player] then
        activePlayers[player] = { skeleton = {} }
    end
    local data = activePlayers[player]

    -- Render Box Layout
    if ESP.box and ESP.enabled then
        if not data.box then
            data.box = Drawing.new("Square")
            data.box.Thickness = 1.5
            data.box.Filled = false
        end
        data.box.Color = ESP.boxColor
        data.box.Transparency = ESP.boxTransparency
        
        local screenPoint, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        if onScreen then
            local scale = 1.5
            data.box.Size = Vector2.new(100 * scale, 200 * scale)
            data.box.Position = Vector2.new(screenPoint.X - data.box.Size.X / 2, screenPoint.Y - data.box.Size.Y / 2)
            data.box.Visible = true
        else
            data.box.Visible = false
        end
    elseif data.box then
        data.box.Visible = false
    end

    -- Render Head-to-Root Lines
    if ESP.line and ESP.enabled then
        if not data.line then
            data.line = Drawing.new("Line")
            data.line.Thickness = 1.5
        end
        data.line.Color = ESP.lineColor
        data.line.Transparency = ESP.lineTransparency
        
        local rootScreenPoint, rootOnScreen = Camera:WorldToViewportPoint(rootPart.Position)
        local headScreenPoint, headOnScreen = Camera:WorldToViewportPoint(head.Position)
        if rootOnScreen and headOnScreen then
            data.line.From = Vector2.new(rootScreenPoint.X, rootScreenPoint.Y)
            data.line.To = Vector2.new(headScreenPoint.X, headScreenPoint.Y)
            data.line.Visible = true
        else
            data.line.Visible = false
        end
    elseif data.line then
        data.line.Visible = false
    end

    -- Render Health Metrics
    if ESP.health and ESP.enabled then
        if not data.healthBar then
            data.healthBar = Drawing.new("Square")
            data.healthBar.Thickness = 1
            data.healthBar.Filled = true
        end
        data.healthBar.Color = ESP.healthBarColor
        data.healthBar.Transparency = ESP.healthBarTransparency
        
        local screenPoint, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        if onScreen then
            data.healthBar.Position = Vector2.new(screenPoint.X - ESP.healthBarWidth / 2, screenPoint.Y - 22)
            data.healthBar.Size = Vector2.new(ESP.healthBarWidth * (math.clamp(humanoid.Health, 0, humanoid.MaxHealth) / humanoid.MaxHealth), ESP.healthBarHeight)
            data.healthBar.Visible = true
        else
            data.healthBar.Visible = false
        end
    elseif data.healthBar then
        data.healthBar.Visible = false
    end

    -- Render Full Real-Time Skeleton
    if ESP.skeleton and ESP.enabled then
        local bones = {
            {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
            {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"},
            {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"},
            {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"},
            {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}
        }
        
        for i, boneRelation in ipairs(bones) do
            local p1 = character:FindFirstChild(boneRelation[1]) or character:FindFirstChild("Torso")
            local p2 = character:FindFirstChild(boneRelation[2]) or character:FindFirstChild("Torso")
            
            if p1 and p2 then
                if not data.skeleton[i] then
                    data.skeleton[i] = Drawing.new("Line")
                    data.skeleton[i].Thickness = 1.5
                end
                data.skeleton[i].Color = ESP.lineColor
                data.skeleton[i].Transparency = ESP.lineTransparency
                
                local pos1, vis1 = Camera:WorldToViewportPoint(p1.Position)
                local pos2, vis2 = Camera:WorldToViewportPoint(p2.Position)
                
                if vis1 or vis2 then
                    data.skeleton[i].From = Vector2.new(pos1.X, pos1.Y)
                    data.skeleton[i].To = Vector2.new(pos2.X, pos2.Y)
                    data.skeleton[i].Visible = true
                else
                    data.skeleton[i].Visible = false
                end
            elseif data.skeleton[i] then
                data.skeleton[i].Visible = false
            end
        end
    elseif data.skeleton then
        for _, boneLine in pairs(data.skeleton) do boneLine.Visible = false end
    end
end

Players.PlayerRemoving:Connect(ClearPlayerESP)

-- ==========================================
-- MAIN ENGINE TICK
-- ==========================================

RunService.RenderStepped:Connect(function()
    -- Sync FOV Display Object
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    fovCircle.Radius = Aimbot.fov
    fovCircle.Visible = Aimbot.enabled and Aimbot.showFov

    -- Run Aimbot Logic Subsystem
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

    -- Run ESP Logic Subsystem
    local espTime = tick()
    if not ESP.performanceMode or (espTime - lastTargetTime) > targetUpdateInterval then
        for player, _ in pairs(activePlayers) do
            if not IsESPValidTarget(player) then
                ClearPlayerESP(player)
            end
        end

        for _, player in ipairs(Players:GetPlayers()) do
            if IsESPValidTarget(player) then
                UpdatePlayerESP(player)
            end
        end
    end
end)

-- ==========================================
-- MOD MENU GUI CREATION (DZ STORE V1 STYLE)
-- ==========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DZ_STORE_V1_PANEL"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Colors = {
    Background = Color3.fromRGB(18, 18, 22),
    Accent = Color3.fromRGB(255, 50, 75),
    DarkElement = Color3.fromRGB(28, 28, 34),
    Text = Color3.fromRGB(245, 245, 245),
    Active = Color3.fromRGB(255, 50, 75),
    Inactive = Color3.fromRGB(45, 45, 55)
}

-- Mobile Floating Toggle Button (Open & Close Menu)
local MobileFloatingButton = Instance.new("TextButton")
MobileFloatingButton.Parent = ScreenGui
MobileFloatingButton.Size = UDim2.new(0, 50, 0, 50)
MobileFloatingButton.Position = UDim2.new(1, -65, 0, 25)
MobileFloatingButton.BackgroundColor3 = Colors.Accent
MobileFloatingButton.Text = "DZ"
MobileFloatingButton.Font = Enum.Font.GothamBlack
MobileFloatingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MobileFloatingButton.TextSize = 16
MobileFloatingButton.BorderSizePixel = 0
Instance.new("UICorner", MobileFloatingButton).CornerRadius = UDim.new(1, 0)
MobileFloatingButton.Active = true
MobileFloatingButton.Draggable = true -- Allows mobile players to drag it anywhere

-- Main Panel Frame
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 320, 0, 460)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -230)
MainFrame.BackgroundColor3 = Colors.Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
MainFrame.Visible = false

-- Title Bar Top Layout
local TitleBar = Instance.new("Frame")
TitleBar.Parent = MainFrame
TitleBar.Size = UDim2.new(1, 0, 0, 45)
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
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "DZ STORE V1"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBlack
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Desktop GUI Inline Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TitleBar
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -38, 0.5, -15)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16

-- Toggle Visual State Configurations
local function ToggleMenuState()
    MainFrame.Visible = not MainFrame.Visible
end

MobileFloatingButton.MouseButton1Click:Connect(ToggleMenuState)
CloseBtn.MouseButton1Click:Connect(ToggleMenuState)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        ToggleMenuState()
    end
end)

-- Main Dynamic Scroll Area
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Parent = MainFrame
ContentFrame.Size = UDim2.new(1, -16, 1, -60)
ContentFrame.Position = UDim2.new(0, 8, 0, 52)
ContentFrame.BackgroundColor3 = Colors.Background
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 4
ContentFrame.ScrollBarImageColor3 = Colors.Accent
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 550)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ContentFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local layoutOrder = 0

-- UI Component: Functional Option Toggle
local function CreateToggle(name, tableRef, configKey)
    layoutOrder = layoutOrder + 1
    local container = Instance.new("Frame")
    container.Parent = ContentFrame
    container.Size = UDim2.new(1, 0, 0, 38)
    container.BackgroundColor3 = Colors.DarkElement
    container.LayoutOrder = layoutOrder
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Parent = container
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Colors.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13

    local btn = Instance.new("TextButton")
    btn.Parent = container
    btn.Size = UDim2.new(0, 52, 0, 24)
    btn.Position = UDim2.new(1, -64, 0.5, -12)
    btn.BackgroundColor3 = tableRef[configKey] and Colors.Active or Colors.Inactive
    btn.Text = tableRef[configKey] and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    btn.MouseButton1Click:Connect(function()
        tableRef[configKey] = not tableRef[configKey]
        btn.BackgroundColor3 = tableRef[configKey] and Colors.Active or Colors.Inactive
        btn.Text = tableRef[configKey] and "ON" or "OFF"
    end)
end

-- UI Component: Scale/Value Sliders
local function CreateSlider(name, tableRef, configKey, min, max, isDecimal)
    layoutOrder = layoutOrder + 1
    local container = Instance.new("Frame")
    container.Parent = ContentFrame
    container.Size = UDim2.new(1, 0, 0, 52)
    container.BackgroundColor3 = Colors.DarkElement
    container.LayoutOrder = layoutOrder
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Parent = container
    label.Size = UDim2.new(1, -20, 0, 22)
    label.Position = UDim2.new(0, 12, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = string.format("%s: %s", name, tostring(tableRef[configKey]))
    label.TextColor3 = Colors.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13

    local sliderBg = Instance.new("Frame")
    sliderBg.Parent = container
    sliderBg.Size = UDim2.new(1, -24, 0, 6)
    sliderBg.Position = UDim2.new(0, 12, 0, 32)
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
    local function StartSlide() isSliding = true end
    local function EndSlide() isSliding = false end

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then StartSlide() end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then EndSlide() end
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

local function CreateSection(text)
    layoutOrder = layoutOrder + 1
    local label = Instance.new("TextLabel")
    label.Parent = ContentFrame
    label.Size = UDim2.new(1, 0, 0, 24)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Colors.Accent
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.LayoutOrder = layoutOrder
end

-- ==========================================
-- MENU ASSIGNMENT POPULATION
-- ==========================================
CreateSection("AIMBOT OPTIONS")
CreateToggle("Enable Aimbot", Aimbot, "enabled")
CreateToggle("Instant Lock", Aimbot, "instantLock")
CreateToggle("Auto Fire", Aimbot, "autoFire")
CreateToggle("Team Check (Aim)", Aimbot, "teamCheck")
CreateToggle("Show FOV Circle", Aimbot, "showFov")
CreateSlider("FOV Radius", Aimbot, "fov", 10, 800, false)
CreateSlider("Smoothness", Aimbot, "smoothness", 0, 0.99, true)

CreateSection("ESP VISUAL OPTIONS")
CreateToggle("Enable ESP Master", ESP, "enabled")
CreateToggle("Box ESP", ESP, "box")
CreateToggle("Skeleton ESP", ESP, "skeleton")
CreateToggle("Snaplines ESP", ESP, "line")
CreateToggle("Healthbar ESP", ESP, "health")
CreateToggle("Team Check (ESP)", ESP, "teamCheck")
CreateSlider("Max Render Distance", ESP, "distanceCheck", 100, 15000, false)
