--[[
    DZ HUB v1.0
    Integrated with logic from: 
    - "Prompt for RB hack.rtf"
    - "RB havk prompt 2.rtf"
    - "Prompt for RB hack 3.rtf"
    - "aimbot code from video.txt"
]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

--------------------------------------------------------------------------------
-- 1. KEY SYSTEM (DZ HUB BRANDING)
--------------------------------------------------------------------------------
local function LaunchKeySystem(onSuccess)
    local Screen = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 300, 0, 200)
    Main.Position = UDim2.new(0.5, -150, 0.5, -100)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    
    local Title = Instance.new("TextLabel", Main)
    Title.Text = "DZ HUB | KEY REQUIRED"
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.TextColor3 = Color3.fromRGB(130, 0, 255)
    Title.BackgroundTransparency = 1

    local Input = Instance.new("TextBox", Main)
    Input.PlaceholderText = "Enter Key..."
    Input.Size = UDim2.new(0.8, 0, 0, 40)
    Input.Position = UDim2.new(0.1, 0, 0.35, 0)
    Input.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Input.TextColor3 = Color3.new(1,1,1)

    local Verify = Instance.new("TextButton", Main)
    Verify.Text = "Verify"
    Verify.Size = UDim2.new(0.8, 0, 0, 40)
    Verify.Position = UDim2.new(0.1, 0, 0.65, 0)
    Verify.BackgroundColor3 = Color3.fromRGB(130, 0, 255)
    Verify.TextColor3 = Color3.new(1,1,1)

    -- Animated Intro[cite: 3]
    Main.BackgroundTransparency = 1
    TweenService:Create(Main, TweenInfo.new(0.5), {BackgroundTransparency = 0.1}):Play()

    Verify.MouseButton1Click:Connect(function()
        if Input.Text == "DZ_2026" then
            Screen:Destroy()
            onSuccess()
        else
            Input.Text = "INVALID KEY"
            task.wait(1)
            Input.Text = ""
        end
    end)
end

--------------------------------------------------------------------------------
-- 2. CORE HUB INITIALIZATION
--------------------------------------------------------------------------------
local function InitializeHub()
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local Window = Rayfield:CreateWindow({
        Name = "DZ HUB v1.0",
        LoadingTitle = "DZ Hub Loading...",
        LoadingSubtitle = "by Dev Challenge"
    })

    getgenv().DZ_Config = {
        Fly = false, FlySpeed = 50,
        Aimbot = false, TeamCheck = true, FOV = 250,
        ESP = false
    }

    -- Logic Helper: Team Check[cite: 5]
    local function IsEnemy(p)
        if not getgenv().DZ_Config.TeamCheck then return true end
        if p.Team == nil or p.Team ~= LocalPlayer.Team then return true end
        return false
    end

    ----------------------------------------------------------------------------
    -- MAIN TAB (MOVEMENT & FIXED FLY)[cite: 3]
    ----------------------------------------------------------------------------
    local MainTab = Window:CreateTab("Main")
    
    MainTab:CreateToggle({
        Name = "Fixed Fly",
        CurrentValue = false,
        Callback = function(Value)
            getgenv().DZ_Config.Fly = Value
            local Char = LocalPlayer.Character
            if not Char or not Char:FindFirstChild("HumanoidRootPart") then return end
            
            if Value then
                task.spawn(function()
                    local Root = Char.HumanoidRootPart
                    local BV = Instance.new("BodyVelocity", Root)
                    BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    
                    while getgenv().DZ_Config.Fly do
                        BV.Velocity = Camera.CFrame.LookVector * getgenv().DZ_Config.FlySpeed
                        task.wait()
                    end
                    BV:Destroy() -- Cleanup
                    Root.Velocity = Vector3.new(0, 0, 0) -- FIXED: Immediate Stop[cite: 3]
                end)
            else
                Char.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0) -- FIXED: Immediate Stop[cite: 3]
            end
        end,
    })

    MainTab:CreateSlider({
        Name = "Fly Speed",
        Range = {16, 500},
        Increment = 1,
        CurrentValue = 50,
        Callback = function(Value) getgenv().DZ_Config.FlySpeed = Value end,
    })

    ----------------------------------------------------------------------------
    -- COMBAT TAB (TEAM CHECKED)[cite: 5]
    ----------------------------------------------------------------------------
    local CombatTab = Window:CreateTab("Combat")

    CombatTab:CreateToggle({
        Name = "Aimbot (Hold E)",
        CurrentValue = false,
        Callback = function(Value) getgenv().DZ_Config.Aimbot = Value end,
    })

    CombatTab:CreateToggle({
        Name = "Team Check",
        CurrentValue = true,
        Callback = function(Value) getgenv().DZ_Config.TeamCheck = Value end,
    })

    -- Aimbot Logic from "aimbot code from video.txt"[cite: 4, 5]
    RunService.RenderStepped:Connect(function()
        if getgenv().DZ_Config.Aimbot and UserInputService:IsKeyDown(Enum.KeyCode.E) then
            local Target = nil
            local BestDist = getgenv().DZ_Config.FOV
            
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and IsEnemy(p) then
                    local Pos, OnScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                    if OnScreen then
                        local Mouse = UserInputService:GetMouseLocation()
                        local Dist = (Vector2.new(Pos.X, Pos.Y) - Mouse).Magnitude
                        if Dist < BestDist then
                            BestDist = Dist
                            Target = p.Character.Head
                        end
                    end
                end
            end
            
            if Target then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Position) -- Aimbot Lock[cite: 5]
            end
        end
    end)

    ----------------------------------------------------------------------------
    -- VISUALS TAB[cite: 1, 5]
    ----------------------------------------------------------------------------
    local VisualsTab = Window:CreateTab("Visuals")
    
    VisualsTab:CreateToggle({
        Name = "Enemy ESP",
        CurrentValue = false,
        Callback = function(Value) getgenv().DZ_Config.ESP = Value end,
    })

    -- ESP Loop with Team Check Logic[cite: 5]
    task.spawn(function()
        while task.wait(1) do
            if getgenv().DZ_Config.ESP then
                -- Simulation of Highlight application from Source 5
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and IsEnemy(p) then
                        -- Apply Visual Highlights here
                    end
                end
            end
        end
    end)

    Rayfield:Notify({Title = "DZ HUB", Content = "System Loaded Successfully", Duration = 5})
end

-- Execution Sequence[cite: 3]
LaunchKeySystem(InitializeHub)