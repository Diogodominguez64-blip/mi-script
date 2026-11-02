--[[ DIOGO DRAG V1 - Ultimate Edition + Pro ESP
    FPS Booster, Speed, Rejoin, Key Binder, Info & Advanced ESP, Aimbot, Bypass Master.
]]

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    repeat task.wait() until Players.LocalPlayer
    LocalPlayer = Players.LocalPlayer
end

pcall(function()
    for _, g in pairs(CoreGui:GetChildren()) do
        if g.Name == "DiogoDragV1" then g:Destroy() end
    end
end)
pcall(function()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        for _, g in pairs(pg:GetChildren()) do
            if g.Name == "DiogoDragV1" then g:Destroy() end
        end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DiogoDragV1"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local parented = pcall(function() ScreenGui.Parent = CoreGui end)
if not parented or not ScreenGui.Parent then
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    ScreenGui.Parent = pg or LocalPlayer:WaitForChild("PlayerGui")
end

-- COLORES
local ACCENT = Color3.fromRGB(0, 255, 150)
local BG_DARK = Color3.fromRGB(12, 12, 12)
local BG_SIDEBAR = Color3.fromRGB(18, 18, 18)
local BG_LIGHT = Color3.fromRGB(25, 25, 25)
local TEXT_COLOR = Color3.fromRGB(240, 240, 240)
local TEXT_DIM = Color3.fromRGB(150, 150, 150)
local REQUIRED_KEY = "diogo123"

local currentToggleKey = Enum.KeyCode.RightControl
local isBindingKey = false
local bindTarget = nil
local authenticated = false
local hasDrawing = (Drawing ~= nil and type(Drawing.new) == "function")

-- CONFIG ESP
local ESP = {
    Enabled = false, Boxes = false, BoxStyle = "Corner", Fill = false, FillTransparency = 0.65,
    Names = false, HealthBar = false, HealthText = false, Distance = false, Tracers = false,
    TracerOrigin = "Bottom", TracerThickness = 2, Skeleton = false, HeadDot = false,
    TeamCheck = true, MaxDistance = 1000, TextSize = 14, BoxThickness = 1, Opacity = 1, Color = ACCENT,
}

-- CONFIG AIMBOT
local AIM = {
    Enabled = false, Active = false, Bind = Enum.KeyCode.Q, Mouse = nil, Mode = "Hold",
    Part = "Head", FOV = 120, Smoothness = 0.22, MaxDistance = 900, Prediction = 0.12,
    WallCheck = false, TeamCheck = true, AutoFire = false, Silent = false,
    SilentMode = "Direction", TargetHighlight = false,
}

-- CONFIG BYPASS
local BYPASS = {
    Enabled = false, Viewmodel = true, PostFX = true, Particles = true, Lights = true,
    Shadows = true, FOV = true, HideGui = false, FOVValue = 110,
}

local ESP_Cache = {}
local TRACER_ORIGINS = {"Bottom", "Top", "Center"}
local AIM_PARTS = {"Head", "UpperTorso", "HumanoidRootPart", "Nearest"}
local AIM_MODES = {"Hold", "Toggle"}
local SILENT_MODES = {"Off", "Position", "Direction"}
local MOUSE_BUTTONS = {
    [Enum.UserInputType.MouseButton1] = "Mouse1",
    [Enum.UserInputType.MouseButton2] = "Mouse2",
    [Enum.UserInputType.MouseButton3] = "Mouse3",
}

local R15_BONES = {
    {"Head","UpperTorso"}, {"UpperTorso","LowerTorso"},
    {"LowerTorso","LeftUpperLeg"}, {"LeftUpperLeg","LeftLowerLeg"}, {"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"}, {"RightUpperLeg","RightLowerLeg"}, {"RightLowerLeg","RightFoot"},
    {"UpperTorso","LeftUpperArm"}, {"LeftUpperArm","LeftLowerArm"}, {"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"}, {"RightUpperArm","RightLowerArm"}, {"RightLowerArm","RightHand"},
}
local R6_BONES = {
    {"Head","Torso"}, {"Torso","Left Arm"}, {"Torso","Right Arm"},
    {"Torso","Left Leg"}, {"Torso","Right Leg"},
}

-- UTILIDADES
local function ApplyStyle(obj, radius, strokeColor, strokeThickness)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, radius or 8)
    if strokeColor then
        local s = Instance.new("UIStroke", obj)
        s.Color = strokeColor
        s.Thickness = strokeThickness or 1
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    end
end

local function SmoothTween(obj, properties, duration)
    TweenService:Create(obj, TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), properties):Play()
end

local function newDrawing(class)
    return Drawing.new(class)
end

local function safeSet(instance, prop, value)
    pcall(function() instance[prop] = value end)
end

local function cycle(tbl, current, btn, prefix)
    local idx = table.find(tbl, current) or 1
    idx = idx + 1
    if idx > #tbl then idx = 1 end
    if btn then btn.Text = prefix .. tbl[idx] end
    return tbl[idx]
end

-- ELEMENTOS PRINCIPALES
local MAIN_SIZE = UDim2.new(0, 540, 0, 400)

local Main = Instance.new("Frame", ScreenGui)
Main.Size = MAIN_SIZE
Main.Position = UDim2.new(0.5, -270, 0.5, -200)
Main.BackgroundColor3 = BG_DARK
Main.Visible = false
Main.ZIndex = 5
ApplyStyle(Main, 12, Color3.fromRGB(40, 40, 40), 1)

local TopBar = Instance.new("Frame", Main)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = BG_SIDEBAR
TopBar.ZIndex = 6
ApplyStyle(TopBar, 12, nil, 0)

local Title = Instance.new("TextLabel", TopBar)
Title.Text = "diogo drag v1"
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = ACCENT
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 7

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0.5, -15)
CloseBtn.Text = "×"
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.TextSize = 22
CloseBtn.ZIndex = 7
ApplyStyle(CloseBtn, 6)

local SideBar = Instance.new("Frame", Main)
SideBar.Size = UDim2.new(0, 130, 1, -40)
SideBar.Position = UDim2.new(0, 0, 0, 40)
SideBar.BackgroundColor3 = BG_SIDEBAR
SideBar.ZIndex = 6
ApplyStyle(SideBar, 0)

local SidebarLayout = Instance.new("UIListLayout", SideBar)
SidebarLayout.Padding = UDim.new(0, 5)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local SidebarPadding = Instance.new("UIPadding", SideBar)
SidebarPadding.PaddingTop = UDim.new(0, 10)

local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(1, -150, 1, -50)
Container.Position = UDim2.new(0, 140, 0, 45)
Container.BackgroundTransparency = 1
Container.ZIndex = 6

local Pages = {}

