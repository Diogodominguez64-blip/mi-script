--[[
    DZ HUB - MM2 MASTER EDITION
    Optimized for Xeno Executor
    Features: 
    - Full Drawing ESP (Boxes, Names, Distance, Tracers, Roles)
    - Murderer: Fake TP All, Kill All, Kill Sheriff
    - Sheriff: Bring Murderer, Fixed Auto-Shot
    - Global: ClickShot, Modifiable FOV
]]

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- // Configuration
getgenv().DZ_Config = {
    Visuals = {
        Enabled = false,
        Boxes = false,
        Names = false,
        Roles = false,
        Distance = false,
        Tracers = false,
        MaxDistance = 2000
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

-- // Drawing Objects (FOV & ESP)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

local ESP_Cache = {}

-- // Role Logic
local Roles = { Murderer = nil, Sheriff = nil }

local function GetPlayerRole(player)
    if player.Backpack:FindFirstChild("Knife") or (player.Character and player.Character:FindFirstChild("Knife")) then
        return "Murderer"
    elseif player.Backpack:FindFirstChild("Gun") or (player.Character and player.Character:FindFirstChild("Gun")) then
        return "Sheriff"
    end
    return "Innocent"
end

local function UpdateRoles()
    Roles.Murderer = nil
    Roles.Sheriff = nil
    for _, v in pairs(Players:GetPlayers()) do
        local role = GetPlayerRole(v)
        if role == "Murderer" then Roles.Murderer = v
        elseif role == "Sheriff" then Roles.Sheriff = v end
    end
end

-- // ESP Creation
local function CreateESP(player)
    local drawings = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Tracer = Drawing.new("Line")
    }
    ESP_Cache[player] = drawings
end

local function UpdateESP()
    for player, draw in pairs(ESP_Cache) do
        local char = player.Character
        if getgenv().DZ_Config.Visuals.Enabled and char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            local dist = (Camera.CFrame.Position - root.Position).Magnitude

            if onScreen and dist < getgenv().DZ_Config.Visuals.MaxDistance then
                local role = GetPlayerRole(player)
                local color = Color3.fromRGB(0, 255, 100) -- Green
                if role == "Murderer" then color = Color3.fromRGB(255, 0, 0) -- Red
                elseif role == "Sheriff" then color = Color3.fromRGB(0, 150, 255) end -- Blue

                local sizeX, sizeY = 2000 / pos.Z, 3000 / pos.Z

                draw.Box.Visible = getgenv().DZ_Config.Visuals.Boxes
                draw.Box.Color = color
                draw.Box.Size = Vector2.new(sizeX, sizeY)
                draw.Box.Position = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2)

                draw.Name.Visible = getgenv().DZ_Config.Visuals.Names
                local text = player.Name
                if getgenv().DZ_Config.Visuals.Roles then text = "[" .. role .. "] " .. text end
                if getgenv().DZ_Config.Visuals.Distance then text = text .. " (" .. math.floor(dist) .. "m)" end
                draw.Name.Text = text
                draw.Name.Color = color
                draw.Name.Position = Vector2.new(pos.X, pos.Y - sizeY / 2 - 15)
                draw.Name.Center, draw.Name.Outline = true, true

                draw.Tracer.Visible = getgenv().DZ_Config.Visuals.Tracers
                draw.Tracer.Color = color
                draw.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                draw.Tracer.To = Vector2.new(pos.X, pos.Y + sizeY / 2)
            else
                for _, d in pairs(draw) do d.Visible = false end
            end
        else
            for _, d in pairs(draw) do d.Visible = false end
        end
    end
end

-- // Combat: ClickShot & Auto-Shot Logic
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

-- // Main Update Loop
RunService.RenderStepped:Connect(function()
    UpdateRoles()
    UpdateESP()
    
    FOVCircle.Visible = getgenv().DZ_Config.Combat.ShowFOV
    FOVCircle.Radius = getgenv().DZ_Config.Combat.FOV
    FOVCircle.Position = UserInputService:GetMouseLocation()

    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end

    -- Murderer: Fake TP All
    if getgenv().DZ_Config.Murderer.FakeTPAll then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.CFrame = myChar.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
            end
        end
    end

    -- Sheriff: Bring Murderer
    if getgenv().DZ_Config.Sheriff.BringMurderer and Roles.Murderer and Roles.Murderer.Character then
        local mRoot = Roles.Murderer.Character:FindFirstChild("HumanoidRootPart")
        if mRoot then
            mRoot.CFrame = myChar.HumanoidRootPart.CFrame * CFrame.new(0, 0, -10)
        end
    end

    -- Sheriff: Auto-Shot Fixed
    if getgenv().DZ_Config.Combat.AutoShot and Roles.Murderer then
        local gun = myChar:FindFirstChild("Gun")
        if gun and Roles.Murderer.Character then
            local mPos, onScreen = Camera:WorldToViewportPoint(Roles.Murderer.Character.HumanoidRootPart.Position)
            local mouseLoc = UserInputService:GetMouseLocation()
            if onScreen and (Vector2.new(mPos.X, mPos.Y) - mouseLoc).Magnitude < getgenv().DZ_Config.Combat.FOV then
                gun:Activate()
            end
        end
    end
end)

