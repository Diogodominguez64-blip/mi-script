-- Hypershot mobile menu - FOV / Aimbot / Silent Aim / ESP
-- Single file, executor side. No Drawing API. One ScreenGui (the panel only).
print("[hs] start")

local P   = game:GetService("Players")
local R   = game:GetService("RunService")
local U   = game:GetService("UserInputService")
local W   = game:GetService("Workspace")
local RS  = game:GetService("ReplicatedStorage")
local LP  = P.LocalPlayer

if _G.__hs and type(_G.__hs.unload) == "function" then pcall(_G.__hs.unload) end

local C = {
    aim       = false,
    mode      = "silent",
    assist    = true,
    fov       = 150,
    smooth    = 14,
    maxDist   = 700,
    mobs      = true,
    players   = true,
    esp       = true,
    espName   = true,
    espDist   = true,
    espHp     = true,
    espChams  = false,
    espLine   = true,
    espMax    = 1200,
    espMobs   = true,
    espPlayers= true,
    ring      = true,
}

local COL = {
    bg    = Color3.fromRGB(16, 16, 20),
    row   = Color3.fromRGB(32, 32, 40),
    on    = Color3.fromRGB(90, 220, 140),
    off   = Color3.fromRGB(70, 70, 82),
    txt   = Color3.fromRGB(235, 235, 240),
    dim   = Color3.fromRGB(150, 150, 162),
    esp   = Color3.fromRGB(120, 200, 255),
    mob   = Color3.fromRGB(255, 190, 70),
    enemy = Color3.fromRGB(255, 70, 70),
}

local function new(cls, props, parent)
    local o = Instance.new(cls)
    if props then for k, v in next, props do o[k] = v end end
    if parent then o.Parent = parent end
    return o
end

local function corner(o, r)
    return new("UICorner", { CornerRadius = UDim.new(0, r or 6) }, o)
end

local function stroke(o, c, t, a)
    return new("UIStroke", {
        Color = c or Color3.new(1, 1, 1),
        Thickness = t or 1,
        Transparency = a or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, o)
end

--=====================================================================
-- Root
--=====================================================================
local function host()
    local ok, h = pcall(function() return gethui and gethui() end)
    if ok and h then return h end
    local ok2, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and cg then return cg end
    return LP:WaitForChild("PlayerGui", 10)
end

local Gui = new("ScreenGui", {
    Name = "HS_Menu",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 9999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
pcall(function() if syn and syn.protect_gui then syn.protect_gui(Gui) end end)
Gui.Parent = host()
print("[hs] gui")

--=====================================================================
-- Widgets
--=====================================================================
local function mkToggle(parent, label, init, cb)
    local b = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = COL.row,
        AutoButtonColor = false,
        Text = "",
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = parent,
    })
    corner(b, 5)
    new("TextLabel", {
        Size = UDim2.new(1, -58, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = COL.txt,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = label,
        Parent = b,
    })
    local knob = new("Frame", {
        Size = UDim2.new(0, 34, 0, 16),
        Position = UDim2.new(1, -44, 0.5, -8),
        BackgroundColor3 = init and COL.on or COL.off,
        Parent = b,
    })
    corner(knob, 8)
    local dot = new("Frame", {
        Size = UDim2.new(0, 12, 0, 12),
        Position = init and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = knob,
    })
    corner(dot, 6)
    local state = init
    local function paint()
        knob.BackgroundColor3 = state and COL.on or COL.off
        dot.Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
    end
    b.MouseButton1Click:Connect(function()
        state = not state
        paint()
        cb(state)
    end)
    return b
end

local function mkSlider(parent, label, min, max, init, cb)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = COL.row,
        Parent = parent,
    })
    corner(row, 5)
    local cap = new("TextLabel", {
        Size = UDim2.new(1, -20, 0, 18),
        Position = UDim2.new(0, 10, 0, 2),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = COL.txt,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = label,
        Parent = row,
    })
    local track = new("Frame", {
        Size = UDim2.new(1, -20, 0, 4),
        Position = UDim2.new(0, 10, 1, -12),
        BackgroundColor3 = COL.off,
        Parent = row,
    })
    corner(track, 2)
    local fill = new("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = COL.on,
        Parent = track,
    })
    corner(fill, 2)
    local value = init
    local function paint()
        local a = (value - min) / (max - min)
        fill.Size = UDim2.new(a, 0, 1, 0)
        cap.Text = label .. "  " .. tostring(math.floor(value))
    end
    local function setFromX(px)
        local abs = track.AbsolutePosition.X
        local w = track.AbsoluteSize.X
        if w <= 0 then return end
        local a = math.clamp((px - abs) / w, 0, 1)
        value = math.floor(min + (max - min) * a + 0.5)
        paint()
        cb(value)
    end
    local dragging = false
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(i.Position.X)
        end
    end)
    track.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    U.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch then
            setFromX(i.Position.X)
        end
    end)
    paint()
    return row
