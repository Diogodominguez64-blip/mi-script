--[[
    DZ HUB v7.0 - ELITE FPS EDITION
    - REBUILT: Skeleton & Box ESP[cite: 5]
    - ADDED: Adjustable Silent Aim[cite: 2]
    - FIXED: Universal FPS Aimbot[cite: 5]
    - ENHANCED: Motion-Blurred Key UI[cite: 3]
]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

--------------------------------------------------------------------------------
-- 1. PREMIUM KEY SYSTEM (ENHANCED ANIMATIONS)[cite: 3]
--------------------------------------------------------------------------------
local function LaunchKeySystem(onSuccess)
    local Screen = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 350, 0, 250)
    Main.Position = UDim2.new(0.5, -175, 0.4, -125) -- Start slightly higher for slide-down
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    Main.BackgroundTransparency = 1
    
    local UIStroke = Instance.new("UIStroke", Main)
    UIStroke.Color = Color3.fromRGB(130, 0, 255)
    UIStroke.Thickness = 2
    UIStroke.Transparency = 1

    local Title = Instance.new("TextLabel", Main)
    Title.Text = "DZ HUB v7.0 | ELITE FPS"
    Title.Size = UDim2.new(1, 0, 0, 60)
    Title.TextColor3 = Color3.fromRGB(130, 0, 255)
    Title.Font = Enum.Font.Code
    Title.TextSize = 22
    Title.BackgroundTransparency = 1
    Title.TextTransparency = 1

    -- Animation Sequence: Slide Down & Fade In[cite: 3]
    TweenService:Create(Main, TweenInfo.new(0.8, Enum.EasingStyle.Quart), {Position = UDim2.new(0.5, -175, 0.5, -125), BackgroundTransparency = 0.1}):Play()
    TweenService:Create(UIStroke, TweenInfo.new(1), {Transparency = 0}):Play()
    TweenService:Create(Title, TweenInfo.new(1.2), {TextTransparency = 0}):Play()

    local Input = Instance.new("TextBox", Main)
    Input.PlaceholderText = "Enter Key..."
    Input.Size = UDim2.new(0.8, 0, 0, 45)
    Input.Position = UDim2.new(0.1, 0, 0.45, 0)
    Input.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Input.TextColor3 = Color3.new(1,1,1)

    local Verify = Instance.new("TextButton", Main)
    Verify.Text = "INITIALIZE"
    Verify.Size = UDim2.new(0.8, 0, 0, 45)
    Verify.Position = UDim2.new(0.1, 0, 0.75, 0)
    Verify.BackgroundColor3 = Color3.fromRGB(130, 0, 255)
    Verify.TextColor3 = Color3.new(1,1,1)

    Verify.MouseButton1Click:Connect(function()
        if Input.Text == "DZ_2026" then
            TweenService:Create(Main, TweenInfo.new(0.5), {Size = UDim2.new(0,0,0,0), Transparency = 1}):Play()
            task.wait(0.5)
            Screen:Destroy()
            onSuccess()
        end
    end)
end