-- // Kill Functions
local function InstantKill(target)
    if not target or not target.Character then return end
    local knife = LocalPlayer.Character:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
    if knife then
        LocalPlayer.Character.Humanoid:EquipTool(knife)
        local root = target.Character:FindFirstChild("HumanoidRootPart")
        if root then
            firetouchinterest(root, knife.Handle, 0)
            firetouchinterest(root, knife.Handle, 1)
        end
    end
end

-- // Input Logic
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and getgenv().DZ_Config.Combat.ClickShot then
        local target = GetTargetInFOV()
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if target and tool then
            tool:Activate()
            local remote = tool:FindFirstChild("Attack") or tool:FindFirstChild("Shoot")
            if remote then remote:FireServer(target.Character.HumanoidRootPart.Position) end
        end
    end
end)

-- // UI Creation
local Window = Fluent:CreateWindow({
    Title = "DZ HUB | MM2 ULTIMATE",
    SubTitle = "Xeno Dashboard",
    TabWidth = 160, Size = UDim2.fromOffset(580, 500), Acrylic = true, Theme = "Dark", MinimizeKey = Enum.KeyCode.RightShift
})

local Tabs = {
    Murd = Window:AddTab({ Title = "Murderer", Icon = "skull" }),
    Sheriff = Window:AddTab({ Title = "Sheriff", Icon = "shield" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "crosshair" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" })
}

-- Murderer Tab
Tabs.Murd:AddToggle("FakeTPAll", {Title = "Fake TP (Bring All)", Default = false}):OnChanged(function(v) getgenv().DZ_Config.Murderer.FakeTPAll = v end)
Tabs.Murd:AddButton({Title = "Kill All", Callback = function() for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then InstantKill(p) end end end})
Tabs.Murd:AddButton({Title = "Kill Sheriff Only", Callback = function() if Roles.Sheriff then InstantKill(Roles.Sheriff) end end})

-- Sheriff Tab
Tabs.Sheriff:AddToggle("BringMurd", {Title = "Fake TP Murderer", Default = false}):OnChanged(function(v) getgenv().DZ_Config.Sheriff.BringMurderer = v end)
Tabs.Sheriff:AddToggle("AutoShot", {Title = "Auto-Shot Murderer", Default = false}):OnChanged(function(v) getgenv().DZ_Config.Combat.AutoShot = v end)

-- Combat Tab
Tabs.Combat:AddToggle("ClickShot", {Title = "Click to Kill/Shoot", Default = false}):OnChanged(function(v) getgenv().DZ_Config.Combat.ClickShot = v end)
Tabs.Combat:AddToggle("ShowFOV", {Title = "Show FOV Circle", Default = true}):OnChanged(function(v) getgenv().DZ_Config.Combat.ShowFOV = v end)
Tabs.Combat:AddSlider("FOVSize", {Title = "FOV Radius", Min = 50, Max = 800, Default = 150}):OnChanged(function(v) getgenv().DZ_Config.Combat.FOV = v end)

-- Visuals Tab (Full Restoration)
Tabs.Visuals:AddToggle("ESPMaster", {Title = "Enable ESP", Default = false}):OnChanged(function(v) getgenv().DZ_Config.Visuals.Enabled = v end)
Tabs.Visuals:AddToggle("ESPBoxes", {Title = "Show Boxes", Default = false}):OnChanged(function(v) getgenv().DZ_Config.Visuals.Boxes = v end)
Tabs.Visuals:AddToggle("ESPNames", {Title = "Show Names", Default = false}):OnChanged(function(v) getgenv().DZ_Config.Visuals.Names = v end)
Tabs.Visuals:AddToggle("ESPRoles", {Title = "Show Roles", Default = false}):OnChanged(function(v) getgenv().DZ_Config.Visuals.Roles = v end)
Tabs.Visuals:AddToggle("ESPDist", {Title = "Show Distance", Default = false}):OnChanged(function(v) getgenv().DZ_Config.Visuals.Distance = v end)
Tabs.Visuals:AddToggle("ESPTracers", {Title = "Show Tracers", Default = false}):OnChanged(function(v) getgenv().DZ_Config.Visuals.Tracers = v end)

-- Initialize
Players.PlayerAdded:Connect(CreateESP)
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end

Fluent:Notify({Title = "DZ HUB", Content = "MM2 Ultimate Ready. Sheriff & Visuals Repaired.", Duration = 5})