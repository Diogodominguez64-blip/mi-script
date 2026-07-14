-- ==========================================
-- DZ STORE V2 - Neon UI Redesign
-- Version: 5.0 (Aimbot, Name ESP, Silent Aim, Wall Check)
-- ==========================================

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Theme Colors
local Theme = {
    Background = Color3.fromRGB(15, 15, 18),
    NeonAccent = Color3.fromRGB(57, 255, 20),
    ElementBg = Color3.fromRGB(24, 24, 28),
    Text = Color3.fromRGB(245, 245, 245),
    TextDark = Color3.fromRGB(10, 10, 10),
    Inactive = Color3.fromRGB(40, 40, 48)
}

-- Configurations
local Aimbot = {
    enabled = true,
    fov = 150,
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

-- FOV Circle Graphic
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Aimbot.fovColor
fovCircle.Thickness = 1.5
fovCircle.NumSides = 64
fovCircle.Radius = Aimbot.fov
fovCircle.Filled = false
fovCircle.Transparency = Aimbot.fovTransparency
fovCircle.Visible = Aimbot.showFov

-- Game Detection
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
        Title = "Game Detected",
        Text = "Loaded hacks for " .. detectedGame,
        Duration = 5
    })
end

detectGame()

-- ==========================================
-- CORE VALIDATION & WALL CHECK
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
-- SILENT AIM LOGIC
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
    
    if Aimbot.autoFire and UserInputService:IsMouseButtonPressed(Aimbot.aimKey) then
        -- Note: mouse1press/release depend on executor environment
        if mouse1press then mouse1press() task.wait(0.05) mouse1release() end
    end
end

-- ==========================================
-- ESP LOGIC
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
-- MAIN RUNNERS
-- ==========================================

local lastTargetTime = 0
local targetUpdateInterval = 0.016
local currentTarget = nil

RunService.Heartbeat:Connect(function()
    if Aimbot.silentAim then ExecuteSilentAim() end
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

-- ==========================================
-- MOD MENU GUI
-- ==========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DZ_STORE_V2"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 340, 0, 480)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -240)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local MobileFloatingButton = Instance.new("TextButton")
MobileFloatingButton.Parent = ScreenGui
MobileFloatingButton.Size = UDim2.new(0, 56, 0, 56)
MobileFloatingButton.Position = UDim2.new(1, -70, 0, 30)
MobileFloatingButton.BackgroundColor3 = Theme.Background
MobileFloatingButton.Text = "DZ"
MobileFloatingButton.Font = Enum.Font.GothamBlack
MobileFloatingButton.TextColor3 = Theme.NeonAccent
Instance.new("UICorner", MobileFloatingButton).CornerRadius = UDim.new(1, 0)

local function ToggleMenu() MainFrame.Visible = not MainFrame.Visible end
MobileFloatingButton.MouseButton1Click:Connect(ToggleMenu)

local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Parent = MainFrame
ContentFrame.Size = UDim2.new(1, -20, 1, -115)
ContentFrame.Position = UDim2.new(0, 10, 0, 105)
ContentFrame.BackgroundTransparency = 1
Instance.new("UIListLayout", ContentFrame).Padding = UDim.new(0, 10)

-- Helper Functions for UI
local function CreateToggle(name, tableRef, configKey)
    local container = Instance.new("Frame", ContentFrame)
    container.Size = UDim2.new(1, -10, 0, 42)
    container.BackgroundColor3 = Theme.ElementBg
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(0, 56, 0, 26)
    btn.Position = UDim2.new(1, -70, 0.5, -13)
    btn.Text = tableRef[configKey] and "ON" or "OFF"
    btn.MouseButton1Click:Connect(function()
        tableRef[configKey] = not tableRef[configKey]
        btn.Text = tableRef[configKey] and "ON" or "OFF"
    end)
end

-- Initialization
local function CreateSection(text)
    local label = Instance.new("TextLabel", ContentFrame)
    label.Size = UDim2.new(1, -10, 0, 26)
    label.Text = text
    label.TextColor3 = Theme.NeonAccent
    label.BackgroundTransparency = 1
end

CreateSection("AIMBOT SYSTEM")
CreateToggle("Enable Aimbot", Aimbot, "enabled")
CreateToggle("Wall Check", Aimbot, "wallCheck")
CreateToggle("Team Check", Aimbot, "teamCheck")
CreateSection("SILENT AIM")
CreateToggle("Enable Silent Aim", Aimbot, "silentAim")
CreateSection("VISUAL METRICS (ESP)")
CreateToggle("Name ESP", ESP, "nameEnabled")
CreateToggle("Skeleton ESP", ESP, "skeletonEnabled")
CreateToggle("Snaplines", ESP, "lineEnabled")
