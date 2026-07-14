-- Enhanced Aimbot with Mod Menu
-- Version: 2.1 - Added FOV and Smoothness Editable (Fully Completed)

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Aimbot Configuration
local Aimbot = {
    enabled = true,
    silentAim = false,
    fov = 150,
    smoothness = 0.3,
    aimKey = Enum.UserInputType.MouseButton2,
    teamCheck = false,
    showFov = true,
    fovColor = Color3.fromRGB(255, 0, 0),
    fovTransparency = 0.3,
    bone = "Head",
    maxDistance = 10000,
    prediction = true,
    predictionAmount = 0.25,
    autoFire = false,
    instantLock = false,
    performanceMode = true
}

-- FOV Circle Drawing
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Aimbot.fovColor
fovCircle.Thickness = 1
fovCircle.NumSides = 64
fovCircle.Radius = Aimbot.fov
fovCircle.Filled = false
fovCircle.Transparency = Aimbot.fovTransparency
fovCircle.Visible = Aimbot.showFov

-- ==========================================
-- AIMBOT LOGIC
-- ==========================================

-- Function to check if a player is a valid target
local function IsValidTarget(player)
    if player == LocalPlayer then return false end
    
    local character = player.Character
    if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then 
        return false 
    end
    
    if Aimbot.teamCheck and player.Team == LocalPlayer.Team then return false end
    
    return true
end

-- Function to get the closest player to the cursor
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

-- Enhanced prediction function
local function GetPredictedPosition(target)
    if not Aimbot.prediction then return target.Position end
    
    local humanoid = target.Parent:FindFirstChild("Humanoid")
    if not humanoid then return target.Position end
    
    local velocity = humanoid.MoveDirection * humanoid.WalkSpeed
    if humanoid:FindFirstChild("BodyVelocity") then
        velocity = velocity + humanoid.BodyVelocity.Velocity
    end
    
    local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) 
        and (LocalPlayer.Character.HumanoidRootPart.Position - target.Position).Magnitude 
        or (Camera.CFrame.Position - target.Position).Magnitude
        
    local timeToReach = distance / 2000
    
    return target.Position + (velocity * timeToReach * Aimbot.predictionAmount)
end

-- Enhanced aim function
local function AimAt(target)
    if not target then return end
    
    local character = target.Character
    if not character then return end
    
    local targetBone = character:FindFirstChild(Aimbot.bone) or character:FindFirstChild("HumanoidRootPart")
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
        if mouse1press then
            mouse1press()
            task.wait(0.1)
            mouse1release()
        end
    end
end

-- Optimized main update function
local lastTargetTime = 0
local targetUpdateInterval = 0.016
local currentTarget = nil

local function OnRender()
    -- Update FOV circle
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    fovCircle.Radius = Aimbot.fov
    fovCircle.Visible = Aimbot.enabled and Aimbot.showFov

    if not Aimbot.enabled then return end
    
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

RunService.RenderStepped:Connect(OnRender)

-- ==========================================
-- MOD MENU GUI
-- ==========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EnhancedAimbotGUI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 300, 0, 420)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Habilita arrastrar el menú desde la barra superior

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Parent = MainFrame
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TitleBar.BorderSizePixel = 0
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

-- Fix bottom corners of TitleBar to blend with MainFrame
local TitleBottomCover = Instance.new("Frame")
TitleBottomCover.Parent = TitleBar
TitleBottomCover.Size = UDim2.new(1, 0, 0, 8)
TitleBottomCover.Position = UDim2.new(0, 0, 1, -8)
TitleBottomCover.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TitleBottomCover.BorderSizePixel = 0

local Title = Instance.new("TextLabel")
Title.Parent = TitleBar
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "Enhanced Aimbot v2.1"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold

local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Parent = MainFrame
ContentFrame.Size = UDim2.new(1, -10, 1, -40)
ContentFrame.Position = UDim2.new(0, 5, 0, 35)
ContentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 4
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 350) -- Altura ajustable según contenido

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ContentFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Helpers para crear UI
local layoutOrder = 0

local function CreateToggle(name, configKey)
    layoutOrder = layoutOrder + 1
    local container = Instance.new("Frame")
    container.Parent = ContentFrame
    container.Size = UDim2.new(1, -10, 0, 30)
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder

    local label = Instance.new("TextLabel")
    label.Parent = container
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = " " .. name
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.SourceSans

    local btn = Instance.new("TextButton")
    btn.Parent = container
    btn.Size = UDim2.new(0, 40, 0, 20)
    btn.Position = UDim2.new(1, -45, 0.5, -10)
    btn.BackgroundColor3 = Aimbot[configKey] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    btn.Text = Aimbot[configKey] and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    btn.MouseButton1Click:Connect(function()
        Aimbot[configKey] = not Aimbot[configKey]
        btn.BackgroundColor3 = Aimbot[configKey] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        btn.Text = Aimbot[configKey] and "ON" or "OFF"
    end)
end

local function CreateSlider(name, configKey, min, max, isDecimal)
    layoutOrder = layoutOrder + 1
    local container = Instance.new("Frame")
    container.Parent = ContentFrame
    container.Size = UDim2.new(1, -10, 0, 45)
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder

    local label = Instance.new("TextLabel")
    label.Parent = container
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = string.format("%s: %s", name, tostring(Aimbot[configKey]))
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.SourceSans

    local sliderBg = Instance.new("Frame")
    sliderBg.Parent = container
    sliderBg.Size = UDim2.new(1, -20, 0, 6)
    sliderBg.Position = UDim2.new(0, 10, 0, 25)
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Parent = sliderBg
    fill.Size = UDim2.new((Aimbot[configKey] - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local btn = Instance.new("TextButton")
    btn.Parent = sliderBg
    btn.Size = UDim2.new(1, 0, 1, 20)
    btn.Position = UDim2.new(0, 0, 0, -10)
    btn.BackgroundTransparency = 1
    btn.Text = ""

    local isSliding = false
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then isSliding = true end
    end)
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then isSliding = false end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isSliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = math.clamp(input.Position.X - sliderBg.AbsolutePosition.X, 0, sliderBg.AbsoluteSize.X)
            local percentage = relativeX / sliderBg.AbsoluteSize.X
            fill.Size = UDim2.new(percentage, 0, 1, 0)
            
            local value = min + ((max - min) * percentage)
            if not isDecimal then value = math.floor(value) else value = math.floor(value * 100) / 100 end
            
            Aimbot[configKey] = value
            label.Text = string.format("%s: %s", name, tostring(value))
        end
    end)
end

-- Popular el Menú
CreateToggle("Enable Aimbot", "enabled")
CreateToggle("Show FOV Circle", "showFov")
CreateToggle("Team Check", "teamCheck")
CreateToggle("Instant Lock", "instantLock")
CreateToggle("Auto Fire", "autoFire")
CreateToggle("Performance Mode", "performanceMode")

CreateSlider("FOV Radius", "fov", 10, 800, false)
CreateSlider("Smoothness", "smoothness", 0, 0.99, true)

-- Toggle Menu Visibility with Insert Key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
