--[[
    olliE Hypershot Menu v1
    Silent Aim + FOV Circle + ESP
    Mobile / Delta / Fluxus / Codex friendly
    Touch drag + tap toggles
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- // Config (edit these if you want different defaults)
local Config = {
    SilentAim = true,
    Aimbot = false,          -- mouse lock (optional, more detectable)
    FOV = 120,
    ShowFOV = true,
    TeamCheck = true,
    WallCheck = false,       -- true = only visible targets
    HitPart = "Head",        -- Head / HumanoidRootPart / UpperTorso
    Smoothness = 0.18,       -- only used by Aimbot
    ESP = true,
    ESP_Box = true,
    ESP_Name = true,
    ESP_Distance = true,
    ESP_Health = true,
    ESP_Tracer = false,
    ESP_TeamColor = true,
    MaxDistance = 1200,
}

-- // State
local Connections = {}
local ESPObjects = {}
local CurrentTarget = nil
local MenuOpen = true
local Dragging = false
local DragStart = nil
local StartPos = nil

-- // Cleanup old menu
pcall(function()
    if CoreGui:FindFirstChild("OllieHyperMenu") then
        CoreGui.OllieHyperMenu:Destroy()
    end
end)

-- // UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OllieHyperMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 280, 0, 420)
Main.Position = UDim2.new(0, 20, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Main

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 200, 255)
UIStroke.Thickness = 1.5
UIStroke.Parent = Main

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 12)
TitleFix.Position = UDim2.new(0, 0, 1, -12)
TitleFix.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "olliE · Hypershot"
Title.TextColor3 = Color3.fromRGB(0, 220, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -32, 0, 4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -16, 1, -48)
Content.Position = UDim2.new(0, 8, 0, 40)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 255)
Content.CanvasSize = UDim2.new(0, 0, 0, 520)
Content.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 6)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Content

-- // Helpers
local function CreateToggle(name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 34)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    frame.BorderSizePixel = 0
    frame.Parent = Content

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 230)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 42, 0, 22)
    btn.Position = UDim2.new(1, -48, 0.5, -11)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 180, 120) or Color3.fromRGB(60, 60, 70)
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Parent = frame

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 5)
    bc.Parent = btn

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 180, 120) or Color3.fromRGB(60, 60, 70)
        btn.Text = state and "ON" or "OFF"
        callback(state)
    end)

    return frame
end

local function CreateSlider(name, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    frame.BorderSizePixel = 0
    frame.Parent = Content

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. tostring(default)
    label.TextColor3 = Color3.fromRGB(220, 220, 230)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -20, 0, 8)
    bar.Position = UDim2.new(0, 10, 0, 30)
    bar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    bar.BorderSizePixel = 0
    bar.Parent = frame

    local barC = Instance.new("UICorner")
    barC.CornerRadius = UDim.new(0, 4)
    barC.Parent = bar

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    fill.BorderSizePixel = 0
    fill.Parent = bar

    local fillC = Instance.new("UICorner")
    fillC.CornerRadius = UDim.new(0, 4)
    fillC.Parent = fill

    local sliding = false
    local function update(input)
        local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * rel)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        label.Text = name .. ": " .. tostring(val)
        callback(val)
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            update(input)
        end
    end)
    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)

    return frame
end

-- // Build UI
CreateToggle("Silent Aim", Config.SilentAim, function(v) Config.SilentAim = v end)
CreateToggle("Aimbot (lock)", Config.Aimbot, function(v) Config.Aimbot = v end)
CreateToggle("Show FOV", Config.ShowFOV, function(v) Config.ShowFOV = v; FOVCircle.Visible = v end)
CreateSlider("FOV Size", 40, 300, Config.FOV, function(v) Config.FOV = v end)
CreateToggle("Team Check", Config.TeamCheck, function(v) Config.TeamCheck = v end)
CreateToggle("Wall Check", Config.WallCheck, function(v) Config.WallCheck = v end)

local partFrame = Instance.new("Frame")
partFrame.Size = UDim2.new(1, 0, 0, 34)
partFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
partFrame.BorderSizePixel = 0
partFrame.Parent = Content
local pc = Instance.new("UICorner")
pc.CornerRadius = UDim.new(0, 6)
pc.Parent = partFrame
local pl = Instance.new("TextLabel")
pl.Size = UDim2.new(0.5, 0, 1, 0)
pl.Position = UDim2.new(0, 10, 0, 0)
pl.BackgroundTransparency = 1
pl.Text = "Hit Part"
pl.TextColor3 = Color3.fromRGB(220, 220, 230)
pl.Font = Enum.Font.Gotham
pl.TextSize = 13
pl.TextXAlignment = Enum.TextXAlignment.Left
pl.Parent = partFrame
local partBtn = Instance.new("TextButton")
partBtn.Size = UDim2.new(0, 90, 0, 22)
partBtn.Position = UDim2.new(1, -100, 0.5, -11)
partBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
partBtn.Text = Config.HitPart
partBtn.TextColor3 = Color3.new(1, 1, 1)
partBtn.Font = Enum.Font.Gotham
partBtn.TextSize = 11
partBtn.Parent = partFrame
local pbc = Instance.new("UICorner")
pbc.CornerRadius = UDim.new(0, 5)
pbc.Parent = partBtn
local parts = {"Head", "HumanoidRootPart", "UpperTorso"}
local partIdx = 1
partBtn.MouseButton1Click:Connect(function()
    partIdx = partIdx % #parts + 1
    Config.HitPart = parts[partIdx]
    partBtn.Text = Config.HitPart
end)

