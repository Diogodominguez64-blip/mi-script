-- Hypershot mobile menu - FOV / Aimbot / Silent Aim / ESP
-- Single file, executor side. No Drawing API. One ScreenGui (the panel only).

-- The whole load is wrapped. Any failure prints [hs] FATAL with the line
-- number, copies it to the clipboard, and paints it on screen for 30s.
local __hs_ok, __hs_err = pcall(function()
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

        -- shot paths, each independently switchable
        pMouse    = true,    -- GameUIMod.GetMousePos  -> Vector3 world point
        pLoc      = true,    -- UIS:GetMouseLocation   -> Vector2 screen point
        pRay      = true,    -- Camera:ScreenPointToRay / ViewportPointToRay
        pNet      = true,    -- RemoteEvent:FireServer argument rewrite

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
        b.MouseButton1Click:Connect(cb)
        return b
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

    local VPY = (W.CurrentCamera and W.CurrentCamera.ViewportSize.Y) or 600
    local PANEL_H = math.clamp(VPY - 80, 300, 620)

    local Panel = new("Frame", {
        Size = UDim2.new(0, 272, 0, PANEL_H),
        Position = UDim2.new(0, 70, 0.5, -PANEL_H * 0.5),
        BackgroundColor3 = COL.bg,
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
        Size = UDim2.new(1, -16, 0, 24),
        Position = UDim2.new(0, 8, 1, -26),
        BackgroundTransparency = 1,
        Font = Enum.Font.Code,
        TextSize = 9,
        TextColor3 = COL.dim,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Text = "idle",
        Parent = Panel,
    })

    local Body = new("ScrollingFrame", {
        Size = UDim2.new(1, -16, 1, -70),
        Position = UDim2.new(0, 8, 0, 40),
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
    stroke(Ring, Color3.new(1, 1, 1), 1.5, 0.35)

    local function syncRing()
        local cam = W.CurrentCamera
        if not cam then return end
        local s = C.fov * 2
        Ring.Size = UDim2.new(0, s, 0, s)
        Ring.Position = UDim2.new(0.5, -C.fov, 0.5, -C.fov)
        Ring.Visible = C.ring
        local vp = cam.ViewportSize
        if math.abs(vp.X * 0.5 - C.fov) > vp.X * 0.5
        or math.abs(vp.Y * 0.5 - C.fov) > vp.Y * 0.5 then
            Ring.Visible = false
        end
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
        pcall(function()
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
    local scanEvery = 0.15

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
        local center = Vector2.new(cx, cy)
        for _, t in ipairs(list) do
            local p = t.part.Position
            t.dist = (p - eye).Magnitude
            local sp, on = cam:WorldToViewportPoint(p)
            if on and sp.Z > 0 then
                t.screen = Vector2.new(sp.X, sp.Y)
                t.onScreen = true
                t.centerDist = (t.screen - center).Magnitude
            else
                t.onScreen = false
                t.centerDist = math.huge
            end
            t.st = sameTeam(t.model)
        end
        return list
    end

    --=====================================================================
    -- Shot router
    --   Every path the game might read the aim point from is covered, and each
    --   one keeps its own counter so the status line says which path is live.
    --
    --   pNet    __namecall FireServer      -> argument rewrite      (mobile)
    --   pRay    Camera:ScreenPointToRay    -> Ray direction
    --           Camera:ViewportPointToRay
    --   pLoc    UIS:GetMouseLocation       -> Vector2 screen point
    --   pMouse  GameUIMod.GetMousePos      -> Vector3 world point
    --=====================================================================
    local S = {
        tgt   = nil,
        inst  = false,
        mp    = { h = 0, c = 0 },
        loc   = { h = 0, c = 0 },
        ray   = { h = 0, c = 0 },
        net   = { h = 0, c = 0 },
        log   = {},
        order = {},
        module = nil,
        origFn = nil,
        namecall = nil,
    }

    local function armed()
        if not C.aim then return false end
        if C.mode == "silent" then return true end
        return C.assist
    end

    local function headPos()
        local t = S.tgt
        local p = t and t.part
        if p and p.Parent then return p.Position end
        return nil
    end

    local function logShot(name, args, n)
        local parts = {}
        for i = 1, n do parts[i] = typeof(args[i]) end
        local sig = name .. "(" .. table.concat(parts, ",") .. ")"
        local rec = S.log[sig]
        if not rec then
            rec = { n = 0, name = name }
            S.log[sig] = rec
            S.order[#S.order + 1] = sig
            if #S.order > 60 then table.remove(S.order, 1) end
        end
        rec.n = rec.n + 1
    end

    local function dumpLog()
        if #S.order == 0 then
            print("[hs] shot log empty - no remote has fired yet")
            return
        end
        print("[hs] ---- shot log ----")
        for _, sig in ipairs(S.order) do
            print(string.format("[hs] %5d  %s", S.log[sig].n, sig))
        end
        print("[hs] ------------------")
    end

    -- One Vector3 rewrite at most, plus one direction rewrite. A magnitude near
    -- 1 is treated as a unit direction and re-aimed from the camera; anything
    -- further out is treated as a world point and swapped for the head.
    local function retargetArgs(args, n)
        local hp = headPos()
        if not hp then return nil end
        local cam = W.CurrentCamera
        local eye = cam and cam.CFrame.Position or nil
        local changed = 0
        for i = 1, n do
            if changed >= 2 then break end
            local v = args[i]
            local tv = typeof(v)
            if tv == "Vector3" then
                local m = v.Magnitude
                if m > 0.5 and m < 1.5 then
                    if eye then
                        local d = hp - eye
                        if d.Magnitude > 0.01 then
                            args[i] = d.Unit
                            changed = changed + 1
                        end
                    end
                elseif eye then
                    local d = (v - eye).Magnitude
                    if d > 8 and d <= C.maxDist + 100 then
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

    local WANT = {
        FireServer = true,
        InvokeServer = true,
        ScreenPointToRay = true,
        ViewportPointToRay = true,
        GetMouseLocation = true,
    }

    local function makeDetour(old, gnm)
        local unpackFn = table.unpack or unpack
        return function(self, ...)
            local m = gnm()
            if not WANT[m] then return old(self, ...) end

            if m == "GetMouseLocation" then
                if C.pLoc and self == U then
                    S.loc.c = S.loc.c + 1
                    local hp = headPos()
                    if armed() and hp then
                        local cam = W.CurrentCamera
                        if cam then
                            local sp, on = cam:WorldToViewportPoint(hp)
                            if on then
                                S.loc.h = S.loc.h + 1
                                return Vector2.new(sp.X, sp.Y)
                            end
                        end
                    end
                end
                return old(self, ...)
            end

            if m == "ScreenPointToRay" or m == "ViewportPointToRay" then
                local ray = old(self, ...)
                if C.pRay and self == W.CurrentCamera then
                    S.ray.c = S.ray.c + 1
                    local hp = headPos()
                    if armed() and hp and type(ray) == "table" and ray.Origin then
                        local dir = hp - ray.Origin
                        if dir.Magnitude > 0.01 then
                            S.ray.h = S.ray.h + 1
                            return Ray.new(ray.Origin, dir.Unit * math.max(ray.Direction.Magnitude, 1))
                        end
                    end
                end
                return ray
            end

            -- FireServer / InvokeServer
            local n = select("#", ...)
            local args = { ... }
            local nm = tostring(self.Name)
            logShot(nm, args, n)
            S.net.c = S.net.c + 1
            if C.pNet and armed() then
                local na, nn = retargetArgs(args, n)
                if na then
                    S.net.h = S.net.h + 1
                    return old(self, unpackFn(na, 1, nn))
                end
            end
            return old(self, ...)
        end
    end

    local function installNamecall()
        if S.namecall then return true end
        local gnm = getnamecallmethod or get_namecall_method
        if type(gnm) ~= "function" then return false end

        -- Preferred: hookmetamethod returns the original in one step. Both the
        -- original and the real detour are forward-declared locals so the
        -- wrapper's upvalues bind to them, not to globals.
        if type(hookmetamethod) == "function" then
            local oldNamecall = nil
            local detour = nil
            local wrapper = function(self, ...)
                if detour then return detour(self, ...) end
                if oldNamecall then return oldNamecall(self, ...) end
            end
            local okH, orig = pcall(hookmetamethod, game, "__namecall", wrapper)
            if okH and type(orig) == "function" then
                oldNamecall = orig
                detour = makeDetour(orig, gnm)
                S.namecall = { kind = "hmm", old = orig, detour = detour }
                return true
            end
        end

        -- Fallback: raw metatable swap.
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

        S.namecall = { kind = "mt", mt = mt, old = old, detour = detour }
        return true
    end

    local function uninstallNamecall()
        local nc = S.namecall
        if not nc then return end
        S.namecall = nil
        if nc.kind == "hmm" and type(hookmetamethod) == "function" then
            pcall(hookmetamethod, game, "__namecall", nc.old)
            return
        end
        if nc.mt then
            pcall(function()
                if type(setreadonly) == "function" then setreadonly(nc.mt, false) end
                nc.mt.__namecall = nc.old
                if type(setreadonly) == "function" then setreadonly(nc.mt, true) end
            end)
        end
    end

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

    local function installMouse()
        if S.module then return true end
        local m = findMod()
        if not m then return false end
        local ok, t = pcall(require, m)
        if not ok or type(t) ~= "table" then return false end
        local f = t.GetMousePos
        if type(f) ~= "function" then return false end

        S.module = t
        S.origFn = f

        local function detour(...)
            local a, b, c = f(...)
            S.mp.c = S.mp.c + 1
            if C.pMouse and armed() then
                local hp = headPos()
                if hp then
                    if typeof(a) == "Vector3" then
                        S.mp.h = S.mp.h + 1
                        return hp
                    elseif typeof(a) == "Vector2" then
                        local cam = W.CurrentCamera
                        if cam then
                            local sp, on = cam:WorldToViewportPoint(hp)
                            if on then
                                S.mp.h = S.mp.h + 1
                                return Vector2.new(sp.X, sp.Y)
                            end
                        end
                    end
                end
            end
            return a, b, c
        end

        if type(hookfunction) == "function" then
            local okh, orig = pcall(hookfunction, f, detour)
            if okh and type(orig) == "function" then
                S.origFn = orig
                S.inst = true
                return true
            end
        end
        if pcall(function() t.GetMousePos = detour end) then
            S.inst = true
            return true
        end
        return false
    end

    local function installAll()
        installNamecall()
        installMouse()
    end

    local function uninstall()
        uninstallNamecall()
        if S.module and S.origFn then
            if type(restorefunction) == "function" and S.inst then
                pcall(restorefunction, S.origFn)
            end
            pcall(function() S.module.GetMousePos = S.origFn end)
        end
        S.module = nil
        S.origFn = nil
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
            rec.bb = bb
            rec.name = new("TextLabel", {
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
            rec.dist = new("TextLabel", {
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
            rec.bar = new("Frame", {
                Size = UDim2.new(1, -40, 0, 4),
                Position = UDim2.new(0, 20, 0, 30),
                BackgroundColor3 = Color3.fromRGB(40, 40, 48),
                Visible = C.espHp,
                Parent = bb,
            })
            corner(rec.bar, 2)
            rec.fill = new("Frame", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = COL.on,
                Parent = rec.bar,
            })
            corner(rec.fill, 2)
        end

        if C.espChams then
            rec.hl = new("Highlight", {
                Name = "hs_hl",
                FillColor = colour(t),
                FillTransparency = 0.72,
                OutlineColor = colour(t),
                OutlineTransparency = 0.2,
                DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
                Adornee = model,
                Parent = model,
            })
        end

        if C.espLine then
            ensureTracer()
            rec.att = new("Attachment", { Name = "hs_head", Parent = part })
            rec.beam = new("Beam", {
                Name = "hs_beam",
                Attachment0 = tracerAtt,
                Attachment1 = rec.att,
                Width0 = 0.06,
                Width1 = 0.02,
                FaceCamera = true,
                LightEmission = 1,
                Color = ColorSequence.new(colour(t)),
                Transparency = NumberSequence.new(0.35),
                Parent = part,
            })
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
                        rec = okb and built or nil
                        if rec then esp[t.model] = rec end
                    end
                    if rec then
                        if rec.name then
                            rec.name.Text = t.model.Name
                            rec.name.TextColor3 = colour(t)
                        end
                        if rec.dist then rec.dist.Text = string.format("%d m", math.floor(t.dist)) end
                        if rec.fill then
                            local h = t.model:FindFirstChildOfClass("Humanoid")
                            local frac = 1
                            if h and h.MaxHealth > 0 then frac = math.clamp(h.Health / h.MaxHealth, 0, 1) end
                            rec.fill.Size = UDim2.new(frac, 0, 1, 0)
                            rec.fill.BackgroundColor3 = frac > 0.5 and COL.on
                                or (frac > 0.2 and COL.mob or COL.enemy)
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
        bound = pcall(function()
            R:BindToRenderStep(BIND, Enum.RenderPriority.Camera.Value + 1, applyAim)
        end)
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
            applyAim(dt)
        end

        statusClock = statusClock + dt
        if statusClock >= 0.4 then
            statusClock = 0
            if not S.namecall then installNamecall() end
            if not S.module then installMouse() end
            syncRing()
            local live = S.net.h + S.ray.h + S.loc.h + S.mp.h
            Status.Text = string.format(
                "t%d e%d  %s %s\nmp %d/%d loc %d/%d ray %d/%d net %d/%d",
                #targets, (function() local n = 0 for _ in pairs(esp) do n = n + 1 end return n end)(),
                S.namecall and "NC" or "nc-", S.module and "MOD" or "mod-",
                S.mp.h, S.mp.c, S.loc.h, S.loc.c,
                S.ray.h, S.ray.c, S.net.h, S.net.c)
            Status.TextColor3 = live > 0 and COL.on or COL.dim
        end
    end)

    bind(LP.CharacterAdded, function()
        installAll()
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

    section("SHOT PATHS")
    mkToggle(Body, "Remote args (silent)", C.pNet, function(v) C.pNet = v end)
    mkToggle(Body, "Touch ray", C.pRay, function(v) C.pRay = v end)
    mkToggle(Body, "Mouse location", C.pLoc, function(v) C.pLoc = v end)
    mkToggle(Body, "GameUIMod.GetMousePos", C.pMouse, function(v) C.pMouse = v end)
    mkButton(Body, "Dump shot log to console", dumpLog)

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
        stats = function()
            return S.mp, S.loc, S.ray, S.net, S.namecall ~= nil, S.inst
        end,
        dump = dumpLog,
        log = dumpLog,
    }
    if getgenv then pcall(function() getgenv().__hs = _G.__hs end) end

    task.spawn(function() pcall(installAll) end)
    syncRing()
    print("[hs] ready")
end)

if not __hs_ok then
    local msg = "[hs] FATAL " .. tostring(__hs_err)
    warn(msg)
    pcall(function() if setclipboard then setclipboard(msg) end end)
    pcall(function()
        local sg = Instance.new("ScreenGui")
        sg.Name = "HS_Fatal"
        sg.ResetOnSpawn = false
        sg.DisplayOrder = 2147483647
        local okh, h = pcall(function() return gethui and gethui() end)
        sg.Parent = (okh and h) or game:GetService("CoreGui")
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -40, 0, 130)
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
