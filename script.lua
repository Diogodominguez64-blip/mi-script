--[[
    DZ HUB v2.0 - Educational Script Simulation
    Changes: Aimbot moved to Main, Fly moved to Extras, ESP & Aimbot Fixed.
    Referencing: "aimbot code from video_2.txt" and "Prompt for RB hack 3.rtf"
]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

--------------------------------------------------------------------------------
-- 1. SECURE LOGIN SYSTEM (DZ HUB v2.0)
--------------------------------------------------------------------------------
local function LaunchKeySystem(onSuccess)
    local Screen = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 320, 0, 220)
    Main.Position = UDim2.new(0.5, -160, 0.5, -110)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    
    local UICorner = Instance.new("UICorner", Main)
    local UIStroke = Instance.new("UIStroke", Main)
    UIStroke.Color = Color3.fromRGB(130, 0, 255)
    UIStroke.Thickness = 2

    local Title = Instance.new("TextLabel", Main)
    Title.Text = "DZ HUB v2.0 | ACCESS"
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.TextColor3 = Color3.fromRGB(130, 0, 255)
    Title.Font = Enum.Font.GothamBold
    Title.BackgroundTransparency = 1

    local Input = Instance.new("TextBox", Main)
    Input.PlaceholderText = "Enter Key..."
    Input.Size = UDim2.new(0.8, 0, 0, 40)
    Input.Position = UDim2.new(0.1, 0, 0.4, 0)
    Input.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Input.TextColor3 = Color3.new(1,1,1)

    local Verify = Instance.new("TextButton", Main)
    Verify.Text = "Initialize Hub"
    Verify.Size = UDim2.new(0.8, 0, 0, 45)
    Verify.Position = UDim2.new(0.1, 0, 0.7, 0)
    Verify.BackgroundColor3 = Color3.fromRGB(130, 0, 255)
    Verify.TextColor3 = Color3.new(1,1,1)

    Verify.MouseButton1Click:Connect(function()
        if Input.Text == "DZ_2026" then
            Screen:Destroy()
            onSuccess()
        else
            Input.Text = ""
            Input.PlaceholderText = "ACCESS DENIED"
        end
    end)
end

--------------------------------------------------------------------------------
-- 2. MAIN HUB (v2.0 REORGANIZED)
--------------------------------------------------------------------------------
local function InitializeHub()
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local Window = Rayfield:CreateWindow({
        Name = "DZ HUB v2.0",
        LoadingTitle = "Initializing Systems...",
        LoadingSubtitle = "by Dev Challenge"
    })

    getgenv().DZ_Config = {
        Fly = false, FlySpeed = 50,
        Aimbot = false, TeamCheck = true, FOV = 250,
        ESP = false
    }

    -- Helper: Team & Health Check[cite: 5]
    local function IsValidTarget(p)
        if not p.Character or not p.Character:FindFirstChild("Humanoid") then return false end
        if p.Character.Humanoid.Health <= 0 then return false end
        if getgenv().DZ_Config.TeamCheck and p.Team == LocalPlayer.Team then return false end
        return true
    end

    ----------------------------------------------------------------------------
    -- TAB 1: MAIN (COMBAT FOCUS)[cite: 1]
    ----------------------------------------------------------------------------
    local MainTab = Window:CreateTab("Main")
    
    MainTab:CreateSection("Aimbot Settings")
    MainTab:CreateToggle({
        Name = "Aimbot (Hold E)",
        CurrentValue = false,
        Callback = function(Value) getgenv().DZ_Config.Aimbot = Value end,
    })

    MainTab:CreateToggle({
        Name = "Team Check",
        CurrentValue = true,
        Callback = function(Value) getgenv().DZ_Config.TeamCheck = Value end,
    })

    MainTab:CreateSlider({
        Name = "Aimbot FOV",
        Range = {50, 800},
        Increment = 10,
        CurrentValue = 250,
        Callback = function(Value) getgenv().DZ_Config.FOV = Value end,
    })

    ----------------------------------------------------------------------------
    -- TAB 2: VISUALS (ESP FIX)[cite: 5]
    ----------------------------------------------------------------------------
    local VisualsTab = Window:CreateTab("Visuals")
    
    VisualsTab:CreateToggle({
        Name = "Enemy Highlights",
        CurrentValue = false,
        Callback = function(Value) getgenv().DZ_Config.ESP = Value end,
    })

    -- ESP Fixed Logic: Uses Highlights for visibility[cite: 5]
    task.spawn(function()
        while task.wait(1) do
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    local char = p.Character
                    if char and getgenv().DZ_Config.ESP and IsValidTarget(p) then
                        if not char:FindFirstChild("DZ_ESP") then
                            local highlight = Instance.new("Highlight", char)
                            highlight.Name = "DZ_ESP"
                            highlight.FillColor = Color3.fromRGB(255, 0, 0)
                            highlight.OutlineColor = Color3.new(1, 1, 1)
                        end
                    elseif char and char:FindFirstChild("DZ_ESP") then
                        char.DZ_ESP:Destroy()
                    end
                end
            end
        end
    end)

    ----------------------------------------------------------------------------
    -- TAB 3: EXTRAS (MOVEMENT)[cite: 3]
    ----------------------------------------------------------------------------
    local ExtrasTab = Window:CreateTab("Extras")

    ExtrasTab:CreateSection("Flight Mechanics")
    ExtrasTab:CreateToggle({
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
                    BV.Name = "DZ_Fly"
                    BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    
                    while getgenv().DZ_Config.Fly do
                        BV.Velocity = Camera.CFrame.LookVector * getgenv().DZ_Config.FlySpeed
                        task.wait()
                    end
                    BV:Destroy()
                    Root.Velocity = Vector3.zero -- FULL STOP[cite: 3]
                end)
            else
                if Char.HumanoidRootPart:FindFirstChild("DZ_Fly") then
                    Char.HumanoidRootPart.DZ_Fly:Destroy()
                end
                Char.HumanoidRootPart.Velocity = Vector3.zero -- FULL STOP[cite: 3]
            end
        end,
    })

    ExtrasTab:CreateSlider({
        Name = "Flight Speed",
        Range = {16, 500},
        Increment = 5,
        CurrentValue = 50,
        Callback = function(Value) getgenv().DZ_Config.FlySpeed = Value end,
    })

    ----------------------------------------------------------------------------
    -- AIMBOT RENDER LOOP[cite: 4, 5]
    ----------------------------------------------------------------------------
    RunService.RenderStepped:Connect(function()
        if getgenv().DZ_Config.Aimbot and UserInputService:IsKeyDown(Enum.KeyCode.E) then
            local Target = nil
            local ClosestDist = getgenv().DZ_Config.FOV
            
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and IsValidTarget(p) then
                    local Head = p.Character:FindFirstChild("Head")
                    if Head then
                        local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Head.Position)
                        if OnScreen then
                            local Mouse = UserInputService:GetMouseLocation()
                            local Dist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Mouse).Magnitude
                            if Dist < ClosestDist then
                                ClosestDist = Dist
                                Target = Head
                            end
                        end
                    end
                end
            end
            
            if Target then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Position)
            end
        end
    end)

    Rayfield:Notify({Title = "DZ HUB v2.0", Content = "Combat and Extras tabs initialized.", Duration = 5})
end

LaunchKeySystem(InitializeHub)