end

--=====================================================================
-- Panel
--=====================================================================
local Btn = new("TextButton", {
    Size = UDim2.new(0, 46, 0, 46),
    Position = UDim2.new(0, 14, 0.5, -23),
    BackgroundColor3 = COL.bg,
    Text = "HS",
    TextColor3 = COL.txt,
    TextSize = 15,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    Parent = Gui,
})
corner(Btn, 23)
stroke(Btn, COL.on, 1.5)

local Panel = new("Frame", {
    Size = UDim2.new(0, 268, 0, 0),
    Position = UDim2.new(0, 70, 0.5, -200),
    BackgroundColor3 = COL.bg,
    AutomaticSize = Enum.AutomaticSize.Y,
    Visible = false,
    Parent = Gui,
})
corner(Panel, 10)
stroke(Panel, Color3.fromRGB(60, 60, 72), 1)

local Head = new("Frame", {
    Size = UDim2.new(1, 0, 0, 34),
    BackgroundColor3 = COL.row,
    Parent = Panel,
})
corner(Head, 10)
new("TextLabel", {
    Size = UDim2.new(1, -60, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextColor3 = COL.txt,
    TextXAlignment = Enum.TextXAlignment.Left,
    Text = "Hypershot",
    Parent = Head,
})
local CloseBtn = new("TextButton", {
    Size = UDim2.new(0, 26, 0, 26),
    Position = UDim2.new(1, -32, 0.5, -13),
    BackgroundColor3 = COL.bg,
    Text = "x",
    TextColor3 = COL.dim,
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    Parent = Head,
})
corner(CloseBtn, 6)

local Status = new("TextLabel", {
    Size = UDim2.new(1, -16, 0, 16),
    Position = UDim2.new(0, 8, 1, 2),
    BackgroundTransparency = 1,
    Font = Enum.Font.Code,
    TextSize = 10,
    TextColor3 = COL.dim,
    TextXAlignment = Enum.TextXAlignment.Left,
    Text = "idle",
    Parent = Panel,
})

local Body = new("Frame", {
    Size = UDim2.new(1, -16, 0, 0),
    Position = UDim2.new(0, 8, 0, 40),
    BackgroundTransparency = 1,
    AutomaticSize = Enum.AutomaticSize.Y,
    Parent = Panel,
})
new("UIListLayout", {
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, Body)

local function section(title)
    local l = new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = COL.dim,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = title,
        Parent = Body,
    })
    return l
end

local function drag(frame, handle)
    local on, start, base = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            on = true
            start = i.Position
            base = frame.Position
        end
    end)
    handle.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            on = false
        end
    end)
    U.InputChanged:Connect(function(i)
        if not on then return end
        if i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch then
            local d = i.Position - start
            frame.Position = UDim2.new(base.X.Scale, base.X.Offset + d.X,
                                       base.Y.Scale, base.Y.Offset + d.Y)
        end
    end)
end

drag(Panel, Head)
drag(Btn, Btn)

local function setPanel(v)
    Panel.Visible = v
    Btn.Text = v and "<" or "HS"
end

Btn.MouseButton1Click:Connect(function() setPanel(not Panel.Visible) end)
CloseBtn.MouseButton1Click:Connect(function() setPanel(false) end)

