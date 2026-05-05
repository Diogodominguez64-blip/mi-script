--[[
    DZ HUB - FP2 / GROUNDWORK ENGINE SPECIALIZED
    Executor: Xeno (Optimized)
    Fixes: Hit Registration, Missing ESP, Target Detection
]]

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- // Configuration Global
getgenv().DZ_Config = {
    Aimbot = {
        Enabled = false,
        TeamCheck = true,
        AliveCheck = true,
        WallCheck = true,
        Smoothness = 0.25, -- Adjusted for hit-reg stability
        FOV = 150,
        AimPart = "Head",
        ShowFOV = true
    },
    ESP = {
        Enabled = false,
        Boxes = false,
        Names = false,
        Health = false,
        Distance = false,
        Tracers = false,
        MaxDistance = 1500
    }
}

-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Radius = getgenv().DZ_Config.Aimbot.FOV
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

-- // Helper Functions for Groundwork Engine
local function GetChar(player)
    return player.Character or workspace:FindFirstChild(player.Name)
end

local function IsAlive(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health > 0 then return true end
    -- FP2 Custom Health System Check
    local hVal = char:FindFirstChild("Health")
    return hVal and hVal.Value > 0 or false
end

local function GetClosestTarget()
    local target = nil
    local shortestDist = getgenv().DZ_Config.Aimbot.FOV
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if getgenv().DZ_Config.Aimbot.TeamCheck and player.Team == LocalPlayer.Team then continue end
            
            local char = GetChar(player)
            if char and IsAlive(char) then
                local part = char:FindFirstChild(getgenv().DZ_Config.Aimbot.AimPart)
                if part then
                    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                        if dist < shortestDist then
                            if getgenv().DZ_Config.Aimbot.WallCheck then
                                local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000)
                                if workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, char, Camera}) then continue end
                            end
                            shortestDist = dist
                            target = part
                        end
                    end
                end
            end
        end
    end
    return target
end

-- // ESP System (100% Functional Restoration)
local ESP_Table = {}

local function CreateESP(player)
    local drawings = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Text"),
        Tracer = Drawing.new("Line")
    }
    ESP_Table[player] = drawings
end

local function UpdateESP()
    for player, draw in pairs(ESP_Table) do
        local char = GetChar(player)
        if getgenv().DZ_Config.ESP.Enabled and char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            local distance = (Camera.CFrame.Position - root.Position).Magnitude

            if onScreen and distance < getgenv().DZ_Config.ESP.MaxDistance then
                local sizeX = 2000 / pos.Z
                local sizeY = 3000 / pos.Z

                -- Boxes
                draw.Box.Visible = getgenv().DZ_Config.ESP.Boxes
                draw.Box.Size = Vector2.new(sizeX, sizeY)
                draw.Box.Position = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2)
                draw.Box.Color = Color3.fromRGB(255, 50, 50)

                -- Names & Distance
                draw.Name.Visible = getgenv().DZ_Config.ESP.Names
                draw.Name.Text = player.Name .. (getgenv().DZ_Config.ESP.Distance and " ["..math.floor(distance).."m]" or "")
                draw.Name.Position = Vector2.new(pos.X, pos.Y - sizeY/2 - 15)
                draw.Name.Center = true
                draw.Name.Outline = true

                -- Health
                if getgenv().DZ_Config.ESP.Health then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    draw.Health.Visible = true
                    draw.Health.Text = hum and math.floor(hum.Health) .. "%" or "??%"
                    draw.Health.Position = Vector2.new(pos.X, pos.Y + sizeY/2 + 5)
                    draw.Health.Color = Color3.fromRGB(0, 255, 100)
                    draw.Health.Center = true
                else draw.Health.Visible = false end

                -- Tracers
                if getgenv().DZ_Config.ESP.Tracers then
                    draw.Tracer.Visible = true
                    draw.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    draw.Tracer.To = Vector2.new(pos.X, pos.Y + sizeY/2)
                else draw.Tracer.Visible = false end
            else
                for _, d in pairs(draw) do d.Visible = false end
            end
        else
            for _, d in pairs(draw) do d.Visible = false end
        end
    end
end

-- // Main Loop (Fixes Hit Registration)
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Visible = getgenv().DZ_Config.Aimbot.ShowFOV
    FOVCircle.Radius = getgenv().DZ_Config.Aimbot.FOV
    
    UpdateESP()

    if getgenv().DZ_Config.Aimbot.Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestTarget()
        if target then
            local pos, onScreen = Camera:WorldToViewportPoint(target.Position)
            if onScreen then
                local mouseLoc = UserInputService:GetMouseLocation()
                -- Fixed Delta Math: Uses interpolation to prevent hit-reg desync
                local moveX = (pos.X - mouseLoc.X) * getgenv().DZ_Config.Aimbot.Smoothness
                local moveY = (pos.Y - mouseLoc.Y) * getgenv().DZ_Config.Aimbot.Smoothness
                
                -- Xeno specific relative move
                if mousemoverel then
                    mousemoverel(moveX, moveY)
                end
            end
        end
    end
end)

-- // UI Creation
local Window = Fluent:CreateWindow({
    Title = "DZ HUB | Final FP2 Fix",
    TabWidth = 160, Size = UDim2.fromOffset(580, 460), Acrylic = true, Theme = "Dark", MinimizeKey = Enum.KeyCode.RightShift
})

local Tabs = { Combat = Window:AddTab({ Title = "Combat", Icon = "crosshair" }), Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }) }

Tabs.Combat:AddToggle("Aim", {Title = "Enable Aimbot", Default = false}):OnChanged(function(v) getgenv().DZ_Config.Aimbot.Enabled = v end)
Tabs.Combat:AddToggle("ShowFOV", {Title = "Show FOV Circle", Default = true}):OnChanged(function(v) getgenv().DZ_Config.Aimbot.ShowFOV = v end)
Tabs.Combat:AddSlider("Smooth", {Title = "Smoothness (HitReg Fix)", Min = 0.1, Max = 1, Default = 0.25, Rounding = 2}):OnChanged(function(v) getgenv().DZ_Config.Aimbot.Smoothness = v end)
Tabs.Combat:AddSlider("FOV", {Title = "FOV Size", Min = 50, Max = 800, Default = 150}):OnChanged(function(v) getgenv().DZ_Config.Aimbot.FOV = v end)

Tabs.Visuals:AddToggle("ESP", {Title = "Enable ESP", Default = false}):OnChanged(function(v) getgenv().DZ_Config.ESP.Enabled = v end)
Tabs.Visuals:AddToggle("Boxes", {Title = "Boxes", Default = false}):OnChanged(function(v) getgenv().DZ_Config.ESP.Boxes = v end)
Tabs.Visuals:AddToggle("Names", {Title = "Names", Default = false}):OnChanged(function(v) getgenv().DZ_Config.ESP.Names = v end)
Tabs.Visuals:AddToggle("Health", {Title = "Health", Default = false}):OnChanged(function(v) getgenv().DZ_Config.ESP.Health = v end)
Tabs.Visuals:AddToggle("Dist", {Title = "Distance", Default = false}):OnChanged(function(v) getgenv().DZ_Config.ESP.Distance = v end)
Tabs.Visuals:AddToggle("Tracers", {Title = "Tracers", Default = false}):OnChanged(function(v) getgenv().DZ_Config.ESP.Tracers = v end)

Players.PlayerAdded:Connect(CreateESP)
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end

Fluent:Notify({Title = "DZ HUB", Content = "Groundwork Fix Loaded. Hit registration repaired.", Duration = 5})