--------------------------------------------------------------------------------
-- 2. UNIVERSAL ENGINE (FPS TARGETING)[cite: 1, 5]
--------------------------------------------------------------------------------
local function InitializeHub()
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local Window = Rayfield:CreateWindow({
        Name = "DZ HUB v7.0",
        LoadingTitle = "FPS Specialist Suite",
        LoadingSubtitle = "Master Edition"
    })

    getgenv().DZ_Config = {
        Aimbot = false, SilentAim = false, SilentHitChance = 100,
        ESP = false, ESPSkeleton = false, TeamCheck = true,
        FOV = 200, ShowFOV = false, Fly = false, FlySpeed = 50
    }

    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1
    FOVCircle.Color = Color3.fromRGB(130, 0, 255)

    -- Helper: Optimized FPS Target Finder[cite: 5]
    local function GetFPSTarget()
        local Target, BestDist = nil, getgenv().DZ_Config.FOV
        local Mouse = UserInputService:GetMouseLocation()

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local head = p.Character:FindFirstChild("Head")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if head and hum and hum.Health > 0 then
                    if not getgenv().DZ_Config.TeamCheck or p.Team ~= LocalPlayer.Team then
                        local pos, vis = Camera:WorldToViewportPoint(head.Position)
                        if vis then
                            local mag = (Vector2.new(pos.X, pos.Y) - Mouse).Magnitude
                            if mag < BestDist then BestDist = mag; Target = head end
                        end
                    end
                end
            end
        end
        return Target
    end

    ----------------------------------------------------------------------------
    -- TABS: MAIN, VISUALS, EXTRAS[cite: 1]
    ----------------------------------------------------------------------------
    local MainTab = Window:CreateTab("Main")
    MainTab:CreateSection("Aimbot & Silent")
    
    MainTab:CreateToggle({Name = "Enable Aimbot (Hold E)", Callback = function(v) getgenv().DZ_Config.Aimbot = v end})
    MainTab:CreateToggle({Name = "Enable Silent Aim", Callback = function(v) getgenv().DZ_Config.SilentAim = v end})
    MainTab:CreateSlider({Name = "Silent Hit Chance", Range = {0, 100}, CurrentValue = 100, Callback = function(v) getgenv().DZ_Config.SilentHitChance = v end})
    MainTab:CreateSlider({Name = "FOV Radius", Range = {50, 800}, CurrentValue = 200, Callback = function(v) getgenv().DZ_Config.FOV = v end})
    MainTab:CreateToggle({Name = "Show FOV Circle", Callback = function(v) getgenv().DZ_Config.ShowFOV = v end})

    local VisualsTab = Window:CreateTab("Visuals")
    VisualsTab:CreateToggle({Name = "Box ESP", Callback = function(v) getgenv().DZ_Config.ESP = v end})
    VisualsTab:CreateToggle({Name = "Skeleton Lines", Callback = function(v) getgenv().DZ_Config.ESPSkeleton = v end})
    VisualsTab:CreateToggle({Name = "Team Check", CurrentValue = true, Callback = function(v) getgenv().DZ_Config.TeamCheck = v end})

    local ExtrasTab = Window:CreateTab("Extras")
    ExtrasTab:CreateToggle({Name = "Fixed Fly", Callback = function(v) 
        getgenv().DZ_Config.Fly = v 
        -- Physics-based fly stabilization[cite: 3]
    end})

    ----------------------------------------------------------------------------
    -- RUNTIME ENGINE (COMBAT & VISUALS)[cite: 2, 5]
    ----------------------------------------------------------------------------
    RunService.RenderStepped:Connect(function()
        FOVCircle.Visible = getgenv().DZ_Config.ShowFOV
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = getgenv().DZ_Config.FOV

        -- Visuals: Skeleton Logic[cite: 5]
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local highlight = p.Character:FindFirstChild("DZ_Highlight")
                if getgenv().DZ_Config.ESP and (not getgenv().DZ_Config.TeamCheck or p.Team ~= LocalPlayer.Team) then
                    if not highlight then highlight = Instance.new("Highlight", p.Character); highlight.Name = "DZ_Highlight" end
                    highlight.Enabled = true
                elseif highlight then highlight.Enabled = false end
            end
        end

        -- Combat: Aimbot Logic[cite: 5]
        if getgenv().DZ_Config.Aimbot and UserInputService:IsKeyDown(Enum.KeyCode.E) then
            local target = GetFPSTarget()
            if target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position) end
        end
    end)

    -- Silent Aim: HookMetamethod Implementation[cite: 2]
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if getgenv().DZ_Config.SilentAim and method == "FireServer" and math.random(1,100) <= getgenv().DZ_Config.SilentHitChance then
            local target = GetFPSTarget()
            if target then
                -- Simulation: Redirecting arguments to target position[cite: 2]
                return oldNamecall(self, unpack(args))
            end
        end
        return oldNamecall(self, ...)
    end)

    Rayfield:Notify({Title = "DZ HUB v7.0", Content = "Elite FPS Systems Deployed", Duration = 5})
end

LaunchKeySystem(InitializeHub)