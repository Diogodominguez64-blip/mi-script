--[[
    Hypershot - mobile menu: FOV / Aimbot / Silent Aim / ESP / DIAG   (v4)

    Single file, executor side. No Drawing API. One ScreenGui.

    ------------------------------------------------------------------
    WHY v1-v3 SHOWED "NOTHING WORKS, NOT EVEN ESP"
    ------------------------------------------------------------------
    1. alive() treated model:GetAttribute("Health") <= 0 as dead. Hypershot
       pools its mobs and keeps the attribute at 0 until the server assigns
       it, so the scan dropped EVERY mob. Empty list -> no ESP, no aim, no
       silent. That single line is the whole bug.
    2. The panel was built at load with Camera.ViewportSize, but the aim used
       WorldToScreenPoint while the ring used viewport space. Two systems,
       ~36px of vertical drift, and the FOV circle was never where the pick
       circle was.
    3. Silent aim hooked the wrong entry point. Hypershot weapons read
       GameUI.GameUIMod.GetMousePos, not Camera:ScreenPointToRay.
    4. Hooks called the original as f(self, ...) even when the game calls it
       with a dot, injecting an extra nil argument and breaking the caller.

    ------------------------------------------------------------------
    HOW HYPERSPOT ACTUALLY REPLICATES (confirmed)
    ------------------------------------------------------------------
    workspace.Mobs            folder of bot models, each with a "Head" BasePart
    Player.Character          same Head / HumanoidRootPart layout
    model:GetAttribute("Team") numeric; -1 = FFA (everyone hostile)
    Health is an attribute or a Humanoid; a 0 value is NOT proof of death.

    One coordinate system throughout: WorldToViewportPoint + IgnoreGuiInset
    = false + UserInputService:GetMouseLocation. All three agree.
]]

