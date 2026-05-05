--[[
    DZ HUB - MM2 SPECIALIZED (XENO)
    Features: Fake TP (Client-side Bring), Click-to-Kill, Role Sniping
]]

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- // Configuration
getgenv().MM2_Config = {
    Visuals = {
        Enabled = false,
        MurdererESP = true,
        SheriffESP = true,
        InnocentESP = false,
        ShowRoles = true,
    },
    Combat = {
        ClickShot = false, -- Kill whoever is in FOV on click
        FOV = 150,
        ShowFOV = true,
    },
    Murderer = {
        FakeTP = false, -- Teleports players to you locally
        KillAll = false,
        KillSheriffOnly = false,
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
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Color = Color3.fromRGB(255, 0, 0)

-- // Role Cache
local Roles = { Murderer = nil, Sheriff = nil }

local function UpdateRoles()
    Roles.Murderer = nil
    Roles.Sheriff = nil
    for _, v in pairs(Players:GetPlayers()) do
        if v.Backpack:FindFirstChild("Knife") or (v.Character and v.Character:FindFirstChild("Knife")) then
            Roles.Murderer = v
        elseif v.Backpack:FindFirstChild("Gun") or (v.Character and v.Character:FindFirstChild("Gun")) then
            Roles.Sheriff = v
        end
    end
end

-- // Utility: Find Target in FOV
local function GetTargetInFOV()
    local target = nil
    local dist = getgenv().MM2_Config.Combat.FOV
    local mouseLoc = UserInputService:GetMouseLocation()

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if onScreen then
                local magnitude = (Vector2.new(pos.X, pos.Y) - mouseLoc).Magnitude
                if magnitude < dist then
                    dist = magnitude
                    target = p
                end
            end
        end
    end
    return target
end

-- // Fake TP / Client-Side Bring Logic
RunService.RenderStepped:Connect(function()
    UpdateRoles()
    
    -- FOV Update
    FOVCircle.Visible = getgenv().MM2_Config.Combat.ShowFOV
    FOVCircle.Radius = getgenv().MM2_Config.Combat.FOV
    FOVCircle.Position = UserInputService:GetMouseLocation()

    -- Fake TP (Client Side Only)
    if getgenv().MM2_Config.Murderer.FakeTP and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myPos = LocalPlayer.Character.HumanoidRootPart.CFrame
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                -- Move them 3 studs in front of you so you can hit them
                p.Character.HumanoidRootPart.CFrame = myPos * CFrame.new(0, 0, -3)
            end
        end
    end
end)

-- // Click Shot / Click Kill
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and getgenv().MM2_Config.Combat.ClickShot then
        local target = GetTargetInFOV()
        if target then
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then
                -- If we have a gun/knife, use it
                tool:Activate()
                -- Some MM2 scripts require firing the remote directly for "Click Kill"
                local remote = tool:FindFirstChild("Attack") or tool:FindFirstChild("Shoot")
                if remote then remote:FireServer(target.Character.HumanoidRootPart.Position) end
            end
        end
    end
end)

-- // Role Specific Killing
local function KillTarget(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local knife = LocalPlayer.Character:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
    if knife then
        LocalPlayer.Character.Humanoid:EquipTool(knife)
        -- Teleport hit logic
        local root = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            firetouchinterest(root, knife.Handle, 0)
            firetouchinterest(root, knife.Handle, 1)
        end
    end
end

-- // UI SETUP
local Window = Fluent:CreateWindow({
    Title = "DZ HUB | MM2 CHAOS",
    SubTitle = "Xeno Optimized",
    TabWidth = 160, Size = UDim2.fromOffset(580, 460), Acrylic = true, Theme = "Dark", MinimizeKey = Enum.KeyCode.RightShift
})

local Tabs = {
    Murd = Window:AddTab({ Title = "Murderer", Icon = "skull" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "crosshair" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" })
}

-- // Murderer Tab
Tabs.Murd:AddToggle("FakeTP", {Title = "Fake TP (Bring All)", Default = false}):OnChanged(function(v) getgenv().MM2_Config.Murderer.FakeTP = v end)

Tabs.Murd:AddButton({
    Title = "Kill All",
    Description = "Attempts to kill everyone instantly.",
    Callback = function()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then KillTarget(p) end
        end
    end
})

Tabs.Murd:AddButton({
    Title = "Kill Sheriff Only",
    Description = "Targets the person with the gun.",
    Callback = function()
        if Roles.Sheriff then KillTarget(Roles.Sheriff) end
    end
})

-- // Combat Tab
Tabs.Combat:AddToggle("ClickShot", {Title = "Click to Kill (FOV)", Default = false}):OnChanged(function(v) getgenv().MM2_Config.Combat.ClickShot = v end)
Tabs.Combat:AddToggle("ShowFOV", {Title = "Show FOV Circle", Default = true}):OnChanged(function(v) getgenv().MM2_Config.Combat.ShowFOV = v end)
Tabs.Combat:AddSlider("FOV", {Title = "FOV Size", Min = 50, Max = 800, Default = 150}):OnChanged(function(v) getgenv().MM2_Config.Combat.FOV = v end)

-- // Visuals Tab (Restored from previous MM2 script)
Tabs.Visuals:AddToggle("MasterESP", {Title = "Enable ESP", Default = true}):OnChanged(function(v) getgenv().MM2_Config.Visuals.Enabled = v end)
Tabs.Visuals:AddToggle("MurdESP", {Title = "Murderer ESP", Default = true}):OnChanged(function(v) getgenv().MM2_Config.Visuals.MurdererESP = v end)
Tabs.Visuals:AddToggle("SheriffESP", {Title = "Sheriff ESP", Default = true}):OnChanged(function(v) getgenv().MM2_Config.Visuals.SheriffESP = v end)

Fluent:Notify({Title = "DZ HUB", Content = "MM2 Chaos Loaded. Press Right Shift.", Duration = 5})