-- DRAG
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- CONSTRUCTORES UI
local function CreatePage(name)
    local p = Instance.new("ScrollingFrame", Container)
    p.Name = name.."Page"
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.Visible = false
    p.ZIndex = 7
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 2
    p.ScrollBarImageColor3 = ACCENT
    p.ScrollingDirection = Enum.ScrollingDirection.Y
    p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local layout = Instance.new("UIListLayout", p)
    layout.Padding = UDim.new(0, 8)
    local padding = Instance.new("UIPadding", p)
    padding.PaddingLeft = UDim.new(0, 5)
    padding.PaddingRight = UDim.new(0, 5)
    padding.PaddingTop = UDim.new(0, 5)
    padding.PaddingBottom = UDim.new(0, 10)
    Pages[name] = p
    return p
end

local function CreateTab(text, targetName)
    local btn = Instance.new("TextButton", SideBar)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.BackgroundColor3 = BG_LIGHT
    btn.Text = text
    btn.TextColor3 = TEXT_DIM
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.ZIndex = 7
    ApplyStyle(btn, 6, Color3.fromRGB(35, 35, 35), 1)

    btn.MouseButton1Click:Connect(function()
        for name, page in pairs(Pages) do page.Visible = (name == targetName) end
        for _, child in pairs(SideBar:GetChildren()) do
            if child:IsA("TextButton") then
                SmoothTween(child, {TextColor3 = TEXT_DIM, BackgroundColor3 = BG_LIGHT})
            end
        end
        SmoothTween(btn, {TextColor3 = ACCENT, BackgroundColor3 = BG_DARK})
    end)
    return btn
end

local function Section(text, parent)
    local l = Instance.new("TextLabel", parent)
    l.Size = UDim2.new(1, -10, 0, 22)
    l.BackgroundTransparency = 1
    l.Text = "— " .. text .. " —"
    l.TextColor3 = ACCENT
    l.Font = Enum.Font.GothamBold
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 8
end

local function CreateToggle(name, parent, callback, default)
    local TglFrame = Instance.new("TextButton", parent)
    TglFrame.Size = UDim2.new(1, -10, 0, 38)
    TglFrame.BackgroundColor3 = BG_LIGHT
    TglFrame.Text = "  " .. name
    TglFrame.TextColor3 = TEXT_COLOR
    TglFrame.Font = Enum.Font.Gotham
    TglFrame.TextSize = 13
    TglFrame.TextXAlignment = Enum.TextXAlignment.Left
    TglFrame.ZIndex = 8
    ApplyStyle(TglFrame, 6, Color3.fromRGB(35, 35, 35), 1)

    local Indicator = Instance.new("Frame", TglFrame)
    Indicator.Size = UDim2.new(0, 30, 0, 16)
    Indicator.Position = UDim2.new(1, -40, 0.5, -8)
    Indicator.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Indicator.ZIndex = 9
    ApplyStyle(Indicator, 10)

    local Dot = Instance.new("Frame", Indicator)
    Dot.Size = UDim2.new(0, 10, 0, 10)
    Dot.Position = UDim2.new(0, 3, 0.5, -5)
    Dot.BackgroundColor3 = Color3.new(1,1,1)
    Dot.ZIndex = 10
    ApplyStyle(Dot, 10)

    local enabled = default or false
    local function paint(state)
        SmoothTween(Dot, {Position = state and UDim2.new(1, -13, 0.5, -5) or UDim2.new(0, 3, 0.5, -5)}, 0.2)
        SmoothTween(Indicator, {BackgroundColor3 = state and ACCENT or Color3.fromRGB(50, 50, 50)}, 0.2)
    end
    if enabled then paint(true) end

    TglFrame.MouseButton1Click:Connect(function()
        enabled = not enabled
        paint(enabled)
        pcall(callback, enabled)
    end)
end

local function CreateSlider(name, parent, min, max, step, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 46)
    frame.BackgroundColor3 = BG_LIGHT
    frame.ZIndex = 8
    ApplyStyle(frame, 6, Color3.fromRGB(35, 35, 35), 1)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -70, 0, 22)
    label.Position = UDim2.new(0, 10, 0, 2)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = TEXT_COLOR
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 9

    local valueLabel = Instance.new("TextLabel", frame)
    valueLabel.Size = UDim2.new(0, 60, 0, 22)
    valueLabel.Position = UDim2.new(1, -70, 0, 2)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = ACCENT
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 13
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.ZIndex = 9

    local track = Instance.new("Frame", frame)
    track.Size = UDim2.new(1, -20, 0, 6)
    track.Position = UDim2.new(0, 10, 0, 30)
    track.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    track.ZIndex = 9
    ApplyStyle(track, 3)

    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = ACCENT
    fill.ZIndex = 10
    ApplyStyle(fill, 3)

    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new(0, 0, 0.5, -6)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.ZIndex = 11
    ApplyStyle(knob, 6)

    local function setValue(v, fire)
        v = math.clamp(v, min, max)
        if step > 0 then
            v = math.clamp(math.floor((v / step) + 0.5) * step, min, max)
        end
        local alpha = (max > min) and ((v - min) / (max - min)) or 0
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, -6, 0.5, -6)
        valueLabel.Text = (step < 1) and string.format("%.2f", v) or tostring(math.floor(v + 0.5))
        if fire then pcall(callback, v) end
    end
    setValue(default, false)

    local sliding = false
    local function updateFromInput(input)
        local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
        setValue(min + (max - min) * rel, true)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            updateFromInput(input)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(input)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
end

local function CreateButton(name, parent, callback)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1, -10, 0, 38)
    Btn.BackgroundColor3 = BG_LIGHT
    Btn.Text = name
    Btn.TextColor3 = TEXT_COLOR
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 13
    Btn.ZIndex = 8
    ApplyStyle(Btn, 6, Color3.fromRGB(35, 35, 35), 1)
    if callback then
        Btn.MouseButton1Click:Connect(function() pcall(callback) end)
    end
    return Btn
end

local function CreateLabel(text, parent, color)
    local Label = Instance.new("TextLabel", parent)
    Label.Size = UDim2.new(1, -10, 0, 25)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = color or TEXT_DIM
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 8
end

-- ============ ESP ============
local function getCache(player)
    local c = ESP_Cache[player]
    if not c then
        c = {}
        ESP_Cache[player] = c
    end
    return c
end

local function hideAll(cache)
    if not cache then return end
    for key, obj in pairs(cache) do
        if key == "billboard" or key == "highlight" then
            obj.Enabled = false
        else
            obj.Visible = false
        end
    end
end

local function clearCache(player)
    local c = ESP_Cache[player]
    if not c then return end
    for _, obj in pairs(c) do
        if typeof(obj) == "Instance" then
            pcall(function() obj:Destroy() end)
        else
            pcall(function() obj.Visible = false end)
        end
    end
    ESP_Cache[player] = nil
end

local function ensureLine(cache, key)
    if not cache[key] then cache[key] = newDrawing("Line") end
    return cache[key]
