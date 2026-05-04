--[[
    ENIGMA HUB v12.0 (TEAM CHECK FIX)
    - LOGIC FIX: Now ignores players on your same Team.
    - TARGETS: Only Enemies and Neutral players.
    - UI: Draggable & High Visibility preserved.
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--------------------------------------------------------------------------------
-- 1. CONFIGURATION
--------------------------------------------------------------------------------
local Config = {
    Aimbot = false,
    AimKey = Enum.KeyCode.E,
    ESP = false,
    TeamCheck = true, -- Set to TRUE to ignore teammates
    FOV = 250,
    MenuOpen = true
}

local Theme = {
    Purple = Color3.fromRGB(130, 0, 255),
    Black = Color3.fromRGB(10, 10, 15),
    White = Color3.fromRGB(255, 255, 255),
    Grey = Color3.fromRGB(40, 40, 50),
    Red = Color3.fromRGB(255, 50, 50) -- Enemy Color
}

--------------------------------------------------------------------------------
-- 2. UI ENGINE (DRAGGABLE + VISIBLE)
--------------------------------------------------------------------------------
local function CreateGUI()
    if LocalPlayer.PlayerGui:FindFirstChild("ENIGMA_TEAM_FIX") then
        LocalPlayer.PlayerGui.DZ_TEAM_FIX:Destroy()
    end

    local Screen = Instance.new("ScreenGui")
    Screen.Name = "DZ_TEAM_FIX"
    Screen.ResetOnSpawn = false
    Screen.ZIndexBehavior = Enum.ZIndexBehavior.Global 
    Screen.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- CONTAINER (Draggable Parent)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, 300, 0, 400)
    Container.Position = UDim2.new(0.5, -150, 0.3, 0)
    Container.BackgroundTransparency = 1 
    Container.Parent = Screen

    -- BACKGROUND (The "Handle")
    local Bg = Instance.new("Frame")
    Bg.Size = UDim2.new(1, 0, 1, 0)
    Bg.BackgroundColor3 = Theme.Black
    Bg.BackgroundTransparency = 0.1
    Bg.BorderSizePixel = 2
    Bg.BorderColor3 = Theme.Purple
    Bg.ZIndex = 1 
    Bg.Active = true
    Bg.Parent = Container

    -- HEADER
    local Header = Instance.new("TextLabel")
    Header.Text = "DZ v12 :: TEAM FIX"
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.BackgroundTransparency = 1
    Header.TextColor3 = Theme.Purple
    Header.Font = Enum.Font.Code
    Header.TextSize = 20
    Header.ZIndex = 10 
    Header.Parent = Container

    -- DRAG LOGIC
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        Container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    Bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = Container.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    Bg.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)

    -- BUTTONS
    local function CreateBtn(text, yPos, flag)
        local Btn = Instance.new("TextButton")
        Btn.Parent = Container
        Btn.Text = text .. " [OFF]"
        Btn.Size = UDim2.new(0.9, 0, 0, 45)
        Btn.Position = UDim2.new(0.05, 0, 0, yPos)
        Btn.BackgroundColor3 = Theme.Grey
        Btn.TextColor3 = Theme.White
        Btn.Font = Enum.Font.Code
        Btn.TextSize = 14
        Btn.ZIndex = 20 
        
        local Stroke = Instance.new("UIStroke"); Stroke.Color = Color3.new(0,0,0); Stroke.Thickness = 2; Stroke.Parent = Btn

        Btn.Activated:Connect(function()
            Config[flag] = not Config[flag]
            if Config[flag] then
                Btn.Text = text .. " [ON]"
                Btn.BackgroundColor3 = Theme.Purple
            else
                Btn.Text = text .. " [OFF]"
                Btn.BackgroundColor3 = Theme.Grey
            end
        end)
    end

    CreateBtn("AIM ASSIST (HOLD E)", 60, "Aimbot")
    CreateBtn("ESP (ENEMIES ONLY)", 120, "ESP")

    -- MINIMIZE
    local MinBtn = Instance.new("TextButton")
    MinBtn.Text = "-"
    MinBtn.Size = UDim2.new(0, 40, 0, 40)
    MinBtn.Position = UDim2.new(1, -40, 0, 0)
    MinBtn.BackgroundTransparency = 1
    MinBtn.TextColor3 = Theme.White
    MinBtn.TextSize = 30
    MinBtn.ZIndex = 30
    MinBtn.Parent = Container

    MinBtn.Activated:Connect(function()
        Config.MenuOpen = not Config.MenuOpen
        if Config.MenuOpen then
            Container.Size = UDim2.new(0, 300, 0, 400); Bg.Visible = true; MinBtn.Text = "-"
            for _,v in pairs(Container:GetChildren()) do if v:IsA("TextButton") and v ~= MinBtn then v.Visible = true end end
        else
            Container.Size = UDim2.new(0, 300, 0, 50); Bg.Visible = true; MinBtn.Text = "+"
            for _,v in pairs(Container:GetChildren()) do if v:IsA("TextButton") and v ~= MinBtn then v.Visible = false end end
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Insert then Container.Visible = not Container.Visible end
    end)
