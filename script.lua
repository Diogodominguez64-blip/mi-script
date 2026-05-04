--[[
    DZ HUB v6.0 - FPS LAUNCH MASTER EDITION
    Focus: FPS Launch (Universal Compatibility + Map Persistence)
    Referencing: "aimbot code from video_2.txt", "Prompt for RB hack 3.rtf"
]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

--------------------------------------------------------------------------------
-- 1. SECURE KEY SYSTEM (v6.0)[cite: 3]
--------------------------------------------------------------------------------
local function LaunchKeySystem(onSuccess)
    local Screen = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 320, 0, 240)
    Main.Position = UDim2.new(0.5, -160, 0.5, -120)
    Main.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    
    local UIStroke = Instance.new("UIStroke", Main)
    UIStroke.Color = Color3.fromRGB(130, 0, 255)
    UIStroke.Thickness = 3

    local Title = Instance.new("TextLabel", Main)
    Title.Text = "DZ HUB v6.0 | FPS SPECIALIST"
    Title.Size = UDim2.new(1, 0, 0, 60)
    Title.TextColor3 = Color3.fromRGB(130, 0, 255)
    Title.Font = Enum.Font.Code
    Title.TextSize = 20
    Title.BackgroundTransparency = 1

    local Input = Instance.new("TextBox", Main)
    Input.PlaceholderText = "Key: DZ_2026"
    Input.Size = UDim2.new(0.8, 0, 0, 45)
    Input.Position = UDim2.new(0.1, 0, 0.4, 0)
    Input.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Input.TextColor3 = Color3.new(1,1,1)

    local Verify = Instance.new("TextButton", Main)
    Verify.Text = "DEPLOY HUB"
    Verify.Size = UDim2.new(0.8, 0, 0, 50)
    Verify.Position = UDim2.new(0.1, 0, 0.7, 0)
    Verify.BackgroundColor3 = Color3.fromRGB(130, 0, 255)
    Verify.TextColor3 = Color3.new(1,1,1)

    Verify.MouseButton1Click:Connect(function()
        if Input.Text == "DZ_2026" then Screen:Destroy(); onSuccess() end
    end)
end

