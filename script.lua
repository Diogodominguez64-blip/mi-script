-- ╔══════════════════════════════════════════════╗
-- ║   DIOGO SCRIPT v5  |  MM2 Edition           ║
-- ║   Key: Diogo1234                            ║
-- ╚══════════════════════════════════════════════╝

local KEY_CORRECTA     = "Diogo1234"
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")
local lp               = Players.LocalPlayer
local camera           = workspace.CurrentCamera

-- ═══════════════════════════════════════════
--  PALETA
-- ═══════════════════════════════════════════
local C = {
    bg0     = Color3.fromRGB(6,   6,  12),
    bg1     = Color3.fromRGB(10,  10,  18),
    bg2     = Color3.fromRGB(14,  14,  24),
    bg3     = Color3.fromRGB(20,  20,  36),
    accent  = Color3.fromRGB(110, 60, 255),
    accentB = Color3.fromRGB(50, 170, 255),
    accentG = Color3.fromRGB(50, 230, 130),
    accentR = Color3.fromRGB(255, 55,  75),
    accentY = Color3.fromRGB(255, 200, 50),
    text    = Color3.fromRGB(228, 228, 245),
    textDim = Color3.fromRGB(110, 115, 155),
    line    = Color3.fromRGB(26,  26,  50),
    sheriff  = Color3.fromRGB(50,  180, 255),
    murder   = Color3.fromRGB(255, 50,  70),
    innocent = Color3.fromRGB(80,  255, 140),
    gunFloor = Color3.fromRGB(255, 220, 50),
}

-- ═══════════════════════════════════════════
--  DETECCION DE ROLES MM2
-- ═══════════════════════════════════════════
local function getRole(player)
    local char = player.Character
    local bp   = player:FindFirstChildOfClass("Backpack")

    local function hasTool(name)
        local nl = name:lower()
        if char then
            for _, t in ipairs(char:GetChildren()) do
                if t:IsA("Tool") and t.Name:lower():find(nl) then return true end
            end
        end
        if bp then
            for _, t in ipairs(bp:GetChildren()) do
                if t:IsA("Tool") and t.Name:lower():find(nl) then return true end
            end
        end
        return false
    end

    if hasTool("Knife")   then return "murder"  end
    if hasTool("Revolver") or hasTool("Sheriff") or hasTool("Gun") or hasTool("Pistol") then
        return "sheriff"
    end

    local function scanValues(parent)
        if not parent then return nil end
        for _, v in ipairs(parent:GetChildren()) do
            local n = v.Name:lower()
            if n == "role" or n == "team" or n == "playerrole" then
                local val = (v:IsA("StringValue") or v:IsA("IntValue")) and tostring(v.Value):lower()
                if val then
                    if val == "murderer" or val == "murder" or val == "2" then return "murder"  end
                    if val == "sheriff"  or val == "1"                    then return "sheriff" end
                    if val == "innocent" or val == "0"                    then return "innocent" end
                end
            end
        end
        return nil
    end

    local r = scanValues(char) or scanValues(player)
    if r then return r end

    local ls = player:FindFirstChild("leaderstats")
    if ls then
        local rv = ls:FindFirstChild("Role") or ls:FindFirstChild("role")
        if rv then
            local s = tostring(rv.Value):lower()
            if s:find("murder")  then return "murder"  end
            if s:find("sheriff") then return "sheriff" end
        end
    end

    return "innocent"
end

local function roleColor(role)
    if role == "murder"  then return C.murder  end
    if role == "sheriff" then return C.sheriff  end
    return C.innocent
end

local function roleLabel(role)
    if role == "murder"  then return "MURDER"  end
    if role == "sheriff" then return "SHERIFF" end
    return "INOCENTE"
end

-- ═══════════════════════════════════════════
--  TOAST SYSTEM
-- ═══════════════════════════════════════════
local ToastGui = Instance.new("ScreenGui")
ToastGui.Name = "DToasts"
ToastGui.ResetOnSpawn = false
ToastGui.IgnoreGuiInset = true
ToastGui.Parent = game:GetService("CoreGui")
local toastY = 24

local function toast(msg, color)
    color = color or C.accentB
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 270, 0, 42)
    f.Position = UDim2.new(1, 20, 0, toastY)
    f.BackgroundColor3 = C.bg1
    f.BorderSizePixel = 0
    f.ZIndex = 60
    f.Parent = ToastGui
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 4, 1, 0)
    bar.BackgroundColor3 = color
    bar.BorderSizePixel = 0
    bar.ZIndex = 61
    bar.Parent = f
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -16, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = msg
    lbl.TextColor3 = C.text
    lbl.TextScaled = true
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 61
    lbl.Parent = f

    local stroke = Instance.new("UIStroke", f)
    stroke.Color = color

    TweenService:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Position = UDim2.new(1, -282, 0, toastY)
    }):Play()
    toastY += 50

    task.delay(2.8, function()
        TweenService:Create(f, TweenInfo.new(0.25), {
            Position = UDim2.new(1, 20, 0, f.Position.Y.Offset),
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.3)
        f:Destroy()
        toastY = math.max(24, toastY - 50)
    end)
end

-- ═══════════════════════════════════════════
--  KEY GUI
-- ═══════════════════════════════════════════
local KeyGui = Instance.new("ScreenGui")
KeyGui.Name = "KeySystem"
KeyGui.ResetOnSpawn = false
KeyGui.IgnoreGuiInset = true
KeyGui.Parent = game:GetService("CoreGui")

local Overlay = Instance.new("Frame")
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.BackgroundColor3 = Color3.new(0, 0, 0)
Overlay.BackgroundTransparency = 0.5
Overlay.BorderSizePixel = 0
Overlay.ZIndex = 1
Overlay.Parent = KeyGui

local KF = Instance.new("Frame")
KF.Size = UDim2.new(0, 0, 0, 0)
KF.Position = UDim2.new(0.5, 0, 0.5, 0)
KF.AnchorPoint = Vector2.new(0.5, 0.5)
KF.BackgroundColor3 = C.bg1
KF.BorderSizePixel = 0
KF.ZIndex = 2
KF.Parent = KeyGui
Instance.new("UICorner", KF).CornerRadius = UDim.new(0, 16)
local KStr = Instance.new("UIStroke")
KStr.Color = C.accent
KStr.Thickness = 2
KStr.Parent = KF

TweenService:Create(KF, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 420, 0, 260)
}):Play()

local KTopBar = Instance.new("Frame")
KTopBar.Size = UDim2.new(1, 0, 0, 4)
KTopBar.BackgroundColor3 = C.accent
KTopBar.BorderSizePixel = 0
KTopBar.ZIndex = 3
KTopBar.Parent = KF
Instance.new("UICorner", KTopBar).CornerRadius = UDim.new(1, 0)
Instance.new("UIGradient", KTopBar).Color = ColorSequence.new(C.accent, C.accentB)

local KTitle = Instance.new("TextLabel")
KTitle.Size = UDim2.new(1, 0, 0, 52)
KTitle.Position = UDim2.new(0, 0, 0, 14)
KTitle.BackgroundTransparency = 1
KTitle.Text = "DIOGO SCRIPT  //  MM2"
KTitle.TextColor3 = C.text
KTitle.TextScaled = true
KTitle.Font = Enum.Font.GothamBold
KTitle.ZIndex = 3
KTitle.Parent = KF

