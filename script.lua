--[[
    Hypershot mobile menu — FOV / Aimbot / ESP
    Executor: any (Synapse, Delta, Codex, Fluxus, Wave). No Drawing API required.
    Re-execution safe: previous instance is torn down on load.
]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")

local LP = Players.LocalPlayer

--// teardown previous run
if _G.__hs_menu and type(_G.__hs_menu.unload) == "function" then
    pcall(_G.__hs_menu.unload)
end

--=====================================================================
-- Config
--=====================================================================
local Config = {
    -- aimbot
    aimEnabled   = false,
    aimFov        = 140,     -- pixels, radius from viewport centre
    aimSmooth     = 14,      -- higher = snappier
    aimPart       = "Head",  -- "Head" | "HumanoidRootPart" | "UpperTorso"
    aimTeamCheck  = true,
    aimWallCheck  = true,
    aimMaxDist    = 600,
    -- esp
    espEnabled    = true,
    espBox        = true,
    espName       = true,
    espHealth     = true,
    espDistance   = true,
    espTracer     = true,
    espTeamCheck  = false,
    espMaxDist    = 900,
    espColor      = Color3.fromRGB(120, 200, 255),
    espEnemyColor = Color3.fromRGB(255, 70, 70),
    -- fov
    fovVisible    = true,
    fovColor      = Color3.fromRGB(255, 255, 255),
}

local MENU_KEY = Enum.KeyCode.RightShift

--=====================================================================
-- Util
--=====================================================================
local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in next, props do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function corner(o, r)
    return new("UICorner", { CornerRadius = UDim.new(0, r or 6) }, o)
end

local function stroke(o, color, thickness, transparency)
    return new("UIStroke", {
        Color = color or Color3.new(1, 1, 1),
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, o)
end

local function raycastParams(exclude)
    local p = RaycastParams.new()
    p.FilterType = Enum.RaycastFilterType.Exclude
    p.FilterDescendantsInstances = exclude
    p.IgnoreWater = true
    return p
end

-- RaycastFilterType.Blacklist on older builds
pcall(function()
    local p = RaycastParams.new()
    p.FilterType = Enum.RaycastFilterType.Exclude
end) or pcall(function()
    Config.__legacyRay = true
end)

local function makeDraggable(frame, handle)
    local dragging, dragStart, startPos = false, nil, nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local d = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

--=====================================================================
-- GUI root
--=====================================================================
local function rootParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    local ok2, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and cg then return cg end
    return LP:WaitForChild("PlayerGui")
end

local Gui = new("ScreenGui", {
    Name = "HS_Menu",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 9999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
pcall(function()
    if syn and syn.protect_gui then syn.protect_gui(Gui) end
end)
Gui.Parent = rootParent()

--=====================================================================
-- Widgets
--=====================================================================
local Theme = {
    bg      = Color3.fromRGB(18, 18, 22),
    panel   = Color3.fromRGB(26, 26, 32),
    row     = Color3.fromRGB(34, 34, 42),
    accent  = Color3.fromRGB(120, 200, 255),
    text    = Color3.fromRGB(232, 232, 238),
    dim     = Color3.fromRGB(150, 150, 160),
}

local function makeToggle(parent, text, default, callback)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Theme.row,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        Parent = parent,
    }, parent)
    corner(row, 6)

    new("TextLabel", {
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.fromOffset(10, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = Theme.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = text,
    }, row)

    local state = default and true or false

    local btn = new("TextButton", {
        Size = UDim2.fromOffset(38, 20),
        Position = UDim2.new(1, -48, 0.5, -10),
        BackgroundColor3 = state and Theme.accent or Color3.fromRGB(60, 60, 70),
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
    }, row)
    corner(btn, 10)

    local knob = new("Frame", {
        Size = UDim2.fromOffset(16, 16),
        Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.fromOffset(2, 2),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
    }, btn)
    corner(knob, 8)

    local function render()
        btn.BackgroundColor3 = state and Theme.accent or Color3.fromRGB(60, 60, 70)
        knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.fromOffset(2, 2)
    end

    btn.MouseButton1Click:Connect(function()
        state = not state
        render()
        callback(state)
    end)

    return row
end

local function makeSlider(parent, text, min, max, default, decimals, callback)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = Theme.row,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
    }, parent)
    corner(row, 6)

    local label = new("TextLabel", {
        Size = UDim2.new(0.6, 0, 0, 20),
        Position = UDim2.fromOffset(10, 4),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = Theme.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = text,
    }, row)

    local valueLabel = new("TextLabel", {
        Size = UDim2.new(0.4, -14, 0, 20),
        Position = UDim2.new(0.6, 4, 0, 4),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = Theme.accent,
        TextXAlignment = Enum.TextXAlignment.Right,
        Text = tostring(default),
    }, row)

    local bar = new("Frame", {
        Size = UDim2.new(1, -20, 0, 6),
        Position = UDim2.new(0, 10, 1, -16),
        BackgroundColor3 = Color3.fromRGB(52, 52, 62),
        BorderSizePixel = 0,
    }, row)
    corner(bar, 3)

    local fill = new("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Theme.accent,
        BorderSizePixel = 0,
    }, bar)
    corner(fill, 3)

    local value = math.clamp(default, min, max)

    local function apply()
        local frac = (max - min) > 0 and (value - min) / (max - min) or 0
        fill.Size = UDim2.new(frac, 0, 1, 0)
        local f = decimals and ("%." .. decimals .. "f") or "%d"
        valueLabel.Text = string.format(f, value)
        callback(value)
    end

    local function setFromX(px)
        local abs = bar.AbsolutePosition.X
        local w = bar.AbsoluteSize.X
        if w <= 0 then return end
        local frac = math.clamp((px - abs) / w, 0, 1)
        value = min + (max - min) * frac
        if not decimals then value = math.floor(value + 0.5) end
        apply()
    end

    local dragging = false
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(input.Position.X)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    bar.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            setFromX(input.Position.X)
        end
    end)

    apply()
    return row
