--[[
    DZ HUB v5.0 - MASTER UNIVERSAL EDITION
    - RE-ENGINEERED COMBAT: Aggressive Aimbot with direct CFrame Injection.
    - RE-ENGINEERED VISUALS: Persistent Highlights with Team-Aware Logic.
    - RE-ENGINEERED MOVEMENT: Physics-Stabilized Flight.
]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

--------------------------------------------------------------------------------
-- 1. MASTER KEY SYSTEM (v5.0)[cite: 3]
--------------------------------------------------------------------------------
local function LaunchKeySystem(onSuccess)
    local Screen = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 320, 0, 240)
    Main.Position = UDim2.new(0.5, -160, 0.5, -120)
    Main.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
    
    local UIStroke = Instance.new("UIStroke", Main)
    UIStroke.Color = Color3.fromRGB(130, 0, 255)
    UIStroke.Thickness = 3

    local Title = Instance.new("TextLabel", Main)
    Title.Text = "DZ HUB v5.0 | MASTER LOGIN"
    Title.Size = UDim2.new(1, 0, 0, 60)
    Title.TextColor3 = Color3.fromRGB(130, 0, 255)
    Title.Font = Enum.Font.Code
    Title.TextSize = 22
    Title.BackgroundTransparency = 1

    local Input = Instance.new("TextBox", Main)
    Input.PlaceholderText = "Key: DZ_2026"
    Input.Size = UDim2.new(0.8, 0, 0, 45)
    Input.Position = UDim2.new(0.1, 0, 0.4, 0)
    Input.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Input.TextColor3 = Color3.new(1,1,1)

    local Verify = Instance.new("TextButton", Main)
    Verify.Text = "INITIALIZE ENGINE"
    Verify.Size = UDim2.new(0.8, 0, 0, 50)
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
-- 2. UNIVERSAL ENGINE INITIALIZATION
--------------------------------------------------------------------------------
local function InitializeHub()
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local Window = Rayfield:CreateWindow({
        Name = "DZ HUB v5.0",
        LoadingTitle = "Master Engine Initializing...",
        LoadingSubtitle = "Universal Compatibility Mode"
    })

    getgenv().DZ_Config = {
        Aimbot = false, Aggressive = false, ShowFOV = false, FOV = 250,
        TeamCheck = true, ESP = false, Fly = false, FlySpeed = 50
    }

    -- FOV Rendering Setup[cite: 3]
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1
    FOVCircle.Color = Color3.fromRGB(130, 0, 255)
    FOVCircle.Transparency = 1
    FOVCircle.Visible = false

    -- Universal Target Finder[cite: 5]
    local function GetUniversalTarget()
        local BestTarget = nil
        local MaxDist = getgenv().DZ_Config.FOV
        local MouseLocation = UserInputService:GetMouseLocation()

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local char = player.Character
                local head = char:FindFirstChild("Head") or char:FindFirstChildWhichIsA("Part")
                local hum = char:FindFirstChildOfClass("Humanoid")

                if head and hum and hum.Health > 0 then
                    if not getgenv().DZ_Config.TeamCheck or player.Team ~= LocalPlayer.Team then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - MouseLocation).Magnitude
                            if dist < MaxDist then
                                MaxDist = dist
                                BestTarget = head
                            end
                        end
                    end
                end
            end
        end
        return BestTarget
    end

    ----------------------------------------------------------------------------
    -- TAB 1: MAIN (COMBAT ENGINE)[cite: 1, 5]
    ----------------------------------------------------------------------------
    local MainTab = Window:CreateTab("Main")
    
    MainTab:CreateToggle({
        Name = "Master Aimbot (Key: E)",
        CurrentValue = false,
        Callback = function(v) getgenv().DZ_Config.Aimbot = v end
    })

    MainTab:CreateToggle({
        Name = "Aggressive Snapping",
        CurrentValue = false,
        Callback = function(v) getgenv().DZ_Config.Aggressive = v end
    })

    MainTab:CreateToggle({
        Name = "Render FOV Circle",
        CurrentValue = false,
        Callback = function(v) getgenv().DZ_Config.ShowFOV = v end
    })

    MainTab:CreateSlider({
        Name = "FOV Radius",
        Range = {50, 800},
        Increment = 10,
        CurrentValue = 250,
        Callback = function(v) getgenv().DZ_Config.FOV = v end
    })

    ----------------------------------------------------------------------------
    -- TAB 2: VISUALS (UNIVERSAL ESP)[cite: 5]
    ----------------------------------------------------------------------------
    local VisualsTab = Window:CreateTab("Visuals")
    
    VisualsTab:CreateToggle({
        Name = "Universal Player ESP",
        CurrentValue = false,
        Callback = function(v) getgenv().DZ_Config.ESP = v end
    })

    -- Universal Persistence Loop[cite: 5]
    RunService.RenderStepped:Connect(function()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local isValid = getgenv().DZ_Config.ESP and (not getgenv().DZ_Config.TeamCheck or p.Team ~= LocalPlayer.Team)
                local highlight = p.Character:FindFirstChild("DZ_MASTER_ESP")
                
                if isValid then
                    if not highlight then
                        highlight = Instance.new("Highlight", p.Character)
                        highlight.Name = "DZ_MASTER_ESP"
                        highlight.FillColor = Color3.fromRGB(130, 0, 255)
                    end
                    highlight.Enabled = true
                elseif highlight then
                    highlight.Enabled = false
                end
            end
        end
    end)

    ----------------------------------------------------------------------------
    -- TAB 3: EXTRAS (MOVEMENT)[cite: 3]
    ----------------------------------------------------------------------------
    local ExtrasTab = Window:CreateTab("Extras")

    ExtrasTab:CreateToggle({
        Name = "Master Fly Mechanic",
        CurrentValue = false,
        Callback = function(Value)
            getgenv().DZ_Config.Fly = Value
            local Char = LocalPlayer.Character
            if not Char or not Char:FindFirstChild("HumanoidRootPart") then return end
            
            if Value then
                task.spawn(function()
                    local Root = Char.HumanoidRootPart
                    local BV = Instance.new("BodyVelocity", Root)
                    BV.Name = "DZ_Master_Velocity"
                    BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    
                    while getgenv().DZ_Config.Fly do
                        BV.Velocity = Camera.CFrame.LookVector * getgenv().DZ_Config.FlySpeed
                        task.wait()
                    end
                    BV:Destroy()
                    Root.Velocity = Vector3.zero -- Physics Stabilization[cite: 3]
                end)
            else
                Char.HumanoidRootPart.Velocity = Vector3.zero -- Physics Stabilization[cite: 3]
            end
        end,
    })

    ----------------------------------------------------------------------------
    -- UNIVERSAL COMBAT RUNTIME[cite: 4, 5]
    ----------------------------------------------------------------------------
    RunService.RenderStepped:Connect(function()
        -- FOV Management
        FOVCircle.Visible = getgenv().DZ_Config.ShowFOV
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = getgenv().DZ_Config.FOV

        -- Aimbot Logic Execution
        if getgenv().DZ_Config.Aimbot and UserInputService:IsKeyDown(Enum.KeyCode.E) then
            local Target = GetUniversalTarget()
            if Target then
                local TargetCF = CFrame.new(Camera.CFrame.Position, Target.Position)
                if getgenv().DZ_Config.Aggressive then
                    Camera.CFrame = TargetCF -- Instant Snap[cite: 5]
                else
                    Camera.CFrame = Camera.CFrame:Lerp(TargetCF, 0.2) -- Master Smooth[cite: 5]
                end
            end
        end
    end)

    Rayfield:Notify({Title = "DZ HUB v5.0", Content = "Universal Master Engine Active", Duration = 5})
end

LaunchKeySystem(InitializeHub)