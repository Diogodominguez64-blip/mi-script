--[[
    DZ HUB - GROUNDWORK EDITION (XENO EXECUTOR)
    Target: [FPS] Lanzamiento / FP2
    Design: Fluent Modern
]]

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "DZ HUB | Frontlines 2 & Groundwork",
    SubTitle = "Xeno Executor Optimized",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightShift 
})

-- // Variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

getgenv().Toggled = false
getgenv().AimbotConfig = {
    Enabled = false,
    TeamCheck = true,
    AliveCheck = true,
    WallCheck = true,
    Smoothness = 0.4, -- Lower is faster
    FOV = 120,
    AimPart = "Head"
}

getgenv().ESPConfig = {
    Enabled = false,
    Boxes = false,
    Names = false,
    Distance = false,
    Tracers = false,
    MaxDistance = 2000
}

-- // Utility Functions
local function IsVisible(part, character)
    if not getgenv().AimbotConfig.WallCheck then return true end
    local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000)
    local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera, character})
    return hit == nil
end

local function GetClosestPlayer()
    local closestDistance = getgenv().AimbotConfig.FOV
    local target = nil
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and (not getgenv().AimbotConfig.TeamCheck or player.Team ~= LocalPlayer.Team) then
            -- Groundwork games sometimes put characters in different workspace folders
            local char = player.Character or workspace:FindFirstChild(player.Name)
            if char and char:FindFirstChild(getgenv().AimbotConfig.AimPart) then
                local part = char[getgenv().AimbotConfig.AimPart]
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                
                if onScreen and IsVisible(part, char) then
                    local mouseLocation = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mouseLocation).Magnitude
                    
                    if distance < closestDistance then
                        closestDistance = distance
                        target = part
                    end
                end
            end
        end
    end
    return target
end

-- // Aimbot Logic (Xeno mousemoverel)
RunService.RenderStepped:Connect(function()
    if getgenv().AimbotConfig.Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestPlayer()
        if target then
            local screenPos, onScreen = Camera:WorldToViewportPoint(target.Position)
            local mouseLocation = UserInputService:GetMouseLocation()
            
            if onScreen then
                local x = (screenPos.X - mouseLocation.X) * getgenv().AimbotConfig.Smoothness
                local y = (screenPos.Y - mouseLocation.Y) * getgenv().AimbotConfig.Smoothness
                mousemoverel(x, y)
            end
        end
    end
end)

-- // ESP Library (Drawing API)
local ESP_Folder = {}

local function CreateESP(player)
    local drawings = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Tracer = Drawing.new("Line")
    }
    
    drawings.Box.Visible = false
    drawings.Box.Color = Color3.fromRGB(255, 0, 0)
    drawings.Box.Thickness = 1
    
    drawings.Name.Visible = false
    drawings.Name.Color = Color3.fromRGB(255, 255, 255)
    drawings.Name.Size = 14
    drawings.Name.Center = true
    drawings.Name.Outline = true
    
    drawings.Tracer.Visible = false
    drawings.Tracer.Color = Color3.fromRGB(255, 0, 0)
    drawings.Tracer.Thickness = 1

    ESP_Folder[player] = drawings
end

local function UpdateESP()
    for player, drawing in pairs(ESP_Folder) do
        local char = player.Character or workspace:FindFirstChild(player.Name)
        if getgenv().ESPConfig.Enabled and char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            local distance = (Camera.CFrame.Position - root.Position).Magnitude
            
            if onScreen and distance < getgenv().ESPConfig.MaxDistance then
                local sizeX = 2000 / screenPos.Z
                local sizeY = 3000 / screenPos.Z
                
                if getgenv().ESPConfig.Boxes then
                    drawing.Box.Visible = true
                    drawing.Box.Size = Vector2.new(sizeX, sizeY)
                    drawing.Box.Position = Vector2.new(screenPos.X - sizeX / 2, screenPos.Y - sizeY / 2)
                else drawing.Box.Visible = false end
                
                if getgenv().ESPConfig.Names then
                    drawing.Name.Visible = true
                    drawing.Name.Text = player.Name .. (getgenv().ESPConfig.Distance and " ["..math.floor(distance).."m]" or "")
                    drawing.Name.Position = Vector2.new(screenPos.X, screenPos.Y - sizeY / 2 - 15)
                else drawing.Name.Visible = false end
                
                if getgenv().ESPConfig.Tracers then
                    drawing.Tracer.Visible = true
                    drawing.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    drawing.Tracer.To = Vector2.new(screenPos.X, screenPos.Y + sizeY / 2)
                else drawing.Tracer.Visible = false end
            else
                drawing.Box.Visible = false
                drawing.Name.Visible = false
                drawing.Tracer.Visible = false
            end
        else
            drawing.Box.Visible = false
            drawing.Name.Visible = false
            drawing.Tracer.Visible = false
        end
    end
end

RunService.RenderStepped:Connect(UpdateESP)
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end
Players.PlayerAdded:Connect(CreateESP)

-- // Tabs
local Tabs = {
    Combat = Window:AddTab({ Title = "Combat", Icon = "crosshair" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" })
}

-- // Combat UI
Tabs.Combat:AddToggle("AimActive", {Title = "Enable Aimbot", Default = false}):OnChanged(function(v) getgenv().AimbotConfig.Enabled = v end)
Tabs.Combat:AddToggle("WallCheck", {Title = "Wall Check", Default = true}):OnChanged(function(v) getgenv().AimbotConfig.WallCheck = v end)
Tabs.Combat:AddSlider("Smoothness", {Title = "Smoothness", Min = 0.1, Max = 1, Default = 0.4, Rounding = 1}):OnChanged(function(v) getgenv().AimbotConfig.Smoothness = v end)
Tabs.Combat:AddSlider("FOV", {Title = "FOV Size", Min = 50, Max = 800, Default = 120, Rounding = 0}):OnChanged(function(v) getgenv().AimbotConfig.FOV = v end)
Tabs.Combat:AddDropdown("Part", {Title = "Aim Part", Values = {"Head", "HumanoidRootPart"}, Default = "Head"}):OnChanged(function(v) getgenv().AimbotConfig.AimPart = v end)

-- // Visuals UI
Tabs.Visuals:AddToggle("ESPActive", {Title = "Master ESP", Default = false}):OnChanged(function(v) getgenv().ESPConfig.Enabled = v end)
Tabs.Visuals:AddToggle("ESPBox", {Title = "Boxes", Default = false}):OnChanged(function(v) getgenv().ESPConfig.Boxes = v end)
Tabs.Visuals:AddToggle("ESPNames", {Title = "Names", Default = false}):OnChanged(function(v) getgenv().ESPConfig.Names = v end)
Tabs.Visuals:AddToggle("ESPDist", {Title = "Distance", Default = false}):OnChanged(function(v) getgenv().ESPConfig.Distance = v end)
Tabs.Visuals:AddToggle("ESPTracers", {Title = "Tracers", Default = false}):OnChanged(function(v) getgenv().ESPConfig.Tracers = v end)

Fluent:Notify({Title = "DZ HUB Loaded", Content = "Optimized for Xeno & Groundwork.", Duration = 5})