end

local function makeSection(parent, title)
    local wrap = new("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
    }, parent)

    new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Theme.dim,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = string.upper(title),
    }, wrap)

    local list = new("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.fromOffset(0, 24),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
    }, wrap)

    new("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, list)

    return wrap, list
end

--=====================================================================
-- Toggle button + panel
--=====================================================================
local Toggle = new("TextButton", {
    Name = "HS_Toggle",
    Size = UDim2.fromOffset(52, 52),
    Position = UDim2.new(0, 18, 0.5, -26),
    BackgroundColor3 = Theme.bg,
    Text = "HS",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = Theme.accent,
    AutoButtonColor = false,
    BorderSizePixel = 0,
    ZIndex = 10,
}, Gui)
corner(Toggle, 26)
stroke(Toggle, Theme.accent, 1.5, 0.35)
makeDraggable(Toggle, Toggle)

local Panel = new("Frame", {
    Name = "HS_Panel",
    Size = UDim2.fromOffset(300, 430),
    Position = UDim2.new(0.5, -150, 0.5, -215),
    BackgroundColor3 = Theme.bg,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 11,
}, Gui)
corner(Panel, 12)
stroke(Panel, Theme.accent, 1, 0.55)

local Header = new("Frame", {
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = Theme.panel,
    BorderSizePixel = 0,
    ZIndex = 12,
}, Panel)
corner(Header, 12)

new("TextLabel", {
    Size = UDim2.new(1, -60, 1, 0),
    Position = UDim2.fromOffset(14, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    TextColor3 = Theme.text,
    TextXAlignment = Enum.TextXAlignment.Left,
    Text = "HYPERSHOT",
    ZIndex = 13,
}, Header)

local CloseBtn = new("TextButton", {
    Size = UDim2.fromOffset(28, 28),
    Position = UDim2.new(1, -36, 0.5, -14),
    BackgroundColor3 = Color3.fromRGB(48, 48, 58),
    Text = "×",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = Theme.text,
    AutoButtonColor = false,
    BorderSizePixel = 0,
    ZIndex = 13,
}, Header)
corner(CloseBtn, 8)

makeDraggable(Panel, Header)

local Scroll = new("ScrollingFrame", {
    Size = UDim2.new(1, -16, 1, -56),
    Position = UDim2.fromOffset(8, 48),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = Theme.accent,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ZIndex = 12,
}, Panel)

new("UIListLayout", {
    Padding = UDim.new(0, 12),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, Scroll)

local function setPanel(open)
    Panel.Visible = open
end

Toggle.MouseButton1Click:Connect(function()
    setPanel(not Panel.Visible)
end)
CloseBtn.MouseButton1Click:Connect(function()
    setPanel(false)
end)

--=====================================================================
-- FOV ring (instance-rendered, mobile-safe)
--=====================================================================
local FovRing = new("Frame", {
    Name = "HS_Fov",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(Config.aimFov * 2, Config.aimFov * 2),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Visible = Config.fovVisible,
    ZIndex = 5,
}, Gui)
corner(FovRing, 9999)
local FovStroke = stroke(FovRing, Config.fovColor, 1, 0.4)

local function syncFov()
    local cam = Workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
    FovRing.Position = UDim2.fromOffset(vp.X * 0.5, vp.Y * 0.5)
    FovRing.Size = UDim2.fromOffset(Config.aimFov * 2, Config.aimFov * 2)
    FovStroke.Color = Config.fovColor
    FovRing.Visible = Config.fovVisible
end

--=====================================================================
-- Recognition pass (server-replicated state + client visibility)
--=====================================================================
local Recognition = {}
Recognition.cache = {}

local function getTeam(plr)
    local t = plr.Team
    if t then return t end
    local ok, attr = pcall(function() return plr:GetAttribute("Team") end)
    if ok and attr then return attr end
    local ls = plr:FindFirstChild("leaderstats")
    if ls then
        local tf = ls:FindFirstChild("Team")
        if tf then return tf.Value end
    end
    return nil
end

local function getCharacter(plr)
    local c = plr.Character
    if not c or not c.Parent then return nil end
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return nil end
    local root = hum.RootPart or c:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    return c, hum, root
end

local function getAimPart(char, mode)
    if mode == "Head" then
        return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    elseif mode == "UpperTorso" then
        return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
    end
    return char:FindFirstChild("HumanoidRootPart")
end

local function isVisible(char, root, part)
    local cam = Workspace.CurrentCamera
    if not cam then return false end
    local origin = cam.CFrame.Position
    local target = part.Position
    local params = raycastParams({ LP.Character, Gui })
    local hit = Workspace:Raycast(origin, target - origin, params)
    if not hit then return true end
    return hit.Instance:IsDescendantOf(char)
end

function Recognition.scan()
    local cam = Workspace.CurrentCamera
    if not cam then return {} end
    local myTeam = getTeam(LP)
    local out = {}

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local char, hum, root = getCharacter(plr)
            if char and root then
                local part = getAimPart(char, Config.aimPart) or root
                local screen, onScreen, depth = cam:WorldToViewportPoint(part.Position)
                local dist = (cam.CFrame.Position - root.Position).Magnitude

                local team = getTeam(plr)
                local sameTeam = (team ~= nil and myTeam ~= nil and team == myTeam)

                if dist <= Config.espMaxDist or Config.aimEnabled then
                    out[#out + 1] = {
                        player   = plr,
                        char     = char,
                        hum      = hum,
                        root     = root,
                        part     = part,
                        screen   = Vector2.new(screen.X, screen.Y),
                        onScreen = onScreen and depth > 0,
                        depth    = depth,
                        dist     = dist,
                        team     = team,
                        sameTeam = sameTeam,
                    }
                end
            end
        end
    end

    return out
end

--=====================================================================
-- ESP
--=====================================================================
local EspGui = new("ScreenGui", {
    Name = "HS_ESP",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 9998,
}, Gui)
local TracerLayer = new("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Visible = Config.espEnabled,
}, EspGui)

local espCache = {}   -- [Player] = {billboard=, box=, name=, hp=, hpFill=, dist=}
local tracerPool = {}

local function destroyEsp(plr)
    local e = espCache[plr]
    if e and e.billboard then
        e.billboard:Destroy()
    end
    espCache[plr] = nil
end

local function buildEsp(plr, root)
    local bb = new("BillboardGui", {
        Name = "HS_ESP_BB",
        AlwaysOnTop = true,
        Size = UDim2.new(2.6, 0, 3.4, 0),
        StudsOffsetWorldSpace = Vector3.new(0, 0.6, 0),
        LightInfluence = 0,
        MaxDistance = Config.espMaxDist,
        ResetOnSpawn = false,
    }, root)

    local box = new("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, bb)
    local boxStroke = stroke(box, Config.espColor, 1.2, 0.15)

    local nameLabel = new("TextLabel", {
        Size = UDim2.new(1, 40, 0, 14),
        Position = UDim2.new(0.5, -20, 0, -18),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Config.espColor,
        TextStrokeTransparency = 0.5,
        Text = plr.Name,
    }, bb)

    local distLabel = new("TextLabel", {
        Size = UDim2.new(1, 40, 0, 12),
        Position = UDim2.new(0.5, -20, 1, 4),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = Theme.dim,
        TextStrokeTransparency = 0.5,
        Text = "",
    }, bb)

    local hpBg = new("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        Position = UDim2.new(0, -6, 0, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
    }, bb)

    local hpFill = new("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 230, 110),
        BorderSizePixel = 0,
    }, hpBg)

    espCache[plr] = {
        billboard = bb,
        box = box,
        boxStroke = boxStroke,
        name = nameLabel,
        dist = distLabel,
        hpFill = hpFill,
    }
    return espCache[plr]
end

local function tracerFor(plr)
    local t = tracerPool[plr]
    if t then return t end
    local f = new("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Config.espColor,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        Visible = false,
    }, TracerLayer)
    tracerPool[plr] = f
    return f