end

local function ensureSquare(cache, key)
    if not cache[key] then cache[key] = newDrawing("Square") end
    return cache[key]
end

local function hide(obj)
    if obj then obj.Visible = false end
end

local function projectBox(cam, model)
    local cf, size = model:GetBoundingBox()
    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
    local visible = false
    for _, sx in ipairs({-0.5, 0.5}) do
        for _, sy in ipairs({-0.5, 0.5}) do
            for _, sz in ipairs({-0.5, 0.5}) do
                local world = (cf * CFrame.new(size.X * sx, size.Y * sy, size.Z * sz)).Position
                local sp, onScreen = cam:WorldToViewportPoint(world)
                if sp.Z > 0 then
                    minX = math.min(minX, sp.X)
                    maxX = math.max(maxX, sp.X)
                    minY = math.min(minY, sp.Y)
                    maxY = math.max(maxY, sp.Y)
                    if onScreen then visible = true end
                end
            end
        end
    end
    if minX == math.huge then return nil end
    return Vector2.new(minX, minY), Vector2.new(maxX, maxY), visible
end

local function drawSkeleton(cache, cam, char, transparency, thickness)
    local bones = char:FindFirstChild("UpperTorso") and R15_BONES or R6_BONES
    for i, pair in ipairs(bones) do
        local a = char:FindFirstChild(pair[1])
        local b = char:FindFirstChild(pair[2])
        local line = ensureLine(cache, "bone" .. i)
        if a and b then
            local pa, sa = cam:WorldToViewportPoint(a.Position)
            local pb, sb = cam:WorldToViewportPoint(b.Position)
            if sa and sb and pa.Z > 0 and pb.Z > 0 then
                line.From = Vector2.new(pa.X, pa.Y)
                line.To = Vector2.new(pb.X, pb.Y)
                line.Color = ESP.Color
                line.Thickness = thickness
                line.Transparency = transparency
                line.Visible = true
            else
                line.Visible = false
            end
        else
            line.Visible = false
        end
    end
end

local function drawCornerBox(cache, min, max, transparency, thickness)
    local w = max.X - min.X
    local h = max.Y - min.Y
    local len = math.min(w, h) * 0.22
    local segs = {
        {min.X, min.Y, min.X + len, min.Y},
        {min.X, min.Y, min.X, min.Y + len},
        {max.X, min.Y, max.X - len, min.Y},
        {max.X, min.Y, max.X, min.Y + len},
        {min.X, max.Y, min.X + len, max.Y},
        {min.X, max.Y, min.X, max.Y - len},
        {max.X, max.Y, max.X - len, max.Y},
        {max.X, max.Y, max.X, max.Y - len},
    }
    for i, s in ipairs(segs) do
        local line = ensureLine(cache, "corner" .. i)
        line.From = Vector2.new(s[1], s[2])
        line.To = Vector2.new(s[3], s[4])
        line.Color = ESP.Color
        line.Thickness = thickness
        line.Transparency = transparency
        line.Visible = true
    end
end

local function hideCornerBox(cache)
    for i = 1, 8 do
        local line = cache["corner" .. i]
        if line then line.Visible = false end
    end
end

local function renderPlayer(cam, player)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    local head = char and char:FindFirstChild("Head")

    if not char or not hrp or not hum or not head or hum.Health <= 0 then
        hideAll(ESP_Cache[player])
        return
    end
    if ESP.TeamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
        hideAll(ESP_Cache[player])
        return
    end

    local dist = (cam.CFrame.Position - hrp.Position).Magnitude
    if dist > ESP.MaxDistance then
        hideAll(ESP_Cache[player])
        return
    end

    local cache = getCache(player)
    local transparency = 1 - ESP.Opacity

    local min, max, onScreen = projectBox(cam, char)
    if not min or not onScreen then
        hideAll(cache)
        return
    end

    local w = max.X - min.X
    local h = max.Y - min.Y

    if ESP.Boxes and hasDrawing then
        if ESP.BoxStyle == "Full" then
            hideCornerBox(cache)
            local box = ensureSquare(cache, "box2d")
            box.Size = Vector2.new(w, h)
            box.Position = min
            box.Color = ESP.Color
            box.Thickness = ESP.BoxThickness
            box.Filled = false
            box.Transparency = transparency
            box.Visible = true
        else
            hide(cache.box2d)
            drawCornerBox(cache, min, max, transparency, ESP.BoxThickness)
        end
    elseif ESP.Boxes then
        if not cache.highlight then
            local hl = Instance.new("Highlight")
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = char
            cache.highlight = hl
        end
        cache.highlight.FillTransparency = 0.65
        cache.highlight.FillColor = ESP.Color
        cache.highlight.OutlineColor = ESP.Color
        cache.highlight.Enabled = true
    else
        hide(cache.box2d)
        if cache.highlight then cache.highlight.Enabled = false end
        hideCornerBox(cache)
    end

    if ESP.Fill and hasDrawing then
        local fillBox = ensureSquare(cache, "fill")
        fillBox.Size = Vector2.new(w, h)
        fillBox.Position = min
        fillBox.Color = ESP.Color
        fillBox.Filled = true
        fillBox.Thickness = 0
        fillBox.Transparency = ESP.FillTransparency
        fillBox.Visible = true
    else
        hide(cache.fill)
    end

    if ESP.HealthBar and hasDrawing then
        local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
        local bg = ensureSquare(cache, "hpbg")
        bg.Size = Vector2.new(4, h)
        bg.Position = Vector2.new(min.X - 7, min.Y)
        bg.Color = Color3.new(0, 0, 0)
        bg.Filled = true
        bg.Thickness = 0
        bg.Transparency = 0.4
        bg.Visible = true

        local bar = ensureSquare(cache, "hpbar")
        bar.Size = Vector2.new(4, h * pct)
        bar.Position = Vector2.new(min.X - 7, min.Y + (h * (1 - pct)))
        bar.Color = Color3.fromRGB(255, 60, 60):Lerp(Color3.fromRGB(0, 255, 90), pct)
        bar.Filled = true
        bar.Thickness = 0
        bar.Transparency = transparency
        bar.Visible = true
    else
        hide(cache.hpbg)
        hide(cache.hpbar)
    end

    if ESP.Skeleton and hasDrawing then
        drawSkeleton(cache, cam, char, transparency, math.max(1, ESP.BoxThickness))
    elseif cache.bone1 then
        for i = 1, #R15_BONES do
            local line = cache["bone" .. i]
            if line then line.Visible = false end
        end
    end

    if ESP.HeadDot and hasDrawing then
        local sp = cam:WorldToViewportPoint(head.Position)
        if sp.Z > 0 then
            local dot = cache.dot
            if not dot then
                dot = newDrawing("Circle")
                cache.dot = dot
            end
            dot.Position = Vector2.new(sp.X, sp.Y)
            dot.Radius = math.clamp(900 / math.max(dist, 1), 2, 8)
            dot.Filled = true
            dot.Color = ESP.Color
            dot.Transparency = transparency
            dot.Visible = true
        else
            hide(cache.dot)
        end
    else
        hide(cache.dot)
    end

    if ESP.Tracers and hasDrawing then
        local tracer = ensureLine(cache, "tracer")
        local originX = cam.ViewportSize.X / 2
        local originY = cam.ViewportSize.Y
        if ESP.TracerOrigin == "Top" then
            originY = 0
        elseif ESP.TracerOrigin == "Center" then
            originY = cam.ViewportSize.Y / 2
        end
        tracer.From = Vector2.new(originX, originY)
        tracer.To = Vector2.new(min.X + w / 2, max.Y)
        tracer.Color = ESP.Color
        tracer.Thickness = ESP.TracerThickness
        tracer.Transparency = transparency
        tracer.Visible = true
    else
        hide(cache.tracer)
    end

    if ESP.Names or ESP.HealthText or ESP.Distance then
        if not cache.billboard then
            local bb = Instance.new("BillboardGui")
            bb.Size = UDim2.new(0, 160, 0, 60)
            bb.Adornee = head
            bb.AlwaysOnTop = true
            bb.StudsOffsetWorldSpace = Vector3.new(0, 2.6, 0)
            bb.Parent = head
            cache.billboard = bb

            local nameL = Instance.new("TextLabel", bb)
            nameL.Name = "NameLabel"
            nameL.Size = UDim2.new(1, 0, 0.34, 0)
            nameL.BackgroundTransparency = 1
            nameL.TextStrokeTransparency = 0.4
            nameL.Font = Enum.Font.GothamBold
            nameL.TextColor3 = Color3.new(1, 1, 1)

            local hpL = Instance.new("TextLabel", bb)
            hpL.Name = "HealthLabel"
            hpL.Size = UDim2.new(1, 0, 0.33, 0)
            hpL.Position = UDim2.new(0, 0, 0.34, 0)
            hpL.BackgroundTransparency = 1
            hpL.TextStrokeTransparency = 0.4
            hpL.Font = Enum.Font.Gotham
            hpL.TextColor3 = Color3.fromRGB(255, 110, 110)

            local distL = Instance.new("TextLabel", bb)
            distL.Name = "DistLabel"
            distL.Size = UDim2.new(1, 0, 0.33, 0)
            distL.Position = UDim2.new(0, 0, 0.67, 0)
            distL.BackgroundTransparency = 1
            distL.TextStrokeTransparency = 0.4
            distL.Font = Enum.Font.Gotham
            distL.TextColor3 = ESP.Color
        end
        cache.billboard.Enabled = true
        local nl = cache.billboard.NameLabel
        local hl = cache.billboard.HealthLabel
        local dl = cache.billboard.DistLabel
        nl.TextSize = ESP.TextSize
        hl.TextSize = math.max(8, ESP.TextSize - 2)
        dl.TextSize = math.max(8, ESP.TextSize - 2)
        nl.Text = ESP.Names and player.Name or ""
        nl.Visible = ESP.Names
        hl.Text = ESP.HealthText and ("HP: " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)) or ""
        hl.Visible = ESP.HealthText
        dl.Text = ESP.Distance and (math.floor(dist) .. "m") or ""
        dl.Visible = ESP.Distance
    elseif cache.billboard then
        cache.billboard.Enabled = false
    end