end

CreateGUI()

--------------------------------------------------------------------------------
-- 3. VISUALS (ESP - TEAM CHECKED)
--------------------------------------------------------------------------------
local ESP_Folder = Instance.new("Folder", Workspace)
local FOV_Box = Instance.new("Frame")
FOV_Box.BackgroundTransparency = 1
FOV_Box.BorderColor3 = Theme.Purple
FOV_Box.BorderSizePixel = 2
FOV_Box.Visible = false
FOV_Box.ZIndex = 100
FOV_Box.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function IsEnemy(player)
    if not Config.TeamCheck then return true end -- If check disabled, everyone is enemy
    if player.Team == nil then return true end -- Neutral is enemy
    if player.Team == LocalPlayer.Team then return false end -- Teammate
    return true -- Different team
end

local function UpdateESP()
    ESP_Folder:ClearAllChildren()
    if not Config.ESP then return end

    local function Highlight(target, color)
        local box = Instance.new("BoxHandleAdornment")
        box.Size = Vector3.new(4, 5, 2)
        box.Adornee = target
        box.AlwaysOnTop = true
        box.ZIndex = 10
        box.Transparency = 0.5
        box.Color3 = color
        box.Parent = ESP_Folder
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if IsEnemy(p) then
                Highlight(p.Character.HumanoidRootPart, Theme.Red)
            end
        end
    end
    
    -- NPCs are always enemies
    for _, m in pairs(Workspace:GetChildren()) do
        if m:IsA("Model") and m:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(m) then
            Highlight(m.HumanoidRootPart, Theme.Red)
        end
    end
end

task.spawn(function()
    while true do UpdateESP() task.wait(1) end
end)

--------------------------------------------------------------------------------
-- 4. AIMBOT (TEAM CHECKED)
--------------------------------------------------------------------------------
local function GetClosest()
    local Mouse = UserInputService:GetMouseLocation()
    local BestDist = Config.FOV
    local Target = nil

    local function Check(char, plr)
        if plr and not IsEnemy(plr) then return end -- SKIP TEAMMATES

        local Head = char:FindFirstChild("Head")
        local Hum = char:FindFirstChild("Humanoid")
        
        if Head and Hum and Hum.Health > 0 then
            local Pos, Vis = Camera:WorldToViewportPoint(Head.Position)
            if Vis then
                local Dist = (Vector2.new(Pos.X, Pos.Y) - Mouse).Magnitude
                if Dist < BestDist then
                    BestDist = Dist
                    Target = Head
                end
            end
        end
    end

    for _, p in pairs(Players:GetPlayers()) do 
        if p ~= LocalPlayer and p.Character then Check(p.Character, p) end
    end
    for _, m in pairs(Workspace:GetChildren()) do
        if m:IsA("Model") and m:FindFirstChild("Humanoid") then Check(m, nil) end
    end
    
    return Target
end

RunService.RenderStepped:Connect(function()
    local m = UserInputService:GetMouseLocation()
    
    if Config.Aimbot then
        FOV_Box.Visible = true
        FOV_Box.Size = UDim2.new(0, Config.FOV*2, 0, Config.FOV*2)
        FOV_Box.Position = UDim2.new(0, m.X - Config.FOV, 0, m.Y - Config.FOV)
    else
        FOV_Box.Visible = false
    end

    if Config.Aimbot and UserInputService:IsKeyDown(Config.AimKey) then
        local t = GetClosest()
        if t then
            FOV_Box.BorderColor3 = Color3.fromRGB(0, 255, 0)
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Position)
        else
            FOV_Box.BorderColor3 = Theme.Purple
        end
    end
end)