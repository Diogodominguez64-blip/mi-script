-- Hypershot mobile menu - v5 (table-scan silent + desacoplado aimbot)
-- Fixes v4: net 0/0 porque el remoto de disparo manda (string, table)
-- y los args van DENTRO de la tabla. v5 escanea tablas profundas,
-- reescribe Vector3/CFrame/Ray/Vector2 adentro, y desacopla el aimbot
-- del silent para que la cámara pegue aunque el remoto no se toque.

local __hs_ok, __hs_err = pcall(function()
    print("[hs] start v5")

    local P   = game:GetService("Players")
    local R   = game:GetService("RunService")
    local U   = game:GetService("UserInputService")
    local W   = game:GetService("Workspace")
    local RS  = game:GetService("ReplicatedStorage")
    local LP  = P.LocalPlayer

    if _G.__hs and type(_G.__hs.unload) == "function" then pcall(_G.__hs.unload) end

    local C = {
        aim       = false,
        mode      = "silent",     -- "silent" | "camera"
        assist    = true,
        snapCam   = false,
        fov       = 300,
        fovOrigin = "center",
        smooth    = 14,
        maxDist   = 900,
        mobs      = true,
        players   = true,
        autoMobs  = true,
        team      = true,
        hitPart   = "Head",
        pred      = 0,
        aimVis    = false,
        hold      = false,
        netBlind  = true,

        pMouse    = true,
        pLoc      = true,
        pRay      = true,
        pHit      = true,
        pNet      = true,

        esp       = true,
        espName   = true,
        espDist   = true,
        espHp     = true,
        espChams  = false,
        espLine   = true,
        espMax    = 500,
        espMobs   = true,
        espPlayers= true,
        ring      = true,
        lockbox   = true,
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
    local function corner(o, r) return new("UICorner", { CornerRadius = UDim.new(0, r or 6) }, o) end
    local function stroke(o, c, t, a)
        return new("UIStroke", {
            Color = c or Color3.new(1, 1, 1),
            Thickness = t or 1,
            Transparency = a or 0,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        }, o)
    end

    local function host()
        local ok, h = pcall(function() return gethui and gethui() end)
        if ok and h then return h end
        local ok2, cg = pcall(function() return game:GetService("CoreGui") end)
        if ok2 and cg then return cg end
        return LP:WaitForChild("PlayerGui", 10)
    end

    local Gui = new("ScreenGui", {
        Name = "HS_Menu", ResetOnSpawn = false, IgnoreGuiInset = true,
        DisplayOrder = 9999, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(Gui) end end)
    Gui.Parent = host()

    -- widgets (sin cambios)
    local function mkToggle(parent, label, init, cb)
        local b = new("TextButton", { Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = COL.row, AutoButtonColor = false, Text = "", Parent = parent })
        corner(b, 5)
        new("TextLabel", { Size = UDim2.new(1, -58, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = COL.txt, TextXAlignment = Enum.TextXAlignment.Left, Text = label, Parent = b })
        local knob = new("Frame", { Size = UDim2.new(0, 34, 0, 16), Position = UDim2.new(1, -44, 0.5, -8), BackgroundColor3 = init and COL.on or COL.off, Parent = b })
        corner(knob, 8)
        local dot = new("Frame", { Size = UDim2.new(0, 12, 0, 12), Position = init and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Color3.new(1,1,1), Parent = knob })
        corner(dot, 6)
        local state = init
        local function paint()
            knob.BackgroundColor3 = state and COL.on or COL.off
            dot.Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
        end
        b.MouseButton1Click:Connect(function() state = not state; paint(); cb(state) end)
        return b
    end
    local function mkSlider(parent, label, min, max, init, cb)
        local row = new("Frame", { Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = COL.row, Parent = parent })
        corner(row, 5)
        local cap = new("TextLabel", { Size = UDim2.new(1, -20, 0, 18), Position = UDim2.new(0, 10, 0, 2), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = COL.txt, TextXAlignment = Enum.TextXAlignment.Left, Text = label, Parent = row })
        local track = new("Frame", { Size = UDim2.new(1, -20, 0, 4), Position = UDim2.new(0, 10, 1, -12), BackgroundColor3 = COL.off, Parent = row })
        corner(track, 2)
        local fill = new("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = COL.on, Parent = track })
        corner(fill, 2)
        local value = math.clamp(init, min, max)
        local function paint() fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0); cap.Text = label .. "  " .. tostring(math.floor(value)) end
        local function setFromX(px)
            local w = track.AbsoluteSize.X; if w <= 0 then return end
            local v = math.floor(min + (max - min) * math.clamp((px - track.AbsolutePosition.X) / w, 0, 1) + 0.5)
            if v == value then return end; value = v; paint(); cb(value)
        end
        local drag
        track.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = i; setFromX(i.Position.X) end end)
        track.InputEnded:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then drag = nil end end)
        U.InputChanged:Connect(function(i) if not drag then return end; if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then setFromX(i.Position.X) end end)
        paint(); return row
    end
    local function mkButton(parent, label, cb)
        local b = new("TextButton", { Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = COL.row, AutoButtonColor = false, Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = COL.txt, Text = label, Parent = parent })
        corner(b, 5); b.MouseButton1Click:Connect(function() cb(b) end); return b
    end

    -- panel / overlay
    local Btn = new("TextButton", { Size = UDim2.new(0, 46, 0, 46), Position = UDim2.new(0, 14, 0.5, -23), BackgroundColor3 = COL.bg, Text = "HS", TextColor3 = COL.txt, TextSize = 15, Font = Enum.Font.GothamBold, AutoButtonColor = false, Parent = Gui })
    corner(Btn, 23); stroke(Btn, COL.on, 1.5)
    local VPY = (W.CurrentCamera and W.CurrentCamera.ViewportSize.Y) or 600
    local PANEL_H = math.clamp(VPY - 80, 300, 620)
    local Panel = new("Frame", { Size = UDim2.new(0, 272, 0, PANEL_H), Position = UDim2.new(0, 70, 0.5, -PANEL_H * 0.5), BackgroundColor3 = COL.bg, Visible = false, Parent = Gui })
    corner(Panel, 10); stroke(Panel, Color3.fromRGB(60, 60, 72), 1)
    local Head = new("Frame", { Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = COL.row, Parent = Panel })
    corner(Head, 10)
    new("TextLabel", { Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = COL.txt, TextXAlignment = Enum.TextXAlignment.Left, Text = "Hypershot v5", Parent = Head })
    local CloseBtn = new("TextButton", { Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, -32, 0.5, -13), BackgroundColor3 = COL.bg, Text = "x", TextColor3 = COL.dim, TextSize = 14, Font = Enum.Font.GothamBold, AutoButtonColor = false, Parent = Head })
    corner(CloseBtn, 6)
    local Status = new("TextLabel", { Size = UDim2.new(1, -16, 0, 24), Position = UDim2.new(0, 8, 1, -26), BackgroundTransparency = 1, Font = Enum.Font.Code, TextSize = 9, TextColor3 = COL.dim, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Text = "idle", Parent = Panel })
    local Body = new("ScrollingFrame", { Size = UDim2.new(1, -16, 1, -70), Position = UDim2.new(0, 8, 0, 40), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4, ScrollingDirection = Enum.ScrollingDirection.Y, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = Panel })
    new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, Body)
    local function section(title)
        return new("TextLabel", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = COL.dim, TextXAlignment = Enum.TextXAlignment.Left, Text = title, Parent = Body })
    end
    local function drag(frame, handle)
        local on, start, base = false, nil, nil
        handle.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then on = true; start = i.Position; base = frame.Position end end)
        handle.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then on = false end end)
        U.InputChanged:Connect(function(i) if not on then return end; if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then local d = i.Position - start; frame.Position = UDim2.new(base.X.Scale, base.X.Offset + d.X, base.Y.Scale, base.Y.Offset + d.Y) end end)
    end
    drag(Panel, Head); drag(Btn, Btn)
    local function setPanel(v) Panel.Visible = v; Btn.Text = v and "<" or "HS" end
    Btn.MouseButton1Click:Connect(function() setPanel(not Panel.Visible) end)
    CloseBtn.MouseButton1Click:Connect(function() setPanel(false) end)

    local Ring = new("Frame", { Size = UDim2.new(0, 300, 0, 300), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 1, Visible = false, Parent = Gui })
    corner(Ring, 1000); local RingStroke = stroke(Ring, Color3.new(1,1,1), 1.5, 0.35)
    local Cross = new("Frame", { Size = UDim2.new(0, 4, 0, 4), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 0.2, Visible = false, Parent = Gui })
    corner(Cross, 2)
    local Lock = new("Frame", { Size = UDim2.new(0, 26, 0, 26), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Visible = false, Parent = Gui })
    corner(Lock, 3); local LockStroke = stroke(Lock, COL.on, 1.5, 0.1)
    local AimBtn = new("TextButton", { Size = UDim2.new(0, 46, 0, 46), Position = UDim2.new(0, 14, 0.5, 32), BackgroundColor3 = COL.bg, Text = "AIM", TextSize = 11, Font = Enum.Font.GothamBold, TextColor3 = COL.dim, AutoButtonColor = false, Visible = false, Parent = Gui })
    corner(AimBtn, 23); stroke(AimBtn, COL.off, 1.5)

    -- targeting helpers
    local MAXT = 96
    local function isHitboxName(n) return n == "Head" or n == "Hitbox" or n == "HitBox" or n == "Torso" or n == "UpperTorso" or n == "HumanoidRootPart" or n == "Chest" end
    local function firstPart(list) for _, d in ipairs(list) do if d:IsA("BasePart") then return d end end; return nil end
    local function partOf(model)
        if not model then return nil end
        local want = C.hitPart
        if want and want ~= "Any" then
            local d = model:FindFirstChild(want)
            if d and d:IsA("BasePart") then return d end
            for _, c in ipairs(model:GetChildren()) do if c:IsA("Folder") or c:IsA("Model") then local g = c:FindFirstChild(want); if g and g:IsA("BasePart") then return g end end end
        end
        local head = model:FindFirstChild("Head"); if head and head:IsA("BasePart") then return head end
        local root = model:FindFirstChild("HumanoidRootPart"); if root and root:IsA("BasePart") then return root end
        local kids = model:GetChildren()
        for _, d in ipairs(kids) do if d:IsA("BasePart") and isHitboxName(d.Name) then return d end end
        local flat = firstPart(kids); if flat then return flat end
        for _, c in ipairs(kids) do if c:IsA("Folder") or c:IsA("Model") then local p = firstPart(c:GetChildren()); if p then return p end end end
        return nil
    end
    local function alive(model)
        if not model or not model.Parent then return false end
        local h = model:FindFirstChildOfClass("Humanoid")
        if h then local okh, hp = pcall(function() return h.Health end); if okh and type(hp) == "number" and hp <= 0 then return false end end
        local okA, attr = pcall(function() return model:GetAttribute("Health") end)
        if okA and type(attr) == "number" and attr <= 0 then return false end
        return true
    end
    local function isPlayerChar(model)
        for _, pl in ipairs(P:GetPlayers()) do if pl.Character == model then return true end end
        return false
    end
    local GlbStf
    pcall(function()
        local m = RS:FindFirstChild("Modules"); local g = m and m:FindFirstChild("GlobalStuff")
        if g and g:IsA("ModuleScript") then local okr, t = pcall(require, g); if okr and type(t) == "table" and type(t.SameTeam) == "function" then GlbStf = t end end
    end)
    local function sameTeam(model)
        if not GlbStf then return nil end
        local ok, r = pcall(GlbStf.SameTeam, GlbStf, LP, model)
        if ok and type(r) == "boolean" then return r end
        return nil
    end

    -- discovery
    local containerNodes, containerNames = {}, {}
    local mobCached, nodesFound = 0, 0
    local discoverEvery, discoverClock, discovering = 6, 0, false
    local function discover()
        if discovering then return end; discovering = true
        local okAll, err = pcall(function()
            local nodes, seen, names = {}, {}, {}
            local visited = 0
            local function walk(node, depth)
                if depth > 6 or visited > 3000 then return end
                local okk, kids = pcall(function() return node:GetChildren() end); if not okk then return end
                local isHit = false
                for _, ch in ipairs(kids) do
                    visited = visited + 1; if visited > 3000 then return end
                    if ch:IsA("Model") then if not isPlayerChar(ch) and alive(ch) and partOf(ch) then isHit = true end; walk(ch, depth + 1)
                    elseif ch:IsA("Folder") or ch:IsA("Configuration") then walk(ch, depth + 1) end
                end
                if isHit and not seen[node] then
                    seen[node] = true; nodes[#nodes+1] = node
                    local nm = (node == W) and "Workspace" or node.Name
                    names[nm] = (names[nm] or 0) + 1; containerNames[#containerNames+1] = nm
                end
            end
            walk(W, 0); containerNodes = nodes; nodesFound = #nodes
        end)
        discovering = false
        if not okAll then print("[hs] discover error: " .. tostring(err)) end
    end
    local function containerSummary()
        local seen, out = {}, {}
        for _, n in ipairs(containerNames) do if not seen[n] then seen[n] = true; out[#out+1] = n; if #out >= 8 then break end end end
        return #out == 0 and "-" or table.concat(out, ",")
    end

    local targets, esp = {}, {}
    local scanClock, scanEvery = 0, 0.05
    local function pushOut(out, m, kind)
        if #out >= MAXT or not m or not m.Parent then return end
        if kind == "mob" and isPlayerChar(m) then return end
        local ok, rec = pcall(function()
            if not alive(m) then return nil end
            local part = partOf(m); if not part then return nil end
            return { model = m, part = part, kind = kind }
        end)
        if ok and rec then out[#out+1] = rec end
    end
    local function collect()
        local out = {}
        if C.mobs then
            if C.autoMobs then
                if #containerNodes == 0 then
                    for _, ch in ipairs(W:GetChildren()) do if ch:IsA("Model") then pushOut(out, ch, "mob") end end
                else
                    for _, node in ipairs(containerNodes) do
                        if node == W or node.Parent ~= nil then
                            local okk, kids = pcall(function() return node:GetChildren() end)
                            if okk then for _, ch in ipairs(kids) do if ch:IsA("Model") then pushOut(out, ch, "mob") end end end
                        end
                    end
                end
            else
                for _, name in ipairs({ "Mobs", "Enemies", "Monsters", "NPCs", "Dummies" }) do
                    local folder = W:FindFirstChild(name)
                    if folder then local okk, kids = pcall(function() return folder:GetChildren() end); if okk then for _, ch in ipairs(kids) do if ch:IsA("Model") then pushOut(out, ch, "mob") end end end end
                end
            end
        end
        if C.players then
            for _, pl in ipairs(P:GetPlayers()) do if pl ~= LP and pl.Character then pushOut(out, pl.Character, "player") end end
        end
        mobCached = #out; return out
    end
    local MAX_SCREEN = 9000
    local function project(list)
        local cam = W.CurrentCamera; if not cam then return list end
        local eye = cam.CFrame.Position
        for _, t in ipairs(list) do
            t.dist = (t.part.Position - eye).Magnitude
            local sp, on = cam:WorldToScreenPoint(t.part.Position)
            if on and sp.Z > 0 and sp.X > -MAX_SCREEN and sp.X < MAX_SCREEN and sp.Y > -MAX_SCREEN and sp.Y < MAX_SCREEN then
                t.screen = Vector2.new(sp.X, sp.Y); t.onScreen = true
            else t.onScreen = false; t.screen = nil end
            t.st = sameTeam(t.model)
        end
        return list
    end

    local S = {
        tgt = nil, busy = false, raw = false,
        mp = { h = 0, c = 0 }, loc = { h = 0, c = 0 }, ray = { h = 0, c = 0 },
        hit = { h = 0, c = 0 }, net = { h = 0, c = 0 },
        log = {}, order = {}, module = nil, origFn = nil, hookFn = nil,
        inst = false, namecall = nil, index = nil, gnmDead = false,
    }
    local holdAim = false
    local function fovOrigin()
        local cam = W.CurrentCamera; local vp = (cam and cam.ViewportSize) or Vector2.new(1280, 720)
        if C.fovOrigin == "cursor" then
            local okp, p = pcall(function() S.raw = true; local loc = U:GetMouseLocation(); S.raw = false; return loc end)
            S.raw = false
            if okp and typeof(p) == "Vector2" then return p end
        end
        return Vector2.new(vp.X * 0.5, vp.Y * 0.5)
    end
    local function screenOf(part)
        local cam = W.CurrentCamera; if not cam or not part then return nil end
        local sp, on = cam:WorldToScreenPoint(part.Position)
        if on and sp.Z > 0 then return Vector2.new(sp.X, sp.Y) end
        return nil
    end
    local function aimPoint()
        local p = S.tgt and S.tgt.part
        if not p or not p.Parent then return nil end
        if C.pred > 0 then
            local okv, v = pcall(function() return p.AssemblyLinearVelocity end)
            if okv and typeof(v) == "Vector3" then return p.Position + v * (C.pred / 1000) end
        end
        return p.Position
    end
    local function armed()
        if not C.aim then return false end
        if C.hold and not holdAim then return false end
        if not S.tgt then return false end
        if C.aimVis and S.tgt.vis == false then return false end
        return true
    end
    local rp = RaycastParams.new(); rp.FilterType = Enum.RaycastFilterType.Exclude; rp.IgnoreWater = true
    local function visible(t)
        local cam = W.CurrentCamera; if not cam then return true end
        local filter = {}
        if LP.Character then filter[#filter+1] = LP.Character end
        if t.model then filter[#filter+1] = t.model end
        rp.FilterDescendantsInstances = filter
        local ok, res = pcall(function() return W:Raycast(cam.CFrame.Position, t.part.Position - cam.CFrame.Position, rp) end)
        if not ok then return true end
        return res == nil
    end

    -- shot router v5: table-scan
    local function logShot(inst, name, args, n)
        local parts, shot = {}, false
        for i = 1, n do
            local tv = typeof(args[i]); parts[i] = tv
            if tv == "CFrame" then shot = true
            elseif tv == "Vector3" then local m = args[i].Magnitude; if m > 0.5 and m < 1.5 then shot = true end
            elseif tv == "Vector2" or tv == "Ray" then shot = true
            elseif tv == "table" then
                local ok, has = pcall(function()
                    for _, v in pairs(args[i]) do
                        local vt = typeof(v)
                        if vt == "CFrame" or vt == "Ray" or vt == "Vector2" then return true end
                        if vt == "Vector3" then local m = v.Magnitude; if m > 0.5 and m < 1.5 then return true end end
                    end
                    return false
                end)
                if ok and has then shot = true end
            end
        end
        local sig = name .. "(" .. table.concat(parts, ",") .. ")"
        local rec = S.log[sig]
        if not rec then
            rec = { n = 0, name = name, inst = inst, shot = shot }
            S.log[sig] = rec; S.order[#S.order+1] = sig
            if #S.order > 80 then table.remove(S.order, 1) end
        end
        rec.n = rec.n + 1; if shot then rec.shot = true end
    end
    local function dumpLog()
        if #S.order == 0 then print("[hs] shot log empty"); return end
        print("[hs] ---- shot log ----")
        for _, sig in ipairs(S.order) do local r = S.log[sig]; print(string.format("[hs] %5d %s %s", r.n, r.shot and "*" or " ", sig)) end
        print("[hs] ------------------")
    end

    -- v5: retarget profundo. Escanea tablas un nivel adentro.
    local function retargetArgs(args, n)
        local hp = aimPoint(); if not hp then return nil end
        local cam = W.CurrentCamera; local eye = cam and cam.CFrame.Position or nil
        local changed = 0
        local function dirFrom()
            if not eye then return nil end
            local d = hp - eye; if d.Magnitude <= 0.01 then return nil end
            return d.Unit
        end
        local function tgtScreen() return screenOf(S.tgt and S.tgt.part) end

        local function retargetOne(v)
            local tv = typeof(v)
            if tv == "Vector3" then
                local m = v.Magnitude
                if m > 0.5 and m < 1.5 then local d = dirFrom(); if d then return d, true end
                elseif eye then
                    local d = (v - eye).Magnitude
                    if d > 4 and d <= C.maxDist + 250 then return hp, true end
                end
            elseif tv == "Vector2" then local sp = tgtScreen(); if sp then return sp, true end
            elseif tv == "CFrame" then return CFrame.lookAt(v.Position, hp), true
            elseif tv == "Ray" then
                local d = hp - v.Origin
                if d.Magnitude > 0.01 then return Ray.new(v.Origin, d.Unit * math.max(v.Direction.Magnitude, 100)), true end
            end
            return v, false
        end

        for i = 1, n do
            if changed >= 4 then break end
            local v = args[i]
            if typeof(v) == "table" then
                for k, sub in pairs(v) do
                    local nv, did = retargetOne(sub)
                    if did then v[k] = nv; changed = changed + 1; if changed >= 4 then break end end
                end
            else
                local nv, did = retargetOne(v)
                if did then args[i] = nv; changed = changed + 1 end
            end
        end
        if changed > 0 then return args, n end
        return nil
    end

    local SHOT_NAME = { "shoot", "fire", "hit", "damage", "attack", "shot", "aim", "swing", "cast", "spell", "combat", "bullet", "reload", "gun", "weapon", "dmg" }
    local function shotishName(name)
        local ln = string.lower(tostring(name))
        for _, k in ipairs(SHOT_NAME) do if string.find(ln, k, 1, true) then return true end end
        return false
    end
    local function blindShot(self, args, n)
        if n < 1 or n > 4 then return nil end
        if not shotishName(self.Name) then return nil end
        return args, n
    end
    local WANT = { FireServer = true, InvokeServer = true, ScreenPointToRay = true, ViewportPointToRay = true, GetMouseLocation = true }

    local function makeDetour(old, gnm)
        local unpackFn = table.unpack or unpack
        local function safeOld(self, ...)
            S.busy = true; local res = table.pack(pcall(old, self, ...)); S.busy = false
            if res[1] then return unpackFn(res, 2, res.n) end; error(res[2], 0)
        end
        return function(self, ...)
            if S.busy or S.raw then return old(self, ...) end
            local m; local okm, got = pcall(gnm); if okm then m = got end
            if m == nil then S.gnmDead = true; if C.pNet and not C.netBlind then C.netBlind = true end end
            if m and not WANT[m] then return old(self, ...) end
            if m == "GetMouseLocation" then
                if C.pLoc and self == U and armed() then
                    local sp = screenOf(S.tgt.part)
                    if sp then S.loc.c = S.loc.c + 1; S.loc.h = S.loc.h + 1; return sp end
                end
                return old(self, ...)
            end
            if m == "ScreenPointToRay" or m == "ViewportPointToRay" then
                if C.pRay and self == W.CurrentCamera and armed() then
                    S.ray.c = S.ray.c + 1; local ray = old(self, ...)
                    local hp = aimPoint()
                    if hp and type(ray) == "table" and ray.Origin then
                        local d = hp - ray.Origin
                        if d.Magnitude > 0.01 then S.ray.h = S.ray.h + 1; return Ray.new(ray.Origin, d.Unit * math.max(ray.Direction.Magnitude, 1)) end
                    end
                    return ray
                end
                return old(self, ...)
            end
            local n = select("#", ...); local args = { ... }
            if m == nil then
                if not (C.netBlind and C.pNet and armed()) then return old(self, ...) end
                local na, nn = blindShot(self, args, n); if not na then return old(self, ...) end
                S.net.c = S.net.c + 1
                local okr, ra, rn = pcall(retargetArgs, na, nn)
                if not (okr and ra) then return old(self, ...) end
                S.net.h = S.net.h + 1; return safeOld(self, unpackFn(ra, 1, rn))
            end
            pcall(logShot, self, tostring(self.Name), args, n)
            if not (C.pNet and armed()) then return old(self, ...) end
            S.net.c = S.net.c + 1
            local okr, na, nn = pcall(retargetArgs, args, n)
            if not (okr and na) then return old(self, ...) end
            S.net.h = S.net.h + 1; return safeOld(self, unpackFn(na, 1, nn))
        end
    end

    local function installNamecall()
        if S.namecall then return true end
        local gnm = getnamecallmethod or get_namecall_method
        if type(gnm) ~= "function" then return false end
        if type(hookmetamethod) == "function" then
            local oldNamecall = nil; local detour = nil
            local wrapper = function(self, ...) if detour then return detour(self, ...) end; if oldNamecall then return oldNamecall(self, ...) end end
            local okH, orig = pcall(hookmetamethod, game, "__namecall", wrapper)
            if okH and type(orig) == "function" then oldNamecall = orig; detour = makeDetour(orig, gnm); S.namecall = { kind = "hmm", old = orig, detour = detour }; return true end
        end
        if type(getrawmetatable) ~= "function" then return false end
        local ok, mt = pcall(getrawmetatable, game); if not ok or type(mt) ~= "table" then return false end
        local old = mt.__namecall; if type(old) ~= "function" then return false end
        local detour = makeDetour(old, gnm)
        local okw = pcall(function() if type(setreadonly) == "function" then setreadonly(mt, false) end; mt.__namecall = detour; if type(setreadonly) == "function" then setreadonly(mt, true) end end)
        if not okw then pcall(function() mt.__namecall = old end); return false end
        S.namecall = { kind = "mt", mt = mt, old = old, detour = detour }; return true
    end

    local function installIndex()
        if S.index then return true end
        if type(hookmetamethod) ~= "function" then return false end
        local orig, wrapper
        wrapper = function(self, key)
            if S.busy or S.raw then return orig(self, key) end
            if not C.pHit or not armed() then return orig(self, key) end
            local okc, cls = pcall(function() return self.ClassName end)
            if not (okc and cls == "Mouse") then return orig(self, key) end
            if key ~= "Hit" and key ~= "Target" and key ~= "UnitRay" and key ~= "X" and key ~= "Y" then return orig(self, key) end
            local hp = aimPoint(); if not hp then return orig(self, key) end
            if key == "Hit" then S.hit.c = S.hit.c + 1; S.hit.h = S.hit.h + 1; return CFrame.new(hp)
            elseif key == "Target" then
                local p = S.tgt and S.tgt.part
                if p and p.Parent then S.hit.c = S.hit.c + 1; S.hit.h = S.hit.h + 1; return p end
                return orig(self, key)
            elseif key == "UnitRay" then
                local cam = W.CurrentCamera; if not cam then return orig(self, key) end
                local d = hp - cam.CFrame.Position; if d.Magnitude < 0.01 then return orig(self, key) end
                S.hit.c = S.hit.c + 1; S.hit.h = S.hit.h + 1; return Ray.new(cam.CFrame.Position, d.Unit)
            else
                local sp = screenOf(S.tgt and S.tgt.part)
                if sp then S.hit.c = S.hit.c + 1; S.hit.h = S.hit.h + 1; return key == "X" and sp.X or sp.Y end
                return orig(self, key)
            end
        end
        local okH, ret = pcall(hookmetamethod, game, "__index", wrapper)
        if not okH or type(ret) ~= "function" then return false end
        orig = ret; S.index = { kind = "hmm", old = orig, detour = wrapper }; return true
    end

    local function uninstallIndex()
        local ix = S.index; if not ix then return end; S.index = nil
        if type(hookmetamethod) == "function" then pcall(hookmetamethod, game, "__index", ix.old) end
    end
    local function uninstallNamecall()
        local nc = S.namecall; if not nc then return end; S.namecall = nil
        if nc.kind == "hmm" and type(hookmetamethod) == "function" then pcall(hookmetamethod, game, "__namecall", nc.old); return end
        if nc.mt then pcall(function() if type(setreadonly) == "function" then setreadonly(nc.mt, false) end; nc.mt.__namecall = nc.old; if type(setreadonly) == "function" then setreadonly(nc.mt, true) end end) end
    end

    local function findMod()
        local pg = LP:FindFirstChild("PlayerGui"); if not pg then return nil end
        local g = pg:FindFirstChild("GameUI")
        if g then local m = g:FindFirstChild("GameUIMod"); if m and m:IsA("ModuleScript") then return m end end
        for _, d in ipairs(pg:GetDescendants()) do if d:IsA("ModuleScript") and d.Name == "GameUIMod" then return d end end
        return nil
    end
    local function installMouse()
        if S.module then return true end
        local m = findMod(); if not m then return false end
        local ok, t = pcall(require, m); if not ok or type(t) ~= "table" then return false end
        local f = t.GetMousePos; if type(f) ~= "function" then return false end
        S.module = t; S.origFn = f
        local function detour(...)
            if S.busy or S.raw then return f(...) end
            local a, b, c = f(...)
            if not (C.pMouse and armed()) then return a, b, c end
            local hp = aimPoint(); if not hp then return a, b, c end
            if typeof(a) == "Vector3" then S.mp.h = S.mp.h + 1; return hp
            elseif typeof(a) == "Vector2" then local sp = screenOf(S.tgt.part); if sp then S.mp.h = S.mp.h + 1; return sp end end
            return a, b, c
        end
        if type(hookfunction) == "function" then
            local okh, orig = pcall(hookfunction, f, detour)
            if okh and type(orig) == "function" then S.origFn = orig; S.hookFn = detour; S.inst = true; return true end
        end
        if pcall(function() t.GetMousePos = detour end) then S.hookFn = detour; S.inst = true; return true end
        return false
    end

    local function syncIndex() if C.pHit then if not S.index then installIndex() end else if S.index then uninstallIndex() end end end
    local function installAll() installNamecall(); syncIndex(); installMouse() end
    local function uninstall()
        uninstallNamecall(); uninstallIndex()
        if S.module then
            if S.hookFn and type(restorefunction) == "function" then pcall(restorefunction, S.hookFn) end
            if S.origFn then pcall(function() S.module.GetMousePos = S.origFn end) end
        end
        S.module = nil; S.origFn = nil; S.hookFn = nil; S.inst = false; S.tgt = nil; S.busy = false
    end

    -- ESP
    local tracerPart, tracerAtt
    local function ensureTracer()
        local cam = W.CurrentCamera; if not cam then return end
        if not tracerPart or not tracerPart.Parent then
            tracerPart = new("Part", { Name = "hs_tracer_origin", Size = Vector3.new(0.1,0.1,0.1), Transparency = 1, CanCollide = false, CanQuery = false, CanTouch = false, Anchored = true, CastShadow = false, Parent = cam })
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
        local part = t.part; local rec = {}
        local bb = new("BillboardGui", { Name = "hs_bb", Size = UDim2.new(0, 170, 0, 46), StudsOffset = Vector3.new(0, 2.2, 0), AlwaysOnTop = true, MaxDistance = C.espMax, Adornee = part, Parent = part })
        rec.bb = bb
        rec.name = new("TextLabel", { Size = UDim2.new(1,0,0,15), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = colour(t), TextStrokeTransparency = 0.4, Text = model.Name, Visible = C.espName, Parent = bb })
        rec.dist = new("TextLabel", { Size = UDim2.new(1,0,0,13), Position = UDim2.new(0,0,0,15), BackgroundTransparency = 1, Font = Enum.Font.Code, TextSize = 11, TextColor3 = COL.txt, TextStrokeTransparency = 0.4, Text = "", Visible = C.espDist, Parent = bb })
        rec.bar = new("Frame", { Size = UDim2.new(1,-40,0,4), Position = UDim2.new(0,20,0,30), BackgroundColor3 = Color3.fromRGB(40,40,48), Visible = C.espHp, Parent = bb })
        corner(rec.bar, 2)
        rec.fill = new("Frame", { Size = UDim2.new(1,0,1,0), BackgroundColor3 = COL.on, Parent = rec.bar })
        corner(rec.fill, 2)
        rec.hl = new("Highlight", { Name = "hs_hl", FillColor = colour(t), FillTransparency = 0.72, OutlineColor = colour(t), OutlineTransparency = 0.2, DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, Adornee = model, Enabled = C.espChams, Parent = model })
        if C.espLine then
            ensureTracer()
            rec.att = new("Attachment", { Name = "hs_head", Parent = part })
            rec.beam = new("Beam", { Name = "hs_beam", Attachment0 = tracerAtt, Attachment1 = rec.att, Width0 = 0.06, Width1 = 0.02, FaceCamera = true, LightEmission = 1, Color = ColorSequence.new(colour(t)), Transparency = NumberSequence.new(0.35), Parent = part })
        end
        return rec
    end
    local function destroy(rec) for _, k in ipairs({ "bb", "hl", "beam", "att" }) do local o = rec[k]; if o then pcall(function() o:Destroy() end) end end end
    local function renderEsp(list)
        if not C.esp then for model, rec in pairs(esp) do destroy(rec); esp[model] = nil end; return end
        local seen = {}
        for _, t in ipairs(list) do
            if t.dist and t.dist <= C.espMax and t.part.Parent then
                local want = (t.kind == "mob" and C.espMobs) or (t.kind == "player" and C.espPlayers)
                if want then
                    seen[t.model] = true
                    local rec = esp[t.model]
                    if not rec then local okb, built = pcall(build, t.model, t); rec = okb and built or nil; if rec then esp[t.model] = rec end end
                    if rec then
                        if rec.name then rec.name.Text = t.model.Name; rec.name.TextColor3 = colour(t); rec.name.Visible = C.espName end
                        if rec.dist then rec.dist.Text = string.format("%d m", math.floor(t.dist)); rec.dist.Visible = C.espDist end
                        if rec.bar then rec.bar.Visible = C.espHp end
                        if rec.fill then
                            local h = t.model:FindFirstChildOfClass("Humanoid"); local frac = 1
                            if h then local okh, mx = pcall(function() return h.MaxHealth end); if okh and mx and mx > 0 then frac = math.clamp(h.Health / mx, 0, 1) end end
                            rec.fill.Size = UDim2.new(frac, 0, 1, 0)
                            rec.fill.BackgroundColor3 = frac > 0.5 and COL.on or (frac > 0.2 and COL.mob or COL.enemy)
                        end
                        if rec.hl then rec.hl.FillColor = colour(t); rec.hl.OutlineColor = colour(t); rec.hl.Enabled = C.espChams end
                        if rec.beam then rec.beam.Enabled = C.espLine and true or false; if C.espLine then rec.beam.Color = ColorSequence.new(colour(t)) end end
                    end
                end
            end
        end
        for model, rec in pairs(esp) do if not seen[model] or not model.Parent then destroy(rec); esp[model] = nil end end
    end

    -- aimbot
    local T = { current = nil, origin = Vector2.new(0, 0) }
    local function pick(list)
        local cam = W.CurrentCamera; if not cam then return nil end
        local origin = fovOrigin(); T.origin = origin
        local best, bestD = nil, math.huge
        for _, t in ipairs(list) do
            local want = (t.kind == "mob" and C.mobs) or (t.kind == "player" and C.players)
            if want and t.onScreen and t.dist <= C.maxDist then
                if not (C.team and t.st == true) then
                    local d = (t.screen - origin).Magnitude
                    if d <= C.fov and d < bestD then
                        if C.aimVis then t.vis = visible(t) else t.vis = true end
                        if t.vis ~= false then best, bestD = t, d end
                    end
                end
            end
        end
        return best
    end
    local BIND = "hs_camera_aim"; local bound = false
    local function applyAim(dt)
        if not C.aim then return end
        if C.mode ~= "camera" and not C.snapCam then return end
        if C.hold and not holdAim then return end
        local t = T.current; local cam = W.CurrentCamera; if not t or not cam then return end
        local hp = aimPoint(); if not hp then return end
        local a = math.clamp((dt or 0.016) * C.smooth, 0.08, 1)
        if C.mode == "silent" then a = math.clamp(a * 0.5, 0.04, 0.5) end
        cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position, hp), a)
    end
    local function tryBind() if bound then return end; bound = pcall(function() R:BindToRenderStep(BIND, Enum.RenderPriority.Camera.Value + 1, applyAim) end) end

    -- diagnostics
    local DiagBox = new("TextLabel", { Size = UDim2.new(1,0,0,150), BackgroundColor3 = Color3.fromRGB(24,24,30), BackgroundTransparency = 0, Font = Enum.Font.Code, TextSize = 9, TextColor3 = COL.dim, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, Text = "diag: press Run diagnostics", Visible = false, Parent = Body })
    corner(DiagBox, 5)
    local function espCount() local n = 0; for _ in pairs(esp) do n = n + 1 end; return n end
    local function diagnostics()
        local lines = {}; local function add(f, ...) lines[#lines+1] = string.format(f, ...) end
        local gnm = getnamecallmethod or get_namecall_method
        add("hs diag v5  t=%d esp=%d mobs=%d", #targets, espCount(), mobCached)
        add("exec gethui=%s hmm=%s hookfn=%s gnm=%s", tostring(type(gethui) == "function"), tostring(type(hookmetamethod) == "function"), tostring(type(hookfunction) == "function"), tostring(type(gnm) == "function"))
        add("hook nc=%s ix=%s mod=%s gnmdead=%s blind=%s", tostring(S.namecall ~= nil), tostring(S.index ~= nil), tostring(S.module ~= nil), tostring(S.gnmDead), tostring(C.netBlind))
        add("nodes=%d  %s", nodesFound, containerSummary())
        add("cat %d/%d loc %d/%d ray %d/%d hit %d/%d net %d/%d", S.mp.h, S.mp.c, S.loc.h, S.loc.c, S.ray.h, S.ray.c, S.hit.h, S.hit.c, S.net.h, S.net.c)
        local t = S.tgt
        if t then add("tgt %s %.0fm on=%s", tostring(t.model.Name), t.dist or -1, tostring(t.onScreen)) else add("tgt none") end
        local shown = 0
        for _, sig in ipairs(S.order) do local r = S.log[sig]; add("%s%4d %s", r.shot and "*" or " ", r.n, sig); shown = shown + 1; if shown >= 10 then break end end
        if shown == 0 then add("no remotes logged yet") end
        local text = table.concat(lines, "\n")
        print("[hs] ==== diag v5 ===="); for _, l in ipairs(lines) do print("[hs] " .. l) end; print("[hs] ==================")
        DiagBox.Text = text; DiagBox.Visible = true
    end

    -- loop
    local conns = {}
    local function bind(sig, fn) local c = sig:Connect(fn); conns[#conns+1] = c; return c end
    local statusClock = 0
    local function overlay()
        local origin = T.origin; local locked = S.tgt ~= nil and armed()
        Ring.Size = UDim2.new(0, C.fov * 2, 0, C.fov * 2); Ring.Position = UDim2.new(0, origin.X, 0, origin.Y); Ring.Visible = C.ring
        RingStroke.Color = locked and COL.on or Color3.new(1,1,1); RingStroke.Transparency = locked and 0.1 or 0.35
        Cross.Position = UDim2.new(0, origin.X, 0, origin.Y); Cross.Visible = C.ring
        local sp = S.tgt and S.tgt.screen
        Lock.Visible = C.lockbox and locked and sp ~= nil
        if Lock.Visible then Lock.Position = UDim2.new(0, sp.X, 0, sp.Y) end
        AimBtn.BackgroundColor3 = holdAim and COL.on or COL.bg
        AimBtn.TextColor3 = holdAim and Color3.new(0,0,0) or COL.dim
    end
    local function blockReason()
        if not C.aim then return "aim off" end
        if C.hold and not holdAim then return "hold key" end
        if not S.tgt then if #targets == 0 then return "NO TARGETS" end; return "out of fov" end
        if C.aimVis and S.tgt.vis == false then return "no los" end
        return "LOCK " .. tostring(S.tgt.model.Name)
    end
    local function frame(dt)
        local cam = W.CurrentCamera; if not cam then return end
        if tracerPart and tracerPart.Parent then tracerPart.CFrame = cam.CFrame * CFrame.new(0, -0.5, -1) end
        scanClock = scanClock + dt; if scanClock >= scanEvery then scanClock = 0; targets = collect() end
        project(targets)
        discoverClock = discoverClock + dt
        if C.autoMobs and discoverClock >= discoverEvery then discoverClock = 0; task.spawn(discover) end
        renderEsp(targets)
        local t = pick(targets); T.current = t; S.tgt = t
        if C.aim and (C.mode == "camera" or C.snapCam) then if not bound then tryBind() end end
        overlay()
        statusClock = statusClock + dt
        if statusClock >= 0.4 then
            statusClock = 0
            if not S.namecall then installNamecall() end
            syncIndex()
            if not S.module then installMouse() end
            local live = S.net.h + S.ray.h + S.loc.h + S.mp.h + S.hit.h
            Status.Text = string.format("%s t%d mobs%d\n%s  net %d/%d ray %d/%d loc %d/%d", (S.namecall and "NC" or "nc-") .. " " .. (S.module and "MOD" or "mod-"), #targets, mobCached, blockReason(), S.net.h, S.net.c, S.ray.h, S.ray.c, S.loc.h, S.loc.c)
            Status.TextColor3 = live > 0 and COL.on or COL.dim
        end
    end
    bind(R.RenderStepped, function(dt) local ok, err = pcall(frame, dt); if not ok then if not S.lastErr or S.lastErr ~= tostring(err) then S.lastErr = tostring(err); warn("[hs] frame error: " .. S.lastErr) end end end)
    bind(LP.CharacterAdded, function() task.wait(0.6); installAll(); task.spawn(discover) end)

    -- input
    local AIM_KEY = Enum.KeyCode.E
    bind(U.InputBegan, function(i, gp) if gp then return end; if C.hold and i.KeyCode == AIM_KEY then holdAim = true end end)
    bind(U.InputEnded, function(i, gp) if gp then return end; if i.KeyCode == AIM_KEY then holdAim = false end end)
    AimBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then holdAim = true end end)
    AimBtn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then holdAim = false end end)

    -- panel build
    section("AIMBOT")
    mkToggle(Body, "Enable aimbot", C.aim, function(v) C.aim = v end)
    mkToggle(Body, "Silent (no camera move)", C.mode == "silent", function(v) C.mode = v and "silent" or "camera"; T.current = nil end)
    mkSlider(Body, "FOV radius", 20, 800, C.fov, function(v) C.fov = v end)
    mkToggle(Body, "FOV from cursor", C.fovOrigin == "cursor", function(v) C.fovOrigin = v and "cursor" or "center" end)
    mkSlider(Body, "Smooth", 1, 40, C.smooth, function(v) C.smooth = v end)
    mkSlider(Body, "Max distance", 100, 2000, C.maxDist, function(v) C.maxDist = v end)
    mkSlider(Body, "Prediction (ms)", 0, 200, C.pred, function(v) C.pred = v end)
    mkToggle(Body, "Hold key to aim (E / AIM)", C.hold, function(v) C.hold = v; AimBtn.Visible = v; if not v then holdAim = false end end)
    mkToggle(Body, "Wall check", C.aimVis, function(v) C.aimVis = v end)
    mkToggle(Body, "Team check", C.team, function(v) C.team = v end)
    mkToggle(Body, "Target mobs", C.mobs, function(v) C.mobs = v end)
    mkToggle(Body, "Target players", C.players, function(v) C.players = v end)
    mkToggle(Body, "Retarget shots in camera mode", C.assist, function(v) C.assist = v end)
    mkToggle(Body, "Silent + snap camera", C.snapCam, function(v) C.snapCam = v end)
    mkToggle(Body, "Show FOV ring", C.ring, function(v) C.ring = v end)
    mkToggle(Body, "Show lock box", C.lockbox, function(v) C.lockbox = v end)

    local PART_ORDER = { "Head", "Hitbox", "Torso", "UpperTorso", "HumanoidRootPart", "Any" }
    local partBtn; partBtn = mkButton(Body, "Target part: " .. C.hitPart, function()
        local idx = 1; for i, v in ipairs(PART_ORDER) do if v == C.hitPart then idx = i end end
        C.hitPart = PART_ORDER[(idx % #PART_ORDER) + 1]; partBtn.Text = "Target part: " .. C.hitPart; task.spawn(discover)
    end)

    section("TARGETS")
    mkToggle(Body, "Auto-detect mobs", C.autoMobs, function(v) C.autoMobs = v; if v then task.spawn(discover) end end)
    mkButton(Body, "Rescan world now", function() task.spawn(discover) end)
    mkToggle(Body, "ESP mobs", C.espMobs, function(v) C.espMobs = v end)
    mkToggle(Body, "ESP players", C.espPlayers, function(v) C.espPlayers = v end)

    section("SHOT PATHS")
    mkToggle(Body, "Remote args (silent)", C.pNet, function(v) C.pNet = v end)
    mkToggle(Body, "Remote args, blind (no method name)", C.netBlind, function(v) C.netBlind = v end)
    mkToggle(Body, "Touch ray", C.pRay, function(v) C.pRay = v end)
    mkToggle(Body, "Mouse location", C.pLoc, function(v) C.pLoc = v end)
    mkToggle(Body, "GameUIMod.GetMousePos", C.pMouse, function(v) C.pMouse = v end)
    mkToggle(Body, "Mouse.Hit / Target / UnitRay / X / Y", C.pHit, function(v) C.pHit = v; syncIndex() end)
    mkButton(Body, "Dump shot log to console", dumpLog)

    section("ESP")
    mkToggle(Body, "Enable ESP", C.esp, function(v) C.esp = v end)
    mkToggle(Body, "Names", C.espName, function(v) C.espName = v end)
    mkToggle(Body, "Distance", C.espDist, function(v) C.espDist = v end)
    mkToggle(Body, "Health bar", C.espHp, function(v) C.espHp = v end)
    mkToggle(Body, "Chams", C.espChams, function(v) C.espChams = v end)
    mkToggle(Body, "Tracer lines", C.espLine, function(v) C.espLine = v end)
    mkSlider(Body, "ESP max distance", 200, 3000, C.espMax, function(v) C.espMax = v end)

    section("DIAG")
    mkButton(Body, "Run diagnostics (console + panel)", diagnostics)
    mkButton(Body, "Copy diag to clipboard", function() pcall(function() if setclipboard then setclipboard(DiagBox.Text) end end) end)

    mkToggle(Body, "Open panel on load", true, function(v) setPanel(v) end)
    setPanel(true)

    -- unload
    local function unload()
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end; conns = {}
        pcall(function() R:UnbindFromRenderStep(BIND) end)
        uninstall()
        for model, rec in pairs(esp) do destroy(rec); esp[model] = nil end
        if tracerPart then pcall(function() tracerPart:Destroy() end) end
        pcall(function() Gui:Destroy() end)
        _G.__hs = nil; pcall(function() if getgenv then getgenv().__hs = nil end end)
    end

    _G.__hs = { unload = unload, config = C, diag = diagnostics, dump = dumpLog, log = dumpLog, discover = discover, stats = function() return S.mp, S.loc, S.ray, S.net, S.namecall ~= nil, S.inst end }
    if getgenv then pcall(function() getgenv().__hs = _G.__hs end) end

    task.spawn(function() pcall(installAll); pcall(discover); task.wait(3); print("[hs] post-load diag v5"); pcall(diagnostics) end)
    overlay(); print("[hs] ready v5")
end)

if not __hs_ok then
    local msg = "[hs] FATAL " .. tostring(__hs_err)
    warn(msg); pcall(function() if setclipboard then setclipboard(msg) end end)
    pcall(function()
        local sg = Instance.new("ScreenGui"); sg.Name = "HS_Fatal"; sg.ResetOnSpawn = false; sg.DisplayOrder = 2147483647
        local okh, h = pcall(function() return gethui and gethui() end); sg.Parent = (okh and h) or game:GetService("CoreGui")
        local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -40, 0, 130); lbl.Position = UDim2.new(0, 20, 0, 20)
        lbl.BackgroundColor3 = Color3.fromRGB(30, 0, 0); lbl.BackgroundTransparency = 0.1; lbl.TextColor3 = Color3.fromRGB(255, 120, 120)
        lbl.Font = Enum.Font.Code; lbl.TextSize = 12; lbl.TextWrapped = true; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextYAlignment = Enum.TextYAlignment.Top
        lbl.Text = msg; lbl.Parent = sg; task.delay(30, function() pcall(function() sg:Destroy() end) end)
    end)
end
