--[[
    DZ HUB - MURDER MYSTERY 2 (MM2)
    Executor: Xeno (Optimized)
    Design: Fluent UI
    Features: Role ESP, Grab Gun, Auto-Shot, Click-to-Kill
]]

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- // Configuration
getgenv().MM2_Config = {
    Visuals = {
        Enabled = false,
        MurdererESP = false,
        SheriffESP = false,
        InnocentESP = false,
        ShowRoles = false,
        GunESP = true
    },
    Combat = {
        AutoShot = false, -- Automatically shoots the murderer
        ClickShot = false, -- Instant shoot on click
        KillAura = false, -- If you are the murderer
    },
    Utility = {
        GrabGun = false, -- Teleports you to the gun if dropped
        AutoGrab = false -- Automatically teleports to gun when it drops
    }
}

-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // Variables for Role Detection
local Roles = {
    Murderer = nil,
    Sheriff = nil
}

-- // Helper: Detect Roles
local function UpdateRoles()
    Roles.Murderer = nil
    Roles.Sheriff = nil
    for _, v in pairs(Players:GetPlayers()) do
        if v.Backpack:FindFirstChild("Knife") or (v.Character and v.Character:FindFirstChild("Knife")) then
            Roles.Murderer = v
        end
        if v.Backpack:FindFirstChild("Gun") or (v.Character and v.Character:FindFirstChild("Gun")) then
            Roles.Sheriff = v
        end
    end
end

-- // Helper: Grab Gun
local function GrabDroppedGun()
    local GunDrop = workspace:FindFirstChild("GunDrop") or workspace:FindFirstChild("DroppedGun")
    if GunDrop and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local OldCF = LocalPlayer.Character.HumanoidRootPart.CFrame
        LocalPlayer.Character.HumanoidRootPart.CFrame = GunDrop.CFrame
        task.wait(0.2)
        LocalPlayer.Character.HumanoidRootPart.CFrame = OldCF
    end
end

-- // Combat: Auto Shot Logic
RunService.RenderStepped:Connect(function()
    UpdateRoles()
    
    -- Auto Grab Gun
    if getgenv().MM2_Config.Utility.AutoGrab then
        if workspace:FindFirstChild("GunDrop") then GrabDroppedGun() end
    end

    -- Auto Shot (Triggerbot for Murderer)
    if getgenv().MM2_Config.Combat.AutoShot and Roles.Murderer then
        local Gun = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun")
        if Gun and Roles.Murderer.Character and Roles.Murderer.Character:FindFirstChild("HumanoidRootPart") then
            local Mouse = LocalPlayer:GetMouse()
            if Mouse.Target and Mouse.Target:IsDescendantOf(Roles.Murderer.Character) then
                Gun:Activate()
            end
        end
    end
end)

-- // ESP System (Optimized for MM2 Roles)
local ESP_Objects = {}
local function CreateESP(player)
    local drawings = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text")
    }
    ESP_Objects[player] = drawings
end

RunService.RenderStepped:Connect(function()
    for player, draw in pairs(ESP_Objects) do
        local char = player.Character
        if getgenv().MM2_Config.Visuals.Enabled and char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            
            if onScreen then
                local isMurderer = (player == Roles.Murderer)
                local isSheriff = (player == Roles.Sheriff)
                
                -- Color Coding
                local color = Color3.fromRGB(0, 255, 100) -- Innocent
                if isMurderer then color = Color3.fromRGB(255, 0, 0) end
                if isSheriff then color = Color3.fromRGB(0, 150, 255) end

                -- Filtering
                local visible = false
                if isMurderer and getgenv().MM2_Config.Visuals.MurdererESP then visible = true end
                if isSheriff and getgenv().MM2_Config.Visuals.SheriffESP then visible = true end
                if not isMurderer and not isSheriff and getgenv().MM2_Config.Visuals.InnocentESP then visible = true end

                draw.Box.Visible = visible
                draw.Box.Color = color
                draw.Box.Size = Vector2.new(2000 / pos.Z, 3000 / pos.Z)
                draw.Box.Position = Vector2.new(pos.X - draw.Box.Size.X / 2, pos.Y - draw.Box.Size.Y / 2)

                draw.Name.Visible = visible
                draw.Name.Text = player.Name .. (getgenv().MM2_Config.Visuals.ShowRoles and (isMurderer and " [MURDER]" or isSheriff and " [SHERIFF]" or " [INNOCENT]") or "")
                draw.Name.Position = Vector2.new(pos.X, pos.Y - draw.Box.Size.Y / 2 - 15)
                draw.Name.Color = color
                draw.Name.Center = true
                draw.Name.Outline = true
            else
                draw.Box.Visible = false
                draw.Name.Visible = false
            end
        else
            draw.Box.Visible = false
            draw.Name.Visible = false
        end
    end
end)

-- // UI Creation
local Window = Fluent:CreateWindow({
    Title = "DZ HUB | Murder Mystery 2",
    SubTitle = "Xeno Optimized",
    TabWidth = 160, Size = UDim2.fromOffset(580, 460), Acrylic = true, Theme = "Dark", MinimizeKey = Enum.KeyCode.RightShift
})

local Tabs = {
    Combat = Window:AddTab({ Title = "Combat", Icon = "crosshair" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Utility = Window:AddTab({ Title = "Utility", Icon = "wrench" })
}

-- // Combat Tab
Tabs.Combat:AddToggle("AutoShot", {Title = "Auto Shot Murderer", Default = false}):OnChanged(function(v) getgenv().MM2_Config.Combat.AutoShot = v end)
Tabs.Combat:AddParagraph({Title = "Info", Content = "Auto Shot fires the gun automatically when your crosshair is over the Murderer."})

-- // Visuals Tab
Tabs.Visuals:AddToggle("MasterESP", {Title = "Enable ESP", Default = false}):OnChanged(function(v) getgenv().MM2_Config.Visuals.Enabled = v end)
Tabs.Visuals:AddToggle("MurdESP", {Title = "Murderer ESP (Red)", Default = false}):OnChanged(function(v) getgenv().MM2_Config.Visuals.MurdererESP = v end)
Tabs.Visuals:AddToggle("SheriffESP", {Title = "Sheriff ESP (Blue)", Default = false}):OnChanged(function(v) getgenv().MM2_Config.Visuals.SheriffESP = v end)
Tabs.Visuals:AddToggle("InnoESP", {Title = "Innocent ESP (Green)", Default = false}):OnChanged(function(v) getgenv().MM2_Config.Visuals.InnocentESP = v end)
Tabs.Visuals:AddToggle("ShowRoles", {Title = "Show Role Labels", Default = false}):OnChanged(function(v) getgenv().MM2_Config.Visuals.ShowRoles = v end)

-- // Utility Tab
Tabs.Utility:AddButton({
    Title = "Grab Dropped Gun",
    Description = "Teleports you to the gun if the Sheriff dies.",
    Callback = function() GrabDroppedGun() end
})
Tabs.Utility:AddToggle("AutoGrab", {Title = "Auto Grab Gun", Default = false}):OnChanged(function(v) getgenv().MM2_Config.Utility.AutoGrab = v end)

-- // Initialize
Players.PlayerAdded:Connect(CreateESP)
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end

Fluent:Notify({Title = "DZ HUB MM2", Content = "MM2 Tools Loaded. Good luck, Detective.", Duration = 5})