end

RunService.RenderStepped:Connect(function()
    if not authenticated or not ESP.Enabled then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    local ok, err = pcall(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                renderPlayer(cam, player)
            end
        end
    end)
    if not ok then warn("DiogoDrag ESP:", err) end
end)

Players.PlayerRemoving:Connect(clearCache)

-- ============ AIMBOT ============
local aimTarget = nil
local aimPart = nil
local fovCircle = nil
local highlightTarget = nil
local autoFireClock = 0

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function isVisible(part)
    local cam = workspace.CurrentCamera
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, cam}
    local origin = cam.CFrame.Position
    local hit = workspace:Raycast(origin, part.Position - origin, rayParams)
    if not hit then return true end
    return hit.Instance:IsDescendantOf(part.Parent)
end

local function resolvePart(char)
    if AIM.Part == "Nearest" then
        local head = char:FindFirstChild("Head")
        local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
        local cam = workspace.CurrentCamera
        if head and torso and cam then
            local a = cam:WorldToViewportPoint(head.Position)
            local b = cam:WorldToViewportPoint(torso.Position)
            local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
            if (Vector2.new(a.X, a.Y) - center).Magnitude < (Vector2.new(b.X, b.Y) - center).Magnitude then
                return head
            end
            return torso
        end
        return head or torso
    end
    return char:FindFirstChild(AIM.Part) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

local function findTarget()
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local best, bestScore, bestPart = nil, math.huge, nil

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if char and hum and hrp and hum.Health > 0 then
                local teamBlocked = AIM.TeamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team
                if not teamBlocked then
                    local dist = (cam.CFrame.Position - hrp.Position).Magnitude
                    if dist <= AIM.MaxDistance then
                        local part = resolvePart(char)
                        if part then
                            local sp = cam:WorldToViewportPoint(part.Position)
                            if sp.Z > 0 then
                                local score = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                                if score <= AIM.FOV and score < bestScore then
                                    if not AIM.WallCheck or isVisible(part) then
                                        best, bestScore, bestPart = player, score, part
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return best, bestPart
end

local function releaseAim()
    AIM.Active = false
    aimTarget = nil
    aimPart = nil
    if highlightTarget then
        highlightTarget:Destroy()
        highlightTarget = nil
    end
end

local function startAim()
    if AIM.Active then return end
    AIM.Active = true
end

-- Cámara: se aplica después de la cámara del juego, sin tocar CameraType
RunService:BindToRenderStep("DiogoAim", Enum.RenderPriority.Camera.Value + 1, function(dt)
    if not AIM.Active then return end
    local cam = workspace.CurrentCamera
    if not cam or not aimPart then return end
    local dist = (cam.CFrame.Position - aimPart.Position).Magnitude
    local predicted = aimPart.Position + aimPart.AssemblyLinearVelocity * (AIM.Prediction * math.clamp(dist / 100, 0.2, 3))
    local targetCF = CFrame.lookAt(cam.CFrame.Position, predicted)
    local alpha = 1 - math.exp(-dt / math.max(AIM.Smoothness, 0.01))
    cam.CFrame = cam.CFrame:Lerp(targetCF, math.clamp(alpha, 0, 1))
end)