--=====================================================================
-- FOV ring
--=====================================================================
local Ring = new("Frame", {
    Size = UDim2.new(0, 300, 0, 300),
    Position = UDim2.new(0.5, -150, 0.5, -150),
    BackgroundTransparency = 1,
    Visible = false,
    Parent = Gui,
})
corner(Ring, 1000)
local RingStroke = stroke(Ring, Color3.new(1, 1, 1), 1.5, 0.35)

local function syncRing()
    local cam = W.CurrentCamera
    if not cam then return end
    local s = C.fov * 2
    Ring.Size = UDim2.new(0, s, 0, s)
    Ring.Position = UDim2.new(0.5, -C.fov, 0.5, -C.fov)
    Ring.Visible = C.ring
    local vp = cam.ViewportSize
    local cx, cy = vp.X * 0.5, vp.Y * 0.5
    local dx, dy = math.abs(cx - C.fov), math.abs(cy - C.fov)
    if dx > cx or dy > cy then Ring.Visible = false end
end

--=====================================================================
-- Targeting
--=====================================================================
local function partOf(model)
    if not model then return nil end
    local h = model:FindFirstChild("Head")
    if h and h:IsA("BasePart") then return h end
    local r = model:FindFirstChild("HumanoidRootPart")
    if r and r:IsA("BasePart") then return r end
    for _, d in ipairs(model:GetChildren()) do
        if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then return d end
    end
    return nil
end

local function alive(model)
    if not model or not model.Parent then return false end
    local h = model:FindFirstChildOfClass("Humanoid")
    if h and h.Health <= 0 then return false end
    return true
end

local GlbStf
do
    local ok = pcall(function()
        local m = RS:FindFirstChild("Modules")
        local g = m and m:FindFirstChild("GlobalStuff")
        if g and g:IsA("ModuleScript") then
            local okr, t = pcall(require, g)
            if okr and type(t) == "table" and type(t.SameTeam) == "function" then GlbStf = t end
        end
    end)
end

local function sameTeam(model)
    if not GlbStf then return nil end
    local ok, r = pcall(GlbStf.SameTeam, GlbStf, LP, model)
    if ok and type(r) == "boolean" then return r end
    return nil
end

local MAXT = 64
local targets = {}
local esp = {}
local scanClock = 0
local scanEvery = 0.20

