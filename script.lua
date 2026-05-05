--[[
    DZ HUB - MM2 MASTER EDITION [FIXED VISUALS]
    Executor: Xeno Optimized
    Design: Fluent UI
]]

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- // Configuration Global
getgenv().DZ_Config = {
    Visuals = {
        Enabled = false,
        Boxes = false,
        Names = false,
        Distance = false,
        Tracers = false,
        ShowMurderer = false, -- REPAIRED
        ShowSheriff = false,  -- REPAIRED
        ShowInnocents = false,
        MaxDistance = 5000
    },
    Combat = {
        ClickShot = false,
        AutoShot = false,
        FOV = 150,
        ShowFOV = true,
    },
    Murderer = {
        FakeTPAll = false,
    },
    Sheriff = {
        BringMurderer = false,
    }
}

-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // Drawing Objects
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

local ESP_Cache = {}

-- // Role Logic (Instant Detection)
local function GetPlayerRole(player)
    if not player or not player:FindFirstChild("Backpack") then return "Innocent" end
    
    if player.Backpack:FindFirstChild("Knife") or (player.Character and player.Character:FindFirstChild("Knife")) then
        return "Murderer"
    elseif player.Backpack:FindFirstChild("Gun") or (player.Character and player.Character:FindFirstChild("Gun")) then
        return "Sheriff"
    end
    return "Innocent"
end

-- // ESP Management
local function CreateESP(player)
    if ESP_Cache[player] then return end
    ESP_Cache[player] = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Tracer = Drawing.new("Line")
    }
end

local function UpdateESP()
    for player, draw in pairs(ESP_Cache) do
        local char = player.Character
        if getgenv().DZ_Config.Visuals.Enabled and char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            local dist = (Camera.CFrame.Position - root.Position).Magnitude
            
            -- Role Determination for Visuals
            local role = GetPlayerRole(player)
            local shouldShow = false
            local color = Color3.fromRGB(255, 255, 255)

            if role == "Murderer" then
                shouldShow = getgenv().DZ_Config.Visuals.ShowMurderer
                color = Color3.fromRGB(255, 0, 0)
            elseif role == "Sheriff" then
                shouldShow = getgenv().DZ_Config.Visuals.ShowSheriff
                color = Color3.fromRGB(0, 150, 255)
            else
                shouldShow = getgenv().DZ_Config.Visuals.ShowInnocents
                color = Color3.fromRGB(0, 255, 100)
            end

            if onScreen and shouldShow and dist < getgenv().DZ_Config.Visuals.MaxDistance then
                local sizeX, sizeY = 2000 / pos.Z, 3000 / pos.Z

                -- Box
                draw.Box.Visible = getgenv().DZ_Config.Visuals.Boxes
                draw.Box.Color = color
                draw.Box.Size = Vector2.new(sizeX, sizeY)
                draw.Box.Position = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2)
                draw.Box.Thickness = 1

                -- Text (Name + Role + Distance)
                draw.Name.Visible = getgenv().DZ_Config.Visuals.Names
                local info = player.Name .. "\n[" .. role:upper() .. "]"
                if getgenv().DZ_Config.Visuals.Distance then info = info .. " (" .. math.floor(dist) .. "m)" end
                draw.Name.Text = info
                draw.Name.Color = color
                draw.Name.Position = Vector2.new(pos.X, pos.Y - sizeY / 2 - 25)
                draw.Name.Center = true
                draw.Name.Outline = true
                draw.Name.Size = 14

                -- Tracers
                draw.Tracer.Visible = getgenv().DZ_Config.Visuals.Tracers
                draw.Tracer.Color = color
                draw.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                draw.Tracer.To = Vector2.new(pos.X, pos.Y + sizeY / 2)
            else
                draw.Box.Visible = false
                draw.Name.Visible = false
                draw.Tracer.Visible = false
            end
        else
            draw.Box.Visible = false
            draw.Name.Visible = false
            draw.Tracer.Visible = false
        end
    end
end

-- // Combat Helpers
local function GetTargetInFOV()
    local target, shortest = nil, getgenv().DZ_Config.Combat.FOV
    local mouseLoc = UserInputService:GetMouseLocation()

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - mouseLoc).Magnitude
                if mag < shortest then
                    shortest = mag
                    target = p
                end
            end
        end
    end
    return target
end