RunService.RenderStepped:Connect(function(dt)
    if not authenticated or not AIM.Enabled then
        if fovCircle then fovCircle.Visible = false end
        if AIM.Active then releaseAim() end
        return
    end

    local cam = workspace.CurrentCamera
    if not cam then return end

    if hasDrawing then
        if not fovCircle then
            fovCircle = newDrawing("Circle")
            fovCircle.Thickness = 1
            fovCircle.Filled = false
        end
        fovCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
        fovCircle.Radius = AIM.FOV
        fovCircle.Color = ESP.Color
        fovCircle.Transparency = 0.35
        fovCircle.Visible = true
    end

    aimTarget, aimPart = findTarget()

    if aimTarget and AIM.TargetHighlight then
        if not highlightTarget or highlightTarget.Parent ~= aimTarget.Character then
            if highlightTarget then highlightTarget:Destroy() end
            highlightTarget = Instance.new("Highlight")
            highlightTarget.FillColor = ESP.Color
            highlightTarget.OutlineColor = ESP.Color
            highlightTarget.FillTransparency = 0.7
            highlightTarget.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlightTarget.Parent = aimTarget.Character
        end
    elseif highlightTarget then
        highlightTarget:Destroy()
        highlightTarget = nil
    end

    if not AIM.Active then return end

    if aimTarget and aimPart and AIM.AutoFire then
        autoFireClock += dt
        if autoFireClock >= 0.045 then
            autoFireClock = 0
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then
                pcall(function() tool:Activate() end)
            else
                pcall(function()
                    game:GetService("VirtualUser"):Button1Down(Vector2.new(), cam.CFrame)
                end)
            end
        end
    else
        autoFireClock = 0
    end
end)

-- SILENT AIM
task.spawn(function()
    if not (hookmetamethod and getnamecallmethod and getrawmetatable) then return end
    local ok = pcall(function()
        local mt = getrawmetatable(game)
        local old = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            if getnamecallmethod() == "FireServer" and AIM.Silent and AIM.Active and aimPart and AIM.SilentMode ~= "Off" then
                local args = {...}
                local idx = {}
                for i, v in ipairs(args) do
                    if typeof(v) == "Vector3" then table.insert(idx, i) end
                end
                if AIM.SilentMode == "Direction" and #idx >= 2 then
                    local origin = args[idx[1]]
                    args[idx[2]] = (aimPart.Position - origin).Unit
                    for k = 3, #idx do args[idx[k]] = aimPart.Position end
                elseif AIM.SilentMode == "Position" then
                    for _, i in ipairs(idx) do args[i] = aimPart.Position end
                end
                for i, v in ipairs(args) do
                    if typeof(v) == "CFrame" then
                        args[i] = CFrame.lookAt(v.Position, aimPart.Position)
                    end
                end
                return old(self, unpack(args))
            end
            return old(self, ...)
        end)
        setreadonly(mt, true)
    end)
    if not ok then warn("DiogoDrag: silent aim no disponible en este executor") end
end)

-- ============ BYPASS MASTER ============
local bypass = { parts = {}, effects = {}, lights = {}, gui = {}, fov = nil, connected = false }

local function snapshotShadows()
    for _, d in pairs(workspace:GetDescendants()) do
        if d:IsA("BasePart") and d.CastShadow then
            table.insert(bypass.parts, d)
            d.CastShadow = false
        end
    end
    Lighting.GlobalShadows = false
end

local function snapshotParticles()
    for _, d in pairs(workspace:GetDescendants()) do
        if d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("Trail")
            or d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles") then
            if d.Enabled then
                table.insert(bypass.effects, d)
                d.Enabled = false
            end
        end
    end
end

local function snapshotLights()
    for _, d in pairs(workspace:GetDescendants()) do
        if d:IsA("PointLight") or d:IsA("SpotLight") or d:IsA("SurfaceLight") then
            if d.Enabled then
                table.insert(bypass.lights, d)
                d.Enabled = false
            end
        end
    end
end

local function snapshotPostFX()
    for _, d in pairs(Lighting:GetDescendants()) do
        if d:IsA("BloomEffect") or d:IsA("BlurEffect") or d:IsA("SunRaysEffect")
            or d:IsA("DepthOfFieldEffect") or d:IsA("ColorCorrectionEffect")
            or d:IsA("Atmosphere") or d:IsA("Sky") then
            table.insert(bypass.effects, d)
            if d:IsA("Atmosphere") then
                safeSet(d, "Density", 0)
            elseif d:IsA("Sky") then
                safeSet(d, "StarCount", 0)
            else
                safeSet(d, "Enabled", false)
            end
        end
    end
end

local function setTransparency(part, value)
    part.LocalTransparencyModifier = value
end

local function applyViewmodel()
    local cam = workspace.CurrentCamera
    if cam then
        for _, d in pairs(cam:GetDescendants()) do
            if d:IsA("BasePart") then setTransparency(d, 1) end
        end
    end
    local char = LocalPlayer.Character
    if char then
        for _, d in pairs(char:GetDescendants()) do
            if d:IsA("BasePart") then setTransparency(d, 1) end
        end
    end
end

local function clearViewmodel()
    local cam = workspace.CurrentCamera
    if cam then
        for _, d in pairs(cam:GetDescendants()) do
            if d:IsA("BasePart") then setTransparency(d, 0) end
        end
    end
    local char = LocalPlayer.Character
    if char then
        for _, d in pairs(char:GetDescendants()) do
            if d:IsA("BasePart") then setTransparency(d, 0) end
        end
    end
end

local function applyBypass()
    if BYPASS.PostFX then snapshotPostFX() end
    if BYPASS.Particles then snapshotParticles() end
    if BYPASS.Lights then snapshotLights() end
    if BYPASS.Shadows then snapshotShadows() end
    if BYPASS.Viewmodel then applyViewmodel() end
    if BYPASS.FOV then
        local cam = workspace.CurrentCamera
        if cam then
            bypass.fov = cam.FieldOfView
            cam.FieldOfView = BYPASS.FOVValue
        end
    end
    if BYPASS.HideGui then
        for _, name in ipairs({"PlayerList", "Backpack", "Chat", "EmotesMenu"}) do
            local ok, state = pcall(function() return StarterGui:GetCoreGuiEnabled(name) end)
            if ok then bypass.gui[name] = state end
            pcall(function() StarterGui:SetCoreGuiEnabled(name, false) end)
        end
    end
    if not bypass.connected then
        bypass.connected = true
        workspace.DescendantAdded:Connect(function(d)
            if not BYPASS.Enabled then return end
            if BYPASS.Shadows and d:IsA("BasePart") then d.CastShadow = false end
            if BYPASS.Particles and (d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("Trail")) then
                d.Enabled = false
            end
            if BYPASS.Lights and (d:IsA("PointLight") or d:IsA("SpotLight") or d:IsA("SurfaceLight")) then
                d.Enabled = false
            end
        end)
        LocalPlayer.CharacterAdded:Connect(function()
            if BYPASS.Enabled and BYPASS.Viewmodel then
                task.wait(0.35)
                applyViewmodel()
            end
        end)
    end