local KSub = Instance.new("TextLabel")
KSub.Size = UDim2.new(1, 0, 0, 18)
KSub.Position = UDim2.new(0, 0, 0, 68)
KSub.BackgroundTransparency = 1
KSub.Text = "Ingresa tu key para continuar"
KSub.TextColor3 = C.textDim
KSub.TextScaled = true
KSub.Font = Enum.Font.Gotham
KSub.ZIndex = 3
KSub.Parent = KF

local KBox = Instance.new("TextBox")
KBox.Size = UDim2.new(0.82, 0, 0, 44)
KBox.Position = UDim2.new(0.09, 0, 0, 100)
KBox.BackgroundColor3 = C.bg3
KBox.TextColor3 = C.text
KBox.PlaceholderText = "Pega tu key aqui..."
KBox.PlaceholderColor3 = C.textDim
KBox.Text = ""
KBox.TextScaled = true
KBox.Font = Enum.Font.Gotham
KBox.BorderSizePixel = 0
KBox.ClearTextOnFocus = false
KBox.ZIndex = 3
KBox.Parent = KF
Instance.new("UICorner", KBox).CornerRadius = UDim.new(0, 10)
local KBStr = Instance.new("UIStroke")
KBStr.Color = C.line
KBStr.Thickness = 1.5
KBStr.Parent = KBox
KBox.Focused:Connect(function()  TweenService:Create(KBStr, TweenInfo.new(0.2), {Color = C.accent}):Play() end)
KBox.FocusLost:Connect(function() TweenService:Create(KBStr, TweenInfo.new(0.2), {Color = C.line}):Play()   end)

local function mkKBtn(text, posX, bg, tc)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.35, 0, 0, 40)
    b.Position = UDim2.new(posX, 0, 0, 158)
    b.BackgroundColor3 = bg
    b.TextColor3 = tc
    b.Text = text
    b.TextScaled = true
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    b.ZIndex = 3
    b.Parent = KF
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = bg:Lerp(Color3.new(1,1,1), 0.15)}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = bg}):Play() end)
    return b
end

local GetKeyBtn = mkKBtn("Get Key",   0.09, C.bg3,   C.accentB)
local VerifyBtn = mkKBtn("Verificar", 0.56, C.accent, Color3.new(1,1,1))

local KStatus = Instance.new("TextLabel")
KStatus.Size = UDim2.new(1, 0, 0, 28)
KStatus.Position = UDim2.new(0, 0, 0, 212)
KStatus.BackgroundTransparency = 1
KStatus.Text = ""
KStatus.TextScaled = true
KStatus.Font = Enum.Font.Gotham
KStatus.ZIndex = 3
KStatus.Parent = KF

GetKeyBtn.MouseButton1Click:Connect(function()
    KStatus.TextColor3 = C.accentB
    KStatus.Text = "KEY: Diogo1234"
end)