-- // Main Heartbeat Loop
RunService.RenderStepped:Connect(function()
    UpdateESP()
    
    FOVCircle.Visible = getgenv().DZ_Config.Combat.ShowFOV
    FOVCircle.Radius = getgenv().DZ_Config.Combat.FOV
    FOVCircle.Position = UserInputService:GetMouseLocation()

    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end

    -- Murderer: Fake TP
    if getgenv().DZ_Config.Murderer.FakeTPAll then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.CFrame = myChar.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
            end
        end
    end

    -- Sheriff: Bring & AutoShot Logic
    local currentMurd = nil
    for _, p in pairs(Players:GetPlayers()) do if GetPlayerRole(p) == "Murderer" then currentMurd = p break end end

    if getgenv().DZ_Config.Sheriff.BringMurderer and currentMurd and currentMurd.Character then
        currentMurd.Character.HumanoidRootPart.CFrame = myChar.HumanoidRootPart.CFrame * CFrame.new(0, 0, -10)
    end

    if getgenv().DZ_Config.Combat.AutoShot and currentMurd and currentMurd.Character then
        local gun = myChar:FindFirstChild("Gun")
        if gun then
            local mPos, onScreen = Camera:WorldToViewportPoint(currentMurd.Character.HumanoidRootPart.Position)
            if onScreen and (Vector2.new(mPos.X, mPos.Y) - UserInputService:GetMouseLocation()).Magnitude < getgenv().DZ_Config.Combat.FOV then
                gun:Activate()
            end
        end
    end
end)

-- // UI Layout
local Window = Fluent:CreateWindow({
    Title = "DZ HUB | MM2 MASTER",
    SubTitle = "Visuals Fixed",
    TabWidth = 160, Size = UDim2.fromOffset(580, 520), Acrylic = true, Theme = "Dark", MinimizeKey = Enum.KeyCode.RightShift
})

local Tabs = {
    Murd = Window:AddTab({ Title = "Murderer", Icon = "skull" }),
    Sheriff = Window:AddTab({ Title = "Sheriff", Icon = "shield" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "crosshair" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" })
}

-- Murderer Features
Tabs.Murd:AddToggle("FakeTPAll", {Title = "Fake TP (Bring All)", Default = false}):OnChanged(function(v) getgenv().DZ_Config.Murderer.FakeTPAll = v end)

-- Sheriff Features
Tabs.Sheriff:AddToggle("BringMurd", {Title = "Bring Murderer (Fake)", Default = false}):OnChanged(function(v) getgenv().DZ_Config.Sheriff.BringMurderer = v end)
Tabs.Sheriff:AddToggle("AutoShot", {Title = "Auto-Shot Murderer", Default = false}):OnChanged(function(v) getgenv().DZ_Config.Combat.AutoShot = v end)

-- Combat Features
Tabs.Combat:AddToggle("ClickShot", {Title = "Click Shot (FOV)", Default = false}):OnChanged(function(v) getgenv().DZ_Config.Combat.ClickShot = v end)
Tabs.Combat:AddSlider("FOV", {Title = "FOV Size", Min = 50, Max = 800, Default = 150}):OnChanged(function(v) getgenv().DZ_Config.Combat.FOV = v end)

-- VISUALS TAB (REPAIRED SECTION)
Tabs.Visuals:AddToggle("MasterESP", {Title = "Master Switch", Default = false}):OnChanged(function(v) getgenv().DZ_Config.Visuals.Enabled = v end)
Tabs.Visuals:AddToggle("ShowMurd", {Title = "Highlight Murderer (Red)", Default = true}):OnChanged(function(v) getgenv().DZ_Config.Visuals.ShowMurderer = v end)
Tabs.Visuals:AddToggle("ShowSher", {Title = "Highlight Sheriff (Blue)", Default = true}):OnChanged(function(v) getgenv().DZ_Config.Visuals.ShowSheriff = v end)
Tabs.Visuals:AddToggle("ShowInno", {Title = "Highlight Innocents", Default = false}):OnChanged(function(v) getgenv().DZ_Config.Visuals.ShowInnocents = v end)
Tabs.Visuals:AddParagraph({Title = "Styles", Content = "Choose how the ESP looks below."})
Tabs.Visuals:AddToggle("Box", {Title = "Boxes", Default = false}):OnChanged(function(v) getgenv().DZ_Config.Visuals.Boxes = v end)
Tabs.Visuals:AddToggle("Name", {Title = "Names & Roles", Default = false}):OnChanged(function(v) getgenv().DZ_Config.Visuals.Names = v end)
Tabs.Visuals:AddToggle("Dist", {Title = "Distance", Default = false}):OnChanged(function(v) getgenv().DZ_Config.Visuals.Distance = v end)
Tabs.Visuals:AddToggle("Tracers", {Title = "Tracers", Default = false}):OnChanged(function(v) getgenv().DZ_Config.Visuals.Tracers = v end)

-- Initialization
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end
Players.PlayerAdded:Connect(CreateESP)

Fluent:Notify({Title = "DZ HUB", Content = "Visuals Repaired. Murderer/Sheriff Toggles are in the Visuals tab.", Duration = 5})