end

local function restoreBypass()
    for _, d in pairs(bypass.parts) do
        if d.Parent then d.CastShadow = true end
    end
    bypass.parts = {}
    for _, d in pairs(bypass.effects) do
        if d.Parent then
            if d:IsA("Atmosphere") then
                safeSet(d, "Density", 0.3)
            elseif d:IsA("Sky") then
                safeSet(d, "StarCount", 3000)
            else
                safeSet(d, "Enabled", true)
            end
        end
    end
    bypass.effects = {}
    for _, d in pairs(bypass.lights) do
        if d.Parent then d.Enabled = true end
    end
    bypass.lights = {}
    Lighting.GlobalShadows = true
    if bypass.fov then
        local cam = workspace.CurrentCamera
        if cam then cam.FieldOfView = bypass.fov end
        bypass.fov = nil
    end
    for name, state in pairs(bypass.gui) do
        pcall(function() StarterGui:SetCoreGuiEnabled(name, state) end)
    end
    bypass.gui = {}
    clearViewmodel()
end

local function setBypass(state)
    BYPASS.Enabled = state
    if state then applyBypass() else restoreBypass() end
end

-- ============ FPS BOOSTER ============
local boostSnapshot = { parts = {}, effects = {}, lights = {}, connected = false }

local function boostOn()
    pcall(function() settings().Rendering.QualityLevel = 1 end)
    pcall(function() setfpscap(240) end)
    Lighting.GlobalShadows = false
    safeSet(Lighting, "ShadowSoftness", 0)
    safeSet(Lighting, "EnvironmentDiffuseScale", 0)
    safeSet(Lighting, "EnvironmentSpecularScale", 0)
    safeSet(Lighting, "Brightness", 2)
    if workspace.Terrain then
        safeSet(workspace.Terrain, "WaterWaveSize", 0)
        safeSet(workspace.Terrain, "WaterReflectance", 0)
        safeSet(workspace.Terrain, "Decoration", false)
    end
    for _, d in pairs(workspace:GetDescendants()) do
        if d:IsA("BasePart") and d.CastShadow then
            d.CastShadow = false
            table.insert(boostSnapshot.parts, d)
        elseif d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("Trail")
            or d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles") then
            if d.Enabled then
                d.Enabled = false
                table.insert(boostSnapshot.effects, d)
            end
        elseif d:IsA("PointLight") or d:IsA("SpotLight") or d:IsA("SurfaceLight") then
            if d.Enabled then
                d.Enabled = false
                table.insert(boostSnapshot.lights, d)
            end
        elseif d:IsA("Decal") or d:IsA("Texture") then
            d.Transparency = 1
        end
    end
    for _, d in pairs(Lighting:GetDescendants()) do
        if d:IsA("BloomEffect") or d:IsA("BlurEffect") or d:IsA("SunRaysEffect")
            or d:IsA("DepthOfFieldEffect") or d:IsA("ColorCorrectionEffect") then
            d.Enabled = false
            table.insert(boostSnapshot.effects, d)
        end
    end
    if not boostSnapshot.connected then
        boostSnapshot.connected = true
        workspace.DescendantAdded:Connect(function(d)
            if d:IsA("BasePart") then
                d.CastShadow = false
            elseif d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("Trail") then
                d.Enabled = false
            end
        end)
    end
end

local function boostOff()
    pcall(function() settings().Rendering.QualityLevel = 8 end)
    pcall(function() setfpscap(60) end)
    Lighting.GlobalShadows = true
    if workspace.Terrain then
        safeSet(workspace.Terrain, "WaterWaveSize", 0.15)
        safeSet(workspace.Terrain, "WaterReflectance", 0.15)
        safeSet(workspace.Terrain, "Decoration", true)
    end
    for _, d in pairs(boostSnapshot.parts) do
        if d.Parent then d.CastShadow = true end
    end
    for _, d in pairs(boostSnapshot.effects) do
        if d.Parent then d.Enabled = true end
    end
    for _, d in pairs(boostSnapshot.lights) do
        if d.Parent then d.Enabled = true end
    end
    boostSnapshot.parts = {}
    boostSnapshot.effects = {}
    boostSnapshot.lights = {}
end

-- ============ KEY SYSTEM ============
local function BuildKeySystem(onSuccess)
    local overlay = Instance.new("Frame", ScreenGui)
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    overlay.BackgroundTransparency = 0.45
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 100

    local card = Instance.new("Frame", overlay)
    card.Size = UDim2.new(0, 320, 0, 210)
    card.Position = UDim2.new(0.5, -160, 0.5, -105)
    card.BackgroundColor3 = BG_DARK
    card.ZIndex = 101
    ApplyStyle(card, 12, ACCENT, 1)

    local title = Instance.new("TextLabel", card)
    title.Text = "AUTHENTICATION"
    title.Size = UDim2.new(1, 0, 0, 44)
    title.BackgroundTransparency = 1
    title.TextColor3 = TEXT_COLOR
    title.Font = Enum.Font.GothamBold
    title.TextSize = 15
    title.ZIndex = 102

    local sub = Instance.new("TextLabel", card)
    sub.Text = "ingresa la key para continuar"
    sub.Size = UDim2.new(1, 0, 0, 18)
    sub.Position = UDim2.new(0, 0, 0, 40)
    sub.BackgroundTransparency = 1
    sub.TextColor3 = TEXT_DIM
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 11
    sub.ZIndex = 102

    local input = Instance.new("TextBox", card)
    input.Size = UDim2.new(0.8, 0, 0, 40)
    input.Position = UDim2.new(0.1, 0, 0.34, 0)
    input.PlaceholderText = "Enter Key..."
    input.PlaceholderColor3 = TEXT_DIM
    input.Text = ""
    input.BackgroundColor3 = BG_LIGHT
    input.TextColor3 = TEXT_COLOR
    input.Font = Enum.Font.Gotham
    input.TextSize = 14
    input.ClearTextOnFocus = false
    input.ZIndex = 102
    ApplyStyle(input, 6, Color3.fromRGB(40, 40, 40), 1)

    local submit = Instance.new("TextButton", card)
    submit.Size = UDim2.new(0.8, 0, 0, 40)
    submit.Position = UDim2.new(0.1, 0, 0.66, 0)
    submit.Text = "AUTHENTICATE"
    submit.BackgroundColor3 = ACCENT
    submit.TextColor3 = BG_DARK
    submit.Font = Enum.Font.GothamBold
    submit.TextSize = 14
    submit.ZIndex = 102
    ApplyStyle(submit, 6)

    local busy = false
    local function tryAuth()
        if busy then return end
        if input.Text == REQUIRED_KEY then
            busy = true
            submit.Text = "OK"
            SmoothTween(card, {Size = UDim2.new(0, 340, 0, 240), BackgroundTransparency = 1}, 0.25)
            task.wait(0.25)
            overlay:Destroy()
            onSuccess()
        else
            busy = true
            input.Text = ""
            input.PlaceholderText = "WRONG KEY!"
            input.PlaceholderColor3 = Color3.fromRGB(255, 60, 60)
            SmoothTween(card, {Position = UDim2.new(0.5, -155, 0.5, -105)}, 0.05)
            task.wait(0.05)
            SmoothTween(card, {Position = UDim2.new(0.5, -165, 0.5, -105)}, 0.05)
            task.wait(0.05)
            SmoothTween(card, {Position = UDim2.new(0.5, -160, 0.5, -105)}, 0.05)
            task.wait(0.85)
            input.PlaceholderText = "Enter Key..."
            input.PlaceholderColor3 = TEXT_DIM
            busy = false
        end
    end

    submit.MouseButton1Click:Connect(tryAuth)
    input.FocusLost:Connect(function(enterPressed)
        if enterPressed then tryAuth() end
    end)
