--[[ 
    DZ HUB - Groundwork / FP2 Specialized
    Executor: Xeno (Optimized for mousemoverel)
    Status: Aimbot Repaired & ESP Functional
]]

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- // Configuration
getgenv().Config = {
    Aimbot = {
        Enabled = false,
        TeamCheck = true,
        AliveCheck = true,
        WallCheck = true,
        Smoothness = 0.35, -- Lower = Snappier, Higher = More Natural
        FOV = 150,
        AimPart = "Head",
        Sensitivity = 1 -- Adjust based on your in-game sens
    },
    ESP = {
        Enabled = true,
        Boxes = true,
        Names = true,
        Tracers = false,
        Distance = true
    }
}

-- // Variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // Improved Target Scanner for Groundwork
local function GetTargetCharacter(player)
    -- Groundwork often clones models into workspace with the player's name
    return player.Character or workspace:FindFirstChild(player.Name)
end

local function IsAlive(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health > 0 then return true end
    -- Fallback for custom health systems
    if char:FindFirstChild("Health") and char.Health.Value > 0 then return true end
    return false
end

local function GetClosestTarget()
    local closestDistance = getgenv().Config.Aimbot.FOV
    local target = nil
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if getgenv().Config.Aimbot.TeamCheck and player.Team == LocalPlayer.Team then continue end
            
            local char = GetTargetCharacter(player)
            if char and IsAlive(char) then
                local part = char:FindFirstChild(getgenv().Config.Aimbot.AimPart)
                if part then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    
                    if onScreen then
                        local mouseLoc = UserInputService:GetMouseLocation()
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mouseLoc).Magnitude
                        
                        if dist < closestDistance then
                            -- Simple WallCheck
                            if getgenv().Config.Aimbot.WallCheck then
                                local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000)
                                local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, char, Camera})
                                if hit then continue end
                            end
                            
                            closestDistance = dist
                            target = part
                        end
                    end
                end
            end
        end
    end
    return target
end

-- // Repaired Aimbot Logic for Xeno
RunService.RenderStepped:Connect(function()
    if getgenv().Config.Aimbot.Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestTarget()
        
        if target then
            local screenPos, onScreen = Camera:WorldToViewportPoint(target.Position)
            if onScreen then
                local mouseLoc = UserInputService:GetMouseLocation()
                
                -- Calculate the pixel delta (how far we need to move)
                local moveX = (screenPos.X - mouseLoc.X) * getgenv().Config.Aimbot.Smoothness
                local moveY = (screenPos.Y - mouseLoc.Y) * getgenv().Config.Aimbot.Smoothness
                
                -- The "Secret Sauce": Using Xeno's mousemoverel for custom engine bypass
                if mousemoverel then
                    mousemoverel(moveX, moveY)
                end
            end
        end
    end
end)

-- // ESP Section (Using Drawing API for 100% Functionality)
local ESP_Objects = {}

local function CreateESP(player)
    local drawings = {
        Box = Drawing.new("Square"),
        Text = Drawing.new("Text"),
        Tracer = Drawing.new("Line")
    }
    ESP_Objects[player] = drawings
end

local function UpdateESP()
    for player, drawing in pairs(ESP_Objects) do
        local char = GetTargetCharacter(player)
        if getgenv().Config.ESP.Enabled and char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            
            if onScreen then
                local dist = (Camera.CFrame.Position - root.Position).Magnitude
                local sizeX = 1500 / screenPos.Z
                local sizeY = 2500 / screenPos.Z
                
                -- Box
                drawing.Box.Visible = getgenv().Config.ESP.Boxes
                drawing.Box.Size = Vector2.new(sizeX, sizeY)
                drawing.Box.Position = Vector2.new(screenPos.X - sizeX / 2, screenPos.Y - sizeY / 2)
                drawing.Box.Color = Color3.fromRGB(255, 50, 50)
                drawing.Box.Thickness = 1

                -- Text
                drawing.Text.Visible = getgenv().Config.ESP.Names
                drawing.Text.Text = player.Name .. (getgenv().Config.ESP.Distance and " ["..math.floor(dist).."m]" or "")
                drawing.Text.Position = Vector2.new(screenPos.X, screenPos.Y - sizeY / 2 - 15)
                drawing.Text.Center = true
                drawing.Text.Outline = true
                drawing.Text.Size = 14
            else
                drawing.Box.Visible = false
                drawing.Text.Visible = false
            end
        else
            drawing.Box.Visible = false
            drawing.Text.Visible = false
        end
    end
end

RunService.RenderStepped:Connect(UpdateESP)
Players.PlayerAdded:Connect(CreateESP)
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end

-- // UI SETUP
local Window = Fluent:CreateWindow({
    Title = "DZ HUB",
    SubTitle = "Groundwork / FP2 Optimized",
    TabWidth = 160, Size = UDim2.fromOffset(580, 460), Acrylic = true, Theme = "Dark", MinimizeKey = Enum.KeyCode.RightShift
})

local Tabs = { Combat = Window:AddTab({ Title = "Combat", Icon = "crosshair" }), Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }) }

Tabs.Combat:AddToggle("Aim", {Title = "Enable Aimbot", Default = false}):OnChanged(function(v) getgenv().Config.Aimbot.Enabled = v end)
Tabs.Combat:AddSlider("Smooth", {Title = "Smoothing", Min = 0.1, Max = 1, Default = 0.35, Rounding = 2}):OnChanged(function(v) getgenv().Config.Aimbot.Smoothness = v end)
Tabs.Combat:AddSlider("FOV", {Title = "FOV Size", Min = 50, Max = 800, Default = 150}):OnChanged(function(v) getgenv().Config.Aimbot.FOV = v end)

Tabs.Visuals:AddToggle("ESP", {Title = "Master ESP", Default = true}):OnChanged(function(v) getgenv().Config.ESP.Enabled = v end)
Tabs.Visuals:AddToggle("Box", {Title = "Show Boxes", Default = true}):OnChanged(function(v) getgenv().Config.ESP.Boxes = v end)
Tabs.Visuals:AddToggle("Name", {Title = "Show Names", Default = true}):OnChanged(function(v) getgenv().Config.ESP.Names = v end)

Fluent:Notify({Title = "DZ HUB", Content = "Script Fixed for FP2. Press Right Shift to Menu.", Duration = 5})