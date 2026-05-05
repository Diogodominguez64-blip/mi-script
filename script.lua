--[[
    FPs ADAPTIVE AIMBOT & ESP FRAMEWORK
    Design: Rayfield UI
    Rendering: Drawing API (100% Functional)
]]--

local Rayfield = loadstring(game:HttpGet('https://sirbloodhound.github.io/Rayfield/source'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- [ Configuration ] --
local Config = {
    Aimbot = {
        Enabled = false,
        Key = Enum.UserInputType.MouseButton2,
        Smoothness = 0.5,
        AimPart = "Head",
        FOV = 100,
        ShowFOV = false,
        WallCheck = true
    },
    ESP = {
        Enabled = false,
        Boxes = false,
        Names = false,
        Health = false,
        Tracers = false,
        MaxDistance = 1500,
        Color = Color3.fromRGB(255, 65, 65)
    }
}

-- [ FOV Circle ] --
local FOVCircle = Drawing.new("Circle")
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
FOVCircle.Radius = Config.Aimbot.FOV
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Visible = false
FOVCircle.Thickness = 1

-- [ Utility Functions ] --

-- Custom Character Finder (Crucial for FP2)
local function GetCharacter(player)
    if player.Character then return player.Character end
    -- If FP2 uses a custom workspace folder for models, it scans for models matching the player's name
    local customChar = workspace:FindFirstChild(player.Name) 
    if customChar and customChar:IsA("Model") then return customChar end
    return nil
end

local function IsAlive(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health > 0 then return true end
    -- FP2 Custom Health check fallback
    local healthVal = character:FindFirstChild("Health")
    if healthVal and healthVal:IsA("NumberValue") and healthVal.Value > 0 then return true end
    return false
end

local function WallCheck(destination, ignoreList)
    if not Config.Aimbot.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = destination - origin
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = ignoreList
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.IgnoreWater = true

    local result = workspace:Raycast(origin, direction, raycastParams)
    return result == nil
end

local function GetClosestTarget()
    local closestDistance = Config.Aimbot.FOV
    local closestTarget = nil
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = GetCharacter(player)
            if character and IsAlive(character) then
                local targetPart = character:FindFirstChild(Config.Aimbot.AimPart) or character:FindFirstChild("HumanoidRootPart")
                if targetPart then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    
                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if distance < closestDistance then
                            -- Wallcheck
                            local ignoreList = {GetCharacter(LocalPlayer), Camera}
                            if WallCheck(targetPart.Position, ignoreList) then
                                closestDistance = distance
                                closestTarget = targetPart
                            end
                        end
                    end
                end
            end
        end
    end
    return closestTarget
end

-- [ Aimbot Logic ] --
local Aiming = false

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Config.Aimbot.Key then Aiming = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Config.Aimbot.Key then Aiming = false end
end)

RunService.RenderStepped:Connect(function()
    -- Update FOV
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = Config.Aimbot.FOV
    FOVCircle.Visible = Config.Aimbot.ShowFOV

    if Config.Aimbot.Enabled and Aiming then
        local target = GetClosestTarget()
        if target then
            local targetPos, onScreen = Camera:WorldToViewportPoint(target.Position)
            if onScreen then
                local mouseLocation = UserInputService:GetMouseLocation()
                local moveVector = Vector2.new((targetPos.X - mouseLocation.X) * Config.Aimbot.Smoothness, (targetPos.Y - mouseLocation.Y) * Config.Aimbot.Smoothness)
                
                -- Use mousemoverel for custom FPS cameras (better than CFrame manipulation)
                if mousemoverel then
                    mousemoverel(moveVector.X, moveVector.Y)
                end
            end
        end
    end
end)

-- [ ESP Logic ] --
local ESP_Objects = {}

local function CreateESP(player)
    local esp = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Text"),
        Tracer = Drawing.new("Line"),
        Player = player
    }
    
    esp.Box.Thickness = 1
    esp.Box.Filled = false
    esp.Name.Size = 16
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Health.Size = 14
    esp.Health.Center = true
    esp.Health.Outline = true
    esp.Tracer.Thickness = 1
    
    ESP_Objects[player] = esp
end

local function RemoveESP(player)
    if ESP_Objects[player] then
        for _, drawing in pairs(ESP_Objects[player]) do
            if typeof(drawing) == "table" and drawing.Remove then drawing:Remove() end
        end
        ESP_Objects[player] = nil
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then CreateESP(player) end
end

Players.PlayerAdded:Connect(function(player) CreateESP(player) end)
Players.PlayerRemoving:Connect(function(player) RemoveESP(player) end)

RunService.RenderStepped:Connect(function()
    for player, esp in pairs(ESP_Objects) do
        local character = GetCharacter(player)
        if Config.ESP.Enabled and character and IsAlive(character) then
            local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso")
            local head = character:FindFirstChild("Head")
            
            if rootPart and head then
                local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local legPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
                
                local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
                
                if onScreen and distance <= Config.ESP.MaxDistance then
                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height / 2
                    
                    -- Box
                    esp.Box.Size = Vector2.new(width, height)
                    esp.Box.Position = Vector2.new(rootPos.X - width / 2, rootPos.Y - height / 2)
                    esp.Box.Color = Config.ESP.Color
                    esp.Box.Visible = Config.ESP.Boxes
                    
                    -- Name
                    esp.Name.Text = player.Name .. " [" .. math.floor(distance) .. "m]"
                    esp.Name.Position = Vector2.new(rootPos.X, rootPos.Y - height / 2 - 20)
                    esp.Name.Color = Config.ESP.Color
                    esp.Name.Visible = Config.ESP.Names
                    
                    -- Tracers
                    esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    esp.Tracer.To = Vector2.new(rootPos.X, rootPos.Y - height / 2)
                    esp.Tracer.Color = Config.ESP.Color
                    esp.Tracer.Visible = Config.ESP.Tracers
                    
                    -- Health
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        esp.Health.Text = tostring(math.floor(humanoid.Health)) .. " HP"
                        esp.Health.Position = Vector2.new(rootPos.X, rootPos.Y + height / 2 + 5)
                        esp.Health.Color = Color3.fromRGB(0, 255, 0)
                        esp.Health.Visible = Config.ESP.Health
                    else
                        esp.Health.Visible = false
                    end
                else
                    esp.Box.Visible = false
                    esp.Name.Visible = false
                    esp.Health.Visible = false
                    esp.Tracer.Visible = false
                end
            end
        else
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Health.Visible = false
            esp.Tracer.Visible = false
        end
    end
end)

-- [ UI Setup ] --
local Window = Rayfield:CreateWindow({
    Name = "FP2 Adaptive Hub | V2",
    LoadingTitle = "Initializing Scripts...",
    LoadingSubtitle = "By Your Favorite AI",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)

-- Combat Elements
CombatTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Flag = "AimToggle",
    Callback = function(Value) Config.Aimbot.Enabled = Value end,
})