end

local function ShowMenu()
    Main.Size = MAIN_SIZE
    Main.BackgroundTransparency = 0
    Main.Visible = true
end

-- BINDS
local function bindLabel()
    if AIM.Mouse then return "Aim: " .. AIM.Mouse end
    return "Aim: " .. AIM.Bind.Name
end

local function isAimInput(input)
    if AIM.Mouse then
        return MOUSE_BUTTONS[input.UserInputType] == AIM.Mouse
    end
    return input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == AIM.Bind
end

CloseBtn.MouseButton1Click:Connect(function()
    SmoothTween(Main, {Size = UDim2.new(0, 520, 0, 380), BackgroundTransparency = 1}, 0.25)
    task.wait(0.25)
    Main.Visible = false
end)

UIS.InputBegan:Connect(function(input, processed)
    if isBindingKey then
        local mouseName = MOUSE_BUTTONS[input.UserInputType]
        if bindTarget == "aim" then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                AIM.Bind = input.KeyCode
                AIM.Mouse = nil
            elseif mouseName then
                AIM.Mouse = mouseName
            end
            AIMKeyBtn.Text = bindLabel()
            isBindingKey = false
            bindTarget = nil
        elseif bindTarget == "menu" and input.UserInputType == Enum.UserInputType.Keyboard then
            currentToggleKey = input.KeyCode
            BindBtn.Text = "Change Menu Key"
            isBindingKey = false
            bindTarget = nil
        end
        return
    end
    if processed then return end
    if input.KeyCode == currentToggleKey and authenticated then
        if Main.Visible then
            Main.Visible = false
        else
            ShowMenu()
        end
        return
    end
    if authenticated and AIM.Enabled and isAimInput(input) then
        if AIM.Mode == "Hold" then
            startAim()
        elseif AIM.Active then
            releaseAim()
        else
            startAim()
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    if AIM.Mode == "Hold" and AIM.Active and isAimInput(input) then
        releaseAim()
    end
end)

-- PÁGINAS
local VisualsPage = CreatePage("Visuals")
local AimbotPage = CreatePage("Aimbot")
local BypassPage = CreatePage("Bypass")
local MicPage = CreatePage("Mic")
local ConfigPage = CreatePage("Config")

local VisualsTab = CreateTab("Visuals", "Visuals")
CreateTab("Aimbot", "Aimbot")
CreateTab("Bypass", "Bypass")
CreateTab("Mic", "Mic")
CreateTab("Config", "Config")

-- [1] VISUALS
if not hasDrawing then
    CreateLabel("AVISO: tu executor no tiene API Drawing.", VisualsPage, Color3.fromRGB(255, 120, 120))
end

Section("Master", VisualsPage)
CreateToggle("Master ESP", VisualsPage, function(v) ESP.Enabled = v end)

Section("Cajas", VisualsPage)
CreateToggle("Box ESP", VisualsPage, function(v) ESP.Boxes = v end)
local styleBtn = CreateButton("Estilo: Corner", VisualsPage)
styleBtn.MouseButton1Click:Connect(function()
    ESP.BoxStyle = (ESP.BoxStyle == "Corner") and "Full" or "Corner"
    styleBtn.Text = "Estilo: " .. ESP.BoxStyle
end)
CreateToggle("Relleno", VisualsPage, function(v) ESP.Fill = v end)
CreateSlider("Opacidad Relleno", VisualsPage, 0.1, 0.95, 0.05, 0.65, function(v) ESP.FillTransparency = v end)
CreateSlider("Grosor Caja", VisualsPage, 1, 4, 1, 1, function(v) ESP.BoxThickness = v end)

Section("Texto", VisualsPage)
CreateToggle("Nombres", VisualsPage, function(v) ESP.Names = v end)
CreateToggle("Distancia", VisualsPage, function(v) ESP.Distance = v end)
CreateToggle("Texto de Vida", VisualsPage, function(v) ESP.HealthText = v end)
CreateSlider("Tamaño Texto", VisualsPage, 8, 24, 1, 14, function(v) ESP.TextSize = v end)

Section("Indicadores", VisualsPage)
CreateToggle("Barra de Vida", VisualsPage, function(v) ESP.HealthBar = v end)
CreateToggle("Esqueleto", VisualsPage, function(v) ESP.Skeleton = v end)
CreateToggle("Punto de Cabeza", VisualsPage, function(v) ESP.HeadDot = v end)

Section("Trazadores", VisualsPage)
CreateToggle("Trazadores", VisualsPage, function(v) ESP.Tracers = v end)
local originBtn = CreateButton("Origen: Bottom", VisualsPage)
originBtn.MouseButton1Click:Connect(function()
    ESP.TracerOrigin = cycle(TRACER_ORIGINS, ESP.TracerOrigin, originBtn, "Origen: ")
end)
CreateSlider("Grosor Trazador", VisualsPage, 1, 5, 1, 2, function(v) ESP.TracerThickness = v end)

Section("Filtros", VisualsPage)
CreateToggle("Team Check", VisualsPage, function(v) ESP.TeamCheck = v end, true)
CreateSlider("Distancia Máxima", VisualsPage, 100, 3000, 50, 1000, function(v) ESP.MaxDistance = v end)
CreateSlider("Opacidad Global", VisualsPage, 0.1, 1, 0.05, 1, function(v) ESP.Opacity = v end)

