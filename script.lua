--[[
    DZ HUB v3.0 - Professional Dev Challenge Simulation
    - Fixed Aimbot (Main) + Aggressive Mode
    - Fixed ESP (Visuals)
    - FOV Circle Rendering
    - Fixed Fly (Extras)
]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

--------------------------------------------------------------------------------
-- 1. SECURE KEY SYSTEM (v3.0)
--------------------------------------------------------------------------------
local function LaunchKeySystem(onSuccess)
    local Screen = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 320, 0, 220)
    Main.Position = UDim2.new(0.5, -160, 0.5, -110)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    
    local UIStroke = Instance.new("UIStroke", Main)
    UIStroke.Color = Color3.fromRGB(130, 0, 255)
    UIStroke.Thickness = 3

    local Title = Instance.new("TextLabel", Main)
    Title.Text = "DZ HUB v3.0 | LOGIN"
    Title.Size = UDim2.new(1, 0, 0, 60)
    Title.TextColor3 = Color3.fromRGB(130, 0, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20
    Title.BackgroundTransparency = 1

    local Input = Instance.new("TextBox", Main)
    Input.PlaceholderText = "Key: DZ_2026"
    Input.Size = UDim2.new(0.8, 0, 0, 45)
    Input.Position = UDim2.new(0.1, 0, 0.4, 0)
    Input.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Input.TextColor3 = Color3.new(1,1,1)

    local Verify = Instance.new("TextButton", Main)
    Verify.Text = "ACCESS SYSTEMS"
    Verify.Size = UDim2.new(0.8, 0, 0, 45)
    Verify.Position = UDim2.new(0.1, 0, 0.7, 0)
    Verify.BackgroundColor3 = Color3.fromRGB(130, 0, 255)
    Verify.TextColor3 = Color3.new(1,1,1)

    Verify.MouseButton1Click:Connect(function()
        if Input.Text == "DZ_2026" then
            Screen:Destroy()
            onSuccess()
        else
            Input.Text = "ACCESS DENIED"
            task.wait(1)
            Input.Text = ""
        end
    end)
end

--------------------------------------------------------------------------------
-- 2. MAIN HUB (v3.0)
--------------------------------------------------------------------------------
local function InitializeHub()
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local Window = Rayfield:CreateWindow({
        Name = "DZ HUB v3.0",
        LoadingTitle = "Securing Environment...",
        LoadingSubtitle = "Aggressive Combat Suite"
    })

    getgenv().DZ_Config = {
        Aimbot = false, 
        Aggressive = false,
        ShowFOV = false,
        FOV = 250,
        TeamCheck = true,
        ESP = false,
        Fly = false,
        FlySpeed = 50
    }

    -- FOV Drawing Setup[cite: 3]
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 2
    FOVCircle.Color = Color3.fromRGB(130, 0, 255)
    FOVCircle.Filled = false
    FOVCircle.Transparency = 0.7

    local function IsValidTarget(p)
        if not p.Character or not p.Character:FindFirstChild("Humanoid") then return false end
        if p.Character.Humanoid.Health <= 0 then return false end
        if getgenv().DZ_Config.TeamCheck and p.Team == LocalPlayer.Team then return false end
        return true
    end

    ----------------------------------------------------------------------------
    -- TAB: MAIN (REBUILT AIMBOT)[cite: 1, 5]
    ----------------------------------------------------------------------------
    local MainTab = Window:CreateTab("Main")
    
    MainTab:CreateToggle({
        Name = "Enable Aimbot (Key: E)",
        CurrentValue = false,
        Callback = function(v) getgenv().DZ_Config.Aimbot = v end
    })

    MainTab:CreateToggle({
        Name = "Aggressive Mode (No Smoothing)",
        CurrentValue = false,
        Callback = function(v) getgenv().DZ_Config.Aggressive = v end
    })

    MainTab:CreateToggle({
        Name = "Show FOV Circle",
        CurrentValue = false,
        Callback = function(v) getgenv().DZ_Config.ShowFOV = v end
    })

    MainTab:CreateSlider({
        Name = "Aimbot Range (FOV)",
        Range = {50, 800},
        Increment = 10,
        CurrentValue = 250,
        Callback = function(v) getgenv().DZ_Config.FOV = v end
    })

    ----------------------------------------------------------------------------
    -- TAB: VISUALS (FIXED ESP)[cite: 5]
    ----------------------------------------------------------------------------
    local VisualsTab = Window:CreateTab("Visuals")
    
    VisualsTab:CreateToggle({
        Name = "Enable Player ESP",
        CurrentValue = false,
        Callback = function(v) getgenv().DZ_Config.ESP = v end
    })

    -- High-Performance ESP Loop[cite: 5]
    RunService.Heartbeat:Connect(function()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local char = p.Character
                if char and getgenv().DZ_Config.ESP and IsValidTarget(p) then
                    local highlight = char:FindFirstChild("DZ_Highlight") or Instance.new("Highlight", char)
                    highlight.Name = "DZ_Highlight"
                    highlight.FillColor = Color3.fromRGB(130, 0, 255)
                    highlight.OutlineColor = Color3.new(1, 1, 1)
                    highlight.Enabled = true
                elseif char and char:FindFirstChild("DZ_Highlight") then
                    char.DZ_Highlight.Enabled = false
                end
            end
        end
    end)

    ----------------------------------------------------------------------------
    -- TAB: EXTRAS (FIXED FLY)[cite: 3]
    ----------------------------------------------------------------------------
    local ExtrasTab = Window:CreateTab("Extras")

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
                    BV.Name = "DZ_Flyer"
                    BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    
                    while getgenv().DZ_Config.Fly do
                        BV.Velocity = Camera.CFrame.LookVector * getgenv().DZ_Config.FlySpeed
                        task.wait()
                    end
                    BV:Destroy()
                    Root.Velocity = Vector3.zero -- FIXED STOP[cite: 3]
                end)
            else
                Char.HumanoidRootPart.Velocity = Vector3.zero -- FIXED STOP[cite: 3]
            end
        end,
    })

    ----------------------------------------------------------------------------
    -- COMBAT ENGINE (AIMBOT & FOV RENDERING)[cite: 4, 5]
    ----------------------------------------------------------------------------
    RunService.RenderStepped:Connect(function()
        -- Update FOV Circle Position and Size
        local Mouse = UserInputService:GetMouseLocation()
        FOVCircle.Position = Mouse
        FOVCircle.Radius = getgenv().DZ_Config.FOV
        FOVCircle.Visible = getgenv().DZ_Config.ShowFOV

        -- Aimbot Execution[cite: 5]
        if getgenv().DZ_Config.Aimbot and UserInputService:IsKeyDown(Enum.KeyCode.E) then
            local Target = nil
            local ClosestDist = getgenv().DZ_Config.FOV
            
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and IsValidTarget(p) then
                    local Head = p.Character:FindFirstChild("Head")
                    if Head then
                        local Pos, OnScreen = Camera:WorldToViewportPoint(Head.Position)
                        if OnScreen then
                            local Dist = (Vector2.new(Pos.X, Pos.Y) - Mouse).Magnitude
                            if Dist < ClosestDist then
                                ClosestDist = Dist
                                Target = Head
                            end
                        end
                    end
                end
            end
            
            if Target then
                if getgenv().DZ_Config.Aggressive then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Position) -- Hard Lock[cite: 4]
                else
                    -- Smooth Tracking
                    local LookAt = CFrame.new(Camera.CFrame.Position, Target.Position)
                    Camera.CFrame = Camera.CFrame:Lerp(LookAt, 0.15)
                end
            end
        end
    end)

    Rayfield:Notify({Title = "DZ HUB v3.0", Content = "Aggressive Systems Active", Duration = 5})
end

LaunchKeySystem(InitializeHub)