CombatTab:CreateToggle({
    Name = "Show FOV",
    CurrentValue = false,
    Flag = "FOVToggle",
    Callback = function(Value) Config.Aimbot.ShowFOV = Value end,
})

CombatTab:CreateToggle({
    Name = "Wall Check",
    CurrentValue = true,
    Flag = "WallToggle",
    Callback = function(Value) Config.Aimbot.WallCheck = Value end,
})

CombatTab:CreateSlider({
    Name = "FOV Size",
    Range = {10, 500},
    Increment = 10,
    CurrentValue = 100,
    Flag = "FOVSize",
    Callback = function(Value) Config.Aimbot.FOV = Value end,
})

CombatTab:CreateSlider({
    Name = "Smoothness",
    Range = {0.1, 1},
    Increment = 0.1,
    CurrentValue = 0.5,
    Flag = "Smoothness",
    Callback = function(Value) Config.Aimbot.Smoothness = Value end,
})

-- Visuals Elements
VisualsTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(Value) Config.ESP.Enabled = Value end,
})

VisualsTab:CreateToggle({
    Name = "Show Boxes",
    CurrentValue = false,
    Flag = "BoxToggle",
    Callback = function(Value) Config.ESP.Boxes = Value end,
})

VisualsTab:CreateToggle({
    Name = "Show Names",
    CurrentValue = false,
    Flag = "NameToggle",
    Callback = function(Value) Config.ESP.Names = Value end,
})

VisualsTab:CreateToggle({
    Name = "Show Health",
    CurrentValue = false,
    Flag = "HealthToggle",
    Callback = function(Value) Config.ESP.Health = Value end,
})

VisualsTab:CreateToggle({
    Name = "Show Tracers",
    CurrentValue = false,
    Flag = "TracerToggle",
    Callback = function(Value) Config.ESP.Tracers = Value end,
})

Rayfield:LoadConfiguration()