VerifyBtn.MouseButton1Click:Connect(function()
    if KBox.Text == KEY_CORRECTA then
        KStatus.TextColor3 = C.accentG
        KStatus.Text = "Verificado! Cargando..."
        TweenService:Create(KF, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        task.wait(0.35)
        KeyGui:Destroy()

        -- ════════════════════════════════════════════════════════════
        --                        MAIN SCRIPT
        -- ════════════════════════════════════════════════════════════
        local speedEnabled  = false
        local noclipEnabled = false
        local flyEnabled    = false
        local jumpEnabled   = false
        local espEnabled    = false
        local currentSpeed  = 50
        local currentJump   = 50
        local hideKey       = Enum.KeyCode.RightShift
        local uiVisible     = true
        local speedLoop, noclipLoop, flyLoop, espLoop
        local espObjects    = {}

        -- ════════════════════════════════════════
        --  MAIN GUI
        -- ════════════════════════════════════════
        local MainGui = Instance.new("ScreenGui")
        MainGui.Name = "DiogoScript"
        MainGui.ResetOnSpawn = false
        MainGui.IgnoreGuiInset = true
        MainGui.Parent = game:GetService("CoreGui")

        local Main = Instance.new("Frame")
        Main.Size = UDim2.new(0, 0, 0, 0)
        Main.Position = UDim2.new(0.5, 0, 0.5, 0)
        Main.AnchorPoint = Vector2.new(0.5, 0.5)
        Main.BackgroundColor3 = C.bg1
        Main.BorderSizePixel = 0
        Main.ClipsDescendants = true
        Main.Parent = MainGui
        Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)
        local MStr = Instance.new("UIStroke")
        MStr.Color = C.accent
        MStr.Thickness = 1.5
        MStr.Parent = Main

        TweenService:Create(Main, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 620, 0, 430)
        }):Play()

        local TopGrad = Instance.new("Frame")
        TopGrad.Size = UDim2.new(1, 0, 0, 4)
        TopGrad.BackgroundColor3 = C.accent
        TopGrad.BorderSizePixel = 0
        TopGrad.ZIndex = 9
        TopGrad.Parent = Main
        Instance.new("UICorner", TopGrad).CornerRadius = UDim.new(1, 0)
        Instance.new("UIGradient", TopGrad).Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   C.accent),
            ColorSequenceKeypoint.new(0.5, C.accentB),
            ColorSequenceKeypoint.new(1,   C.accent),
        })

        -- Header
        local Header = Instance.new("Frame")
        Header.Size = UDim2.new(1, 0, 0, 46)
        Header.Position = UDim2.new(0, 0, 0, 4)
        Header.BackgroundColor3 = C.bg0
        Header.BorderSizePixel = 0
        Header.ZIndex = 8
        Header.Parent = Main

        local HIcon = Instance.new("Frame")
        HIcon.Size = UDim2.new(0, 30, 0, 30)
        HIcon.Position = UDim2.new(0, 14, 0.5, -15)
        HIcon.BackgroundColor3 = C.accent
        HIcon.BorderSizePixel = 0
        HIcon.ZIndex = 9
        HIcon.Parent = Header
        Instance.new("UICorner", HIcon).CornerRadius = UDim.new(0, 7)

        local HIconLabel = Instance.new("TextLabel")
        HIconLabel.Size = UDim2.new(1, 0, 1, 0)
        HIconLabel.BackgroundTransparency = 1
        HIconLabel.Text = "D"
        HIconLabel.TextColor3 = Color3.new(1,1,1)
        HIconLabel.TextScaled = true
        HIconLabel.Font = Enum.Font.GothamBlack
        HIconLabel.ZIndex = 10
        HIconLabel.Parent = HIcon

        local HTitle = Instance.new("TextLabel")
        HTitle.Size = UDim2.new(0, 170, 1, 0)
        HTitle.Position = UDim2.new(0, 52, 0, 0)
        HTitle.BackgroundTransparency = 1
        HTitle.Text = "DIOGO SCRIPT"
        HTitle.TextColor3 = C.text
        HTitle.TextScaled = true
        HTitle.Font = Enum.Font.GothamBold
        HTitle.TextXAlignment = Enum.TextXAlignment.Left
        HTitle.ZIndex = 9
        HTitle.Parent = Header

        local HBadge = Instance.new("Frame")
        HBadge.Size = UDim2.new(0, 58, 0, 22)
        HBadge.Position = UDim2.new(0, 228, 0.5, -11)
        HBadge.BackgroundColor3 = C.accentR
        HBadge.BorderSizePixel = 0
        HBadge.ZIndex = 9
        HBadge.Parent = Header
        Instance.new("UICorner", HBadge).CornerRadius = UDim.new(0, 6)
        Instance.new("UIGradient", HBadge).Color = ColorSequence.new(C.accentR, Color3.fromRGB(255,100,50))

        local HBLbl = Instance.new("TextLabel")
        HBLbl.Size = UDim2.new(1, 0, 1, 0)
        HBLbl.BackgroundTransparency = 1
        HBLbl.Text = "MM2"
        HBLbl.TextColor3 = Color3.new(1,1,1)
        HBLbl.TextScaled = true
        HBLbl.Font = Enum.Font.GothamBold
        HBLbl.ZIndex = 10
        HBLbl.Parent = HBadge

        local MinBtn = Instance.new("TextButton")
        MinBtn.Size = UDim2.new(0, 34, 0, 34)
        MinBtn.Position = UDim2.new(1, -46, 0.5, -17)
        MinBtn.BackgroundColor3 = C.accentR
        MinBtn.TextColor3 = Color3.new(1,1,1)
        MinBtn.Text = "X"
        MinBtn.TextScaled = true
        MinBtn.Font = Enum.Font.GothamBold
        MinBtn.BorderSizePixel = 0
        MinBtn.ZIndex = 10
        MinBtn.Parent = Header
        Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(1, 0)
        MinBtn.MouseEnter:Connect(function() TweenService:Create(MinBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255,100,110)}):Play() end)
        MinBtn.MouseLeave:Connect(function() TweenService:Create(MinBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.accentR}):Play() end)

        local HLine = Instance.new("Frame")
        HLine.Size = UDim2.new(1, 0, 0, 1)
        HLine.Position = UDim2.new(0, 0, 0, 50)
        HLine.BackgroundColor3 = C.line
        HLine.BorderSizePixel = 0
        HLine.Parent = Main

        -- Sidebar
        local Sidebar = Instance.new("Frame")
        Sidebar.Size = UDim2.new(0, 130, 1, -51)
        Sidebar.Position = UDim2.new(0, 0, 0, 51)
        Sidebar.BackgroundColor3 = C.bg0
        Sidebar.BorderSizePixel = 0
        Sidebar.ZIndex = 7
        Sidebar.Parent = Main

        local SLine = Instance.new("Frame")
        SLine.Size = UDim2.new(0, 1, 1, -51)
        SLine.Position = UDim2.new(0, 130, 0, 51)
        SLine.BackgroundColor3 = C.line
        SLine.BorderSizePixel = 0
        SLine.Parent = Main

        local Content = Instance.new("Frame")
        Content.Size = UDim2.new(1, -132, 1, -53)
        Content.Position = UDim2.new(0, 132, 0, 53)
        Content.BackgroundColor3 = C.bg2
        Content.BorderSizePixel = 0
        Content.ClipsDescendants = true
        Content.Parent = Main

        -- ════════════════════════════════════════
        --  TABS
        -- ════════════════════════════════════════
        local tabs     = {}
        local tabPages = {}
        local activeTab = nil

        local tabDefs = {
            {name = "Movement", label = "Movement"},
            {name = "Teleport",  label = "Teleport"},
            {name = "ESP",       label = "ESP"},
            {name = "Misc",      label = "Misc"},
        }

        local function switchTab(name)
            for n, t in pairs(tabs) do
                TweenService:Create(t.btn, TweenInfo.new(0.2), {
                    BackgroundTransparency = 1,
                    TextColor3 = C.textDim,
                }):Play()
                t.ind.Visible = false
                tabPages[n].Visible = false
            end
            TweenService:Create(tabs[name].btn, TweenInfo.new(0.2), {
                BackgroundTransparency = 0,
                TextColor3 = C.accentB,
            }):Play()
            tabs[name].ind.Visible = true
            tabPages[name].Visible = true
            activeTab = name
        end

        local function crearTab(def, idx)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 48)
            btn.Position = UDim2.new(0, 5, 0, (idx-1)*52 + 8)
            btn.BackgroundColor3 = Color3.fromRGB(22, 22, 40)
            btn.BackgroundTransparency = 1
            btn.TextColor3 = C.textDim
            btn.Text = def.label
            btn.TextScaled = true
            btn.Font = Enum.Font.GothamBold
            btn.BorderSizePixel = 0
            btn.ZIndex = 8
            btn.Parent = Sidebar
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

            local ind = Instance.new("Frame")
            ind.Size = UDim2.new(0, 4, 0.55, 0)
            ind.Position = UDim2.new(0, 0, 0.225, 0)
            ind.BackgroundColor3 = C.accent
            ind.BorderSizePixel = 0
            ind.Visible = false
            ind.ZIndex = 9
            ind.Parent = btn
            Instance.new("UICorner", ind).CornerRadius = UDim.new(1, 0)

            local page = Instance.new("ScrollingFrame")
            page.Size = UDim2.new(1, 0, 1, 0)
            page.BackgroundTransparency = 1
            page.BorderSizePixel = 0
            page.ScrollBarThickness = 3
            page.ScrollBarImageColor3 = C.accent
            page.CanvasSize = UDim2.new(0, 0, 0, 800)
            page.Visible = false
            page.ZIndex = 4
            page.Parent = Content

            tabs[def.name]     = {btn = btn, ind = ind}
            tabPages[def.name] = page

            btn.MouseEnter:Connect(function()
                if activeTab ~= def.name then
                    TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.6}):Play()
                end
            end)
            btn.MouseLeave:Connect(function()
                if activeTab ~= def.name then
                    TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
                end
            end)
            btn.MouseButton1Click:Connect(function() switchTab(def.name) end)
            return page
        end

        local movPage  = crearTab(tabDefs[1], 1)
        local tpPage   = crearTab(tabDefs[2], 2)
        local espPage  = crearTab(tabDefs[3], 3)
        local miscPage = crearTab(tabDefs[4], 4)
        switchTab("Movement")

        -- ════════════════════════════════════════
        --  HELPERS UI
        -- ════════════════════════════════════════
        local function secTitle(parent, texto, posY)
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, -20, 0, 28)
            f.Position = UDim2.new(0, 10, 0, posY)
            f.BackgroundTransparency = 1
            f.ZIndex = 5
            f.Parent = parent
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0, 190, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = texto:upper()
            lbl.TextColor3 = C.accent
            lbl.TextScaled = true
            lbl.Font = Enum.Font.GothamBold
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 5
            lbl.Parent = f
            local line = Instance.new("Frame")
            line.Size = UDim2.new(1, -200, 0, 1)
            line.Position = UDim2.new(0, 200, 0.5, 0)
            line.BackgroundColor3 = C.line
            line.BorderSizePixel = 0
            line.ZIndex = 5
            line.Parent = f
        end

        local function mkToggle(parent, texto, posY, cb)
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, -20, 0, 42)
            row.Position = UDim2.new(0, 10, 0, posY)
            row.BackgroundColor3 = C.bg3
            row.BorderSizePixel = 0
            row.ZIndex = 5
            row.Parent = parent
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0.65, 0, 1, 0)
            lbl.Position = UDim2.new(0, 14, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = texto
            lbl.TextColor3 = C.text
            lbl.TextScaled = true
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 6
            lbl.Parent = row
            local bg = Instance.new("Frame")
            bg.Size = UDim2.new(0, 48, 0, 26)
            bg.Position = UDim2.new(1, -60, 0.5, -13)
            bg.BackgroundColor3 = Color3.fromRGB(30, 30, 52)
            bg.BorderSizePixel = 0
            bg.ZIndex = 6
            bg.Parent = row
            Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
            local circle = Instance.new("Frame")
            circle.Size = UDim2.new(0, 20, 0, 20)
            circle.Position = UDim2.new(0, 3, 0.5, -10)
            circle.BackgroundColor3 = C.textDim
            circle.BorderSizePixel = 0
            circle.ZIndex = 7
            circle.Parent = bg
            Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
            local on = false
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.ZIndex = 8
            btn.Parent = bg
            btn.MouseButton1Click:Connect(function()
                on = not on
                TweenService:Create(bg, TweenInfo.new(0.18), {
                    BackgroundColor3 = on and C.accent or Color3.fromRGB(30,30,52)
                }):Play()
                TweenService:Create(circle, TweenInfo.new(0.18), {
                    Position = on and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10),
                    BackgroundColor3 = on and Color3.new(1,1,1) or C.textDim,
                }):Play()
                cb(on)
            end)
        end

        local function mkSlider(parent, texto, posY, minV, maxV, defV, cb)
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, -20, 0, 62)
            f.Position = UDim2.new(0, 10, 0, posY)
            f.BackgroundColor3 = C.bg3
            f.BorderSizePixel = 0
            f.ZIndex = 5
            f.Parent = parent
            Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0.65, 0, 0, 24)
            lbl.Position = UDim2.new(0, 14, 0, 6)
            lbl.BackgroundTransparency = 1
            lbl.Text = texto
            lbl.TextColor3 = C.text
            lbl.TextScaled = true
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 6
            lbl.Parent = f
            local valLbl = Instance.new("TextLabel")
            valLbl.Size = UDim2.new(0.28, 0, 0, 24)
            valLbl.Position = UDim2.new(0.68, 0, 0, 6)
            valLbl.BackgroundTransparency = 1
            valLbl.Text = tostring(defV)
            valLbl.TextColor3 = C.accentB
            valLbl.TextScaled = true
            valLbl.Font = Enum.Font.GothamBold
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.ZIndex = 6
            valLbl.Parent = f
            local track = Instance.new("Frame")
            track.Size = UDim2.new(1, -28, 0, 6)
            track.Position = UDim2.new(0, 14, 0, 44)
            track.BackgroundColor3 = Color3.fromRGB(26, 26, 50)
            track.BorderSizePixel = 0
            track.ZIndex = 6
            track.Parent = f
            Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((defV-minV)/(maxV-minV), 0, 1, 0)
            fill.BackgroundColor3 = C.accent
            fill.BorderSizePixel = 0
            fill.ZIndex = 7
            fill.Parent = track
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
            Instance.new("UIGradient", fill).Color = ColorSequence.new(C.accent, C.accentB)
            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 16, 0, 16)
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.Position = UDim2.new((defV-minV)/(maxV-minV), 0, 0.5, 0)
            knob.BackgroundColor3 = Color3.new(1,1,1)
            knob.BorderSizePixel = 0
            knob.ZIndex = 8
            knob.Parent = track
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
            local ks = Instance.new("UIStroke")
            ks.Color = C.accent
            ks.Thickness = 2
            ks.Parent = knob
            local sliding = false
            track.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = true end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = false end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    local rel = math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    local val = math.round(minV + (maxV - minV) * rel)
                    fill.Size = UDim2.new(rel, 0, 1, 0)
                    knob.Position = UDim2.new(rel, 0, 0.5, 0)
                    valLbl.Text = tostring(val)
                    cb(val)
                end
            end)
        end

        local function mkButton(parent, texto, posY, col, cb)
            col = col or C.accent
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -20, 0, 42)
            btn.Position = UDim2.new(0, 10, 0, posY)
            btn.BackgroundColor3 = col
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Text = texto
            btn.TextScaled = true
            btn.Font = Enum.Font.GothamBold
            btn.BorderSizePixel = 0
            btn.ZIndex = 5
            btn.Parent = parent
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
            btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = col:Lerp(Color3.new(1,1,1), 0.18)}):Play() end)
            btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = col}):Play() end)
            btn.MouseButton1Click:Connect(cb)
            return btn
        end

        -- ════════════════════════════════════════
        --  MOVEMENT TAB
        -- ════════════════════════════════════════
        secTitle(movPage, "Speed", 10)
        mkToggle(movPage, "Enable Speed", 46, function(on)
            speedEnabled = on
            if on then
                speedLoop = RunService.Heartbeat:Connect(function()
                    local c = lp.Character
                    if c then
                        local h = c:FindFirstChildOfClass("Humanoid")
                        if h then h.WalkSpeed = currentSpeed end
                    end
                end)
                toast("Speed ON: " .. currentSpeed, C.accentG)
            else
                if speedLoop then speedLoop:Disconnect() speedLoop = nil end
                local c = lp.Character
                if c then
                    local h = c:FindFirstChildOfClass("Humanoid")
                    if h then h.WalkSpeed = 16 end
                end
                toast("Speed OFF", C.accentR)
            end
        end)
        mkSlider(movPage, "Speed Value", 98, 16, 300, 50, function(v) currentSpeed = v end)

        secTitle(movPage, "Jump", 174)
        mkToggle(movPage, "Enable Jump Power", 210, function(on)
            jumpEnabled = on
            local c = lp.Character
            if c then
                local h = c:FindFirstChildOfClass("Humanoid")
                if h then
                    h.UseJumpPower = true
                    h.JumpPower = on and currentJump or 50
                end
            end
            toast(on and "Jump ON" or "Jump OFF", on and C.accentG or C.accentR)
        end)
        mkSlider(movPage, "Jump Value", 262, 50, 500, 50, function(v)
            currentJump = v
            if jumpEnabled then
                local c = lp.Character
                if c then
                    local h = c:FindFirstChildOfClass("Humanoid")
                    if h then h.UseJumpPower = true h.JumpPower = v end
                end
            end
        end)

        secTitle(movPage, "Fly  (WASD + Space/LCtrl)", 340)
        mkToggle(movPage, "Enable Fly", 376, function(on)
            flyEnabled = on
            local char = lp.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            if on then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = true end
                local bv = Instance.new("BodyVelocity")
                bv.Name = "FlyVel" bv.Velocity = Vector3.zero
                bv.MaxForce = Vector3.new(1e5,1e5,1e5) bv.Parent = hrp
                local bg = Instance.new("BodyGyro")
                bg.Name = "FlyGyro" bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
                bg.D = 50 bg.Parent = hrp
                flyLoop = RunService.Heartbeat:Connect(function()
                    local c = lp.Character if not c then return end
                    local r = c:FindFirstChild("HumanoidRootPart") if not r then return end
                    local vel  = r:FindFirstChild("FlyVel")
                    local gyro = r:FindFirstChild("FlyGyro")
                    if not vel or not gyro then return end
                    local d = Vector3.zero
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then d += camera.CFrame.LookVector  end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then d -= camera.CFrame.LookVector  end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then d -= camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then d += camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space)       then d += Vector3.new(0,1,0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then d -= Vector3.new(0,1,0) end
                    vel.Velocity = d.Magnitude > 0 and d.Unit * 65 or Vector3.zero
                    gyro.CFrame  = camera.CFrame
                end)
                toast("Fly ON", C.accentG)
            else
                if flyLoop then flyLoop:Disconnect() flyLoop = nil end
                local v = hrp:FindFirstChild("FlyVel")
                local g = hrp:FindFirstChild("FlyGyro")
                if v then v:Destroy() end
                if g then g:Destroy() end
                local h = char:FindFirstChildOfClass("Humanoid")
                if h then h.PlatformStand = false end
                toast("Fly OFF", C.accentR)
            end
        end)

        secTitle(movPage, "Noclip", 432)
        mkToggle(movPage, "Enable Noclip", 468, function(on)
            noclipEnabled = on
            if on then
                noclipLoop = RunService.Stepped:Connect(function()
                    local c = lp.Character
                    if c then
                        for _, p in pairs(c:GetDescendants()) do
                            if p:IsA("BasePart") then p.CanCollide = false end
                        end
                    end
                end)
                toast("Noclip ON", C.accentG)
            else
                if noclipLoop then noclipLoop:Disconnect() noclipLoop = nil end
                toast("Noclip OFF", C.accentR)
            end
        end)

        -- ════════════════════════════════════════════════════════
        --  TELEPORT TAB
        -- ════════════════════════════════════════════════════════
        secTitle(tpPage, "Teleport a Jugadores", 10)

        local plrListFrame = Instance.new("Frame")
        plrListFrame.Size = UDim2.new(1, -20, 0, 200)
        plrListFrame.Position = UDim2.new(0, 10, 0, 44)
        plrListFrame.BackgroundColor3 = C.bg0
        plrListFrame.BorderSizePixel = 0
        plrListFrame.ZIndex = 5
        plrListFrame.Parent = tpPage
        Instance.new("UICorner", plrListFrame).CornerRadius = UDim.new(0, 10)

        local plrScroll = Instance.new("ScrollingFrame")
        plrScroll.Size = UDim2.new(1, -8, 1, -8)
        plrScroll.Position = UDim2.new(0, 4, 0, 4)
        plrScroll.BackgroundTransparency = 1
        plrScroll.BorderSizePixel = 0
        plrScroll.ScrollBarThickness = 3
        plrScroll.ScrollBarImageColor3 = C.accent
        plrScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        plrScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        plrScroll.ZIndex = 6
        plrScroll.Parent = plrListFrame
        local plrLayout = Instance.new("UIListLayout")
        plrLayout.Padding = UDim.new(0, 3)
        plrLayout.Parent = plrScroll

        local function refreshPlayers()
            for _, c in pairs(plrScroll:GetChildren()) do
                if not c:IsA("UIListLayout") then c:Destroy() end
            end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp then
                    local role = getRole(p)
                    local col  = roleColor(role)
                    local icon = roleLabel(role)

                    local row = Instance.new("Frame")
                    row.Size = UDim2.new(1, 0, 0, 40)
                    row.BackgroundColor3 = C.bg3
                    row.BorderSizePixel = 0
                    row.ZIndex = 7
                    row.Parent = plrScroll
                    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

                    local roleBar = Instance.new("Frame")
                    roleBar.Size = UDim2.new(0, 4, 1, 0)
                    roleBar.BackgroundColor3 = col
                    roleBar.BorderSizePixel = 0
                    roleBar.ZIndex = 8
                    roleBar.Parent = row
                    Instance.new("UICorner", roleBar).CornerRadius = UDim.new(0, 4)

                    local nameLbl = Instance.new("TextLabel")
                    nameLbl.Size = UDim2.new(0.55, 0, 1, 0)
                    nameLbl.Position = UDim2.new(0, 14, 0, 0)
                    nameLbl.BackgroundTransparency = 1
                    nameLbl.Text = p.Name
                    nameLbl.TextColor3 = C.text
                    nameLbl.TextScaled = true
                    nameLbl.Font = Enum.Font.GothamBold
                    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
                    nameLbl.ZIndex = 8
                    nameLbl.Parent = row

                    local roleLbl = Instance.new("TextLabel")
                    roleLbl.Size = UDim2.new(0.38, 0, 1, 0)
                    roleLbl.Position = UDim2.new(0.58, 0, 0, 0)
                    roleLbl.BackgroundTransparency = 1
                    roleLbl.Text = "[" .. icon .. "]"
                    roleLbl.TextColor3 = col
                    roleLbl.TextScaled = true
                    roleLbl.Font = Enum.Font.Gotham
                    roleLbl.TextXAlignment = Enum.TextXAlignment.Right
                    roleLbl.ZIndex = 8
                    roleLbl.Parent = row

                    local tpBtn = Instance.new("TextButton")
                    tpBtn.Size = UDim2.new(1, 0, 1, 0)
                    tpBtn.BackgroundTransparency = 1
                    tpBtn.Text = ""
                    tpBtn.ZIndex = 9
                    tpBtn.Parent = row
                    tpBtn.MouseEnter:Connect(function()
                        TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(32,32,58)}):Play()
                    end)
                    tpBtn.MouseLeave:Connect(function()
                        TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = C.bg3}):Play()
                    end)
                    tpBtn.MouseButton1Click:Connect(function()
                        local mc = lp.Character
                        local tc = p.Character
                        if mc and tc then
                            local mhrp = mc:FindFirstChild("HumanoidRootPart")
                            local thrp = tc:FindFirstChild("HumanoidRootPart")
                            if mhrp and thrp then
                                mhrp.CFrame = thrp.CFrame + Vector3.new(0, 3.5, 0)
                                toast("TP -> " .. p.Name .. " [" .. icon .. "]", col)
                            end
                        end
                    end)
                end
            end
        end

        refreshPlayers()
        mkButton(tpPage, "Actualizar Lista", 252, C.accent, function()
            refreshPlayers()
            toast("Lista actualizada", C.accentB)
        end)
        Players.PlayerAdded:Connect(function()   task.wait(1)   refreshPlayers() end)
        Players.PlayerRemoving:Connect(function() task.wait(0.1) refreshPlayers() end)

        -- ──────────────────────────────────────────────
        --  ARMA DEL SHERIFF EN SUELO
        -- ──────────────────────────────────────────────
        secTitle(tpPage, "Arma del Sheriff (suelo)", 306)

        local gunStatusLbl = Instance.new("TextLabel")
        gunStatusLbl.Size = UDim2.new(1, -20, 0, 32)
        gunStatusLbl.Position = UDim2.new(0, 10, 0, 340)
        gunStatusLbl.BackgroundColor3 = C.bg3
        gunStatusLbl.TextColor3 = C.textDim
        gunStatusLbl.Text = "  Estado: buscando..."
        gunStatusLbl.TextScaled = true
        gunStatusLbl.Font = Enum.Font.Gotham
        gunStatusLbl.TextXAlignment = Enum.TextXAlignment.Left
        gunStatusLbl.BorderSizePixel = 0
        gunStatusLbl.ZIndex = 5
        gunStatusLbl.Parent = tpPage
        Instance.new("UICorner", gunStatusLbl).CornerRadius = UDim.new(0, 8)

        local SHERIFF_GUN_NAMES = {
            "revolver","sheriffgun","sheriff_gun","sheriffweapon",
            "gun","pistol","classicsheriff","sheriff","sherrifgun",
            "dropped_gun","droppedgun","weapongun"
        }

        local cachedGun    = nil  -- cache para evitar scan completo cada frame
        local gunCacheTime = 0
        local GUN_CACHE_TTL = 0.5  -- re-escanea cada 0.5s

        local function findSheriffGun()
            local now = tick()
            if cachedGun and (now - gunCacheTime) < GUN_CACHE_TTL then
                -- Verifica que el cached sigue siendo válido
                if cachedGun.Parent then return cachedGun end
                cachedGun = nil
            end

            local function isEquippedByPlayer(obj)
                for _, p in ipairs(Players:GetPlayers()) do
                    local c = p.Character
                    if c and obj:IsDescendantOf(c) then return true end
                end
                return false
            end

            for _, obj in ipairs(workspace:GetDescendants()) do
                local n = obj.Name:lower()
                for _, name in ipairs(SHERIFF_GUN_NAMES) do
                    if n == name or n:find(name, 1, true) then
                        if not isEquippedByPlayer(obj) then
                            cachedGun    = obj
                            gunCacheTime = now
                            return obj
                        end
                    end
                end
            end
            cachedGun = nil
            return nil
        end

        local function getGunPosition(gun)
            if gun:IsA("BasePart") then return gun.Position end
            if gun:IsA("Model") or gun:IsA("Tool") then
                local pp = (gun:IsA("Model") and gun.PrimaryPart) or gun:FindFirstChildOfClass("BasePart")
                if pp then return pp.Position end
            end
            return nil
        end

        mkButton(tpPage, "TP a Arma del Sheriff", 380, C.gunFloor, function()
            local char = lp.Character
            if not char then toast("Sin personaje", C.accentR) return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local gun = findSheriffGun()
            if gun then
                local pos = getGunPosition(gun)
                if pos then
                    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 4, 0))
                    gunStatusLbl.Text = "  OK: " .. gun.Name
                    gunStatusLbl.TextColor3 = C.accentG
                    toast("TP a arma: " .. gun.Name, C.gunFloor)
                else
                    toast("Sin posicion del arma", C.accentY)
                end
            else
                toast("Arma no encontrada", C.accentR)
                gunStatusLbl.Text = "  No encontrada en workspace"
                gunStatusLbl.TextColor3 = C.accentR
            end
        end)

        mkButton(tpPage, "Buscar Arma (solo info)", 432, C.accentB, function()
            cachedGun = nil  -- fuerza re-scan
            local gun = findSheriffGun()
            if gun then
                local pos = getGunPosition(gun)
                local posStr = pos and string.format("(%.0f, %.0f, %.0f)", pos.X, pos.Y, pos.Z) or "?"
                gunStatusLbl.Text = "  " .. gun.Name .. " en " .. posStr
                gunStatusLbl.TextColor3 = C.gunFloor
                toast("Arma hallada: " .. gun.Name, C.gunFloor)
            else
                gunStatusLbl.Text = "  No esta en el suelo aun"
                gunStatusLbl.TextColor3 = C.textDim
                toast("Arma no en suelo", C.accentY)
            end
        end)

        local gunWatcher   = nil
        local gunAlertEnabled = false

        secTitle(tpPage, "Alerta de Arma Caida", 484)
        mkToggle(tpPage, "Auto-detectar Arma en Suelo", 520, function(on)
            gunAlertEnabled = on
            if on then
                local lastCheck = 0
                gunWatcher = RunService.Heartbeat:Connect(function()
                    local now = tick()
                    if now - lastCheck < 0.5 then return end  -- revisar cada 0.5s
                    lastCheck = now
                    local gun = findSheriffGun()
                    if gun then
                        gunStatusLbl.Text = "  ARMA EN SUELO: " .. gun.Name
                        gunStatusLbl.TextColor3 = C.gunFloor
                    else
                        gunStatusLbl.Text = "  Sin arma en suelo"
                        gunStatusLbl.TextColor3 = C.textDim
                    end
                end)
                toast("Detector de arma ON", C.gunFloor)
            else
                if gunWatcher then gunWatcher:Disconnect() gunWatcher = nil end
                toast("Detector de arma OFF", C.textDim)
            end
        end)

        -- ════════════════════════════════════════════════════════
        --  ESP MM2  -  OPTIMIZADO
        --  - Billboards siempre activos, sin lineas (caro)
        --  - Loop usa Heartbeat throttled a ~20fps
        --  - getRole se cachea por jugador con TTL de 0.4s
        --  - findSheriffGun usa cache propio
        --  - Sin pcall en el hot-path
        -- ════════════════════════════════════════════════════════

        local espEnabledSheriff  = true
        local espEnabledMurder   = true
        local espEnabledInnocent = true
        local espEnabledGunFloor = true
        local gunFloorBillboard  = nil

        -- Cache de roles por jugador
        local roleCache = {}
        local ROLE_CACHE_TTL = 0.4

        local function getCachedRole(player)
            local entry = roleCache[player]
            if entry and (tick() - entry.time) < ROLE_CACHE_TTL then
                return entry.role
            end
            local r = getRole(player)
            roleCache[player] = {role = r, time = tick()}
            return r
        end

        local function removeAllESP()
            for _, obj in pairs(espObjects) do
                if obj.billboard and obj.billboard.Parent then obj.billboard:Destroy() end
            end
            espObjects = {}
            if gunFloorBillboard and gunFloorBillboard.Parent then
                gunFloorBillboard:Destroy()
                gunFloorBillboard = nil
            end
            roleCache = {}
        end

        -- Crea el billboard de un jugador (solo una vez)
        local function createPlayerESP(player)
            if player == lp or espObjects[player] then return end

            local billboard = Instance.new("BillboardGui")
            billboard.Size = UDim2.new(0, 150, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 3.5, 0)
            billboard.AlwaysOnTop = true
            billboard.Enabled = false
            billboard.Parent = MainGui

            local bgFrame = Instance.new("Frame")
            bgFrame.Size = UDim2.new(1, 0, 1, 0)
            bgFrame.BackgroundColor3 = Color3.new(0, 0, 0)
            bgFrame.BackgroundTransparency = 0.45
            bgFrame.BorderSizePixel = 0
            bgFrame.ZIndex = 1
            bgFrame.Parent = billboard
            Instance.new("UICorner", bgFrame).CornerRadius = UDim.new(0, 6)

            local roleBar = Instance.new("Frame")
            roleBar.Size = UDim2.new(0, 4, 1, 0)
            roleBar.BackgroundColor3 = C.innocent
            roleBar.BorderSizePixel = 0
            roleBar.ZIndex = 2
            roleBar.Parent = billboard
            Instance.new("UICorner", roleBar).CornerRadius = UDim.new(0, 3)

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Size = UDim2.new(1, -8, 0.48, 0)
            nameLbl.Position = UDim2.new(0, 6, 0, 0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text = player.Name
            nameLbl.TextColor3 = Color3.new(1, 1, 1)
            nameLbl.TextScaled = true
            nameLbl.Font = Enum.Font.GothamBold
            nameLbl.TextStrokeTransparency = 0.3
            nameLbl.TextStrokeColor3 = Color3.new(0, 0, 0)
            nameLbl.ZIndex = 3
            nameLbl.Parent = billboard

            local roleLbl = Instance.new("TextLabel")
            roleLbl.Size = UDim2.new(1, -8, 0.48, 0)
            roleLbl.Position = UDim2.new(0, 6, 0.52, 0)
            roleLbl.BackgroundTransparency = 1
            roleLbl.Text = "[INOCENTE]"
            roleLbl.TextColor3 = C.innocent
            roleLbl.TextScaled = true
            roleLbl.Font = Enum.Font.GothamBold
            roleLbl.TextStrokeTransparency = 0.3
            roleLbl.TextStrokeColor3 = Color3.new(0, 0, 0)
            roleLbl.ZIndex = 3
            roleLbl.Parent = billboard

            espObjects[player] = {
                billboard = billboard,
                roleBar   = roleBar,
                roleLbl   = roleLbl,
                lastRole  = "",
            }

            player.AncestryChanged:Connect(function()
                if not player:IsDescendantOf(game) then
                    if billboard.Parent then billboard:Destroy() end
                    espObjects[player] = nil
                    roleCache[player]  = nil
                end
            end)
        end

        -- Crea el billboard del arma (una sola vez)
        local function ensureGunBillboard()
            if gunFloorBillboard and gunFloorBillboard.Parent then return gunFloorBillboard end

            local bb = Instance.new("BillboardGui")
            bb.Size = UDim2.new(0, 140, 0, 36)
            bb.StudsOffset = Vector3.new(0, 2, 0)
            bb.AlwaysOnTop = true
            bb.Enabled = false
            bb.Parent = MainGui

            local gbg = Instance.new("Frame")
            gbg.Size = UDim2.new(1, 0, 1, 0)
            gbg.BackgroundColor3 = Color3.new(0, 0, 0)
            gbg.BackgroundTransparency = 0.45
            gbg.BorderSizePixel = 0
            gbg.ZIndex = 1
            gbg.Parent = bb
            Instance.new("UICorner", gbg).CornerRadius = UDim.new(0, 6)

            local gbar = Instance.new("Frame")
            gbar.Size = UDim2.new(0, 4, 1, 0)
            gbar.BackgroundColor3 = C.gunFloor
            gbar.BorderSizePixel = 0
            gbar.ZIndex = 2
            gbar.Parent = bb
            Instance.new("UICorner", gbar).CornerRadius = UDim.new(0, 3)

            local glbl = Instance.new("TextLabel")
            glbl.Name = "GunLabel"
            glbl.Size = UDim2.new(1, -8, 1, 0)
            glbl.Position = UDim2.new(0, 8, 0, 0)
            glbl.BackgroundTransparency = 1
            glbl.Text = "[ARMA SHERIFF]"
            glbl.TextColor3 = C.gunFloor
            glbl.TextScaled = true
            glbl.Font = Enum.Font.GothamBold
            glbl.TextStrokeTransparency = 0.3
            glbl.TextStrokeColor3 = Color3.new(0, 0, 0)
            glbl.ZIndex = 3
            glbl.Parent = bb

            gunFloorBillboard = bb
            return bb
        end

        -- Loop ESP throttled: actualiza a ~20fps (cada 0.05s)
        local espLastUpdate = 0

        local function espTick()
            local now = tick()
            if now - espLastUpdate < 0.05 then return end
            espLastUpdate = now

            -- Jugadores
            for player, obj in pairs(espObjects) do
                local char = player.Character
                if char then
                    local head = char:FindFirstChild("Head")
                    if not head then
                        obj.billboard.Enabled = false
                        continue
                    end

                    local role = getCachedRole(player)
                    local col  = roleColor(role)
                    local icon = roleLabel(role)

                    local showThis =
                        (role == "sheriff"  and espEnabledSheriff)  or
                        (role == "murder"   and espEnabledMurder)    or
                        (role == "innocent" and espEnabledInnocent)

                    obj.billboard.Adornee  = head
                    obj.billboard.Enabled  = espEnabled and showThis

                    -- Solo actualizar labels si el rol cambio
                    if role ~= obj.lastRole then
                        obj.roleBar.BackgroundColor3 = col
                        obj.roleLbl.TextColor3       = col
                        obj.roleLbl.Text             = "[" .. icon .. "]"
                        obj.lastRole = role
                    end
                else
                    obj.billboard.Enabled = false
                end
            end

            -- Arma en suelo (usa cache interno de findSheriffGun)
            if espEnabled and espEnabledGunFloor then
                local gun = findSheriffGun()
                if gun then
                    local adornee = nil
                    if gun:IsA("BasePart") then adornee = gun
                    elseif gun:IsA("Model") or gun:IsA("Tool") then
                        adornee = gun.PrimaryPart or gun:FindFirstChildOfClass("BasePart")
                    end
                    if adornee then
                        local bb = ensureGunBillboard()
                        bb.Adornee = adornee
                        bb.Enabled = true
                    end
                else
                    if gunFloorBillboard then gunFloorBillboard.Enabled = false end
                end
            elseif gunFloorBillboard then
                gunFloorBillboard.Enabled = false
            end
        end

        local function toggleESP(on)
            espEnabled = on
            if on then
                for _, p in ipairs(Players:GetPlayers()) do createPlayerESP(p) end
                espLoop = RunService.Heartbeat:Connect(espTick)
                toast("ESP ON", C.accentG)
            else
                if espLoop then espLoop:Disconnect() espLoop = nil end
                removeAllESP()
                toast("ESP OFF", C.accentR)
            end
        end

        Players.PlayerAdded:Connect(function(p)
            if espEnabled then task.wait(1) createPlayerESP(p) end
        end)

        -- UI ESP
        secTitle(espPage, "ESP Global", 10)
        mkToggle(espPage, "Enable ESP  (MM2)", 46, toggleESP)

        secTitle(espPage, "Tipos de ESP", 102)

        local function mkEspRow(parent, label, col, posY, initState, cb)
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, -20, 0, 44)
            row.Position = UDim2.new(0, 10, 0, posY)
            row.BackgroundColor3 = C.bg3
            row.BorderSizePixel = 0
            row.ZIndex = 5
            row.Parent = parent
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

            local cbar = Instance.new("Frame")
            cbar.Size = UDim2.new(0, 5, 1, 0)
            cbar.BackgroundColor3 = col
            cbar.BorderSizePixel = 0
            cbar.ZIndex = 6
            cbar.Parent = row
            Instance.new("UICorner", cbar).CornerRadius = UDim.new(0, 4)

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0.6, 0, 1, 0)
            lbl.Position = UDim2.new(0, 18, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = label
            lbl.TextColor3 = col
            lbl.TextScaled = true
            lbl.Font = Enum.Font.GothamBold
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 6
            lbl.Parent = row

            local bg = Instance.new("Frame")
            bg.Size = UDim2.new(0, 46, 0, 24)
            bg.Position = UDim2.new(1, -58, 0.5, -12)
            bg.BackgroundColor3 = initState and col or Color3.fromRGB(30,30,52)
            bg.BorderSizePixel = 0
            bg.ZIndex = 6
            bg.Parent = row
            Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

            local circle = Instance.new("Frame")
            circle.Size = UDim2.new(0, 18, 0, 18)
            circle.Position = initState and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)
            circle.BackgroundColor3 = initState and Color3.new(1,1,1) or C.textDim
            circle.BorderSizePixel = 0
            circle.ZIndex = 7
            circle.Parent = bg
            Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

            local state = initState
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.ZIndex = 8
            btn.Parent = bg

            btn.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(bg, TweenInfo.new(0.18), {
                    BackgroundColor3 = state and col or Color3.fromRGB(30,30,52)
                }):Play()
                TweenService:Create(circle, TweenInfo.new(0.18), {
                    Position = state and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9),
                    BackgroundColor3 = state and Color3.new(1,1,1) or C.textDim,
                }):Play()
                cb(state)
            end)
        end

        mkEspRow(espPage, "SHERIFF",    C.sheriff,  138, true, function(on) espEnabledSheriff  = on end)
        mkEspRow(espPage, "MURDER",     C.murder,   192, true, function(on) espEnabledMurder   = on end)
        mkEspRow(espPage, "INOCENTES",  C.innocent, 246, true, function(on) espEnabledInnocent = on end)
        mkEspRow(espPage, "ARMA SUELO", C.gunFloor, 300, true, function(on)
            espEnabledGunFloor = on
            if not on and gunFloorBillboard then gunFloorBillboard.Enabled = false end
        end)

        local espInfo = Instance.new("TextLabel")
        espInfo.Size = UDim2.new(1, -20, 0, 60)
        espInfo.Position = UDim2.new(0, 10, 0, 360)
        espInfo.BackgroundColor3 = C.bg3
        espInfo.TextColor3 = C.textDim
        espInfo.Text = "  Roles detectados via tools (Knife / Revolver)\n  y por valores de rol en el personaje.\n  Actualizacion: ~20fps para menor lag."
        espInfo.TextScaled = true
        espInfo.Font = Enum.Font.Gotham
        espInfo.TextXAlignment = Enum.TextXAlignment.Left
        espInfo.TextYAlignment = Enum.TextYAlignment.Top
        espInfo.BorderSizePixel = 0
        espInfo.ZIndex = 5
        espInfo.Parent = espPage
        Instance.new("UICorner", espInfo).CornerRadius = UDim.new(0, 10)
        local eip = Instance.new("UIPadding", espInfo)
        eip.PaddingTop  = UDim.new(0, 8)
        eip.PaddingLeft = UDim.new(0, 6)

        -- ════════════════════════════════════════
        --  MISC TAB
        -- ════════════════════════════════════════
        secTitle(miscPage, "UI Controls", 10)
        local hkLbl = Instance.new("TextLabel")
        hkLbl.Size = UDim2.new(1, -20, 0, 32)
        hkLbl.Position = UDim2.new(0, 10, 0, 46)
        hkLbl.BackgroundColor3 = C.bg3
        hkLbl.TextColor3 = C.textDim
        hkLbl.Text = "  Hide Key: RightShift"
        hkLbl.TextScaled = true
        hkLbl.Font = Enum.Font.Gotham
        hkLbl.TextXAlignment = Enum.TextXAlignment.Left
        hkLbl.BorderSizePixel = 0
        hkLbl.ZIndex = 5
        hkLbl.Parent = miscPage
        Instance.new("UICorner", hkLbl).CornerRadius = UDim.new(0, 8)

        local changingKey = false
        local ckBtn = mkButton(miscPage, "Cambiar Tecla", 88, C.accent, function()
            changingKey = true
            ckBtn.Text = "Presiona una tecla..."
            TweenService:Create(ckBtn, TweenInfo.new(0.2), {BackgroundColor3 = C.accentY}):Play()
        end)

        secTitle(miscPage, "Visuals", 144)
        mkToggle(miscPage, "Fullbright", 180, function(on)
            Lighting.Brightness = on and 8 or 1
            Lighting.FogEnd = on and 9e8 or 100000
            for _, v in pairs(Lighting:GetChildren()) do
                if v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") then
                    v.Enabled = not on
                end
            end
            toast(on and "Fullbright ON" or "Fullbright OFF", on and C.accentG or C.accentR)
        end)
        mkToggle(miscPage, "Invisible (Local)", 232, function(on)
            local c = lp.Character
            if c then
                for _, p in pairs(c:GetDescendants()) do
                    if p:IsA("BasePart") or p:IsA("Decal") then p.Transparency = on and 1 or 0 end
                end
            end
            toast(on and "Invisible ON" or "Invisible OFF", on and C.accentG or C.accentR)
        end)

        -- ════════════════════════════════════════
        --  MINIMIZAR + DRAG + HOTKEY
        -- ════════════════════════════════════════
        local minimized = false
        MinBtn.MouseButton1Click:Connect(function()
            minimized = not minimized
            if minimized then
                for _, child in pairs(Main:GetChildren()) do
                    if child ~= MinBtn then child.Visible = false end
                end
                TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                    Size     = UDim2.new(0, 46, 0, 46),
                    Position = UDim2.new(1, -60, 0, 12),
                }):Play()
                MinBtn.Text = "="
                TweenService:Create(MinBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.accent}):Play()
                MinBtn.Position = UDim2.new(0, 6, 0, 6)
            else
                TweenService:Create(Main, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size     = UDim2.new(0, 620, 0, 430),
                    Position = UDim2.new(0.5, -310, 0.5, -215),
                }):Play()
                task.wait(0.18)
                for _, child in pairs(Main:GetChildren()) do child.Visible = true end
                MinBtn.Text = "X"
                TweenService:Create(MinBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.accentR}):Play()
                MinBtn.Position = UDim2.new(1, -46, 0.5, -17)
            end
        end)

        UserInputService.InputBegan:Connect(function(input, gpe)
            if changingKey and input.UserInputType == Enum.UserInputType.Keyboard then
                hideKey = input.KeyCode
                hkLbl.Text = "  Hide Key: " .. input.KeyCode.Name
                ckBtn.Text = "Cambiar Tecla"
                TweenService:Create(ckBtn, TweenInfo.new(0.2), {BackgroundColor3 = C.accent}):Play()
                changingKey = false
                toast("Tecla: " .. input.KeyCode.Name, C.accentB)
            elseif not changingKey
                and input.UserInputType == Enum.UserInputType.Keyboard
                and input.KeyCode == hideKey then
                uiVisible = not uiVisible
                Main.Visible = uiVisible
            end
        end)

        local dragging, dStart, dPos
        Header.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true dStart = i.Position dPos = Main.Position
            end
        end)
        Header.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch) then
                local d = i.Position - dStart
                Main.Position = UDim2.new(
                    dPos.X.Scale, dPos.X.Offset + d.X,
                    dPos.Y.Scale, dPos.Y.Offset + d.Y
                )
            end
        end)

        toast("Diogo Script MM2 cargado!", C.accent)

    else
        KStatus.TextColor3 = C.accentR
        KStatus.Text = "Key incorrecta."
        for i = 1, 3 do
            TweenService:Create(KF, TweenInfo.new(0.05), {Position = UDim2.new(0.5, 10, 0.5, 0)}):Play()
            task.wait(0.06)
            TweenService:Create(KF, TweenInfo.new(0.05), {Position = UDim2.new(0.5, -10, 0.5, 0)}):Play()
            task.wait(0.06)
        end
        TweenService:Create(KF, TweenInfo.new(0.1),  {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
        TweenService:Create(KStr, TweenInfo.new(0.2), {Color = C.accentR}):Play()
        task.wait(1.2)
        TweenService:Create(KStr, TweenInfo.new(0.4), {Color = C.accent}):Play()
    end
end)