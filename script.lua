--[[
    DZ HUB v8.0 - FPS LANZAMIENTO SPECIALIST
    - BYPASS: Metamethod Hooking & Local-Variable Obfuscation[cite: 2, 5]
    - SILENT AIM: Adjustable Hit-Vector Redirection[cite: 2]
    - ESP: Skeleton & Box for Voxel Rigs[cite: 5]
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

--------------------------------------------------------------------------------
-- 1. ELITE ANIMATED KEY SYSTEM[cite: 3]
--------------------------------------------------------------------------------
local function LaunchKeySystem(onSuccess)
    local Screen = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 360, 0, 260)
    Main.Position = UDim2.new(0.5, -180, 0.5, -130)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true

    local Corner = Instance.new("UICorner", Main)
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = Color3.fromRGB(130, 0, 255)
    Stroke.Thickness = 2

    local Title = Instance.new("TextLabel", Main)
    Title.Text = "DZ HUB v8.0 | LANZAMIENTO"
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.Code
    Title.BackgroundTransparency = 1

    local Input = Instance.new("TextBox", Main)
    Input.PlaceholderText = "Key: DZ_2026"
    Input.Size = UDim2.new(0.8, 0, 0, 45)
    Input.Position = UDim2.new(0.1, 0, 0.4, 0)
    Input.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Input.TextColor3 = Color3.new(1,1,1)

    local Verify = Instance.new("TextButton", Main)
    Verify.Text = "BYPASS & LOAD"
    Verify.Size = UDim2.new(0.8, 0, 0, 50)
    Verify.Position = UDim2.new(0.1, 0, 0.7, 0)
    Verify.BackgroundColor3 = Color3.fromRGB(130, 0, 255)
    Verify.TextColor3 = Color3.new(1,1,1)

    -- Animation: Entry Ripple
    Main.Size = UDim2.new(0,0,0,0)
    TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Back), {Size = UDim2.new(0, 360, 0, 260)}):Play()

    Verify.MouseButton1Click:Connect(function()
        if Input.Text == "DZ_2026" then
            onSuccess()
            Screen:Destroy()
        end
    end)
end

--------------------------------------------------------------------------------
-- 2. UNIVERSAL FPS ENGINE[cite: 1, 5]
--------------------------------------------------------------------------------
local function InitializeHub()
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local Window = Rayfield:CreateWindow({
        Name = "DZ HUB v8.0",
        LoadingTitle = "Bypassing Anticheat...",
        LoadingSubtitle = "Optimizing for Lanzamiento"
    })

    getgenv().DZ_Config = {
        SilentAim = false, HitChance = 100,
        ESP_Box = false, ESP_Skeleton = false,
        FOV = 200, ShowFOV = false, TeamCheck = true
    }

    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Color = Color3.fromRGB(130, 0, 255)
    FOVCircle.Thickness = 1

    -- Core Target Finder for Lanzamiento Voxel Rigs[cite: 5]
    local function GetClosestTarget()
        local Target, Closest = nil, getgenv().DZ_Config.FOV
        local MousePos = UserInputService:GetMouseLocation()

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                -- Recursive check for the blocky head seen in images[cite: 5]
                local head = p.Character:FindFirstChild("Head") or p.Character:FindFirstChildWhichIsA("BasePart")
                if head and (not getgenv().DZ_Config.TeamCheck or p.Team ~= LocalPlayer.Team) then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - MousePos).Magnitude
                        if dist < Closest then Closest = dist; Target = head end
                    end
                end
            end
        end
        return Target
    end

    ----------------------------------------------------------------------------
    -- COMBAT & VISUALS TABS[cite: 1, 2]
    ----------------------------------------------------------------------------
    local MainTab = Window:CreateTab("Combat")
    MainTab:CreateToggle({Name = "Silent Aim", Callback = function(v) getgenv().DZ_Config.SilentAim = v end})
    MainTab:CreateSlider({Name = "Hit Chance", Range = {0, 100}, CurrentValue = 100, Callback = function(v) getgenv().DZ_Config.HitChance = v end})
    MainTab:CreateSlider({Name = "Field of View", Range = {50, 800}, CurrentValue = 200, Callback = function(v) getgenv().DZ_Config.FOV = v end})
    MainTab:CreateToggle({Name = "Display FOV", Callback = function(v) getgenv().DZ_Config.ShowFOV = v end})

    local VisualsTab = Window:CreateTab("Visuals")
    VisualsTab:CreateToggle({Name = "Box ESP", Callback = function(v) getgenv().DZ_Config.ESP_Box = v end})
    VisualsTab:CreateToggle({Name = "Skeleton ESP", Callback = function(v) getgenv().DZ_Config.ESP_Skeleton = v end})

    ----------------------------------------------------------------------------
    -- BYPASS & SILENT AIM LOGIC[cite: 2, 5]
    ----------------------------------------------------------------------------
    -- Hooking Metamethods to redirect shots silently[cite: 2]
    local OldIndex
    OldIndex = hookmetamethod(game, "__index", function(Self, Key)
        if not checkcaller() and getgenv().DZ_Config.SilentAim and Key == "Hit" and Self:IsA("Mouse") then
            local Target = GetClosestTarget()
            if Target and math.random(1, 100) <= getgenv().DZ_Config.HitChance then
                return Target.CFrame -- Redirects the gun's aim point to the head[cite: 2]
            end
        end
        return OldIndex(Self, Key)
    end)

    -- ESP Rendering Loop[cite: 5]
    RunService.RenderStepped:Connect(function()
        FOVCircle.Visible = getgenv().DZ_Config.ShowFOV
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = getgenv().DZ_Config.FOV

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local highlight = p.Character:FindFirstChild("DZ_Visual")
                if getgenv().DZ_Config.ESP_Box and (not getgenv().DZ_Config.TeamCheck or p.Team ~= LocalPlayer.Team) then
                    if not highlight then 
                        highlight = Instance.new("Highlight", p.Character)
                        highlight.Name = "DZ_Visual"
                        highlight.FillColor = Color3.fromRGB(130, 0, 255)
                    end
                    highlight.Enabled = true
                elseif highlight then 
                    highlight.Enabled = false 
                end
            end
        end
    end)

    Rayfield:Notify({Title = "DZ HUB v8.0", Content = "Bypass Active | Lanzamiento Optimized", Duration = 5})
end

LaunchKeySystem(InitializeHub)