--------------------------------------------------------------------------------
-- 2. FPS LAUNCH OPTIMIZED ENGINE
--------------------------------------------------------------------------------
local function InitializeHub()
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local Window = Rayfield:CreateWindow({
        Name = "DZ HUB v6.0",
        LoadingTitle = "Initializing FPS Suite...",
        LoadingSubtitle = "Optimized for FPS Launch"
    })

    getgenv().DZ_Config = {
        Aimbot = false, Aggressive = false, ShowFOV = false, FOV = 250,
        TeamCheck = true, ESP = false, Fly = false, FlySpeed = 60, WallCheck = true
    }

    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1
    FOVCircle.Color = Color3.fromRGB(130, 0, 255)

    -- Universal FPS Target Finder[cite: 4, 5]
    local function GetFPSTarget()
        local Target = nil
        local Dist = getgenv().DZ_Config.FOV
        local Mouse = UserInputService:GetMouseLocation()

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local head = p.Character:FindFirstChild("Head") or p.Character:FindFirstChildWhichIsA("BasePart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                
                if head and hum and hum.Health > 0 then
                    if not getgenv().DZ_Config.TeamCheck or p.Team ~= LocalPlayer.Team then
                        local pos, vis = Camera:WorldToViewportPoint(head.Position)
                        if vis then
                            -- Wall Check Implementation[cite: 5]
                            local obs = Camera:GetPartsObscuringTarget({head.Position}, {LocalPlayer.Character, p.Character})
                            if not getgenv().DZ_Config.WallCheck or #obs == 0 then
                                local mag = (Vector2.new(pos.X, pos.Y) - Mouse).Magnitude
                                if mag < Dist then Dist = mag; Target = head end
                            end
                        end
                    end
                end
            end
        end
        return Target
    end

    ----------------------------------------------------------------------------
    -- TAB 1: MAIN (COMBAT)[cite: 1, 5]
    ----------------------------------------------------------------------------
    local MainTab = Window:CreateTab("Main")
    MainTab:CreateToggle({Name = "Aimbot (Hold E)", Callback = function(v) getgenv().DZ_Config.Aimbot = v end})
    MainTab:CreateToggle({Name = "Aggressive Mode", Callback = function(v) getgenv().DZ_Config.Aggressive = v end})
    MainTab:CreateToggle({Name = "Wall Check", CurrentValue = true, Callback = function(v) getgenv().DZ_Config.WallCheck = v end})
    MainTab:CreateToggle({Name = "Show FOV", Callback = function(v) getgenv().DZ_Config.ShowFOV = v end})
    MainTab:CreateSlider({Name = "FOV Radius", Range = {50, 800}, CurrentValue = 250, Callback = function(v) getgenv().DZ_Config.FOV = v end})

    ----------------------------------------------------------------------------
    -- TAB 2: VISUALS (MAP-AWARE ESP)[cite: 5]
    ----------------------------------------------------------------------------
    local VisualsTab = Window:CreateTab("Visuals")
    VisualsTab:CreateToggle({Name = "Universal ESP Highlights", Callback = function(v) getgenv().DZ_Config.ESP = v end})

    -- Map Transition Monitor[cite: 5]
    RunService.Heartbeat:Connect(function()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local h = p.Character:FindFirstChild("DZ_v6_Highlight")
                if getgenv().DZ_Config.ESP and (not getgenv().DZ_Config.TeamCheck or p.Team ~= LocalPlayer.Team) then
                    if not h then
                        h = Instance.new("Highlight", p.Character)
                        h.Name = "DZ_v6_Highlight"
                        h.FillColor = Color3.fromRGB(130, 0, 255)
                    end
                    h.Enabled = true
                elseif h then h.Enabled = false end
            end
        end
    end)

    ----------------------------------------------------------------------------
    -- TAB 3: EXTRAS (FPS MOVEMENT)[cite: 3]
    ----------------------------------------------------------------------------
    local ExtrasTab = Window:CreateTab("Extras")
    ExtrasTab:CreateToggle({
        Name = "Fixed Fly (Stabilized)",
        Callback = function(v)
            getgenv().DZ_Config.Fly = v
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not root then return end
            if v then
                task.spawn(function()
                    local bv = Instance.new("BodyVelocity", root)
                    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    while getgenv().DZ_Config.Fly do
                        bv.Velocity = Camera.CFrame.LookVector * getgenv().DZ_Config.FlySpeed
                        task.wait()
                    end
                    bv:Destroy()
                    root.Velocity = Vector3.zero -- Fixed Stop[cite: 3]
                end)
            else
                root.Velocity = Vector3.zero -- Fixed Stop[cite: 3]
            end
        end
    })

    ----------------------------------------------------------------------------
    -- RUNTIME EXECUTION[cite: 4, 5]
    ----------------------------------------------------------------------------
    RunService.RenderStepped:Connect(function()
        FOVCircle.Visible = getgenv().DZ_Config.ShowFOV
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = getgenv().DZ_Config.FOV

        if getgenv().DZ_Config.Aimbot and UserInputService:IsKeyDown(Enum.KeyCode.E) then
            local target = GetFPSTarget()
            if target then
                local cf = CFrame.new(Camera.CFrame.Position, target.Position)
                if getgenv().DZ_Config.Aggressive then Camera.CFrame = cf 
                else Camera.CFrame = Camera.CFrame:Lerp(cf, 0.2) end
            end
        end
    end)

    Rayfield:Notify({Title = "DZ HUB v6.0", Content = "FPS Launch Mode Engaged", Duration = 5})
end

LaunchKeySystem(InitializeHub)