CreateToggle("ESP", Config.ESP, function(v) Config.ESP = v end)
CreateToggle("ESP Box", Config.ESP_Box, function(v) Config.ESP_Box = v end)
CreateToggle("ESP Name", Config.ESP_Name, function(v) Config.ESP_Name = v end)
CreateToggle("ESP Distance", Config.ESP_Distance, function(v) Config.ESP_Distance = v end)
CreateToggle("ESP Health", Config.ESP_Health, function(v) Config.ESP_Health = v end)
CreateToggle("ESP Tracer", Config.ESP_Tracer, function(v) Config.ESP_Tracer = v end)

-- // Drag
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPos = Main.Position
    end
end)
TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - DragStart
        Main.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    MenuOpen = not MenuOpen
    Main.Visible = MenuOpen
end)

-- // FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 64
FOVCircle.Radius = Config.FOV
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7
FOVCircle.Color = Color3.fromRGB(0, 200, 255)
FOVCircle.Visible = Config.ShowFOV

-- // Utility
local function IsAlive(plr)
    local char = plr.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function SameTeam(plr)
    if not Config.TeamCheck then return false end
    if LocalPlayer.Team and plr.Team then
        return LocalPlayer.Team == plr.Team
    end
    -- Hypershot sometimes uses team values / attributes
    local myTeam = LocalPlayer:GetAttribute("Team") or LocalPlayer:GetAttribute("TeamId")
    local theirTeam = plr:GetAttribute("Team") or plr:GetAttribute("TeamId")
    if myTeam and theirTeam then
        return myTeam == theirTeam
    end
    return false
end

local function GetHitPart(char)
    return char:FindFirstChild(Config.HitPart) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

local function IsVisible(part)
    if not Config.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local dir = (part.Position - origin)
    local ray = Ray.new(origin, dir.Unit * dir.Magnitude)
    local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
    return hit == nil or hit:IsDescendantOf(part.Parent)
end

local function GetClosestInFOV()
    local closest = nil
    local closestDist = Config.FOV
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    -- mobile fallback: center of screen
    if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
        mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and IsAlive(plr) and not SameTeam(plr) then
            local part = GetHitPart(plr.Character)
            if part then
                local screen, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screen.X, screen.Y) - mousePos).Magnitude
                    if dist < closestDist and dist <= Config.FOV then
                        if IsVisible(part) then
                            closestDist = dist
                            closest = part
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- // Silent Aim (hook mouse / camera direction for most FPS frameworks)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if Config.SilentAim and CurrentTarget and CurrentTarget.Parent then
        -- common remote patterns for shoot / fire / ray
        if method == "FireServer" or method == "InvokeServer" then
            local remoteName = tostring(self.Name):lower()
            if remoteName:find("shoot") or remoteName:find("fire") or remoteName:find("ray") or remoteName:find("bullet") or remoteName:find("hit") then
                -- replace direction / target position arguments when possible
                for i, v in ipairs(args) do
                    if typeof(v) == "Vector3" then
                        args[i] = CurrentTarget.Position
                    elseif typeof(v) == "CFrame" then
                        args[i] = CFrame.new(v.Position, CurrentTarget.Position)
                    end
                end
                return oldNamecall(self, unpack(args))
            end
        end
    end
    return oldNamecall(self, ...)
end)

-- // Aimbot loop + FOV update + target selection
table.insert(Connections, RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36) -- offset for mobile status bar-ish
    if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end
    FOVCircle.Radius = Config.FOV
    FOVCircle.Visible = Config.ShowFOV and MenuOpen == false or Config.ShowFOV

    CurrentTarget = GetClosestInFOV()

    if Config.Aimbot and CurrentTarget and CurrentTarget.Parent then
        local targetPos = CurrentTarget.Position
        local camCF = Camera.CFrame
        local newCF = camCF:Lerp(CFrame.new(camCF.Position, targetPos), Config.Smoothness)
        Camera.CFrame = newCF
    end
end))

-- // ESP
local function ClearESP(plr)
    if ESPObjects[plr] then
        for _, obj in pairs(ESPObjects[plr]) do
            pcall(function() obj:Remove() end)
        end
        ESPObjects[plr] = nil
    end
end