end

local function renderEsp(snapshot)
    TracerLayer.Visible = Config.espEnabled

    local alive = {}
    local cam = Workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)

    for _, t in ipairs(snapshot) do
        local show = Config.espEnabled
            and t.onScreen
            and t.dist <= Config.espMaxDist
            and (not Config.espTeamCheck or not t.sameTeam)

        if show then
            alive[t.player] = true
            local e = espCache[t.player]
            if not e or not e.billboard or not e.billboard.Parent then
                e = buildEsp(t.player, t.root)
            end

            local col = t.sameTeam and Config.espColor or Config.espEnemyColor
            e.box.Visible = Config.espBox
            e.boxStroke.Color = col
            e.boxStroke.Transparency = 0.15
            e.name.Visible = Config.espName
            e.name.TextColor3 = col
            e.name.Text = t.player.Name
            e.dist.Visible = Config.espDistance
            e.dist.Text = string.format("%d m", math.floor(t.dist))
            e.hpFill.Parent.Visible = Config.espHealth
            e.hpFill.Size = UDim2.new(1, 0, math.clamp(t.hum.Health / math.max(t.hum.MaxHealth, 1), 0, 1), 0)
            e.hpFill.BackgroundColor3 = Color3.fromRGB(
                math.floor(255 * (1 - t.hum.Health / math.max(t.hum.MaxHealth, 1))),
                math.floor(230 * (t.hum.Health / math.max(t.hum.MaxHealth, 1))), 110)

            -- tracer (mobile-safe: rotated ScreenGui frame)
            local tr = tracerFor(t.player)
            if Config.espTracer then
                local origin = Vector2.new(vp.X * 0.5, vp.Y)
                local delta = t.screen - origin
                local len = delta.Magnitude
                tr.Visible = true
                tr.BackgroundColor3 = col
                tr.Position = UDim2.fromOffset(origin.X, origin.Y)
                tr.Size = UDim2.fromOffset(len, 1)
                tr.Rotation = math.deg(math.atan2(delta.Y, delta.X))
            else
                tr.Visible = false
            end
        else
            local e = espCache[t.player]
            if e and e.billboard then e.billboard.Enabled = false end
            local tr = tracerPool[t.player]
            if tr then tr.Visible = false end
        end
    end

    for plr, e in pairs(espCache) do
        if not alive[plr] then
            if e.billboard then e.billboard.Enabled = false end
        else
            if e.billboard then e.billboard.Enabled = true end
        end
    end
