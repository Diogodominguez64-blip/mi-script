--[[
    DZ HUB v4.0 - Educational Simulation
    Referenced Files: 
    - "Prompt for RB hack.rtf"
    - "RB havk prompt 2.rtf" 
    - "Prompt for RB hack 3.rtf"
    - "aimbot code from video_2.txt"
]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

--------------------------------------------------------------------------------
-- 1. SECURE KEY SYSTEM (v4.0)[cite: 3]
--------------------------------------------------------------------------------
local function LaunchKeySystem(onSuccess)
    local Screen = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 320, 0, 220)
    Main.Position = UDim2.new(0.5, -160, 0.5, -110)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    
    local UIStroke = Instance.new("UIStroke", Main)
    UIStroke.Color = Color3.fromRGB(130, 0, 255)
    UIStroke.Thickness = 2

    local Title = Instance.new("TextLabel", Main)
    Title.Text = "DZ HUB v4.0 | VERIFICATION"
    Title.Size = UDim2.new(1, 0, 0, 60)
    Title.TextColor3 = Color3.fromRGB(130, 0, 255)
    Title.Font = Enum.Font.GothamBold
    Title.BackgroundTransparency = 1

    local Input = Instance.new("TextBox", Main)
    Input.PlaceholderText = "Key: DZ_2026"
    Input.Size = UDim2.new(0.8, 0, 0, 40)
    Input.Position = UDim2.new(0.1, 0, 0.4, 0)
    Input.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Input.TextColor3 = Color3.new(1,1,1)

    local Verify = Instance.new("TextButton", Main)
    Verify.Text = "LAUNCH HUB"
    Verify.Size = UDim2.new(0.8, 0, 0, 45)
    Verify.Position = UDim2.new(0.1, 0, 0.7, 0)
    Verify.BackgroundColor3 = Color3.fromRGB(130, 0, 255)
    Verify.TextColor3 = Color3.new(1,1,1)

    Verify.MouseButton1Click:Connect(function()
        if Input.Text == "DZ_2026" then
            Screen:Destroy()
            onSuccess()
        else
            Input.Text = "INVALID"
            task.wait(0.5)
            Input.Text = ""
        end
    end)
end

--------------------------------------------------------------------------------
-- 2. MAIN HUB (v4.0)[cite: 1, 3]
--------------------------------------------------------------------------------
local function InitializeHub()
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local Window = Rayfield:CreateWindow({
        Name = "DZ HUB v4.0",
        LoadingTitle = "Reconstructing Logic...",
        LoadingSubtitle = "Educational Dev Challenge"
    })

    getgenv().DZ_Config = {
        Aimbot = false, Aggressive = false, ShowFOV = false, FOV = 250,
        TeamCheck = true, ESP = false, Fly = false, FlySpeed = 50
    }

    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 2
    FOVCircle.Color = Color3.fromRGB(130, 0, 255)
    FOVCircle.Transparency = 0.8

    local function GetTarget()
        local Target = nil
        local BestDist = getgenv().DZ_Config.FOV
        local MousePos = UserInputService:GetMouseLocation()

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") then
                if p.Character.Humanoid.Health > 0 and (not getgenv().DZ_Config.TeamCheck or p.Team ~= LocalPlayer.Team) then
                    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                    if OnScreen then
                        local Dist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - MousePos).Magnitude
                        if Dist < BestDist then
                            BestDist = Dist
                            Target = p.Character.Head
                        end
                    end
                end
            end
        end
        return Target
    end

    ----------------------------------------------------------------------------
    -- TAB: MAIN (REBUILT COMBAT)[cite: 5]
    ----------------------------------------------------------------------------
    local MainTab = Window:CreateTab("Main")
    
    MainTab:CreateToggle({
        Name = "Functional Aimbot (Hold E)",
        CurrentValue = false,
        Callback = function(v) getgenv().DZ_Config.Aimbot = v end
    })

    MainTab:CreateToggle({
        Name = "Aggressive Hard Lock",
        CurrentValue = false,
        Callback = function(v) getgenv().DZ_Config.Aggressive = v end
    })

    MainTab:CreateToggle({
        Name = "Display FOV",
        CurrentValue = false,
        Callback = function(v) getgenv().DZ_Config.ShowFOV = v end
    })

    MainTab:CreateSlider({
        Name = "Lock Radius",
        Range = {50, 800},
        Increment = 10,
        CurrentValue = 250,
        Callback = function(v) getgenv().DZ_Config.FOV = v end
    })

    ----------------------------------------------------------------------------
    -- TAB: VISUALS (ROBUST ESP)[cite: 5]
    ----------------------------------------------------------------------------
    local VisualsTab = Window:CreateTab("Visuals")
    
    VisualsTab:CreateToggle({
        Name = "Active Enemy ESP",
        CurrentValue = false,
        Callback = function(v) getgenv().DZ_Config.ESP = v end
    })

    -- Failsafe ESP Loop[cite: 5]
    RunService.RenderStepped:Connect(function()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local isEnemy = not getgenv().DZ_Config.TeamCheck or p.Team ~= LocalPlayer.Team
                if getgenv().DZ_Config.ESP and isEnemy and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    local highlight = p.Character:FindFirstChild("DZ_v4_ESP") or Instance.new("Highlight", p.Character)
                    highlight.Name = "DZ_v4_ESP"
                    highlight.FillColor = Color3.fromRGB(130, 0, 255)
                    highlight.Enabled = true
                elseif p.Character:FindFirstChild("DZ_v4_ESP") then
                    p.Character.DZ_v4_ESP.Enabled = false
                end
            end
        end
    end)

    ----------------------------------------------------------------------------
    -- TAB: EXTRAS (FIXED FLY)[cite: 3]
    ----------------------------------------------------------------------------
    local ExtrasTab = Window:CreateTab("Extras")

    ExtrasTab:CreateToggle({
        Name = "Fixed Fly Mechanic",
        CurrentValue = false,
        Callback = function(Value)
            getgenv().DZ_Config.Fly = Value
            local Char = LocalPlayer.character
            if not Char or not Char:FindFirstChild("HumanoidRootPart") then return end
            
            if Value then
                task.spawn(function()
                    local Root = Char.HumanoidRootPart
                    local BV = Root:FindFirstChild("DZ_v4_Velocity") or Instance.new("BodyVelocity", Root)
                    BV.Name = "DZ_v4_Velocity"
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
    -- COMBAT EXECUTION[cite: 5]
    ----------------------------------------------------------------------------
    RunService.RenderStepped:Connect(function()
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = getgenv().DZ_Config.FOV
        FOVCircle.Visible = getgenv().DZ_Config.ShowFOV

        if getgenv().DZ_Config.Aimbot and UserInputService:IsKeyDown(Enum.KeyCode.E) then
            local target = GetTarget()
            if target then
                local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
                if getgenv().DZ_Config.Aggressive then
                    Camera.CFrame = targetCFrame -- HARD LOCK[cite: 5]
                else
                    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 0.1) -- SMOOTH[cite: 5]
                end
            end
        end
    end)

    Rayfield:Notify({Title = "DZ HUB v4.0", Content = "Combat & ESP Logic Verified", Duration = 5})
end

LaunchKeySystem(InitializeHub)