Section("Color", VisualsPage)
local swatchHolder = Instance.new("Frame", VisualsPage)
swatchHolder.Size = UDim2.new(1, -10, 0, 32)
swatchHolder.BackgroundTransparency = 1
swatchHolder.ZIndex = 8
local swatchLayout = Instance.new("UIListLayout", swatchHolder)
swatchLayout.FillDirection = Enum.FillDirection.Horizontal
swatchLayout.Padding = UDim.new(0, 6)
for _, c in ipairs({
    Color3.fromRGB(0, 255, 150), Color3.fromRGB(255, 60, 60), Color3.fromRGB(60, 130, 255),
    Color3.fromRGB(255, 220, 50), Color3.fromRGB(255, 255, 255), Color3.fromRGB(180, 60, 255),
    Color3.fromRGB(255, 130, 0), Color3.fromRGB(0, 220, 255),
}) do
    local b = Instance.new("TextButton", swatchHolder)
    b.Size = UDim2.new(0, 28, 0, 28)
    b.BackgroundColor3 = c
    b.Text = ""
    b.ZIndex = 8
    ApplyStyle(b, 6, Color3.fromRGB(60, 60, 60), 1)
    b.MouseButton1Click:Connect(function() ESP.Color = c end)
end
CreateSlider("Color R", VisualsPage, 0, 255, 1, 0, function(v)
    ESP.Color = Color3.fromRGB(v, ESP.Color.G * 255, ESP.Color.B * 255)
end)
CreateSlider("Color G", VisualsPage, 0, 255, 1, 255, function(v)
    ESP.Color = Color3.fromRGB(ESP.Color.R * 255, v, ESP.Color.B * 255)
end)
CreateSlider("Color B", VisualsPage, 0, 255, 1, 150, function(v)
    ESP.Color = Color3.fromRGB(ESP.Color.R * 255, ESP.Color.G * 255, v)
end)

-- [2] AIMBOT
Section("Master", AimbotPage)
CreateToggle("Enable Aimbot", AimbotPage, function(v)
    AIM.Enabled = v
    if not v then releaseAim() end
end)
local AIMKeyBtn = CreateButton(bindLabel(), AimbotPage)
AIMKeyBtn.MouseButton1Click:Connect(function()
    isBindingKey = true
    bindTarget = "aim"
    AIMKeyBtn.Text = "Tecla o click..."
end)
local modeBtn = CreateButton("Modo: Hold", AimbotPage)
modeBtn.MouseButton1Click:Connect(function()
    AIM.Mode = cycle(AIM_MODES, AIM.Mode, modeBtn, "Modo: ")
end)
local partBtn = CreateButton("Parte: Head", AimbotPage)
partBtn.MouseButton1Click:Connect(function()
    AIM.Part = cycle(AIM_PARTS, AIM.Part, partBtn, "Parte: ")
end)

Section("Apuntado", AimbotPage)
CreateSlider("FOV", AimbotPage, 20, 600, 5, 120, function(v) AIM.FOV = v end)
CreateSlider("Suavizado", AimbotPage, 0.02, 1, 0.02, 0.22, function(v) AIM.Smoothness = v end)
CreateSlider("Predicción", AimbotPage, 0, 1, 0.02, 0.12, function(v) AIM.Prediction = v end)
CreateSlider("Distancia Máxima", AimbotPage, 100, 3000, 50, 900, function(v) AIM.MaxDistance = v end)

Section("Filtros", AimbotPage)
CreateToggle("Team Check", AimbotPage, function(v) AIM.TeamCheck = v end, true)
CreateToggle("Wall Check", AimbotPage, function(v) AIM.WallCheck = v end)
CreateToggle("Resaltar Objetivo", AimbotPage, function(v) AIM.TargetHighlight = v end)

Section("Disparo", AimbotPage)
CreateToggle("Auto Fire", AimbotPage, function(v) AIM.AutoFire = v end)
CreateToggle("Silent Aim", AimbotPage, function(v) AIM.Silent = v end)
local silentBtn = CreateButton("Silent: Direction", AimbotPage)
silentBtn.MouseButton1Click:Connect(function()
    AIM.SilentMode = cycle(SILENT_MODES, AIM.SilentMode, silentBtn, "Silent: ")
end)

-- [3] BYPASS
Section("Bypass Master", BypassPage)
CreateToggle("Bypass Master", BypassPage, function(v) setBypass(v) end)
CreateLabel("Desactiva lo que resta visibilidad y FPS. Reversible.", BypassPage)

Section("Módulos", BypassPage)
CreateToggle("Quitar Viewmodel", BypassPage, function(v)
    BYPASS.Viewmodel = v
    if BYPASS.Enabled then
        if v then applyViewmodel() else clearViewmodel() end
    end
end, true)
CreateToggle("Desactivar Post FX", BypassPage, function(v) BYPASS.PostFX = v end, true)
CreateToggle("Desactivar Partículas", BypassPage, function(v) BYPASS.Particles = v end, true)
CreateToggle("Desactivar Luces", BypassPage, function(v) BYPASS.Lights = v end, true)
CreateToggle("Desactivar Sombras", BypassPage, function(v) BYPASS.Shadows = v end, true)
CreateToggle("Ocultar CoreGui", BypassPage, function(v) BYPASS.HideGui = v end)

Section("Cámara", BypassPage)
CreateToggle("Unlock FOV", BypassPage, function(v) BYPASS.FOV = v end, true)
CreateSlider("FOV Value", BypassPage, 70, 140, 1, 110, function(v)
    BYPASS.FOVValue = v
    local cam = workspace.CurrentCamera
    if BYPASS.Enabled and BYPASS.FOV and cam then cam.FieldOfView = v end
end)
CreateButton("Restaurar Todo", BypassPage, function()
    setBypass(false)
end)

-- [4] MIC / FPS
Section("FPS Booster", MicPage)
CreateLabel("Extremo: sombras, FX, luces, partículas y calidad.", MicPage)
CreateToggle("FPS Booster", MicPage, function(v)
    if v then boostOn() else boostOff() end
end)
CreateButton("FPS Cap 240", MicPage, function()
    pcall(function() setfpscap(240) end)
end)
CreateButton("FPS Cap 60", MicPage, function()
    pcall(function() setfpscap(60) end)
end)

Section("Utilidades", MicPage)
CreateToggle("Speed Hack", MicPage, function(v)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = v and 50 or 16 end
end)

-- [5] CONFIG
Section("Account", ConfigPage)
CreateLabel("User: " .. LocalPlayer.Name, ConfigPage)
local TimeLabel = CreateLabel("Time: 00:00:00", ConfigPage)

task.spawn(function()
    while task.wait(1) do
        TimeLabel.Text = "Time: " .. os.date("%X")
    end
end)

Section("Menu", ConfigPage)
local BindBtn = CreateButton("Change Menu Key", ConfigPage, function()
    isBindingKey = true
    bindTarget = "menu"
    BindBtn.Text = "Press any key..."
end)

CreateButton("Rejoin Server", ConfigPage, function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

-- INICIO
VisualsPage.Visible = true
VisualsTab.TextColor3 = ACCENT
VisualsTab.BackgroundColor3 = BG_DARK

BuildKeySystem(function()
    authenticated = true
    ShowMenu()
end)