end

--=====================================================================
-- Aimbot (camera CFrame, frame-rate independent)
--=====================================================================
local aimAlpha = 0

local function pickTarget(snapshot)
    local cam = Workspace.CurrentCamera
    if not cam then return nil end
    local vp = cam.ViewportSize
    local center = Vector2.new(vp.X * 0.5, vp.Y * 0.5)

    local best, bestScore = nil, math.huge

    for _, t in ipairs(snapshot) do
        if t.onScreen and t.dist <= Config.aimMaxDist then
            if not (Config.aimTeamCheck and t.sameTeam) then
                local d = (t.screen - center).Magnitude
                if d <= Config.aimFov and d < bestScore then
                    local ok = true
                    if Config.aimWallCheck then
                        ok = isVisible(t.char, t.root, t.part)
                    end
                    if ok then
                        bestScore = d
                        best = t
                    end
                end
            end
        end
    end
    return best
end

local function runAimbot(snapshot, dt)
    if not Config.aimEnabled then return end
    local cam = Workspace.CurrentCamera
    if not cam then return end

    local target = pickTarget(snapshot)
    if not target then return end

    local goal = CFrame.lookAt(cam.CFrame.Position, target.part.Position)
    -- exponential smoothing: identical feel at 30 and 144 fps
    local a = 1 - math.exp(-Config.aimSmooth * dt)
    a = math.clamp(a, 0, 1)
    cam.CFrame = cam.CFrame:Lerp(goal, a)