local function collect()
    local out = {}
    local function add(model, kind)
        if #out >= MAXT then return end
        local ok, rec = pcall(function()
            if not alive(model) then return nil end
            local part = partOf(model)
            if not part then return nil end
            return { model = model, part = part, kind = kind }
        end)
        if ok and rec then out[#out + 1] = rec end
    end

    if C.mobs then
        local folder = W:FindFirstChild("Mobs")
        if folder then
            for _, m in ipairs(folder:GetChildren()) do add(m, "mob") end
        end
    end
    if C.players then
        for _, pl in ipairs(P:GetPlayers()) do
            if pl ~= LP and pl.Character then add(pl.Character, "player") end
        end
    end
    return out
end

local function project(list)
    local cam = W.CurrentCamera
    if not cam then return list end
    local vp = cam.ViewportSize
    local cx, cy = vp.X * 0.5, vp.Y * 0.5
    local eye = cam.CFrame.Position
    for _, t in ipairs(list) do
        local p = t.part.Position
        t.dist = (p - eye).Magnitude
        local sp, on = cam:WorldToViewportPoint(p)
        if on and sp.Z > 0 then
            t.screen = Vector2.new(sp.X, sp.Y)
            t.onScreen = true
            t.centerDist = (t.screen - Vector2.new(cx, cy)).Magnitude
        else
            t.onScreen = false
            t.centerDist = math.huge
        end
        if t.kind == "player" then
            t.st = sameTeam(t.model)
        else
            t.st = nil
        end
    end
    return list
end

--=====================================================================
-- Silent aim
--=====================================================================
local S = { tgt = nil, orig = nil, tbl = nil, inst = false, calls = 0, hits = 0 }

local function findMod()
    local pg = LP:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local g = pg:FindFirstChild("GameUI")
    if g then
        local m = g:FindFirstChild("GameUIMod")
        if m and m:IsA("ModuleScript") then return m end
    end
    for _, d in ipairs(pg:GetDescendants()) do
        if d:IsA("ModuleScript") and d.Name == "GameUIMod" then return d end
    end
    return nil
end

local function armed()
    if not C.aim then return false end
    if C.mode == "silent" then return true end
    return C.assist
end

local function head()
    local t = S.tgt
    local p = t and t.part
    if p and p.Parent then return p end
    return nil
end

local function wrapper(a, b, c)
    S.calls = S.calls + 1
    if armed() then
        local p = head()
        if p then
            if typeof(a) == "Vector3" then
                S.hits = S.hits + 1
                return p.Position
            elseif typeof(a) == "Vector2" then
                local cam = W.CurrentCamera
                if cam then
                    local sp, on = cam:WorldToViewportPoint(p.Position)
                    if on then
                        S.hits = S.hits + 1
                        return Vector2.new(sp.X, sp.Y)
                    end
                end
            end
        end
    end
    return a, b, c
end

local function install()
    if S.inst then return true end
    local m = findMod()
    if not m then return false end
    local ok, t = pcall(require, m)
    if not ok or type(t) ~= "table" then return false end
    local f = t.GetMousePos
    if type(f) ~= "function" then return false end

    S.tbl = t
    S.orig = f

    local function hooked(...)
        local a, b, c = f(...)
        return wrapper(a, b, c)
    end

    if type(hookfunction) == "function" then
        local okh, orig = pcall(hookfunction, f, hooked)
        if okh and type(orig) == "function" then
            S.orig = orig
            S.inst = true
            return true
        end
    end

    local okw = pcall(function() t.GetMousePos = hooked end)
    if okw then
        S.inst = true
        return true
    end
    return false
end

local function uninstall()
    if not S.inst then return end
    if type(restorefunction) == "function" and S.orig then
        pcall(restorefunction, S.orig)
    end
    if S.tbl and S.orig then
        pcall(function() S.tbl.GetMousePos = S.orig end)
    end
    S.inst = false
    S.tgt = nil
end

--=====================================================================
-- ESP
--=====================================================================
local tracerPart, tracerAtt

local function ensureTracer()
    local cam = W.CurrentCamera
    if not cam then return end
    if not tracerPart or not tracerPart.Parent then
        tracerPart = new("Part", {
            Name = "hs_tracer_origin",
            Size = Vector3.new(0.1, 0.1, 0.1),
            Transparency = 1,
            CanCollide = false,
            CanQuery = false,
            CanTouch = false,
            Anchored = true,
            CastShadow = false,
            Parent = cam,
        })
        tracerAtt = new("Attachment", { Name = "hs_att", Parent = tracerPart })
    end
    tracerPart.CFrame = cam.CFrame * CFrame.new(0, -0.5, -1)
end

local function colour(t)
    if t.kind == "mob" then return COL.mob end
    if t.st == false then return COL.enemy end
    return COL.esp
end

local function build(model, t)
    local part = t.part
    local rec = {}

    if C.espName or C.espDist or C.espHp then
        local bb = new("BillboardGui", {
            Name = "hs_bb",
            Size = UDim2.new(0, 170, 0, 54),
            StudsOffset = Vector3.new(0, 2.2, 0),
            AlwaysOnTop = true,
            MaxDistance = C.espMax,
            Adornee = part,
            Parent = part,
        })
        local name = new("TextLabel", {
            Size = UDim2.new(1, 0, 0, 15),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextColor3 = colour(t),
            TextStrokeTransparency = 0.4,
            Text = model.Name,
            Visible = C.espName,
            Parent = bb,
        })
        local dist = new("TextLabel", {
            Size = UDim2.new(1, 0, 0, 13),
            Position = UDim2.new(0, 0, 0, 15),
            BackgroundTransparency = 1,
            Font = Enum.Font.Code,
            TextSize = 11,
            TextColor3 = COL.txt,
            TextStrokeTransparency = 0.4,
            Text = "",
            Visible = C.espDist,
            Parent = bb,
        })
        local bar = new("Frame", {
            Size = UDim2.new(1, -40, 0, 4),
            Position = UDim2.new(0, 20, 0, 30),
            BackgroundColor3 = Color3.fromRGB(40, 40, 48),
            Visible = C.espHp,
            Parent = bb,
        })
        corner(bar, 2)
        local fill = new("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = COL.on,
            Parent = bar,
        })
        corner(fill, 2)
        rec.bb, rec.name, rec.dist, rec.bar, rec.fill = bb, name, dist, bar, fill
    end

    if C.espChams then
        local hl = new("Highlight", {
            Name = "hs_hl",
            FillColor = colour(t),
            FillTransparency = 0.72,
            OutlineColor = colour(t),
            OutlineTransparency = 0.2,
            DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
            Adornee = model,
            Parent = model,
        })
        rec.hl = hl
    end

    if C.espLine then
        ensureTracer()
        local att = new("Attachment", { Name = "hs_head", Parent = part })
        local beam = new("Beam", {
            Name = "hs_beam",
            Attachment0 = tracerAtt,
            Attachment1 = att,
            Width0 = 0.06,
            Width1 = 0.02,
            FaceCamera = true,
            LightEmission = 1,
            Color = ColorSequence.new(colour(t)),
            Transparency = NumberSequence.new(0.35),
            Parent = part,
        })
        rec.att, rec.beam = att, beam
    end

    return rec