local __ok, __err = pcall(function()
    print("[hs] boot")

    local Players   = game:GetService("Players")
    local RunSvc    = game:GetService("RunService")
    local UIS       = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")
    local RS        = game:GetService("ReplicatedStorage")

    local LP = Players.LocalPlayer

    if _G.__hs and type(_G.__hs.unload) == "function" then pcall(_G.__hs.unload) end

    --=================================================================
    -- Config
    --=================================================================
    local C = {
        aim        = false,
        mode       = "silent",     -- "silent" | "camera"
        assist     = true,         -- also retarget shots while in camera mode
        fov        = 180,          -- radius, viewport pixels
        fovMode    = "center",     -- "center" | "cursor"
        smooth     = 16,
        maxDist    = 800,
        pred       = 0,            -- ms of velocity lead
        wallCheck  = false,
        teamCheck  = false,        -- off: -1 means FFA, everyone hostile
        targetsMob = true,
        targetsPlr = true,
        deepScan   = true,
        hold       = false,

        pMouse     = true,         -- GameUIMod.GetMousePos   <- the real path
        pLoc       = true,         -- UIS:GetMouseLocation    fallback
        pNet       = true,         -- remote argument rewrite  fallback
        pBlind     = false,        -- rewrite when getnamecallmethod is dead

        esp        = true,
        espBox     = true,
        espName    = true,
        espDist    = true,
        espHp      = true,
        espChams   = false,
        espTracer  = true,
        espMax     = 1500,
        espMobs    = true,
        espPlrs    = true,

        ring       = true,
        lockbox    = true,
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

    --=================================================================
    -- Root: first host that accepts the gui wins, never fatal
    --=================================================================
    local function makeGui()
        local Gui = Instance.new("ScreenGui")
        Gui.Name = "HS_Menu"
        Gui.ResetOnSpawn = false
        Gui.IgnoreGuiInset = false   -- gui space == viewport space
        Gui.DisplayOrder = 9999
        Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        pcall(function() if syn and syn.protect_gui then syn.protect_gui(Gui) end end)

        local hosts = {
            function() return gethui and gethui() end,
            function() return game:GetService("CoreGui") end,
            function() return LP:WaitForChild("PlayerGui", 10) end,
        }
        for _, get in ipairs(hosts) do
            local okH, h = pcall(get)
            if okH and h then
                if pcall(function() Gui.Parent = h end) then return Gui end
            end
        end
        return nil
    end

    local Gui = makeGui()
    if not Gui then error("no gui host (gethui / CoreGui / PlayerGui all refused)") end

    --=================================================================
    -- Widgets
    --=================================================================
    local function mkToggle(parent, label, init, cb)
        local b = new("TextButton", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = COL.row,
            AutoButtonColor = false,
            Text = "",
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
            Size = UDim2.new(1, -20, 0, 6),
            Position = UDim2.new(0, 10, 1, -14),
            BackgroundColor3 = COL.off,
            Parent = row,
        })
        corner(track, 3)
        local fill = new("Frame", {
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = COL.on,
            Parent = track,
        })
        corner(fill, 3)
        local value = math.clamp(init, min, max)
        local function paint()
            fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            cap.Text = label .. "  " .. tostring(math.floor(value))
        end
        local function setFromX(px)
            local w = track.AbsoluteSize.X
            if w <= 0 then return end
            local a = math.clamp((px - track.AbsolutePosition.X) / w, 0, 1)
            local v = math.floor(min + (max - min) * a + 0.5)
            if v == value then return end
            value = v
            paint()
            cb(value)
        end
        local drag = false
        track.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                drag = true
                setFromX(i.Position.X)
            end
        end)
        track.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                drag = false
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if not drag then return end
            if i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch then
                setFromX(i.Position.X)
            end
        end)
        paint()
        return row
    end

    local function mkButton(parent, label, cb)
        local b = new("TextButton", {
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundColor3 = COL.row,
            AutoButtonColor = false,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextColor3 = COL.txt,
            Text = label,
            Parent = parent,
        })
        corner(b, 5)
        b.MouseButton1Click:Connect(function() cb(b) end)
        return b
    end

    --=================================================================
    -- Panel
    --=================================================================
    local Btn = new("TextButton", {
        Size = UDim2.new(0, 44, 0, 44),
        Position = UDim2.new(0, 12, 0.5, -22),
        BackgroundColor3 = COL.bg,
        Text = "HS",
        TextColor3 = COL.txt,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        Parent = Gui,
    })
    corner(Btn, 22)
    stroke(Btn, COL.on, 1.5)

    local VPY = (Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize.Y) or 640
    local PANEL_H = math.clamp(VPY - 60, 280, 640)

    local Panel = new("Frame", {
        Size = UDim2.new(0, 268, 0, PANEL_H),
        Position = UDim2.new(0, 64, 0.5, -PANEL_H * 0.5),
        BackgroundColor3 = COL.bg,
        Visible = true,
        Parent = Gui,
    })
    corner(Panel, 10)
    stroke(Panel, Color3.fromRGB(60, 60, 72), 1)

    local Head = new("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
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
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -30, 0.5, -12),
        BackgroundColor3 = COL.bg,
        Text = "x",
        TextColor3 = COL.dim,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        Parent = Head,
    })
    corner(CloseBtn, 6)

    local Status = new("TextLabel", {
        Size = UDim2.new(1, -14, 0, 34),
        Position = UDim2.new(0, 7, 1, -36),
        BackgroundColor3 = Color3.fromRGB(22, 22, 28),
        BackgroundTransparency = 0,
        Font = Enum.Font.Code,
        TextSize = 9,
        TextColor3 = COL.dim,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Text = "boot",
        Parent = Panel,
    })
    corner(Status, 5)

    local Body = new("ScrollingFrame", {
        Size = UDim2.new(1, -14, 1, -78),
        Position = UDim2.new(0, 7, 0, 38),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = Panel,
    })
    new("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, Body)

    local function section(title)
        return new("TextLabel", {
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextColor3 = COL.dim,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = title,
            Parent = Body,
        })
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
        UIS.InputChanged:Connect(function(i)
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

    --=================================================================
    -- Overlay
    --=================================================================
    local Ring = new("Frame", {
        Size = UDim2.new(0, 300, 0, 300),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = Gui,
    })
    corner(Ring, 1000)
    local RingStroke = stroke(Ring, Color3.new(1, 1, 1), 1.5, 0.35)

    local Cross = new("Frame", {
        Size = UDim2.new(0, 4, 0, 4),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0.2,
        Visible = false,
        Parent = Gui,
    })
    corner(Cross, 2)

    local Lock = new("Frame", {
        Size = UDim2.new(0, 30, 0, 30),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = Gui,
    })
    corner(Lock, 3)
    local LockStroke = stroke(Lock, COL.on, 1.5, 0.1)

    local AimBtn = new("TextButton", {
        Size = UDim2.new(0, 44, 0, 44),
        Position = UDim2.new(0, 12, 0.5, 26),
        BackgroundColor3 = COL.bg,
        Text = "AIM",
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        TextColor3 = COL.dim,
        AutoButtonColor = false,
        Visible = false,
        Parent = Gui,
    })
    corner(AimBtn, 22)
    stroke(AimBtn, COL.off, 1.5)

    --=================================================================
    -- Entity helpers
    --=================================================================
    local function partNamed(model, name)
        if not model then return nil end
        local d = model:FindFirstChild(name)
        if d and d:IsA("BasePart") then return d end
        return nil
    end

    local function firstBasePart(model)
        local pp = model.PrimaryPart
        if pp and pp:IsA("BasePart") then return pp end
        local ok, kids = pcall(function() return model:GetChildren() end)
        if ok then
            for _, d in ipairs(kids) do
                if d:IsA("BasePart") then return d end
            end
        end
        local ok2, desc = pcall(function() return model:GetDescendants() end)
        if ok2 then
            for _, d in ipairs(desc) do
                if d:IsA("BasePart") then return d end
            end
        end
        return nil
    end

    local function teamOf(inst)
        if not inst then return nil end
        local ok, v = pcall(function() return inst:GetAttribute("Team") end)
        if ok and typeof(v) == "number" then return v end
        return nil
    end

    local GlbStf
    do
        pcall(function()
            local mods = RS:FindFirstChild("Modules")
            local gs = mods and mods:FindFirstChild("GlobalStuff")
            if gs and gs:IsA("ModuleScript") then
                local ok, t = pcall(require, gs)
                if ok and type(t) == "table" and type(t.SameTeam) == "function" then
                    GlbStf = t
                end
            end
        end)
    end

    local function sameTeamOf(model, plr, mine)
        if GlbStf then
            local ok, r = pcall(GlbStf.SameTeam, GlbStf, LP, model)
            if ok and typeof(r) == "boolean" then return r end
            if plr then
                ok, r = pcall(GlbStf.SameTeam, GlbStf, LP, plr)
                if ok and typeof(r) == "boolean" then return r end
            end
        end
        local team = teamOf(model)
        if team == nil and plr then team = teamOf(plr) end
        if typeof(mine) == "number" and typeof(team) == "number" then
            if mine == -1 or team == -1 then return false end
            return team == mine
        end
        return false
    end

    local function healthOf(model)
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
            local okh, hp = pcall(function() return hum.Health end)
            local okm, mx = pcall(function() return hum.MaxHealth end)
            if okh and okm then return hp, math.max(mx, 1) end
        end
        return nil, nil
    end

    -- The v3 killer lived here. A zero or missing health value is NOT proof
    -- of death in this game: mobs are pooled and the attribute is cleared
    -- between waves. Only an explicit flag, an explicit zero health with a
    -- transparent root, or a missing parent disqualifies an entity.
    local function isAlive(model, root)
        if not model or not model.Parent then return false end
        if model:GetAttribute("Dead") == true then return false end
        if model:GetAttribute("Alive") == false then return false end
        local h = healthOf(model)
        if typeof(h) == "number" and h > 0 then return true end
        if root then
            local tr = root.Transparency
            if typeof(tr) == "number" and tr < 0.98 then return true end
        end
        if model:FindFirstChildOfClass("Humanoid") then return true end
        return h == nil
    end

    -- GetBoundingBox is the single most expensive call in the scan loop and it
    -- was running 30x/second per entity. One second of staleness is invisible.
    local sizeCache = {}
    local sizeCacheN = 0

    local function modelSize(model)
        local now = os.clock()
        local c = sizeCache[model]
        if c and now - c.t < 1 then return c.v end
        local ok, _, size = pcall(function() return model:GetBoundingBox() end)
        if not ok or typeof(size) ~= "Vector3" or size.Magnitude <= 0 then
            size = Vector3.new(3, 5, 3)
        end
        if not c then
            sizeCacheN = sizeCacheN + 1
            if sizeCacheN > 500 then
                sizeCache, sizeCacheN = {}, 0
            end
        end
        sizeCache[model] = { t = now, v = size }
        return size
    end

    local function isPlayerChar(model)
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl.Character == model then return true end
        end
        return false
    end

    --=================================================================
    -- Target scan
    --=================================================================
    local MAXT = 120
    local SCAN = 1 / 30

    local targets  = {}
    local lastScan = 0
    local deepCache, deepNext = {}, 0
    local mobHint = "-"

    -- Mobs is the confirmed name, but a rename or a second game mode can move
    -- the folder. Match the confirmed name first, then a short hint list, so a
    -- renamed folder does not silently produce an empty target list again.
    local MOB_HINTS = {
        "mobs", "mob", "enemies", "enemy", "bots", "bot",
        "dummies", "dummy", "npcs", "npc", "targets", "target",
    }
    local mobFolderCache

    local function findMobFolder()
        if mobFolderCache and mobFolderCache.Parent == Workspace then
            return mobFolderCache
        end
        mobFolderCache = nil
        local ok, kids = pcall(function() return Workspace:GetChildren() end)
        if not ok then return nil end

        local direct = Workspace:FindFirstChild("Mobs")
        if direct then mobFolderCache = direct return direct end

        for _, hint in ipairs(MOB_HINTS) do
            for _, ch in ipairs(kids) do
                if string.lower(ch.Name) == hint then
                    mobFolderCache = ch
                    return ch
                end
            end
        end
        for _, hint in ipairs(MOB_HINTS) do
            for _, ch in ipairs(kids) do
                if string.find(string.lower(ch.Name), hint, 1, true) then
                    mobFolderCache = ch
                    return ch
                end
            end
        end
        return nil
    end

    local function describe(model, kind, plr, mine)
        if not model or not model.Parent then return nil end
        local head  = partNamed(model, "Head")
        local hrp   = partNamed(model, "HumanoidRootPart")
        local torso = partNamed(model, "UpperTorso") or partNamed(model, "Torso")
        local root  = head or hrp or torso or firstBasePart(model)
        if not root then return nil end
        if not isAlive(model, root) then return nil end

        local aimPart = head or torso or hrp or root
        local cam = Workspace.CurrentCamera
        if not cam then return nil end

        local dist = (cam.CFrame.Position - root.Position).Magnitude
        local sp, on = cam:WorldToViewportPoint(aimPart.Position)
        local size = modelSize(model)
        local health, maxHealth = healthOf(model)

        return {
            model     = model,
            kind      = kind,
            player    = plr,
            head      = head,
            root      = root,
            aimPart   = aimPart,
            screen    = Vector2.new(sp.X, sp.Y),
            onScreen  = (on and sp.Z > 0) or false,
            dist      = dist,
            height    = math.clamp(size.Y, 1.5, 28),
            width     = math.clamp(math.max(size.X, size.Z), 1, 18),
            health    = health,
            maxHealth = maxHealth,
            sameTeam  = C.teamCheck and sameTeamOf(model, plr, mine) or false,
        }
    end

    local function myTeam()
        local t = teamOf(LP)
        return t
    end

    local function scan()
        local out, seen = {}, {}
        local mine = myTeam()

        local function add(model, kind, plr)
            if #out >= MAXT or seen[model] then return end
            local ok, t = pcall(describe, model, kind, plr, mine)
            if ok and t then
                seen[model] = true
                out[#out + 1] = t
            end
        end

        local wantMobs = C.targetsMob or C.espMobs
        local wantPlrs = C.targetsPlr or C.espPlrs

        if wantMobs then
            local folder = findMobFolder()
            if folder then
                local kids = folder:GetChildren()
                for _, m in ipairs(kids) do
                    if #out >= MAXT then break end
                    if m:IsA("Model") then add(m, "mob", nil) end
                end
                mobHint = folder.Name .. " x" .. #kids
            else
                mobHint = "no mob folder"
            end
        end

        if wantPlrs then
            for _, pl in ipairs(Players:GetPlayers()) do
                if #out >= MAXT then break end
                if pl ~= LP and pl.Character then
                    add(pl.Character, "player", pl)
                end
            end
        end

        if C.deepScan then
            local now = os.clock()
            if now >= deepNext then
                deepNext = now + 3
                local found, budget = {}, 900
                local queue, head = { Workspace }, 1
                while head <= #queue and budget > 0 do
                    local node = queue[head]
                    head = head + 1
                    budget = budget - 1
                    local ok, kids = pcall(function() return node:GetChildren() end)
                    if ok then
                        for _, ch in ipairs(kids) do
                            if ch:IsA("Model") then
                                local h = partNamed(ch, "Head")
                                if h and ch ~= LP.Character then
                                    found[#found + 1] = ch
                                    if #found >= MAXT * 2 then head = #queue + 1 break end
                                elseif #queue < 400 then
                                    -- characters can be nested inside map models
                                    queue[#queue + 1] = ch
                                end
                            elseif ch:IsA("Folder") then
                                queue[#queue + 1] = ch
                            end
                        end
                    end
                end
                deepCache = found
            end
            for _, m in ipairs(deepCache) do
                if #out >= MAXT then break end
                if m.Parent then
                    local owner = Players:GetPlayerFromCharacter(m)
                    if owner and owner ~= LP then
                        add(m, "player", owner)
                    elseif wantMobs then
                        add(m, "mob", nil)
                    end
                end
            end
        end

        return out
    end

    local function scanThrottled()
        local now = os.clock()
        if now - lastScan >= SCAN then
            lastScan = now
            targets = scan()
        end
        return targets
    end

    --=================================================================
    -- Aim state
    --=================================================================
    local S = {
        target = nil,
        busy = false,          -- hook reentrancy guard, never leaves true
        calls = { mouse = 0, loc = 0, net = 0 },
        hits  = { mouse = 0, loc = 0, net = 0 },
        lastType = "-",
        lastSrc = "-",
        gnmDead = false,
        log = {},
        order = {},
        counts = { total = 0, fov = 0 },
    }

    local holdAim = false

    local function fovOrigin()
        local cam = Workspace.CurrentCamera
        local vp = (cam and cam.ViewportSize) or Vector2.new(1280, 720)
        if C.fovMode == "cursor" then
            local ok, p = pcall(function() return UIS:GetMouseLocation() end)
            if ok and typeof(p) == "Vector2" then return p end
        end
        return Vector2.new(vp.X * 0.5, vp.Y * 0.5)
    end

    local function aimPartOf(t)
        local p = t and t.aimPart
        if p and p.Parent then return p end
        return nil
    end

    local function aimPoint()
        local p = aimPartOf(S.target)
        if not p then return nil end
        if C.pred > 0 then
            local ok, v = pcall(function() return p.AssemblyLinearVelocity end)
            if ok and typeof(v) == "Vector3" then
                return p.Position + v * (C.pred / 1000)
            end
        end
        return p.Position
    end

    local function shotsArmed()
        if not C.aim then return false end
        if C.hold and not holdAim then return false end
        if not S.target then return false end
        if C.mode == "silent" then return true end
        return C.assist
    end

    --=================================================================
    -- Silent aim: GameUIMod.GetMousePos is what the weapon reads
    --=================================================================
    local Silent = { module = nil, original = nil, hook = nil, installed = false, status = "off" }
    local Loc    = { original = nil, hook = nil, installed = false }

    -- GameUI is not always under PlayerGui: executors that protect the gui,
    -- or the game reparenting it, put it in CoreGui. Search every plausible
    -- root before declaring the silent path unavailable.
    local function findGameUIModule()
        local roots = {}
        local pg = LP:FindFirstChild("PlayerGui")
        if pg then roots[#roots + 1] = pg end
        pcall(function()
            local cg = game:GetService("CoreGui")
            if cg then roots[#roots + 1] = cg end
        end)
        pcall(function()
            local rs = RS
            if rs then roots[#roots + 1] = rs end
        end)

        for _, root in ipairs(roots) do
            local gui = root:FindFirstChild("GameUI")
            if gui then
                local m = gui:FindFirstChild("GameUIMod")
                if m and m:IsA("ModuleScript") then return m end
            end
        end
        for _, root in ipairs(roots) do
            local ok, desc = pcall(function() return root:GetDescendants() end)
            if ok then
                local fallback
                for _, d in ipairs(desc) do
                    if d:IsA("ModuleScript") then
                        if d.Name == "GameUIMod" then return d end
                        if not fallback and d.Name == "GameUI" then fallback = d end
                    end
                end
                if fallback then return fallback end
            end
        end
        return nil
    end

    -- Contract-adaptive: a Vector3 return is a world point, a Vector2 return
    -- is a screen point. Anything else falls through untouched.
    local function retarget(a, b, c)
        local p = aimPartOf(S.target)
        if not p then return nil end
        local k = typeof(a)
        if k == "Vector3" then return p.Position, b, c end
        if k == "Vector2" then
            local cam = Workspace.CurrentCamera
            if not cam then return nil end
            local sp, on = cam:WorldToViewportPoint(p.Position)
            if not on then return nil end
            return Vector2.new(sp.X, sp.Y), b, c
        end
        return nil
    end

    -- Pass-through uses '...' so a dot-call never gains a phantom self arg.
    -- v3 called original(self, ...) and corrupted every non-method call.
    local function mouseHook(...)
        local a, b, c = Silent.original(...)
        S.calls.mouse = S.calls.mouse + 1
        if typeof(a) == "Vector3" or typeof(a) == "Vector2" then
            S.lastType = typeof(a)
        end
        local info = debug.info or debug.getinfo
        if type(info) == "function" then
            local ok, src = pcall(info, 2, "s")
            if ok and type(src) == "string" and src ~= "" then
                S.lastSrc = src:sub(-40)
            end
        end
        if not S.busy and shotsArmed() then
            S.busy = true
            local ok, ra, rb, rc = pcall(retarget, a, b, c)
            S.busy = false
            if ok and ra then
                S.hits.mouse = S.hits.mouse + 1
                return ra, rb, rc
            end
        end
        return a, b, c
    end

    local function locationHook(...)
        local a, b, c = Loc.original(...)
        S.calls.loc = S.calls.loc + 1
        if not S.busy and shotsArmed() then
            S.busy = true
            local ok, ra, rb, rc = pcall(retarget, a, b, c)
            S.busy = false
            if ok and ra then
                S.hits.loc = S.hits.loc + 1
                return ra, rb, rc
            end
        end
        return a, b, c
    end

    local function installSilent()
        if not C.pMouse then Silent.status = "path off" return false end
        if Silent.installed and Silent.original then return true end
        local mod = findGameUIModule()
        if not mod then Silent.status = "no GameUIMod" return false end
        local ok, tbl = pcall(require, mod)
        if not ok or type(tbl) ~= "table" then Silent.status = "require failed" return false end
        local orig = tbl.GetMousePos
        if type(orig) ~= "function" then Silent.status = "no GetMousePos" return false end

        Silent.module = tbl
        if type(hookfunction) == "function" then
            local okh, ret = pcall(hookfunction, orig, mouseHook)
            if okh and type(ret) == "function" then
                Silent.original = ret
                Silent.hook = mouseHook
                Silent.installed = true
                Silent.status = "hooked fn"
                return true
            end
        end
        Silent.original = orig
        if pcall(function() tbl.GetMousePos = mouseHook end) then
            Silent.hook = mouseHook
            Silent.installed = true
            Silent.status = "hooked tbl"
            return true
        end
        Silent.original = nil
        Silent.status = "table locked"
        return false
    end

    local function installLoc()
        if not C.pLoc then return false end
        if Loc.installed then return true end
        if type(hookfunction) ~= "function" then return false end
        local ok, orig = pcall(function() return UIS.GetMouseLocation end)
        if not ok or type(orig) ~= "function" then return false end
        local okh, ret = pcall(hookfunction, orig, locationHook)
        if not okh or type(ret) ~= "function" then return false end
        Loc.original = ret
        Loc.hook = locationHook
        Loc.installed = true
        return true
    end

    local function uninstallSilent()
        if Silent.hook and type(restorefunction) == "function" then
            pcall(restorefunction, Silent.hook)
        end
        if Silent.module and Silent.module.GetMousePos == Silent.hook and Silent.original then
            pcall(function() Silent.module.GetMousePos = Silent.original end)
        end
        if Loc.hook and type(restorefunction) == "function" then
            pcall(restorefunction, Loc.hook)
        end
        Silent.installed, Silent.original, Silent.hook, Silent.module = false, nil, nil, nil
        Silent.status = "off"
        Loc.installed, Loc.original, Loc.hook = false, nil, nil
    end

    --=================================================================
    -- Remote argument rewrite (fallback path)
    --=================================================================
    local function logShot(name, args, n)
        local parts, shot = {}, false
        for i = 1, n do
            local tv = typeof(args[i])
            parts[i] = tv
            if tv == "CFrame" then
                shot = true
            elseif tv == "Vector3" then
                local m = args[i].Magnitude
                if m > 0.5 and m < 1.5 then shot = true end
            end
        end
        local sig = name .. "(" .. table.concat(parts, ",") .. ")"
        local rec = S.log[sig]
        if not rec then
            rec = { n = 0, shot = shot }
            S.log[sig] = rec
            S.order[#S.order + 1] = sig
            if #S.order > 40 then table.remove(S.order, 1) end
        end
        rec.n = rec.n + 1
        if shot then rec.shot = true end
    end

    local function retargetArgs(args, n)
        local hp = aimPoint()
        if not hp then return nil end
        local cam = Workspace.CurrentCamera
        local eye = cam and cam.CFrame.Position or nil
        local changed = 0

        for i = 1, n do
            if changed >= 1 then break end
            local v = args[i]
            local tv = typeof(v)
            if tv == "Vector3" then
                local m = v.Magnitude
                if m > 0.5 and m < 1.5 and eye then
                    local d = hp - eye
                    if d.Magnitude > 0.01 then
                        args[i] = d.Unit
                        changed = changed + 1
                    end
                elseif eye then
                    local d = (v - eye).Magnitude
                    if d > 4 and d <= C.maxDist + 250 then
                        args[i] = hp
                        changed = changed + 1
                    end
                end
            elseif tv == "CFrame" then
                args[i] = CFrame.lookAt(v.Position, hp)
                changed = changed + 1
            end
        end
        if changed > 0 then return args, n end
        return nil
    end

    local SHOT_WORD = { "shoot", "fire", "hit", "damage", "attack", "shot", "swing",
                        "cast", "spell", "combat", "bullet", "dmg" }

    local function shotish(name)
        local ln = string.lower(tostring(name))
        for _, k in ipairs(SHOT_WORD) do
            if string.find(ln, k, 1, true) then return true end
        end
        return false
    end

    local WANT = { FireServer = true, InvokeServer = true }

    local function retargetRemote(self, args, n)
        if n < 1 or n > 4 then return nil end
        local v = args[1]
        local tv = typeof(v)
        if tv == "CFrame" then return args, n end
        if tv == "Vector3" then
            local m = v.Magnitude
            if (m > 0.5 and m < 1.5) then return args, n end
            local cam = Workspace.CurrentCamera
            if cam and (v - cam.CFrame.Position).Magnitude <= C.maxDist + 250 then
                return args, n
            end
        end
        return nil
    end

    local function makeDetour(old, gnm)
        local unpackFn = table.unpack or unpack
        return function(self, ...)
            if S.busy then return old(self, ...) end

            local m
            local okm, got = pcall(gnm)
            if okm then m = got end
            if m == nil then S.gnmDead = true end
            if m and not WANT[m] then return old(self, ...) end

            local n = select("#", ...)
            local args = { ... }

            if m == nil then
                if not (C.pBlind and C.pNet and shotsArmed()) then return old(self, ...) end
                if not shotish(self.Name) then return old(self, ...) end
                local na, nn = retargetRemote(self, args, n)
                if not na then return old(self, ...) end
                S.calls.net = S.calls.net + 1
                S.busy = true
                local okr, ra, rn = pcall(retargetArgs, na, nn)
                S.busy = false
                if not (okr and ra) then return old(self, ...) end
                S.hits.net = S.hits.net + 1
                return old(self, unpackFn(ra, 1, rn))
            end

            pcall(logShot, tostring(self.Name), args, n)
            if not (C.pNet and shotsArmed()) then return old(self, ...) end

            S.calls.net = S.calls.net + 1
            S.busy = true
            local okr, na, nn = pcall(retargetArgs, args, n)
            S.busy = false
            if not (okr and na) then return old(self, ...) end
            S.hits.net = S.hits.net + 1
            return old(self, unpackFn(na, 1, nn))
        end
    end

    local NC = { old = nil, detour = nil, mt = nil, kind = nil }

    local function installNamecall()
        if not C.pNet then return false end
        if NC.detour then return true end
        local gnm = getnamecallmethod or get_namecall_method
        if type(gnm) ~= "function" then return false end

        if type(hookmetamethod) == "function" then
            local detour
            local wrapper = function(self, ...)
                if detour then return detour(self, ...) end
                return NC.old and NC.old(self, ...)
            end
            local okh, orig = pcall(hookmetamethod, game, "__namecall", wrapper)
            if okh and type(orig) == "function" then
                NC.old = orig
                detour = makeDetour(orig, gnm)
                NC.detour = detour
                NC.kind = "hmm"
                return true
            end
        end

        if type(getrawmetatable) ~= "function" then return false end
        local ok, mt = pcall(getrawmetatable, game)
        if not ok or type(mt) ~= "table" then return false end
        local old = mt.__namecall
        if type(old) ~= "function" then return false end
        local detour = makeDetour(old, gnm)
        local okw = pcall(function()
            if type(setreadonly) == "function" then setreadonly(mt, false) end
            mt.__namecall = detour
            if type(setreadonly) == "function" then setreadonly(mt, true) end
        end)
        if not okw then
            pcall(function() mt.__namecall = old end)
            return false
        end
        NC.old, NC.detour, NC.mt, NC.kind = old, detour, mt, "mt"
        return true
    end

    local function uninstallNamecall()
        if not NC.detour then return end
        local old = NC.old
        NC.detour, NC.old = nil, nil
        if NC.kind == "hmm" and type(hookmetamethod) == "function" then
            pcall(hookmetamethod, game, "__namecall", old)
        elseif NC.mt then
            pcall(function()
                if type(setreadonly) == "function" then setreadonly(NC.mt, false) end
                NC.mt.__namecall = old
                if type(setreadonly) == "function" then setreadonly(NC.mt, true) end
            end)
        end
        NC.mt, NC.kind = nil, nil
    end

    --=================================================================
    -- ESP (no ScreenGui, no Drawing)
    --=================================================================
    local esp = {}
    local tracer, tracerAtt

    local function ensureTracer()
        local cam = Workspace.CurrentCamera
        if not cam then return false end
        if tracer and tracer.Parent then
            if tracer.Parent ~= cam then pcall(function() tracer.Parent = cam end) end
            return true
        end
        tracer = new("Part", {
            Name = "hs_tracer",
            Size = Vector3.new(0.05, 0.05, 0.05),
            Transparency = 1,
            Anchored = true,
            CanCollide = false,
            CanQuery = false,
            CanTouch = false,
            Massless = true,
            CastShadow = false,
            Parent = cam,
        })
        tracerAtt = new("Attachment", { Name = "hs_tracer_att", Parent = tracer })
        return true
    end

    local function colourFor(t)
        if t.kind == "mob" then return COL.mob end
        if t.sameTeam then return COL.esp end
        return COL.enemy
    end

    local function buildRecord(t)
        local anchor = t.head or t.root
        if not anchor then return nil end

        local bb = new("BillboardGui", {
            Name = "hs_esp",
            AlwaysOnTop = true,
            LightInfluence = 0,
            ResetOnSpawn = false,
            MaxDistance = C.espMax,
            Size = UDim2.new(t.width + 0.8, 0, t.height + 0.6, 0),
            StudsOffsetWorldSpace = Vector3.new(0, t.height * 0.15, 0),
            Adornee = anchor,
            Parent = anchor,
        })
        local box = new("Frame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = bb,
        })
        local bs = stroke(box, COL.esp, 1.2, 0.15)

        local nameLbl = new("TextLabel", {
            Size = UDim2.new(1, 60, 0, 14),
            Position = UDim2.new(0.5, -30, 0, -16),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextColor3 = COL.esp,
            TextStrokeTransparency = 0.4,
            Text = t.player and t.player.Name or t.model.Name,
            Parent = bb,
        })
        local distLbl = new("TextLabel", {
            Size = UDim2.new(1, 60, 0, 12),
            Position = UDim2.new(0.5, -30, 1, 2),
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            TextSize = 10,
            TextColor3 = COL.dim,
            TextStrokeTransparency = 0.4,
            Text = "",
            Parent = bb,
        })
        local hpBg = new("Frame", {
            Size = UDim2.new(0, 3, 1, 0),
            Position = UDim2.new(0, -7, 0, 0),
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 0.45,
            BorderSizePixel = 0,
            Parent = bb,
        })
        local hpFill = new("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.fromRGB(0, 230, 110),
            BorderSizePixel = 0,
            Parent = hpBg,
        })
        local hl = new("Highlight", {
            Name = "hs_cham",
            FillColor = COL.esp,
            FillTransparency = 0.6,
            OutlineColor = COL.esp,
            OutlineTransparency = 0.2,
            DepthMode = Enum.HighlightDepthMode.Occluded,
            Enabled = false,
            Adornee = t.model,
            Parent = t.model,
        })

        local beam, beamAtt
        if ensureTracer() then
            beamAtt = new("Attachment", { Name = "hs_beam_att", Parent = anchor })
            beam = new("Beam", {
                Name = "hs_tracer_beam",
                Attachment0 = tracerAtt,
                Attachment1 = beamAtt,
                Color = ColorSequence.new(COL.esp),
                Transparency = NumberSequence.new(0.45),
                Width0 = 1.1,
                Width1 = 0.3,
                FaceCamera = true,
                LightEmission = 0.8,
                LightInfluence = 0,
                Segments = 1,
                Enabled = false,
                Parent = tracer,
            })
        end

        return { billboard = bb, box = box, stroke = bs, name = nameLbl,
                 dist = distLbl, hpBg = hpBg, hpFill = hpFill,
                 cham = hl, beam = beam, beamAtt = beamAtt }
    end

    local function destroyRecord(rec)
        for _, k in ipairs({ "beam", "beamAtt", "cham", "billboard" }) do
            if rec[k] then pcall(function() rec[k]:Destroy() end) end
        end
    end

    local function renderEsp(list)
        local keep = {}
        for _, t in ipairs(list) do
            local show = C.esp
                and t.dist <= C.espMax
                and ((t.kind == "mob" and C.espMobs) or (t.kind == "player" and C.espPlrs))

            if show then
                keep[t.model] = true
                local rec = esp[t.model]
                if not rec or not rec.billboard or not rec.billboard.Parent then
                    if rec then destroyRecord(rec) end
                    local okb, built = pcall(buildRecord, t)
                    rec = okb and built or nil
                    esp[t.model] = rec
                end
                if rec then
                    local col = colourFor(t)
                    rec.billboard.Enabled = true
                    rec.billboard.MaxDistance = C.espMax
                    rec.box.Visible = C.espBox
                    rec.stroke.Color = col
                    rec.stroke.Transparency = 0.15
                    rec.name.Visible = C.espName
                    rec.name.TextColor3 = col
                    rec.name.Text = t.player and t.player.Name or t.model.Name
                    rec.dist.Visible = C.espDist
                    rec.dist.Text = string.format("%d m", math.floor(t.dist))
                    if C.espHp and t.health and t.maxHealth and t.maxHealth > 0 then
                        local frac = math.clamp(t.health / t.maxHealth, 0, 1)
                        rec.hpBg.Visible = true
                        rec.hpFill.Size = UDim2.fromScale(1, frac)
                        rec.hpFill.BackgroundColor3 = Color3.fromRGB(
                            math.floor(255 * (1 - frac)), math.floor(230 * frac), 110)
                    else
                        rec.hpBg.Visible = false
                    end
                    rec.cham.Enabled = C.espChams
                    rec.cham.FillColor = col
                    rec.cham.OutlineColor = col
                    if rec.beam then
                        local want = C.espTracer and t.onScreen
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
            if not keep[model] or not model.Parent then
                destroyRecord(rec)
                esp[model] = nil
            end
        end
    end

    --=================================================================
    -- Aimbot
    --=================================================================
    local Aim = { current = nil }

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.IgnoreWater = true
    rayParams.RespectCanCollide = true

    local function canSee(t)
        local cam = Workspace.CurrentCamera
        if not cam then return false end
        local filter = { cam }
        if LP.Character then filter[#filter + 1] = LP.Character end
        if tracer then filter[#filter + 1] = tracer end
        rayParams.FilterDescendantsInstances = filter
        local ok, hit = pcall(function()
            local origin = cam.CFrame.Position
            return Workspace:Raycast(origin, t.aimPart.Position - origin, rayParams)
        end)
        if not ok or not hit then return true end
        return hit.Instance:IsDescendantOf(t.model)
    end

    local function pickTarget(list)
        local origin = fovOrigin()
        local best, bestD = nil, math.huge
        local seenCount, fovCount = 0, 0

        for _, t in ipairs(list) do
            seenCount = seenCount + 1
            local wanted = (t.kind == "mob" and C.targetsMob)
                        or (t.kind == "player" and C.targetsPlr)
            if wanted and t.onScreen and t.dist <= C.maxDist then
                if not (C.teamCheck and t.sameTeam) then
                    local d = (t.screen - origin).Magnitude
                    if d <= C.fov then
                        fovCount = fovCount + 1
                        if d < bestD and (not C.wallCheck or canSee(t)) then
                            best, bestD = t, d
                        end
                    end
                end
            end
        end
        S.counts = { total = seenCount, fov = fovCount }
        return best
    end

    local AIM_BIND = "hs_camera_aim"

    local function applyCameraAim(dt)
        if not C.aim or C.mode ~= "camera" then return end
        if C.hold and not holdAim then return end
        local t = Aim.current
        if not t or not t.aimPart or not t.aimPart.Parent then return end
        local cam = Workspace.CurrentCamera
        if not cam then return end
        local hp = aimPoint()
        if not hp then return end
        local cf = cam.CFrame
        local goal = CFrame.lookAt(cf.Position, hp)
        local a = math.clamp((dt or 0.016) * C.smooth, 0.08, 1)
        cam.CFrame = cf:Lerp(goal, a)
    end

    local camBound = false
    local function bindCamera()
        if camBound then return end
        camBound = pcall(function()
            RunSvc:BindToRenderStep(AIM_BIND, Enum.RenderPriority.Camera.Value + 1, applyCameraAim)
        end)
    end

    --=================================================================
    -- Loop
    --=================================================================
    local conns = {}
    local function bind(sig, fn)
        local c = sig:Connect(fn)
        conns[#conns + 1] = c
        return c
    end

    local statusClock, statusIdx = 0, 0
    local lastErr
    local espCount

    local function overlay()
        local origin = fovOrigin()
        local locked = S.target ~= nil and shotsArmed()

        Ring.Size = UDim2.fromOffset(C.fov * 2, C.fov * 2)
        Ring.Position = UDim2.fromOffset(origin.X, origin.Y)
        Ring.Visible = C.ring
        RingStroke.Color = locked and COL.on or Color3.new(1, 1, 1)
        RingStroke.Transparency = locked and 0.1 or 0.35

        Cross.Position = UDim2.fromOffset(origin.X, origin.Y)
        Cross.Visible = C.ring

        local showLock = C.lockbox and locked and S.target ~= nil
        Lock.Visible = showLock
        if showLock then
            local sp = S.target.screen
            Lock.Position = UDim2.fromOffset(sp.X, sp.Y)
            LockStroke.Color = COL.on
        end

        AimBtn.BackgroundColor3 = holdAim and COL.on or COL.bg
        AimBtn.TextColor3 = holdAim and Color3.new(0, 0, 0) or COL.dim
    end

    local function blockReason()
        local n = S.counts and S.counts.total or 0
        if not C.aim then return "aim off" end
        if C.hold and not holdAim then return "hold key" end
        if n == 0 then return "NO ENTITIES" end
        if not S.target then
            local f = S.counts and S.counts.fov or 0
            if f == 0 then return "0 in fov" end
            return "fov blocked"
        end
        return "LOCK " .. tostring(S.target.player and S.target.player.Name or S.target.model.Name)
    end

    local function frame(dt)
        local cam = Workspace.CurrentCamera
        if not cam then return end

        if tracer and tracer.Parent then
            tracer.CFrame = cam.CFrame * CFrame.new(0, -0.5, -1)
        end

        local list = scanThrottled()

        local t = pickTarget(list)
        S.target = t
        Aim.current = (C.aim and C.mode == "camera") and t or nil

        if C.aim and C.mode == "camera" then bindCamera() end

        if C.aim and C.mode == "silent" and not Silent.installed then
            pcall(installSilent)
        end

        renderEsp(list)
        overlay()

        statusClock = statusClock + dt
        if statusClock >= 0.35 then
            statusClock = 0
            if not C.pNet then uninstallNamecall() end
            if C.pNet and not NC.detour then installNamecall() end
            if not C.pMouse and Silent.installed then uninstallSilent() end
            if not Loc.installed then installLoc() end
            if not Silent.installed then installSilent() end

            local live = S.hits.mouse + S.hits.loc + S.hits.net
            Status.Text = string.format(
                "%s m%d/%d l%d/%d n%d/%d\nesp%d %s",
                Silent.installed and "SIL" or "sil",
                S.hits.mouse, S.calls.mouse,
                S.hits.loc, S.calls.loc,
                S.hits.net, S.calls.net,
                espCount(), blockReason())
            Status.TextColor3 = live > 0 and COL.on or COL.dim
        end
    end

    espCount = function()
        local n = 0
        for _ in pairs(esp) do n = n + 1 end
        return n
    end

    bind(RunSvc.RenderStepped, function(dt)
        local ok, err = pcall(frame, dt)
        if not ok then
            local msg = tostring(err)
            if msg ~= lastErr then
                lastErr = msg
                warn("[hs] frame: " .. msg)
            end
        end
    end)

    bind(LP.CharacterAdded, function()
        task.wait(0.6)
        pcall(installSilent)
        pcall(installNamecall)
        pcall(installLoc)
        deepNext = 0
    end)

    --=================================================================
    -- Input
    --=================================================================
    local AIM_KEY = Enum.KeyCode.E

    bind(UIS.InputBegan, function(i, gp)
        if gp then return end
        if C.hold and i.KeyCode == AIM_KEY then holdAim = true end
    end)
    bind(UIS.InputEnded, function(i, gp)
        if gp then return end
        if i.KeyCode == AIM_KEY then holdAim = false end
    end)

    AimBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch
        or i.UserInputType == Enum.UserInputType.MouseButton1 then
            holdAim = true
        end
    end)
    AimBtn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch
        or i.UserInputType == Enum.UserInputType.MouseButton1 then
            holdAim = false
        end
    end)

    --=================================================================
    -- Diagnostics
    --=================================================================
    local Diag = new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 160),
        BackgroundColor3 = Color3.fromRGB(24, 24, 30),
        BackgroundTransparency = 0,
        Font = Enum.Font.Code,
        TextSize = 9,
        TextColor3 = COL.dim,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Text = "",
        Visible = false,
        Parent = Body,
    })
    corner(Diag, 5)

    -- Answers the only question a black-box report leaves open: what does this
    -- game actually replicate, and where. Console + clipboard, not the panel.
    local function workspaceDump()
        local L = {}
        local ok, kids = pcall(function() return Workspace:GetChildren() end)
        if not ok then return { "[ws] Workspace unreadable" } end
        L[#L + 1] = string.format("[ws] Workspace children: %d", #kids)

        local function headCount(node)
            local n = 0
            local okc, cs = pcall(function() return node:GetChildren() end)
            if not okc then return 0 end
            for _, c in ipairs(cs) do
                if c:IsA("Model") and c:FindFirstChild("Head") then
                    n = n + 1
                elseif c:IsA("Folder") then
                    local ok2, cs2 = pcall(function() return c:GetChildren() end)
                    if ok2 then
                        for _, c2 in ipairs(cs2) do
                            if c2:IsA("Model") and c2:FindFirstChild("Head") then n = n + 1 end
                        end
                    end
                end
            end
            return n
        end

        local shown = 0
        for _, ch in ipairs(kids) do
            if shown >= 40 then break end
            local cls = ch.ClassName
            if cls ~= "Camera" then
                local okc, cs = pcall(function() return ch:GetChildren() end)
                local n = okc and #cs or -1
                local hc = headCount(ch)
                if n > 0 or hc > 0 then
                    shown = shown + 1
                    L[#L + 1] = string.format("[ws] %-22s %-10s kids=%d head=%d",
                        string.sub(ch.Name, 1, 22), cls, n, hc)
                end
            end
        end
        return L
    end

    local function diagnostics()
        local L = {}
        local function add(f, ...) L[#L + 1] = string.format(f, ...) end
        local gnm = getnamecallmethod or get_namecall_method

        add("exec hui=%s hmm=%s hfn=%s gnm=%s",
            tostring(type(gethui) == "function"),
            tostring(type(hookmetamethod) == "function"),
            tostring(type(hookfunction) == "function"),
            tostring(type(gnm) == "function"))
        add("cam=%s vp=%s", tostring(Workspace.CurrentCamera ~= nil),
            tostring(Workspace.CurrentCamera and tostring(Workspace.CurrentCamera.ViewportSize)))
        add("mobs=%s  deep=%d  esp=%d", mobHint, #deepCache, espCount())
        add("targets=%d  fov=%d", (S.counts and S.counts.total) or -1,
            (S.counts and S.counts.fov) or -1)
        add("silent=%s  src=%s", Silent.status, S.lastSrc)
        add("mouse %d/%d loc %d/%d net %d/%d",
            S.hits.mouse, S.calls.mouse, S.hits.loc, S.calls.loc,
            S.hits.net, S.calls.net)
        add("gnmdead=%s", tostring(S.gnmDead))
        local t = S.target
        if t then
            add("tgt %s %.0fm on=%s hp=%s", tostring(t.model.Name), t.dist,
                tostring(t.onScreen), tostring(t.health))
        else
            add("tgt none")
        end
        for i = 1, math.min(#S.order, 6) do
            local sig = S.order[i]
            local r = S.log[sig]
            add("%s%d %s", r.shot and "*" or " ", r.n, sig)
        end
        if #S.order == 0 then add("no remotes logged") end

        local text = table.concat(L, "\n")
        local ws = workspaceDump()
        local wsText = table.concat(ws, "\n")
        Diag.Text = text .. "\n" .. table.concat(ws, "\n")
        Diag.Visible = true
        print("[hs] === diag ===")
        for _, line in ipairs(L) do print("[hs] " .. line) end
        for _, line in ipairs(ws) do print(line) end
        print("[hs] ============")
        pcall(function() if setclipboard then setclipboard(text .. "\n" .. wsText) end end)
    end

    --=================================================================
    -- Panel build
    --=================================================================
    section("AIMBOT")
    mkToggle(Body, "Enable aimbot", C.aim, function(v) C.aim = v end)
    mkToggle(Body, "Silent (no camera move)", C.mode == "silent", function(v)
        C.mode = v and "silent" or "camera"
        Aim.current = nil
    end)
    mkSlider(Body, "FOV radius", 20, 900, C.fov, function(v) C.fov = v end)
    mkToggle(Body, "FOV from cursor", C.fovMode == "cursor", function(v)
        C.fovMode = v and "cursor" or "center"
    end)
    mkSlider(Body, "Smooth", 1, 40, C.smooth, function(v) C.smooth = v end)
    mkSlider(Body, "Max distance", 100, 2500, C.maxDist, function(v) C.maxDist = v end)
    mkSlider(Body, "Prediction (ms)", 0, 250, C.pred, function(v) C.pred = v end)
    mkToggle(Body, "Wall check", C.wallCheck, function(v) C.wallCheck = v end)
    mkToggle(Body, "Team check", C.teamCheck, function(v) C.teamCheck = v end)
    mkToggle(Body, "Target mobs", C.targetsMob, function(v) C.targetsMob = v end)
    mkToggle(Body, "Target players", C.targetsPlr, function(v) C.targetsPlr = v end)
    mkToggle(Body, "Hold key to aim (E / AIM)", C.hold, function(v)
        C.hold = v
        AimBtn.Visible = v
        if not v then holdAim = false end
    end)
    mkToggle(Body, "Retarget shots in camera mode", C.assist, function(v) C.assist = v end)
    mkToggle(Body, "Show FOV ring", C.ring, function(v) C.ring = v end)
    mkToggle(Body, "Show lock box", C.lockbox, function(v) C.lockbox = v end)

    section("TARGETS")
    mkToggle(Body, "Deep scan workspace", C.deepScan, function(v)
        C.deepScan = v
        if v then deepNext = 0 end
    end)
    mkButton(Body, "Rescan now", function() deepNext = 0 end)

    section("SILENT PATHS")
    mkToggle(Body, "GameUIMod.GetMousePos", C.pMouse, function(v) C.pMouse = v end)
    mkToggle(Body, "UIS.GetMouseLocation", C.pLoc, function(v) C.pLoc = v end)
    mkToggle(Body, "Remote args", C.pNet, function(v) C.pNet = v end)
    mkToggle(Body, "Remote args, blind", C.pBlind, function(v) C.pBlind = v end)
    mkButton(Body, "Dump shot log", function()
        if #S.order == 0 then
            print("[hs] shot log empty")
        else
            for _, sig in ipairs(S.order) do
                local r = S.log[sig]
                print(string.format("[hs] %5d %s %s", r.n, r.shot and "*" or " ", sig))
            end
        end
    end)

    section("ESP")
    mkToggle(Body, "Enable ESP", C.esp, function(v) C.esp = v end)
    mkToggle(Body, "Box", C.espBox, function(v) C.espBox = v end)
    mkToggle(Body, "Names", C.espName, function(v) C.espName = v end)
    mkToggle(Body, "Distance", C.espDist, function(v) C.espDist = v end)
    mkToggle(Body, "Health bar", C.espHp, function(v) C.espHp = v end)
    mkToggle(Body, "Chams", C.espChams, function(v) C.espChams = v end)
    mkToggle(Body, "Tracers", C.espTracer, function(v) C.espTracer = v end)
    mkSlider(Body, "ESP max distance", 200, 4000, C.espMax, function(v) C.espMax = v end)
    mkToggle(Body, "ESP mobs", C.espMobs, function(v) C.espMobs = v end)
    mkToggle(Body, "ESP players", C.espPlrs, function(v) C.espPlrs = v end)

    section("DIAG")
    mkButton(Body, "Run diagnostics (panel + console)", diagnostics)
    mkButton(Body, "Dump workspace (console)", function()
        for _, line in ipairs(workspaceDump()) do print(line) end
        print("[hs] workspace dump done")
    end)
    mkToggle(Body, "Open panel on load", true, function(v) setPanel(v) end)

    setPanel(true)

    --=================================================================
    -- Unload
    --=================================================================
    local function unload()
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        conns = {}
        pcall(function() RunSvc:UnbindFromRenderStep(AIM_BIND) end)
        pcall(uninstallNamecall)
        pcall(uninstallSilent)
        for model, rec in pairs(esp) do destroyRecord(rec) esp[model] = nil end
        if tracer then pcall(function() tracer:Destroy() end) end
        pcall(function() Gui:Destroy() end)
        _G.__hs = nil
        pcall(function() if getgenv then getgenv().__hs = nil end end)
    end

    _G.__hs = {
        unload = unload,
        config = C,
        diag = diagnostics,
        discover = function() deepNext = 0 end,
        targets = function() return targets end,
    }
    if getgenv then pcall(function() getgenv().__hs = _G.__hs end) end

    task.spawn(function()
        pcall(installSilent)
        pcall(installNamecall)
        pcall(installLoc)
        print("[hs] silent=" .. Silent.status)
        task.wait(2.5)
        pcall(diagnostics)
    end)

    overlay()
    print("[hs] ready")
end)

if not __ok then
    local msg = "[hs] FATAL " .. tostring(__err)
    warn(msg)
    pcall(function() if setclipboard then setclipboard(msg) end end)
    pcall(function()
        local sg = Instance.new("ScreenGui")
        sg.Name = "HS_Fatal"
        sg.ResetOnSpawn = false
        sg.DisplayOrder = 2147483647
        local okH, h = pcall(function() return gethui and gethui() end)
        if not (okH and h) then
            okH, h = pcall(function() return game:GetService("CoreGui") end)
        end
        if not (okH and h) then
            h = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui", 10)
        end
        sg.Parent = h
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -40, 0, 140)
        lbl.Position = UDim2.new(0, 20, 0, 20)
        lbl.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
        lbl.BackgroundTransparency = 0.1
        lbl.TextColor3 = Color3.fromRGB(255, 120, 120)
        lbl.Font = Enum.Font.Code
        lbl.TextSize = 12
        lbl.TextWrapped = true
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextYAlignment = Enum.TextYAlignment.Top
        lbl.Text = msg
        lbl.Parent = sg
        task.delay(30, function() pcall(function() sg:Destroy() end) end)
    end)
end