end

--=====================================================================
-- Menu contents
--=====================================================================
local order = 0
local function nextOrder()
    order = order + 1
    return order
end

local _, aimList = makeSection(Scroll, "Aimbot")
aimList.LayoutOrder = nextOrder()
makeToggle(aimList, "Enable aimbot", Config.aimEnabled, function(v) Config.aimEnabled = v end)
makeSlider(aimList, "Aim FOV", 40, 500, Config.aimFov, nil, function(v) Config.aimFov = v; syncFov() end)
makeSlider(aimList, "Smoothing", 2, 40, Config.aimSmooth, nil, function(v) Config.aimSmooth = v end)
makeSlider(aimList, "Max distance", 50, 1200, Config.aimMaxDist, nil, function(v) Config.aimMaxDist = v end)
makeToggle(aimList, "Team check", Config.aimTeamCheck, function(v) Config.aimTeamCheck = v end)
makeToggle(aimList, "Wall check", Config.aimWallCheck, function(v) Config.aimWallCheck = v end)

local _, espList = makeSection(Scroll, "ESP")
espList.LayoutOrder = nextOrder()
makeToggle(espList, "Enable ESP", Config.espEnabled, function(v) Config.espEnabled = v; TracerLayer.Visible = v end)
makeToggle(espList, "Box", Config.espBox, function(v) Config.espBox = v end)
makeToggle(espList, "Name", Config.espName, function(v) Config.espName = v end)
makeToggle(espList, "Health", Config.espHealth, function(v) Config.espHealth = v end)
makeToggle(espList, "Distance", Config.espDistance, function(v) Config.espDistance = v end)
makeToggle(espList, "Tracer", Config.espTracer, function(v) Config.espTracer = v end)
makeToggle(espList, "Team check", Config.espTeamCheck, function(v) Config.espTeamCheck = v end)
makeSlider(espList, "Max distance", 100, 2000, Config.espMaxDist, nil, function(v) Config.espMaxDist = v end)

local _, fovList = makeSection(Scroll, "FOV")
fovList.LayoutOrder = nextOrder()
makeToggle(fovList, "Show FOV ring", Config.fovVisible, function(v) Config.fovVisible = v; syncFov() end)

--=====================================================================
-- Lifecycle
--=====================================================================
local connections = {}
local function bind(signal, fn)
    local c = signal:Connect(fn)
    connections[#connections + 1] = c
    return c
end

-- aim runs on the camera step so the write lands before the frame renders
bind(RunService.RenderStepped, function(dt)
    syncFov()
    local snapshot = Recognition.scan()
    renderEsp(snapshot)
    runAimbot(snapshot, dt)
end)

-- player removal cleanup
bind(Players.PlayerRemoving, function(plr)
    destroyEsp(plr)
    if tracerPool[plr] then
        tracerPool[plr]:Destroy()
        tracerPool[plr] = nil
    end
end)

-- PC keybind, mobile gets the button
bind(UserInputService.InputBegan, function(input, processed)
    if processed then return end
    if input.KeyCode == MENU_KEY then
        setPanel(not Panel.Visible)
    end
end)

-- viewport changes
bind(Workspace.CurrentCamera and Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), function()
    syncFov()
end)

syncFov()

--=====================================================================
-- Unload
--=====================================================================
local function unload()
    for _, c in ipairs(connections) do
        pcall(function() c:Disconnect() end)
    end
    connections = {}
    for plr in pairs(espCache) do destroyEsp(plr) end
    for plr, f in pairs(tracerPool) do pcall(function() f:Destroy() end) end
    tracerPool = {}
    pcall(function() Gui:Destroy() end)
    _G.__hs_menu = nil
end

_G.__hs_menu = { unload = unload, config = Config }