end

local function destroy(rec)
    for _, k in ipairs({ "bb", "hl", "beam", "att" }) do
        local o = rec[k]
        if o then pcall(function() o:Destroy() end) end
    end
end

local function renderEsp(list)
    if not C.esp then
        for model, rec in pairs(esp) do
            destroy(rec)
            esp[model] = nil
        end
        return
    end

    local seen = {}
    for _, t in ipairs(list) do
        if t.dist <= C.espMax and t.part.Parent then
            local want = (t.kind == "mob" and C.espMobs) or (t.kind == "player" and C.espPlayers)
            if want then
                seen[t.model] = true
                local rec = esp[t.model]
                if not rec then
                    local okb, built = pcall(build, t.model, t)
                    if not okb then built = nil end
                    rec = built
                    if rec then esp[t.model] = rec end
                end
                if rec then
                    if rec.name then rec.name.Text = t.model.Name end
                    if rec.name then rec.name.TextColor3 = colour(t) end
                    if rec.dist then rec.dist.Text = string.format("%d m", math.floor(t.dist)) end
                    if rec.fill then
                        local h = t.model:FindFirstChildOfClass("Humanoid")
                        local frac = 1
                        if h and h.MaxHealth > 0 then frac = math.clamp(h.Health / h.MaxHealth, 0, 1) end
                        rec.fill.Size = UDim2.new(frac, 0, 1, 0)
                        rec.fill.BackgroundColor3 = frac > 0.5 and COL.on or (frac > 0.2 and COL.mob or COL.enemy)
                    end
                    if rec.hl then rec.hl.FillColor = colour(t) end
                    if rec.beam then rec.beam.Color = ColorSequence.new(colour(t)) end
                end
            end
        end
    end

    for model, rec in pairs(esp) do
        if not seen[model] or not model.Parent then
            destroy(rec)
            esp[model] = nil
        end
    end
end

--=====================================================================
-- Aimbot
--=====================================================================
local T = { current = nil }

local function pick(list)
    local cam = W.CurrentCamera
    if not cam then return nil end
    local vp = cam.ViewportSize
    local center = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
    local best, bestD = nil, math.huge
    for _, t in ipairs(list) do
        local want = (t.kind == "mob" and C.mobs) or (t.kind == "player" and C.players)
        if want and t.onScreen and t.dist <= C.maxDist then
            if t.centerDist <= C.fov and t.centerDist < bestD then
                best, bestD = t, t.centerDist
            end
        end
    end
    return best, center
end

local BIND = "hs_camera_aim"
local bound = false

local function applyAim(dt)
    if not C.aim or C.mode ~= "camera" then return end
    local t = T.current
    local cam = W.CurrentCamera
    if not t or not cam then return end
    local part = t.part
    if not part or not part.Parent then return end
    local cf = cam.CFrame
    local goal = CFrame.lookAt(cf.Position, part.Position)
    local a = math.clamp((dt or 0.016) * C.smooth, 0.08, 1)
    cam.CFrame = cf:Lerp(goal, a)
