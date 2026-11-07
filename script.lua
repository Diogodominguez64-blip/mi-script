--[[
    Hypershot - mobile menu: FOV / Aimbot / ESP
    Luau (Roblox Lua). Single file, executor side. No Drawing API required.

    Built against how Hypershot actually replicates its entities:

      workspace.Mobs                 folder of mob / bot models, each carrying a
                                     "Head" BasePart and a numeric "Team" attribute
      Player.Character               player models, same Head + HumanoidRootPart
                                     layout, same "Team" attribute on the model
      model:GetAttribute("Team")     numeric team id. -1 means "no team" (FFA),
                                     which is how the game signals "everyone is
                                     hostile", so the team filter self-disables
      Head / HumanoidRootPart        present on both mobs and players, which is
                                     why nothing here reads Humanoid for aim

    Consequences baked into this build:
      * ESP uses zero ScreenGui. Billboards are parented to the target's Head,
        chams are Highlight instances, tracers are Beam instances in 3D.
      * The aimbot resolves targets from Head parts only. Humanoid is read for
        nothing but an optional health number, and its absence is not an error.
      * Characters are not assumed to live at the top of Workspace. The
        resolver walks Mobs, then Player.Character, then a throttled deep scan
        of Workspace so a folder the game hides them in does not blind the menu.

    Re-execution safe: the previous instance tears itself down on load.
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
    aimEnabled    = false,
    aimMode       = "camera",   -- "camera" | "silent"
    aimFov        = 150,        -- pixels, radius from viewport centre
    aimSmooth     = 16,         -- higher = snappier (camera mode only)
    aimMaxDist    = 700,
    aimTeamCheck  = false,      -- SameTeam() decides when the game exposes it
    aimWallCheck  = false,      -- ray from the camera, viewmodel excluded
    silentStrict  = false,      -- true = only retarget callers whose source has "Auto"
    aimMobs       = true,
    aimPlayers    = true,

    -- esp
    espEnabled    = true,
    espBox        = true,
    espName       = true,
    espDistance   = true,
    espHealth     = true,
    espChams      = false,
    espTracer     = true,
    espMaxDist    = 1200,
    espTeamCheck  = false,
    espMobs       = true,
    espPlayers    = true,
    deepScan      = true,

    -- colours
    espColor      = Color3.fromRGB(120, 200, 255),
    espEnemyColor = Color3.fromRGB(255, 70, 70),
    espMobColor   = Color3.fromRGB(255, 190, 70),

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
    if props then
        for k, v in next, props do
            o[k] = v
        end
    end
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
-- Menu root (the only ScreenGui in this build)
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

local Theme = {
    bg     = Color3.fromRGB(18, 18, 22),
    panel  = Color3.fromRGB(26, 26, 32),
    row    = Color3.fromRGB(34, 34, 42),
    accent = Color3.fromRGB(120, 200, 255),
    text   = Color3.fromRGB(232, 232, 238),
    dim    = Color3.fromRGB(150, 150, 160),
    ok     = Color3.fromRGB(90, 220, 140),
    bad    = Color3.fromRGB(255, 90, 90),
}

--=====================================================================
-- Widgets
--=====================================================================
local function makeToggle(parent, text, default, callback)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Theme.row,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
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

    new("TextLabel", {
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
    Size = UDim2.fromOffset(310, 470),
    Position = UDim2.new(0.5, -155, 0.5, -235),
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
    Text = "x",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = Theme.text,
    AutoButtonColor = false,
    BorderSizePixel = 0,
    ZIndex = 13,
}, Header)
corner(CloseBtn, 8)

makeDraggable(Panel, Header)

local Status = new("TextLabel", {
    Size = UDim2.new(1, -20, 0, 16),
    Position = UDim2.fromOffset(10, 42),
    BackgroundTransparency = 1,
    Font = Enum.Font.Code,
    TextSize = 11,
    TextColor3 = Theme.dim,
    TextXAlignment = Enum.TextXAlignment.Left,
    Text = "targets 0 | silent off",
    ZIndex = 12,
}, Panel)

local Scroll = new("ScrollingFrame", {
    Size = UDim2.new(1, -16, 1, -76),
    Position = UDim2.fromOffset(8, 62),
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
-- FOV ring (menu overlay, not part of the ESP)
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
-- Entity model helpers
--   Hypershot keys everything off Head parts + a Team attribute on the
--   model. Nothing below requires a Humanoid to exist.
--=====================================================================
local function partOf(model, name)
    local c = model:FindFirstChild(name)
    if c and c:IsA("BasePart") then return c end
    return nil
end

local function firstBasePart(model)
    local pp = model.PrimaryPart
    if pp and pp:IsA("BasePart") then return pp end
    for _, d in ipairs(model:GetChildren()) do
        if d:IsA("BasePart") then return d end
    end
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") then return d end
    end
    return nil
end

local function teamOf(inst)
    if not inst then return nil end
    local ok, v = pcall(function() return inst:GetAttribute("Team") end)
    if ok and typeof(v) == "number" then return v end
    local ok2, t = pcall(function() return inst.Team end)
    if ok2 and typeof(t) == "number" then return t end
    return nil
end

local function myTeamRaw()
    local char = LP.Character
    local t = teamOf(char)
    if t ~= nil then return t end
    local ok, team = pcall(function() return LP.Team end)
    if ok then return team end
    return nil
end

-- Authoritative team test when the game exposes it; attribute compare otherwise.
-- GlobalStuff.SameTeam is the exact call Hypershot's own scripts use, so it
-- matches the game's notion of hostility including the -1 (FFA) case.
local GlbStf = nil
do
    local rs = game:GetService("ReplicatedStorage")
    local mods = rs:FindFirstChild("Modules")
    local gs = mods and mods:FindFirstChild("GlobalStuff")
    if gs and gs:IsA("ModuleScript") then
        local ok, res = pcall(require, gs)
        if ok and type(res) == "table" then GlbStf = res end
    end
end

local function sameTeamOf(model, plr, team, mine)
    if GlbStf and type(GlbStf.SameTeam) == "function" then
        local ok, r = pcall(GlbStf.SameTeam, GlbStf, LP, model)
        if ok and typeof(r) == "boolean" then return r end
        if plr then
            ok, r = pcall(GlbStf.SameTeam, GlbStf, LP, plr)
            if ok and typeof(r) == "boolean" then return r end
        end
    end
    if typeof(mine) == "number" and typeof(team) == "number" then
        if mine == -1 or team == -1 then return false end
        return team == mine
    end
    return false
end

local function healthOf(model)
    -- Hypershot mobs carry their own health attributes; a Humanoid is only a
    -- fallback and is never required for the entity to be considered valid.
    local h = model:GetAttribute("Health")
    if typeof(h) ~= "number" then h = model:GetAttribute("HP") end
    local m = model:GetAttribute("MaxHealth")
    if typeof(m) ~= "number" then m = model:GetAttribute("MaxHP") end

    if typeof(h) == "number" then
        if typeof(m) ~= "number" or m <= 0 then m = math.max(h, 100) end
        return h, m
    end

    local hum = model:FindFirstChildOfClass("Humanoid")
    if hum then
        return hum.Health, math.max(hum.MaxHealth, 1)
    end
    return nil, nil
end

local function isAlive(model, root)
    local dead = model:GetAttribute("Dead")
    if dead == true then return false end
    local alive = model:GetAttribute("Alive")
    if alive == false then return false end

    local h = healthOf(model)
    if h ~= nil and h > 0 then return true end

    -- A missing or zero health value is not proof of death here: mobs are
    -- pooled and re-used, and Humanoid health is not the source of truth.
    return root.Transparency < 0.98
end

local function modelSize(model, fallback)
    local ok, size = pcall(function()
        local _, s = model:GetBoundingBox()
        return s
    end)
    if ok and typeof(size) == "Vector3" and size.Magnitude > 0 then
        return size
    end
    return fallback
end

--=====================================================================
-- Target scan
--=====================================================================
local MAX_TARGETS = 96
local SCAN_INTERVAL = 1 / 30

local deepCache = {}
local deepNext = 0
local lastScan = 0
local targets = {}

local function describe(model, kind, plr, mine)
    if not model or not model.Parent then return nil end

    local head  = partOf(model, "Head")
    local hrp   = partOf(model, "HumanoidRootPart")
    local torso = partOf(model, "UpperTorso") or partOf(model, "Torso")
    local root  = head or hrp or torso or firstBasePart(model)
    if not root then return nil end
    if not isAlive(model, root) then return nil end

    local aimPart = head or torso or hrp or root
    local cam = Workspace.CurrentCamera
    if not cam then return nil end

    local camPos = cam.CFrame.Position
    local dist = (camPos - root.Position).Magnitude
    local screen, onScreen = cam:WorldToViewportPoint(aimPart.Position)
    local size = modelSize(model, Vector3.new(3, 5, 3))
    local health, maxHealth = healthOf(model)

    local team = teamOf(model)
    if team == nil and plr then
        local ok, t = pcall(function() return plr.Team end)
        if ok then team = t end
    end

    local sameTeam = sameTeamOf(model, plr, team, mine)

    return {
        model     = model,
        kind      = kind,
        player    = plr,
        head      = head,
        root      = root,
        aimPart   = aimPart,
        screen    = Vector2.new(screen.X, screen.Y),
        onScreen  = onScreen and screen.Z > 0,
        dist      = dist,
        height    = math.clamp(size.Y, 1.5, 24),
        width     = math.clamp(math.max(size.X, size.Z), 1, 16),
        health    = health,
        maxHealth = maxHealth,
        team      = team,
        sameTeam  = sameTeam,
    }
end

local function scan()
    local out = {}
    local seen = {}
    local mine = myTeamRaw()

    local function add(model, kind, plr)
        if #out >= MAX_TARGETS then return end
        if seen[model] then return end
        local t = describe(model, kind, plr, mine)
        if t then
            seen[model] = true
            out[#out + 1] = t
        end
    end

    -- 1. mobs folder (bots, zombies, wave enemies)
    if Config.espMobs or Config.aimMobs then
        local folder = Workspace:FindFirstChild("Mobs")
        if folder then
            for _, m in ipairs(folder:GetChildren()) do
                if #out >= MAX_TARGETS then break end
                if m:IsA("Model") then add(m, "mob", nil) end
            end
        end
    end

    -- 2. replicated players
    if Config.espPlayers or Config.aimPlayers then
        for _, plr in ipairs(Players:GetPlayers()) do
            if #out >= MAX_TARGETS then break end
            if plr ~= LP then
                local char = plr.Character
                if char and char.Parent then add(char, "player", plr) end
            end
        end
    end

    -- 3. throttled container walk, for characters the game parents elsewhere
    --    Only Folders are descended into and the container count is capped, so
    --    a map with 20k parts never turns into a per-frame allocation.
    if Config.deepScan then
        local now = os.clock()
        if now >= deepNext then
            deepNext = now + 3
            local found = {}
            local queue = { Workspace }
            local head = 1
            local budget = 1200

            while head <= #queue and budget > 0 do
                local node = queue[head]
                head = head + 1
                budget = budget - 1

                local ok, kids = pcall(function() return node:GetChildren() end)
                if ok then
                    for _, child in ipairs(kids) do
                        if child:IsA("Model") then
                            local h = child:FindFirstChild("Head")
                            if h and h:IsA("BasePart") and child ~= LP.Character then
                                found[#found + 1] = child
                                if #found >= MAX_TARGETS * 2 then
                                    head = #queue + 1
                                    break
                                end
                            end
                        elseif child:IsA("Folder") then
                            queue[#queue + 1] = child
                        end
                    end
                end
            end

            deepCache = found
        end

        for _, m in ipairs(deepCache) do
            if #out >= MAX_TARGETS then break end
            if m.Parent then
                local owner = Players:GetPlayerFromCharacter(m)
                if owner and owner ~= LP then
                    add(m, "player", owner)
                else
                    add(m, "mob", nil)
                end
            end
        end
    end

    return out
end

local function scanThrottled()
    local now = os.clock()
    if now - lastScan < SCAN_INTERVAL then return targets end
    lastScan = now
    targets = scan()
    return targets
end

--=====================================================================
-- ESP - zero ScreenGui
--   BillboardGui parented to the target Head (scales in studs)
--   Highlight for chams
--   Beam from a camera-anchored part to the target Head for tracers
--=====================================================================
local esp = {}          -- [model] = record
local tracerOrigin = nil
local tracerOriginAtt = nil

local function ensureTracerOrigin()
    local cam = Workspace.CurrentCamera
    if not cam then return false end

    if tracerOrigin and tracerOrigin.Parent == cam then return true end
    if tracerOrigin and tracerOrigin.Parent then
        -- camera was replaced on respawn; reparent so existing beams survive
        pcall(function() tracerOrigin.Parent = cam end)
        return true
    end

    tracerOrigin = new("Part", {
        Name = "hs_tracer_origin",
        Size = Vector3.new(0.05, 0.05, 0.05),
        Transparency = 1,
        Anchored = true,
        CanCollide = false,
        CanQuery = false,
        CanTouch = false,
        Massless = true,
        CastShadow = false,
    }, cam)
    tracerOriginAtt = new("Attachment", { Name = "hs_origin" }, tracerOrigin)
    return true
end

local function buildRecord(t)
    local anchor = t.head or t.root
    if not anchor then return nil end

    local bb = new("BillboardGui", {
        Name = "hs_esp",
        AlwaysOnTop = true,
        LightInfluence = 0,
        ResetOnSpawn = false,
        MaxDistance = Config.espMaxDist,
        Size = UDim2.new(t.width + 0.8, 0, t.height + 0.6, 0),
        StudsOffsetWorldSpace = Vector3.new(0, t.height * 0.15, 0),
    })
    bb.Adornee = anchor
    bb.Parent = anchor

    local box = new("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, bb)
    local boxStroke = stroke(box, Config.espColor, 1.2, 0.15)

    local nameLabel = new("TextLabel", {
        Size = UDim2.new(1, 60, 0, 14),
        Position = UDim2.new(0.5, -30, 0, -16),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Config.espColor,
        TextStrokeTransparency = 0.4,
        Text = t.player and t.player.Name or t.model.Name,
    }, bb)

    local distLabel = new("TextLabel", {
        Size = UDim2.new(1, 60, 0, 12),
        Position = UDim2.new(0.5, -30, 1, 2),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = Theme.dim,
        TextStrokeTransparency = 0.4,
        Text = "",
    }, bb)

    local hpBg = new("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        Position = UDim2.new(0, -7, 0, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.45,
        BorderSizePixel = 0,
    }, bb)

    local hpFill = new("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 230, 110),
        BorderSizePixel = 0,
    }, hpBg)

    local hl = new("Highlight", {
        Name = "hs_cham",
        FillColor = Config.espColor,
        FillTransparency = 0.6,
        OutlineColor = Config.espColor,
        OutlineTransparency = 0.2,
        DepthMode = Enum.HighlightDepthMode.Occluded,
        Enabled = false,
    }, t.model)

    local beam, beamAtt = nil, nil
    if ensureTracerOrigin() then
        beamAtt = new("Attachment", { Name = "hs_beam_att" }, anchor)
        beam = new("Beam", {
            Name = "hs_tracer",
            Attachment0 = tracerOriginAtt,
            Attachment1 = beamAtt,
            Color = ColorSequence.new(Config.espColor),
            Transparency = NumberSequence.new(0.45),
            Width0 = 1.1,
            Width1 = 0.3,
            FaceCamera = true,
            LightEmission = 0.8,
            LightInfluence = 0,
            Segments = 1,
            Enabled = false,
        }, tracerOrigin)
    end

    return {
        model   = t.model,
        billboard = bb,
        box       = box,
        stroke    = boxStroke,
        name      = nameLabel,
        dist      = distLabel,
        hpBg      = hpBg,
        hpFill    = hpFill,
        cham      = hl,
        beam      = beam,
        beamAtt   = beamAtt,
    }
end

local function destroyRecord(rec)
    if rec.beam then pcall(function() rec.beam:Destroy() end) end
    if rec.beamAtt then pcall(function() rec.beamAtt:Destroy() end) end
    if rec.cham then pcall(function() rec.cham:Destroy() end) end
    if rec.billboard then pcall(function() rec.billboard:Destroy() end) end
end

local function colourFor(t)
    if t.kind == "mob" then return Config.espMobColor end
    if t.sameTeam then return Config.espColor end
    return Config.espEnemyColor
end

local function renderEsp(list)
    local alive = {}

    for _, t in ipairs(list) do
        local show = Config.espEnabled
            and t.dist <= Config.espMaxDist
            and (not Config.espTeamCheck or not t.sameTeam)
            and ((t.kind == "mob" and Config.espMobs) or (t.kind == "player" and Config.espPlayers))

        if show then
            alive[t.model] = true
            local rec = esp[t.model]
            if not rec or not rec.billboard or not rec.billboard.Parent then
                if rec then destroyRecord(rec) end
                rec = buildRecord(t)
                esp[t.model] = rec
            end

            if rec then
                local col = colourFor(t)

                rec.billboard.Enabled = true
                rec.billboard.MaxDistance = Config.espMaxDist
                rec.box.Visible = Config.espBox
                rec.stroke.Color = col
                rec.stroke.Transparency = 0.15

                rec.name.Visible = Config.espName
                rec.name.TextColor3 = col
                rec.name.Text = t.player and t.player.Name or t.model.Name

                rec.dist.Visible = Config.espDistance
                rec.dist.Text = string.format("%d m", math.floor(t.dist))

                if Config.espHealth and t.health and t.maxHealth then
                    local frac = math.clamp(t.health / t.maxHealth, 0, 1)
                    rec.hpBg.Visible = true
                    rec.hpFill.Size = UDim2.new(1, 0, frac, 0)
                    rec.hpFill.BackgroundColor3 = Color3.fromRGB(
                        math.floor(255 * (1 - frac)),
                        math.floor(230 * frac),
                        110)
                else
                    rec.hpBg.Visible = false
                end

                rec.cham.Enabled = Config.espChams
                rec.cham.FillColor = col
                rec.cham.OutlineColor = col

                if rec.beam then
                    local want = Config.espTracer and t.onScreen
                    rec.beam.Enabled = want
                    if want then
                        rec.beam.Color = ColorSequence.new(col)
                        rec.beam.Width0 = math.clamp(t.dist / 90, 0.5, 2.4)
                    end
                end
            end
        else
            local rec = esp[t.model]
            if rec then
                if rec.billboard then rec.billboard.Enabled = false end
                if rec.beam then rec.beam.Enabled = false end
                if rec.cham then rec.cham.Enabled = false end
            end
        end
    end

    for model, rec in pairs(esp) do
        if not alive[model] or not model.Parent then
            destroyRecord(rec)
            esp[model] = nil
        end
    end
end

--=====================================================================
-- Silent aim hook (Hypershot's own input path)
--   GameUI.GameUIMod.GetMousePos is what the weapon reads for its shot
--   direction, and the game expects a WORLD position back (Vector3), not a
--   screen position. Returning Vector2 makes the weapon fire at nothing.
--   Only shot-path callers get retargeted; everything else (crosshair UI,
--   menu code) falls through to the real function untouched.
--=====================================================================
local Silent = {
    module = nil,
    original = nil,   -- callable that runs the game's real GetMousePos
    hook = nil,
    target = nil,
    installed = false,
    status = "off",
}

local function findGameUiModule()
    local pg = LP:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local gui = pg:FindFirstChild("GameUI")
    if gui then
        local mod = gui:FindFirstChild("GameUIMod")
        if mod and mod:IsA("ModuleScript") then return mod end
    end
    for _, d in ipairs(pg:GetDescendants()) do
        if d:IsA("ModuleScript") and d.Name == "GameUIMod" then return d end
    end
    return nil
end

local SHOT_CALLERS = { "Auto", "Fire", "Shoot", "Weapon" }

local function callerIsShot()
    local info = debug.info or debug.getinfo
    if type(info) ~= "function" then return true end
    for level = 2, 6 do
        local ok, src = pcall(info, level, "s")
        if not ok or type(src) ~= "string" or src == "" then break end
        if Config.silentStrict then
            if src:find("Auto") then return true end
        else
            for _, pat in ipairs(SHOT_CALLERS) do
                if src:find(pat) then return true end
            end
        end
    end
    return false
end

local function silentHook(self, ...)
    if Config.aimEnabled and Config.aimMode == "silent" then
        local t = Silent.target
        local part = t and t.aimPart
        if part and part.Parent and callerIsShot() then
            return part.Position
        end
    end
    return Silent.original(self, ...)
end

local function installSilent()
    if Silent.installed and Silent.original then
        Silent.status = "hooked"
        return true
    end
    local mod = findGameUiModule()
    if not mod then
        Silent.status = "no GameUIMod"
        return false
    end
    local ok, tbl = pcall(require, mod)
    if not ok or type(tbl) ~= "table" then
        Silent.status = "require failed"
        return false
    end
    local orig = tbl.GetMousePos
    if type(orig) ~= "function" then
        Silent.status = "no GetMousePos"
        return false
    end

    Silent.module = tbl

    -- Preferred: detour the function itself, so callers that cached the
    -- reference at require time are still covered.
    if type(hookfunction) == "function" then
        local okh, ret = pcall(hookfunction, orig, silentHook)
        if okh and type(ret) == "function" then
            Silent.original = ret
            Silent.hook = silentHook
            Silent.installed = true
            Silent.status = "hooked fn"
            return true
        end
    end

    Silent.original = orig
    local okw = pcall(function() tbl.GetMousePos = silentHook end)
    if not okw then
        Silent.original = nil
        Silent.status = "table locked"
        return false
    end
    Silent.hook = silentHook
    Silent.installed = true
    Silent.status = "hooked tbl"
    return true
end

local function uninstallSilent()
    if Silent.installed and Silent.hook then
        if type(restorefunction) == "function" then
            pcall(restorefunction, Silent.hook)
        end
        if Silent.module and Silent.module.GetMousePos == Silent.hook and Silent.original then
            pcall(function() Silent.module.GetMousePos = Silent.original end)
        end
    end
    Silent.module = nil
    Silent.original = nil
    Silent.hook = nil
    Silent.installed = false
    Silent.target = nil
    Silent.status = "off"
end

--=====================================================================
-- Aimbot
--=====================================================================
local function canSee(t)
    local cam = Workspace.CurrentCamera
    if not cam then return false end
    -- The camera carries the first-person viewmodel; a ray from the camera
    -- origin starts inside it and would report every target as blocked.
    local filter = { cam }
    if LP.Character then filter[#filter + 1] = LP.Character end
    if tracerOrigin then filter[#filter + 1] = tracerOrigin end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = filter
    params.IgnoreWater = true
    params.RespectCanCollide = true

    local origin = cam.CFrame.Position
    local hit = Workspace:Raycast(origin, t.aimPart.Position - origin, params)
    if not hit then return true end
    return hit.Instance:IsDescendantOf(t.model)
end

local function pickTarget(list, cam)
    local vp = cam.ViewportSize
    local center = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
    local best, bestDist = nil, math.huge

    for _, t in ipairs(list) do
        local wanted = (t.kind == "mob" and Config.aimMobs) or (t.kind == "player" and Config.aimPlayers)
        if wanted and t.onScreen and t.dist <= Config.aimMaxDist then
            if not (Config.aimTeamCheck and t.sameTeam) then
                local d = (t.screen - center).Magnitude
                if d <= Config.aimFov and d < bestDist then
                    if not Config.aimWallCheck or canSee(t) then
                        best, bestDist = t, d
                    end
                end
            end
        end
    end

    return best
end

local Aim = { current = nil }

local function runAimbot(list, dt)
    if not Config.aimEnabled then
        Silent.target = nil
        Aim.current = nil
        return
    end
    local cam = Workspace.CurrentCamera
    if not cam then return end

    local target = pickTarget(list, cam)
    if Config.aimMode == "silent" then
        Silent.target = target
        Aim.current = nil
        if not Silent.installed then
            installSilent()
        end
        return
    end

    Silent.target = nil
    Aim.current = target
end

-- Camera write lives on its own render step at Camera priority + 1, so the
-- game's camera controller (priority 200) runs first and cannot overwrite it.
local AIM_BIND = "hs_camera_aim"

local function applyCameraAim(dt)
    if not Config.aimEnabled or Config.aimMode ~= "camera" then return end
    local t = Aim.current
    if not t or not t.aimPart or not t.aimPart.Parent then return end
    local cam = Workspace.CurrentCamera
    if not cam then return end

    local goal = CFrame.lookAt(cam.CFrame.Position, t.aimPart.Position)
    local a = math.clamp(1 - math.exp(-Config.aimSmooth * dt), 0, 1)
    cam.CFrame = cam.CFrame:Lerp(goal, a)
end

RunService:BindToRenderStep(AIM_BIND, Enum.RenderPriority.Camera.Value + 1, applyCameraAim)

--=====================================================================
-- Menu contents
--=====================================================================
local order = 0
local function nextOrder()
    order = order + 1
    return order
end

local aimWrap, aimList = makeSection(Scroll, "Aimbot")
aimWrap.LayoutOrder = nextOrder()
makeToggle(aimList, "Enable aimbot", Config.aimEnabled, function(v)
    Config.aimEnabled = v
    if not v then uninstallSilent() end
end)
makeToggle(aimList, "Silent aim (GameUIMod hook)", Config.aimMode == "silent", function(v)
    Config.aimMode = v and "silent" or "camera"
    if v then
        installSilent()
    else
        uninstallSilent()
    end
end)
makeToggle(aimList, "Silent: strict caller (Auto only)", Config.silentStrict, function(v)
    Config.silentStrict = v
end)
makeSlider(aimList, "Aim FOV", 40, 600, Config.aimFov, nil, function(v)
    Config.aimFov = v
    syncFov()
end)
makeSlider(aimList, "Smoothing", 2, 40, Config.aimSmooth, nil, function(v)
    Config.aimSmooth = v
end)
makeSlider(aimList, "Max distance", 50, 1500, Config.aimMaxDist, nil, function(v)
    Config.aimMaxDist = v
end)
makeToggle(aimList, "Team check", Config.aimTeamCheck, function(v) Config.aimTeamCheck = v end)
makeToggle(aimList, "Wall check", Config.aimWallCheck, function(v) Config.aimWallCheck = v end)
makeToggle(aimList, "Target mobs", Config.aimMobs, function(v) Config.aimMobs = v end)
makeToggle(aimList, "Target players", Config.aimPlayers, function(v) Config.aimPlayers = v end)

local espWrap, espList = makeSection(Scroll, "ESP")
espWrap.LayoutOrder = nextOrder()
makeToggle(espList, "Enable ESP", Config.espEnabled, function(v) Config.espEnabled = v end)
makeToggle(espList, "Box", Config.espBox, function(v) Config.espBox = v end)
makeToggle(espList, "Name", Config.espName, function(v) Config.espName = v end)
makeToggle(espList, "Distance", Config.espDistance, function(v) Config.espDistance = v end)
makeToggle(espList, "Health", Config.espHealth, function(v) Config.espHealth = v end)
makeToggle(espList, "Chams (Highlight)", Config.espChams, function(v) Config.espChams = v end)
makeToggle(espList, "Tracer (Beam)", Config.espTracer, function(v) Config.espTracer = v end)
makeToggle(espList, "Team check", Config.espTeamCheck, function(v) Config.espTeamCheck = v end)
makeToggle(espList, "Show mobs", Config.espMobs, function(v) Config.espMobs = v end)
makeToggle(espList, "Show players", Config.espPlayers, function(v) Config.espPlayers = v end)
makeSlider(espList, "Max distance", 100, 2500, Config.espMaxDist, nil, function(v)
    Config.espMaxDist = v
end)

local scanWrap, scanList = makeSection(Scroll, "Resolver")
scanWrap.LayoutOrder = nextOrder()
makeToggle(scanList, "Deep scan workspace", Config.deepScan, function(v) Config.deepScan = v end)
makeToggle(scanList, "Show FOV ring", Config.fovVisible, function(v)
    Config.fovVisible = v
    syncFov()
end)

--=====================================================================
-- Lifecycle
--=====================================================================
local connections = {}
local function bind(signal, fn)
    local c = signal:Connect(fn)
    connections[#connections + 1] = c
    return c
end

local statusClock = 0

bind(RunService.RenderStepped, function(dt)
    local cam = Workspace.CurrentCamera
    if not cam then return end

    if tracerOrigin and tracerOrigin.Parent then
        tracerOrigin.CFrame = cam.CFrame * CFrame.new(0, -0.6, -1.2)
    end

    syncFov()

    local list = scanThrottled()
    renderEsp(list)
    runAimbot(list, dt)

    statusClock = statusClock + dt
    if statusClock >= 0.5 then
        statusClock = 0
        if Config.aimEnabled and Config.aimMode == "silent" and not Silent.installed then
            installSilent()
        end
        Status.Text = string.format("targets %d | aim %s | silent %s",
            #list, Config.aimMode, Silent.status)
        Status.TextColor3 = (Config.aimEnabled or Silent.installed) and Theme.ok or Theme.dim
    end
end)

bind(Players.PlayerRemoving, function(plr)
    for model, rec in pairs(esp) do
        if rec.model then
            local owner = Players:GetPlayerFromCharacter(rec.model)
            if owner == plr then
                destroyRecord(rec)
                esp[model] = nil
            end
        end
    end
end)

bind(LP.CharacterAdded, function()
    deepCache = {}
    deepNext = 0
    -- The GameUIMod hook survives respawns; re-installing would stack detours.
    if Config.aimMode == "silent" and Config.aimEnabled and not Silent.installed then
        installSilent()
    end
end)

bind(UserInputService.InputBegan, function(input, processed)
    if processed then return end
    if input.KeyCode == MENU_KEY then
        setPanel(not Panel.Visible)
    end
end)

do
    local cam = Workspace.CurrentCamera
    if cam then
        bind(cam:GetPropertyChangedSignal("ViewportSize"), syncFov)
    end
end

syncFov()

--=====================================================================
-- Unload
--=====================================================================
local function unload()
    for _, c in ipairs(connections) do
        pcall(function() c:Disconnect() end)
    end
    connections = {}

    pcall(function() RunService:UnbindFromRenderStep(AIM_BIND) end)
    Aim.current = nil

    uninstallSilent()

    for model, rec in pairs(esp) do
        destroyRecord(rec)
        esp[model] = nil
    end

    if tracerOrigin then
        pcall(function() tracerOrigin:Destroy() end)
        tracerOrigin = nil
        tracerOriginAtt = nil
    end

    pcall(function() Gui:Destroy() end)
    _G.__hs_menu = nil
end

_G.__hs_menu = { unload = unload, config = Config }
