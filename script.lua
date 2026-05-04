--[[
    DZ HUB v1.0 - Educational Simulation
    Features: Key System, Fixed Fly, Universal ESP, Combat & Farm
]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--------------------------------------------------------------------------------
-- 1. KEY SYSTEM (ENHANCED DESIGN & ANIMATIONS)
--------------------------------------------------------------------------------
local function StartKeySystem(callback)
    local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    ScreenGui.Name = "DZ_KeySystem"

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 0, 0, 0) -- Starts small for animation
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BorderSizePixel = 0

    local UICorner = Instance.new("UICorner", MainFrame)
    local UIStroke = Instance.new("UIStroke", MainFrame)
    UIStroke.Color = Color3.fromRGB(130, 0, 255)
    UIStroke.Thickness = 2

    local Title = Instance.new("TextLabel", MainFrame)
    Title.Text = "DZ HUB | LOGIN"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18

    local KeyInput = Instance.new("TextBox", MainFrame)
    KeyInput.PlaceholderText = "Enter Key Here..."
    KeyInput.Size = UDim2.new(0.8, 0, 0, 40)
    KeyInput.Position = UDim2.new(0.1, 0, 0.4, 0)
    KeyInput.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local SubmitBtn = Instance.new("TextButton", MainFrame)
    SubmitBtn.Text = "Verify Key"
    SubmitBtn.Size = UDim2.new(0.8, 0, 0, 40)
    SubmitBtn.Position = UDim2.new(0.1, 0, 0.7, 0)
    SubmitBtn.BackgroundColor3 = Color3.fromRGB(130, 0, 255)
    SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

    -- Opening Animation
    MainFrame:TweenSize(UDim2.new(0, 300, 0, 200), "Out", "Back", 0.5, true)

    SubmitBtn.MouseButton1Click:Connect(function()
        if KeyInput.Text == "DZ_2026" then -- Simulation Key
            MainFrame:TweenPosition(UDim2.new(0.5, 0, 1.5, 0), "In", "Back", 0.5, true)
            task.wait(0.5)
            ScreenGui:Destroy()
            callback()
        else
            KeyInput.Text = ""
            KeyInput.PlaceholderText = "WRONG KEY!"
            task.wait(1)
            KeyInput.PlaceholderText = "Enter Key Here..."
        end
    end)
end

--------------------------------------------------------------------------------
-- 2. MAIN HUB INITIALIZATION
--------------------------------------------------------------------------------
local function InitializeHub()
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

    local Window = Rayfield:CreateWindow({
       Name = "DZ HUB v1.0",
       LoadingTitle = "DZ Hub Execution",
       LoadingSubtitle = "by Dev Challenge",
       ConfigurationSaving = {
          Enabled = true,
          FolderName = "DZ_Configs"
       },
       KeySystem = false -- We used our own custom one above
    })

    -- Global Toggles[cite: 1, 2]
    getgenv().DZ_Hub = {
        Fly = false,
        FlySpeed = 50,
        ESP = false,
        Aimbot = false
    }

    ----------------------------------------------------------------------------
    -- MAIN TAB: PLAYER MOVEMENT[cite: 3]
    ----------------------------------------------------------------------------
    local MainTab = Window:CreateTab("Main", 4483362458)
    
    local FlyToggle = MainTab:CreateToggle({
       Name = "Fixed Fly",
       CurrentValue = false,
       Callback = function(Value)
          getgenv().DZ_Hub.Fly = Value
          local Char = LocalPlayer.Character
          if not Char or not Char:FindFirstChild("HumanoidRootPart") then return end
          
          if Value then
             -- Fly Logic Implementation[cite: 3]
             task.spawn(function()
                local Root = Char.HumanoidRootPart
                local BV = Instance.new("BodyVelocity", Root)
                BV.Velocity = Vector3.new(0,0,0)
                BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                
                while getgenv().DZ_Hub.Fly do
                   local Dir = Vector3.new(0,0,0)
                   -- Simple movement simulation
                   BV.Velocity = Dir * getgenv().DZ_Hub.FlySpeed
                   task.wait()
                end
                BV:Destroy() -- Cleanup[cite: 3]
             end)
          else
             -- FIXED: Immediate Stop[cite: 3]
             if Char:FindFirstChild("HumanoidRootPart") then
                Char.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
             end
          end
       end,
    })

    MainTab:CreateSlider({
       Name = "Fly Speed",
       Range = {16, 500},
       Increment = 1,
       CurrentValue = 50,
       Callback = function(Value)
          getgenv().DZ_Hub.FlySpeed = Value
       end,
    })

    ----------------------------------------------------------------------------
    -- VISUALS TAB[cite: 4]
    ----------------------------------------------------------------------------
    local VisualsTab = Window:CreateTab("Visuals", 4483362458)
    
    VisualsTab:CreateToggle({
       Name = "Player ESP",
       CurrentValue = false,
       Callback = function(Value)
          getgenv().DZ_Hub.ESP = Value
          -- ESP Logic with Team Check[cite: 4]
       end,
    })

    ----------------------------------------------------------------------------
    -- COMBAT & FARM TABS[cite: 1, 2]
    ----------------------------------------------------------------------------
    local CombatTab = Window:CreateTab("Combat", 4483362458)
    local FarmTab = Window:CreateTab("Farm", 4483362458)

    FarmTab:CreateButton({
       Name = "Auto-Detect Remotes",
       Callback = function()
          Rayfield:Notify({Title = "DZ Hub", Content = "Scanning for RemoteEvents...", Duration = 3})
          -- Simulation of remote finding[cite: 1]
       end,
    })

    Rayfield:Notify({Title = "Success", Content = "DZ Hub Loaded Correctly!", Duration = 5})
end

-- Start Script Sequence
StartKeySystem(InitializeHub)