end

local function tryBind()
    if bound then return end
    local ok = pcall(function()
        R:BindToRenderStep(BIND, Enum.RenderPriority.Camera.Value + 1, applyAim)
    end)
    bound = ok
end

--=====================================================================
-- Loop
--=====================================================================
local conns = {}
local function bind(sig, fn)
    local c = sig:Connect(fn)
    conns[#conns + 1] = c
    return c
end

local statusClock = 0

bind(R.RenderStepped, function(dt)
    local cam = W.CurrentCamera
    if not cam then return end

    if tracerPart and tracerPart.Parent then
        tracerPart.CFrame = cam.CFrame * CFrame.new(0, -0.5, -1)
    end

    scanClock = scanClock + dt
    if scanClock >= scanEvery then
        scanClock = 0
        targets = project(collect())
    end

    renderEsp(targets)

    local t = pick(targets)
    T.current = t
    S.tgt = t

    if C.aim and C.mode == "camera" then
        if not bound then tryBind() end
        applyAim()
    end

    statusClock = statusClock + dt
    if statusClock >= 0.4 then
        statusClock = 0
        if not S.inst then install() end
        syncRing()
        Status.Text = string.format("tgt %d | aim %s | hit %d/%d | %s",
            #targets, C.mode, S.hits, S.calls, S.inst and "hooked" or "no hook")
        Status.TextColor3 = S.inst and COL.on or COL.dim
    end
end)

bind(LP.CharacterAdded, function()
    if not S.inst then install() end
end)

--=====================================================================
-- Panel build
--=====================================================================
section("AIMBOT")
mkToggle(Body, "Enable aimbot", C.aim, function(v) C.aim = v end)
mkToggle(Body, "Silent (no camera move)", C.mode == "silent", function(v)
    C.mode = v and "silent" or "camera"
    T.current = nil
end)
mkSlider(Body, "FOV radius", 30, 500, C.fov, function(v) C.fov = v end)
mkSlider(Body, "Smooth", 1, 40, C.smooth, function(v) C.smooth = v end)
mkSlider(Body, "Max distance", 100, 2000, C.maxDist, function(v) C.maxDist = v end)
mkToggle(Body, "Target mobs", C.mobs, function(v) C.mobs = v end)
mkToggle(Body, "Target players", C.players, function(v) C.players = v end)
mkToggle(Body, "Retarget shots in camera mode", C.assist, function(v) C.assist = v end)
mkToggle(Body, "Show FOV ring", C.ring, function(v) C.ring = v end)

section("ESP")
mkToggle(Body, "Enable ESP", C.esp, function(v) C.esp = v end)
mkToggle(Body, "Names", C.espName, function(v) C.espName = v end)
mkToggle(Body, "Distance", C.espDist, function(v) C.espDist = v end)
mkToggle(Body, "Health bar", C.espHp, function(v) C.espHp = v end)
mkToggle(Body, "Chams", C.espChams, function(v) C.espChams = v end)
mkToggle(Body, "Tracer lines", C.espLine, function(v) C.espLine = v end)
mkSlider(Body, "ESP max distance", 200, 3000, C.espMax, function(v) C.espMax = v end)
mkToggle(Body, "ESP mobs", C.espMobs, function(v) C.espMobs = v end)
mkToggle(Body, "ESP players", C.espPlayers, function(v) C.espPlayers = v end)

mkToggle(Body, "Open panel on load", true, function(v) setPanel(v) end)
setPanel(true)

--=====================================================================
-- Unload
--=====================================================================
local function unload()
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    conns = {}
    pcall(function() R:UnbindFromRenderStep(BIND) end)
    uninstall()
    for model, rec in pairs(esp) do destroy(rec); esp[model] = nil end
    if tracerPart then pcall(function() tracerPart:Destroy() end) end
    pcall(function() Gui:Destroy() end)
    _G.__hs = nil
end

_G.__hs = {
    unload = unload,
    config = C,
    stats = function() return S.hits, S.calls, S.inst end,
}
if getgenv then pcall(function() getgenv().__hs = _G.__hs end) end

task.spawn(function() pcall(install) end)
syncRing()
print("[hs] ready")