local function CreateESP(plr)
    if ESPObjects[plr] then return end
    local box = Drawing.new("Square")
    box.Thickness = 1.5
    box.Filled = false
    box.Color = Color3.fromRGB(0, 220, 255)
    box.Visible = false

    local name = Drawing.new("Text")
    name.Size = 14
    name.Center = true
    name.Outline = true
    name.Color = Color3.fromRGB(255, 255, 255)
    name.Visible = false

    local dist = Drawing.new("Text")
    dist.Size = 12
    dist.Center = true
    dist.Outline = true
    dist.Color = Color3.fromRGB(180, 180, 190)
    dist.Visible = false

    local health = Drawing.new("Line")
    health.Thickness = 2
    health.Color = Color3.fromRGB(0, 255, 100)
    health.Visible = false

    local tracer = Drawing.new("Line")
    tracer.Thickness = 1
    tracer.Color = Color3.fromRGB(0, 200, 255)
    tracer.Visible = false

    ESPObjects[plr] = {Box = box, Name = name, Dist = dist, Health = health, Tracer = tracer}
end

local function UpdateESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if not Config.ESP or not IsAlive(plr) or SameTeam(plr) then
            ClearESP(plr)
            continue
        end

        CreateESP(plr)
        local objs = ESPObjects[plr]
        local char = plr.Character
        local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then
            ClearESP(plr)
            continue
        end

        local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
        local distance = (root.Position - Camera.CFrame.Position).Magnitude
        if not onScreen or distance > Config.MaxDistance then
            objs.Box.Visible = false
            objs.Name.Visible = false
            objs.Dist.Visible = false
            objs.Health.Visible = false
            objs.Tracer.Visible = false
            continue
        end

        local size = math.clamp(2000 / distance, 8, 60)
        local head = char:FindFirstChild("Head")
        local headPos = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0)) or pos
        local footPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))

        if Config.ESP_Box then
            objs.Box.Size = Vector2.new(size * 0.7, size * 1.4)
            objs.Box.Position = Vector2.new(pos.X - size * 0.35, pos.Y - size * 0.7)
            objs.Box.Visible = true
            if Config.ESP_TeamColor and plr.Team and plr.Team.TeamColor then
                objs.Box.Color = plr.Team.TeamColor.Color
            else
                objs.Box.Color = Color3.fromRGB(0, 220, 255)
            end
        else
            objs.Box.Visible = false
        end

        if Config.ESP_Name then
            objs.Name.Text = plr.Name
            objs.Name.Position = Vector2.new(pos.X, headPos.Y - 18)
            objs.Name.Visible = true
        else
            objs.Name.Visible = false
        end

        if Config.ESP_Distance then
            objs.Dist.Text = math.floor(distance) .. "m"
            objs.Dist.Position = Vector2.new(pos.X, footPos.Y + 4)
            objs.Dist.Visible = true
        else
            objs.Dist.Visible = false
        end

        if Config.ESP_Health then
            local hp = hum.Health / hum.MaxHealth
            local barHeight = size * 1.4
            objs.Health.From = Vector2.new(pos.X - size * 0.4 - 4, pos.Y + size * 0.7)
            objs.Health.To = Vector2.new(pos.X - size * 0.4 - 4, pos.Y + size * 0.7 - barHeight * hp)
            objs.Health.Color = Color3.fromRGB(255 * (1 - hp), 255 * hp, 40)
            objs.Health.Visible = true
        else
            objs.Health.Visible = false
        end

        if Config.ESP_Tracer then
            objs.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            objs.Tracer.To = Vector2.new(pos.X, pos.Y)
            objs.Tracer.Visible = true
        else
            objs.Tracer.Visible = false
        end
    end
end

table.insert(Connections, RunService.RenderStepped:Connect(UpdateESP))

Players.PlayerRemoving:Connect(function(plr)
    ClearESP(plr)
end)

-- // Mobile open key (tap the small button if you close the menu)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 48, 0, 48)
OpenBtn.Position = UDim2.new(0, 12, 0, 80)
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 220)
OpenBtn.Text = "H"
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 20
OpenBtn.Visible = false
OpenBtn.Parent = ScreenGui
local obc = Instance.new("UICorner")
obc.CornerRadius = UDim.new(0, 10)
obc.Parent = OpenBtn

CloseBtn.MouseButton1Click:Connect(function()
    MenuOpen = false
    Main.Visible = false
    OpenBtn.Visible = true
end)
OpenBtn.MouseButton1Click:Connect(function()
    MenuOpen = true
    Main.Visible = true
    OpenBtn.Visible = false
end)

-- // Unload helper (optional)
local function Unload()
    for _, c in ipairs(Connections) do
        c:Disconnect()
    end
    for plr in pairs(ESPObjects) do
        ClearESP(plr)
    end
    FOVCircle:Remove()
    ScreenGui:Destroy()
    if oldNamecall then
        -- metamethod restore is executor dependent; most keep the hook until rejoin
    end
end

print("[olliE] Hypershot menu loaded — Silent Aim + FOV + ESP ready")
