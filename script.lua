-- ╔══════════════════════════════════════╗
-- ║     DIOGO SCRIPT  v3  |  NOA Style  ║
-- ║     Key: Diogo1234                  ║
-- ╚══════════════════════════════════════╝

local KEY_CORRECTA   = "Diogo1234"
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")
local Lighting       = game:GetService("Lighting")
local lp             = Players.LocalPlayer
local camera         = workspace.CurrentCamera

-- ══════════════════════════════════════════
--  PALETA DE COLORES  (cambia aquí todo)
-- ══════════════════════════════════════════
local C = {
    bg0      = Color3.fromRGB(7,   7,  13),   -- fondo más oscuro
    bg1      = Color3.fromRGB(11,  11,  20),   -- panel principal
    bg2      = Color3.fromRGB(15,  15,  27),   -- contenido
    bg3      = Color3.fromRGB(20,  20,  36),   -- row items
    accent   = Color3.fromRGB(100, 60, 255),   -- púrpura principal
    accentB  = Color3.fromRGB(60, 180, 255),   -- cyan secundario
    accentG  = Color3.fromRGB(50, 230, 140),   -- verde ok
    accentR  = Color3.fromRGB(255, 60,  80),   -- rojo error
    accentY  = Color3.fromRGB(255, 200,  50),  -- amarillo aviso
    text     = Color3.fromRGB(230, 230, 245),
    textDim  = Color3.fromRGB(120, 125, 160),
    line     = Color3.fromRGB(28,  28,  52),
}

-- ══════════════════════════════════════════
--  TOAST SYSTEM (notificaciones)
-- ══════════════════════════════════════════
local ToastGui = Instance.new("ScreenGui")
ToastGui.Name = "DiogoToasts"
ToastGui.ResetOnSpawn = false
ToastGui.IgnoreGuiInset = true
ToastGui.Parent = game:GetService("CoreGui")

local toastY = 20
local function toast(msg, color)
    color = color or C.accentB
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 260, 0, 40)
    f.Position = UDim2.new(1, 20, 0, toastY)
    f.BackgroundColor3 = C.bg1
    f.BorderSizePixel = 0
    f.ZIndex = 50
    f.Parent = ToastGui
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 4, 1, 0)
    bar.BackgroundColor3 = color
    bar.BorderSizePixel = 0
    bar.ZIndex = 51
    bar.Parent = f
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -16, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = msg
    lbl.TextColor3 = C.text
    lbl.TextScaled = true
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 51
    lbl.Parent = f

    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = f

    TweenService:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Position = UDim2.new(1, -270, 0, toastY)
    }):Play()
    toastY = toastY + 48
    task.delay(2.5, function()
        TweenService:Create(f, TweenInfo.new(0.25), {
            Position = UDim2.new(1, 20, 0, f.Position.Y.Offset),
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.3)
        f:Destroy()
        toastY = math.max(20, toastY - 48)
    end)
end

-- ══════════════════════════════════════════
--  KEY SYSTEM
-- ══════════════════════════════════════════
local KeyGui = Instance.new("ScreenGui")
KeyGui.Name = "KeySystem"
KeyGui.ResetOnSpawn = false
KeyGui.IgnoreGuiInset = true
KeyGui.Parent = game:GetService("CoreGui")

-- Fondo oscuro detrás
local Overlay = Instance.new("Frame")
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Overlay.BackgroundTransparency = 0.45
Overlay.BorderSizePixel = 0
Overlay.ZIndex = 1
Overlay.Parent = KeyGui

local KF = Instance.new("Frame")
KF.Size = UDim2.new(0, 0, 0, 0)           -- empieza en 0 → animación de entrada
KF.Position = UDim2.new(0.5, 0, 0.5, 0)
KF.AnchorPoint = Vector2.new(0.5, 0.5)
KF.BackgroundColor3 = C.bg1
KF.BorderSizePixel = 0
KF.ZIndex = 2
KF.Parent = KeyGui
Instance.new("UICorner", KF).CornerRadius = UDim.new(0, 16)
local KStroke = Instance.new("UIStroke")
KStroke.Color = C.accent
KStroke.Thickness = 2
KStroke.Parent = KF

-- Animate in
TweenService:Create(KF, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 420, 0, 255)
}):Play()

-- Top accent bar
local KBar = Instance.new("Frame")
KBar.Size = UDim2.new(1, 0, 0, 4)
KBar.BackgroundColor3 = C.accent
KBar.BorderSizePixel = 0
KBar.ZIndex = 3
KBar.Parent = KF
Instance.new("UICorner", KBar).CornerRadius = UDim.new(1, 0)

local KTitle = Instance.new("TextLabel")
KTitle.Size = UDim2.new(1, 0, 0, 52)
KTitle.Position = UDim2.new(0, 0, 0, 12)
KTitle.BackgroundTransparency = 1
KTitle.Text = "⚡  DIOGO SCRIPT"
KTitle.TextColor3 = C.text
KTitle.TextScaled = true
KTitle.Font = Enum.Font.GothamBold
KTitle.ZIndex = 3
KTitle.Parent = KF

local KSub = Instance.new("TextLabel")
KSub.Size = UDim2.new(1, 0, 0, 18)
KSub.Position = UDim2.new(0, 0, 0, 66)
KSub.BackgroundTransparency = 1
KSub.Text = "Ingresa tu key para continuar"
KSub.TextColor3 = C.textDim
KSub.TextScaled = true
KSub.Font = Enum.Font.Gotham
KSub.ZIndex = 3
KSub.Parent = KF

local KBox = Instance.new("TextBox")
KBox.Size = UDim2.new(0.82, 0, 0, 44)
KBox.Position = UDim2.new(0.09, 0, 0, 96)
KBox.BackgroundColor3 = C.bg3
KBox.TextColor3 = C.text
KBox.PlaceholderText = "Pega tu key aquí..."
KBox.PlaceholderColor3 = C.textDim
KBox.Text = ""
KBox.TextScaled = true
KBox.Font = Enum.Font.Gotham
KBox.BorderSizePixel = 0
KBox.ClearTextOnFocus = false
KBox.ZIndex = 3
KBox.Parent = KF
Instance.new("UICorner", KBox).CornerRadius = UDim.new(0, 10)
local KBoxStroke = Instance.new("UIStroke")
KBoxStroke.Color = C.line
KBoxStroke.Thickness = 1.5
KBoxStroke.Parent = KBox
KBox.Focused:Connect(function()
    TweenService:Create(KBoxStroke, TweenInfo.new(0.2), {Color = C.accent}):Play()
end)
KBox.FocusLost:Connect(function()
    TweenService:Create(KBoxStroke, TweenInfo.new(0.2), {Color = C.line}):Play()
end)

local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Size = UDim2.new(0.36, 0, 0, 40)
GetKeyBtn.Position = UDim2.new(0.09, 0, 0, 152)
GetKeyBtn.BackgroundColor3 = C.bg3
GetKeyBtn.TextColor3 = C.accentB
GetKeyBtn.Text = "Get Key"
GetKeyBtn.TextScaled = true
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.BorderSizePixel = 0
GetKeyBtn.ZIndex = 3
GetKeyBtn.Parent = KF
Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 10)
local GKStroke = Instance.new("UIStroke")
GKStroke.Color = C.accentB
GKStroke.Thickness = 1.5
GKStroke.Parent = GetKeyBtn

local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Size = UDim2.new(0.36, 0, 0, 40)
VerifyBtn.Position = UDim2.new(0.55, 0, 0, 152)
VerifyBtn.BackgroundColor3 = C.accent
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.Text = "Verificar"
VerifyBtn.TextScaled = true
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.BorderSizePixel = 0
VerifyBtn.ZIndex = 3
VerifyBtn.Parent = KF
Instance.new("UICorner", VerifyBtn).CornerRadius = UDim.new(0, 10)

local KStatus = Instance.new("TextLabel")
KStatus.Size = UDim2.new(1, 0, 0, 26)
KStatus.Position = UDim2.new(0, 0, 0, 204)
KStatus.BackgroundTransparency = 1
KStatus.Text = ""
KStatus.TextScaled = true
KStatus.Font = Enum.Font.Gotham
KStatus.ZIndex = 3
KStatus.Parent = KF

-- Hover effects botones
for _, btn in pairs({GetKeyBtn, VerifyBtn}) do
    local origColor = btn.BackgroundColor3
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = btn.BackgroundColor3:Lerp(Color3.fromRGB(255,255,255), 0.12)
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = origColor
        }):Play()
    end)
end

GetKeyBtn.MouseButton1Click:Connect(function()
    KStatus.TextColor3 = C.accentB
    KStatus.Text = "🔑  Key: Diogo1234"
end)

VerifyBtn.MouseButton1Click:Connect(function()
    if KBox.Text == KEY_CORRECTA then
        KStatus.TextColor3 = C.accentG
        KStatus.Text = "✓  Verificado! Cargando..."
        TweenService:Create(KF, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        task.wait(0.35)
        KeyGui:Destroy()

        -- ══════════════════════════════════════════════════════════
        --                    VARIABLES GLOBALES
        -- ══════════════════════════════════════════════════════════
        local speedEnabled   = false
        local noclipEnabled  = false
        local flyEnabled     = false
        local espEnabled     = false
        local jumpEnabled    = false
        local currentSpeed   = 50
        local currentJump    = 50
        local hideKey        = Enum.KeyCode.RightShift
        local uiVisible      = true
        local speedLoop, noclipLoop, flyLoop, espLoop
        local espObjects     = {}
        local espShowName    = true
        local espShowHealth  = true
        local espShowLines   = true
        local espShowSkeleton= true
        local espLineColor   = Color3.fromRGB(255, 255, 80)
        local espSkelColor   = Color3.fromRGB(255, 120, 50)

        -- ══════════════════════════════════════════════════════════
        --                      MAIN GUI
        -- ══════════════════════════════════════════════════════════
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
        local MainStroke = Instance.new("UIStroke")
        MainStroke.Color = C.accent
        MainStroke.Thickness = 1.5
        MainStroke.Parent = Main

        -- Animate in
        TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 610, 0, 420)
        }):Play()

        -- Top gradient bar
        local TopGrad = Instance.new("Frame")
        TopGrad.Size = UDim2.new(1, 0, 0, 4)
        TopGrad.BackgroundColor3 = C.accent
        TopGrad.BorderSizePixel = 0
        TopGrad.ZIndex = 8
        TopGrad.Parent = Main
        local tg = Instance.new("UIGradient", TopGrad)
        tg.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   C.accent),
            ColorSequenceKeypoint.new(0.5, C.accentB),
            ColorSequenceKeypoint.new(1,   C.accent),
        })

        -- Header
        local Header = Instance.new("Frame")
        Header.Size = UDim2.new(1, 0, 0, 46)
        Header.Position = UDim2.new(0, 0, 0, 4)
        Header.BackgroundColor3 = C.bg1
        Header.BorderSizePixel = 0
        Header.ZIndex = 7
        Header.Parent = Main

        local HTitleIcon = Instance.new("TextLabel")
        HTitleIcon.Size = UDim2.new(0, 28, 0, 28)
        HTitleIcon.Position = UDim2.new(0, 14, 0.5, -14)
        HTitleIcon.BackgroundColor3 = C.accent
        HTitleIcon.TextColor3 = Color3.fromRGB(255,255,255)
        HTitleIcon.Text = "⚡"
        HTitleIcon.TextScaled = true
        HTitleIcon.Font = Enum.Font.GothamBold
        HTitleIcon.BorderSizePixel = 0
        HTitleIcon.ZIndex = 8
        HTitleIcon.Parent = Header
        Instance.new("UICorner", HTitleIcon).CornerRadius = UDim.new(0, 6)

        local HTitle = Instance.new("TextLabel")
        HTitle.Size = UDim2.new(0, 150, 1, 0)
        HTitle.Position = UDim2.new(0, 48, 0, 0)
        HTitle.BackgroundTransparency = 1
        HTitle.Text = "DIOGO SCRIPT"
        HTitle.TextColor3 = C.text
        HTitle.TextScaled = true
        HTitle.Font = Enum.Font.GothamBold
        HTitle.TextXAlignment = Enum.TextXAlignment.Left
        HTitle.ZIndex = 8
        HTitle.Parent = Header

        local HBadge = Instance.new("TextLabel")
        HBadge.Size = UDim2.new(0, 52, 0, 20)
        HBadge.Position = UDim2.new(0, 202, 0.5, -10)
        HBadge.BackgroundColor3 = C.accent
        HBadge.TextColor3 = Color3.fromRGB(255,255,255)
        HBadge.Text = "v3"
        HBadge.TextScaled = true
        HBadge.Font = Enum.Font.GothamBold
        HBadge.BorderSizePixel = 0
        HBadge.ZIndex = 8
        HBadge.Parent = Header
        Instance.new("UICorner", HBadge).CornerRadius = UDim.new(0, 6)

        -- Botón minimizar
        local MinBtn = Instance.new("TextButton")
        MinBtn.Size = UDim2.new(0, 34, 0, 34)
        MinBtn.Position = UDim2.new(1, -46, 0.5, -17)
        MinBtn.BackgroundColor3 = C.accentR
        MinBtn.TextColor3 = Color3.fromRGB(255,255,255)
        MinBtn.Text = "✕"
        MinBtn.TextScaled = true
        MinBtn.Font = Enum.Font.GothamBold
        MinBtn.BorderSizePixel = 0
        MinBtn.ZIndex = 10
        MinBtn.Parent = Header
        Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(1, 0)
        MinBtn.MouseEnter:Connect(function()
            TweenService:Create(MinBtn, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(255, 100, 120)
            }):Play()
        end)
        MinBtn.MouseLeave:Connect(function()
            TweenService:Create(MinBtn, TweenInfo.new(0.15), {
                BackgroundColor3 = C.accentR
            }):Play()
        end)

        -- Línea separadora
        local HLine = Instance.new("Frame")
        HLine.Size = UDim2.new(1, 0, 0, 1)
        HLine.Position = UDim2.new(0, 0, 0, 50)
        HLine.BackgroundColor3 = C.line
        HLine.BorderSizePixel = 0
        HLine.Parent = Main

        -- Sidebar
        local Sidebar = Instance.new("Frame")
        Sidebar.Size = UDim2.new(0, 128, 1, -51)
        Sidebar.Position = UDim2.new(0, 0, 0, 51)
        Sidebar.BackgroundColor3 = C.bg0
        Sidebar.BorderSizePixel = 0
        Sidebar.ZIndex = 6
        Sidebar.Parent = Main

        -- Línea sidebar
        local SLine = Instance.new("Frame")
        SLine.Size = UDim2.new(0, 1, 1, -51)
        SLine.Position = UDim2.new(0, 128, 0, 51)
        SLine.BackgroundColor3 = C.line
        SLine.BorderSizePixel = 0
        SLine.Parent = Main

        -- Content
        local Content = Instance.new("Frame")
        Content.Size = UDim2.new(1, -130, 1, -53)
        Content.Position = UDim2.new(0, 130, 0, 53)
        Content.BackgroundColor3 = C.bg2
        Content.BorderSizePixel = 0
        Content.ClipsDescendants = true
        Content.Parent = Main

        -- ══════════════════════════════════════
        --  TABS
        -- ══════════════════════════════════════
        local tabs = {}
        local tabPages = {}

        local tabDefs = {
            {name="Movement", icon="🏃"},
            {name="Teleport",  icon="🌀"},
            {name="Visuals",   icon="👁"},
            {name="ESP",       icon="📡"},
            {name="Misc",      icon="⚙"},
        }

        local activeTab = nil

        local function switchTab(name)
            for n, t in pairs(tabs) do
                TweenService:Create(t.btn, TweenInfo.new(0.2), {
                    BackgroundTransparency = 1,
                    TextColor3 = C.textDim
                }):Play()
                t.indicator.Visible = false
                tabPages[n].Visible = false
            end
            local t = tabs[name]
            TweenService:Create(t.btn, TweenInfo.new(0.2), {
                BackgroundTransparency = 0,
                TextColor3 = C.accentB
            }):Play()
            t.indicator.Visible = true
            tabPages[name].Visible = true
            activeTab = name
        end

        local function crearTab(def, index)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 46)
            btn.Position = UDim2.new(0, 5, 0, (index-1)*50 + 8)
            btn.BackgroundColor3 = Color3.fromRGB(22, 22, 40)
            btn.BackgroundTransparency = 1
            btn.TextColor3 = C.textDim
            btn.Text = def.icon .. "  " .. def.name
            btn.TextScaled = true
            btn.Font = Enum.Font.GothamBold
            btn.BorderSizePixel = 0
            btn.ZIndex = 7
            btn.Parent = Sidebar
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

            local indicator = Instance.new("Frame")
            indicator.Size = UDim2.new(0, 4, 0.55, 0)
            indicator.Position = UDim2.new(0, 0, 0.225, 0)
            indicator.BackgroundColor3 = C.accent
            indicator.BorderSizePixel = 0
            indicator.Visible = false
            indicator.ZIndex = 8
            indicator.Parent = btn
            Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

            local page = Instance.new("ScrollingFrame")
            page.Size = UDim2.new(1, 0, 1, 0)
            page.BackgroundTransparency = 1
            page.BorderSizePixel = 0
            page.ScrollBarThickness = 3
            page.ScrollBarImageColor3 = C.accent
            page.CanvasSize = UDim2.new(0, 0, 0, 700)
            page.Visible = false
            page.ZIndex = 4
            page.Parent = Content

            tabs[def.name] = {btn = btn, indicator = indicator}
            tabPages[def.name] = page

            btn.MouseEnter:Connect(function()
                if activeTab ~= def.name then
                    TweenService:Create(btn, TweenInfo.new(0.15), {
                        BackgroundTransparency = 0.6
                    }):Play()
                end
            end)
            btn.MouseLeave:Connect(function()
                if activeTab ~= def.name then
                    TweenService:Create(btn, TweenInfo.new(0.15), {
                        BackgroundTransparency = 1
                    }):Play()
                end
            end)
            btn.MouseButton1Click:Connect(function()
                switchTab(def.name)
            end)
            return page
        end

        local movPage  = crearTab(tabDefs[1], 1)
        local tpPage   = crearTab(tabDefs[2], 2)
        local visPage  = crearTab(tabDefs[3], 3)
        local espPage  = crearTab(tabDefs[4], 4)
        local miscPage = crearTab(tabDefs[5], 5)

        switchTab("Movement")

        -- ══════════════════════════════════════
        --  HELPERS UI
        -- ══════════════════════════════════════
        local function secTitle(parent, texto, posY)
            local wrap = Instance.new("Frame")
            wrap.Size = UDim2.new(1, -20, 0, 28)
            wrap.Position = UDim2.new(0, 10, 0, posY)
            wrap.BackgroundTransparency = 1
            wrap.ZIndex = 5
            wrap.Parent = parent

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0, 200, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = texto:upper()
            lbl.TextColor3 = C.accent
            lbl.TextScaled = true
            lbl.Font = Enum.Font.GothamBold
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 5
            lbl.Parent = wrap

            local line = Instance.new("Frame")
            line.Size = UDim2.new(1, -210, 0, 1)
            line.Position = UDim2.new(0, 210, 0.5, 0)
            line.BackgroundColor3 = C.line
            line.BorderSizePixel = 0
            line.ZIndex = 5
            line.Parent = wrap
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
            bg.BackgroundColor3 = Color3.fromRGB(32, 32, 52)
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
                    BackgroundColor3 = on and C.accent or Color3.fromRGB(32, 32, 52)
                }):Play()
                TweenService:Create(circle, TweenInfo.new(0.18), {
                    Position = on and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10),
                    BackgroundColor3 = on and Color3.fromRGB(255,255,255) or C.textDim
                }):Play()
                cb(on)
            end)
            return row
        end

        local function mkSlider(parent, texto, posY, minV, maxV, defV, cb)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, -20, 0, 62)
            frame.Position = UDim2.new(0, 10, 0, posY)
            frame.BackgroundColor3 = C.bg3
            frame.BorderSizePixel = 0
            frame.ZIndex = 5
            frame.Parent = parent
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

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
            lbl.Parent = frame

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
            valLbl.Parent = frame

            local track = Instance.new("Frame")
            track.Size = UDim2.new(1, -28, 0, 6)
            track.Position = UDim2.new(0, 14, 0, 42)
            track.BackgroundColor3 = Color3.fromRGB(28, 28, 50)
            track.BorderSizePixel = 0
            track.ZIndex = 6
            track.Parent = frame
            Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((defV-minV)/(maxV-minV), 0, 1, 0)
            fill.BackgroundColor3 = C.accent
            fill.BorderSizePixel = 0
            fill.ZIndex = 7
            fill.Parent = track
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
            local fg = Instance.new("UIGradient", fill)
            fg.Color = ColorSequence.new(C.accent, C.accentB)

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 16, 0, 16)
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.Position = UDim2.new((defV-minV)/(maxV-minV), 0, 0.5, 0)
            knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
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
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
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

        local function mkButton(parent, texto, posY, cb)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -20, 0, 42)
            btn.Position = UDim2.new(0, 10, 0, posY)
            btn.BackgroundColor3 = C.accent
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            btn.Text = texto
            btn.TextScaled = true
            btn.Font = Enum.Font.GothamBold
            btn.BorderSizePixel = 0
            btn.ZIndex = 5
            btn.Parent = parent
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
            local bg = Instance.new("UIGradient", btn)
            bg.Color = ColorSequence.new(C.accent, C.accentB)
            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = C.accentB}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = C.accent}):Play()
            end)
            btn.MouseButton1Click:Connect(cb)
            return btn
        end

        -- ══════════════════════════════════════
        --  MOVEMENT PAGE
        -- ══════════════════════════════════════
        secTitle(movPage, "Speed", 10)
        mkToggle(movPage, "Enable Speed", 46, function(on)
            speedEnabled = on
            if on then
                speedLoop = RunService.Heartbeat:Connect(function()
                    local char = lp.Character
                    if char then
                        local h = char:FindFirstChildOfClass("Humanoid")
                        if h then h.WalkSpeed = currentSpeed end
                    end
                end)
                toast("Speed activado: " .. currentSpeed, C.accentG)
            else
                if speedLoop then speedLoop:Disconnect() speedLoop = nil end
                local char = lp.Character
                if char then
                    local h = char:FindFirstChildOfClass("Humanoid")
                    if h then h.WalkSpeed = 16 end
                end
                toast("Speed desactivado", C.accentR)
            end
        end)
        mkSlider(movPage, "Speed Value", 98, 16, 300, 50, function(v) currentSpeed = v end)

        secTitle(movPage, "Jump", 174)
        mkToggle(movPage, "Enable Jump Power", 210, function(on)
            jumpEnabled = on
            local char = lp.Character
            if char then
                local h = char:FindFirstChildOfClass("Humanoid")
                if h then
                    h.UseJumpPower = true
                    h.JumpPower = on and currentJump or 50
                end
            end
            toast(on and "Jump activado" or "Jump desactivado", on and C.accentG or C.accentR)
        end)
        mkSlider(movPage, "Jump Value", 262, 50, 500, 50, function(v)
            currentJump = v
            if jumpEnabled then
                local char = lp.Character
                if char then
                    local h = char:FindFirstChildOfClass("Humanoid")
                    if h then h.UseJumpPower = true h.JumpPower = v end
                end
            end
        end)

        secTitle(movPage, "Fly  (W/A/S/D + Space/Ctrl)", 340)
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
                bv.Name = "FlyVel"
                bv.Velocity = Vector3.zero
                bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                bv.Parent = hrp

                local bg = Instance.new("BodyGyro")
                bg.Name = "FlyGyro"
                bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
                bg.D = 50
                bg.Parent = hrp

                flyLoop = RunService.Heartbeat:Connect(function()
                    local c = lp.Character
                    if not c then return end
                    local root = c:FindFirstChild("HumanoidRootPart")
                    if not root then return end
                    local vel = root:FindFirstChild("FlyVel")
                    local gyro = root:FindFirstChild("FlyGyro")
                    if not vel or not gyro then return end
                    local dir = Vector3.zero
                    local spd = 65
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
                    vel.Velocity = dir.Magnitude > 0 and dir.Unit * spd or Vector3.zero
                    gyro.CFrame = camera.CFrame
                end)
                toast("Fly activado ✈", C.accentG)
            else
                if flyLoop then flyLoop:Disconnect() flyLoop = nil end
                local vel  = hrp:FindFirstChild("FlyVel")
                local gyro = hrp:FindFirstChild("FlyGyro")
                if vel  then vel:Destroy()  end
                if gyro then gyro:Destroy() end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = false end
                toast("Fly desactivado", C.accentR)
            end
        end)

        secTitle(movPage, "Noclip", 432)
        mkToggle(movPage, "Enable Noclip", 468, function(on)
            noclipEnabled = on
            if on then
                noclipLoop = RunService.Stepped:Connect(function()
                    local char = lp.Character
                    if char then
                        for _, p in pairs(char:GetDescendants()) do
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

        -- ══════════════════════════════════════
        --  TELEPORT PAGE
        -- ══════════════════════════════════════
        secTitle(tpPage, "Teleport a Jugadores", 10)

        -- Lista de jugadores (scroll)
        local playerListFrame = Instance.new("Frame")
        playerListFrame.Size = UDim2.new(1, -20, 0, 220)
        playerListFrame.Position = UDim2.new(0, 10, 0, 44)
        playerListFrame.BackgroundColor3 = C.bg0
        playerListFrame.BorderSizePixel = 0
        playerListFrame.ZIndex = 5
        playerListFrame.Parent = tpPage
        Instance.new("UICorner", playerListFrame).CornerRadius = UDim.new(0, 10)

        local playerScroll = Instance.new("ScrollingFrame")
        playerScroll.Size = UDim2.new(1, -8, 1, -8)
        playerScroll.Position = UDim2.new(0, 4, 0, 4)
        playerScroll.BackgroundTransparency = 1
        playerScroll.BorderSizePixel = 0
        playerScroll.ScrollBarThickness = 3
        playerScroll.ScrollBarImageColor3 = C.accent
        playerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        playerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        playerScroll.ZIndex = 6
        playerScroll.Parent = playerListFrame
        local playerLayout = Instance.new("UIListLayout")
        playerLayout.Padding = UDim.new(0, 4)
        playerLayout.Parent = playerScroll

        local function refreshPlayers()
            for _, c in pairs(playerScroll:GetChildren()) do
                if c:IsA("TextButton") then c:Destroy() end
            end
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= lp then
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, 0, 0, 38)
                    btn.BackgroundColor3 = C.bg3
                    btn.TextColor3 = C.text
                    btn.Text = "  🎮  " .. p.Name
                    btn.TextScaled = true
                    btn.Font = Enum.Font.Gotham
                    btn.TextXAlignment = Enum.TextXAlignment.Left
                    btn.BorderSizePixel = 0
                    btn.ZIndex = 7
                    btn.Parent = playerScroll
                    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

                    btn.MouseEnter:Connect(function()
                        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35,35,60)}):Play()
                    end)
                    btn.MouseLeave:Connect(function()
                        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = C.bg3}):Play()
                    end)

                    btn.MouseButton1Click:Connect(function()
                        local char = lp.Character
                        local tChar = p.Character
                        if char and tChar then
                            local hrp  = char:FindFirstChild("HumanoidRootPart")
                            local thrp = tChar:FindFirstChild("HumanoidRootPart")
                            if hrp and thrp then
                                hrp.CFrame = thrp.CFrame + Vector3.new(0, 3, 0)
                                toast("Teleportado a " .. p.Name, C.accentG)
                            else
                                toast("No se encontró al jugador", C.accentR)
                            end
                        end
                    end)
                end
            end
        end

        refreshPlayers()

        mkButton(tpPage, "🔄  Actualizar Lista", 272, function()
            refreshPlayers()
            toast("Lista actualizada", C.accentB)
        end)

        Players.PlayerAdded:Connect(function() task.wait(1) refreshPlayers() end)
        Players.PlayerRemoving:Connect(function() task.wait(0.1) refreshPlayers() end)

        -- TP al arma del Sheriff
        secTitle(tpPage, "Arma del Sheriff", 326)

        local sheriffInfo = Instance.new("TextLabel")
        sheriffInfo.Size = UDim2.new(1, -20, 0, 34)
        sheriffInfo.Position = UDim2.new(0, 10, 0, 358)
        sheriffInfo.BackgroundColor3 = C.bg3
        sheriffInfo.TextColor3 = C.textDim
        sheriffInfo.Text = "Busca: 'Sheriff', 'Gun', 'Revolver' en el workspace"
        sheriffInfo.TextScaled = true
        sheriffInfo.Font = Enum.Font.Gotham
        sheriffInfo.BorderSizePixel = 0
        sheriffInfo.ZIndex = 5
        sheriffInfo.Parent = tpPage
        Instance.new("UICorner", sheriffInfo).CornerRadius = UDim.new(0, 8)

        mkButton(tpPage, "⚡  Teleport a Arma del Sheriff", 402, function()
            local char = lp.Character
            if not char then toast("Necesitas un personaje", C.accentR) return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then toast("No se encontró HRP", C.accentR) return end

            -- Nombres posibles del arma del sheriff según el juego
            local targets = {
                "Sheriff", "SheriffGun", "Revolver", "Gun", "Pistol",
                "sheriff_gun", "SherrifGun", "SheriffWeapon", "ShGun",
                "ClassicSheriff", "SheriffTool"
            }

            local found = nil

            -- Buscar en workspace recursivamente
            local function searchRecursive(parent)
                for _, obj in pairs(parent:GetChildren()) do
                    if obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("Tool") then
                        for _, t in pairs(targets) do
                            if string.find(obj.Name:lower(), t:lower()) then
                                found = obj
                                return
                            end
                        end
                    end
                    if not found then
                        searchRecursive(obj)
                    end
                end
            end

            searchRecursive(workspace)

            if found then
                local pos
                if found:IsA("BasePart") then
                    pos = found.Position
                elseif found:IsA("Model") then
                    local p = found:FindFirstChildOfClass("BasePart") or found.PrimaryPart
                    if p then pos = p.Position end
                elseif found:IsA("Tool") then
                    local p = found:FindFirstChildOfClass("BasePart")
                    if p then pos = p.Position end
                end

                if pos then
                    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 4, 0))
                    toast("✓ TP a: " .. found.Name, C.accentG)
                    sheriffInfo.Text = "✓ Encontrado: " .. found.Name
                    sheriffInfo.TextColor3 = C.accentG
                else
                    toast("No se pudo obtener posición", C.accentY)
                end
            else
                toast("Arma del Sheriff no encontrada", C.accentR)
                sheriffInfo.Text = "No encontrada — ¿el juego está cargado?"
                sheriffInfo.TextColor3 = C.accentR
            end
        end)

        -- TP al spawn
        secTitle(tpPage, "Otros", 458)
        mkButton(tpPage, "🏠  Teleport al Spawn", 494, function()
            local char = lp.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
            if spawn then
                hrp.CFrame = spawn.CFrame + Vector3.new(0, 5, 0)
                toast("Teleportado al spawn", C.accentG)
            else
                hrp.CFrame = CFrame.new(0, 10, 0)
                toast("Spawn no encontrado, tp a 0,0,0", C.accentY)
            end
        end)

        -- ══════════════════════════════════════
        --  VISUALS PAGE
        -- ══════════════════════════════════════
        secTitle(visPage, "Jugador", 10)
        mkToggle(visPage, "Invisible (Local)", 46, function(on)
            local char = lp.Character
            if char then
                for _, p in pairs(char:GetDescendants()) do
                    if p:IsA("BasePart") or p:IsA("Decal") then
                        p.Transparency = on and 1 or 0
                    end
                end
            end
            toast(on and "Invisible ON" or "Invisible OFF", on and C.accentG or C.accentR)
        end)

        secTitle(visPage, "Mundo", 102)
        mkToggle(visPage, "Fullbright", 138, function(on)
            Lighting.Brightness = on and 8 or 1
            Lighting.FogEnd = on and 9e8 or 100000
            for _, v in pairs(Lighting:GetChildren()) do
                if v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") then
                    v.Enabled = not on
                end
            end
            toast(on and "Fullbright ON" or "Fullbright OFF", on and C.accentG or C.accentR)
        end)

        -- ══════════════════════════════════════
        --  ESP PAGE
        -- ══════════════════════════════════════
        local function createESP(player)
            if player == lp or espObjects[player] then return end
            local folder = Instance.new("Folder")
            folder.Name = player.Name .. "_ESP"
            folder.Parent = MainGui

            local billboard = Instance.new("BillboardGui")
            billboard.Size = UDim2.new(0, 130, 0, 55)
            billboard.StudsOffset = Vector3.new(0, 3.5, 0)
            billboard.AlwaysOnTop = true
            billboard.Enabled = false
            billboard.Parent = folder

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Size = UDim2.new(1, 0, 0.5, 0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text = player.Name
            nameLbl.TextColor3 = Color3.fromRGB(255,255,255)
            nameLbl.TextScaled = true
            nameLbl.Font = Enum.Font.GothamBold
            nameLbl.TextStrokeTransparency = 0
            nameLbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
            nameLbl.Parent = billboard

            local hpLbl = Instance.new("TextLabel")
            hpLbl.Size = UDim2.new(1, 0, 0.5, 0)
            hpLbl.Position = UDim2.new(0, 0, 0.5, 0)
            hpLbl.BackgroundTransparency = 1
            hpLbl.Text = "HP: ?"
            hpLbl.TextColor3 = C.accentG
            hpLbl.TextScaled = true
            hpLbl.Font = Enum.Font.Gotham
            hpLbl.TextStrokeTransparency = 0
            hpLbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
            hpLbl.Parent = billboard

            local lineHolder = Instance.new("ScreenGui")
            lineHolder.Name = "ESPLine_" .. player.Name
            lineHolder.ResetOnSpawn = false
            lineHolder.IgnoreGuiInset = true
            lineHolder.Enabled = false
            lineHolder.Parent = game:GetService("CoreGui")

            local lineFrame = Instance.new("Frame")
            lineFrame.BackgroundColor3 = espLineColor
            lineFrame.BorderSizePixel = 0
            lineFrame.AnchorPoint = Vector2.new(0, 0.5)
            lineFrame.ZIndex = 2
            lineFrame.Parent = lineHolder

            espObjects[player] = {
                folder = folder,
                billboard = billboard,
                nameLbl = nameLbl,
                hpLbl = hpLbl,
                lineHolder = lineHolder,
                lineFrame = lineFrame,
            }

            player.AncestryChanged:Connect(function()
                if not player:IsDescendantOf(game) then
                    pcall(function() folder:Destroy() end)
                    pcall(function() lineHolder:Destroy() end)
                    espObjects[player] = nil
                end
            end)
        end

        local function updateESP()
            for player, obj in pairs(espObjects) do
                local char = player.Character
                if char then
                    local hrp  = char:FindFirstChild("HumanoidRootPart")
                    local hum  = char:FindFirstChildOfClass("Humanoid")
                    local head = char:FindFirstChild("Head")
                    if hrp and hum and head then
                        obj.billboard.Adornee  = head
                        obj.billboard.Enabled  = espEnabled and (espShowName or espShowHealth)
                        obj.nameLbl.Visible    = espShowName
                        obj.hpLbl.Visible      = espShowHealth
                        obj.nameLbl.Text       = player.Name

                        local hp = math.floor(hum.Health)
                        local mx = math.max(1, math.floor(hum.MaxHealth))
                        obj.hpLbl.Text = "HP: " .. hp .. "/" .. mx
                        local pct = hp / mx
                        obj.hpLbl.TextColor3 = Color3.fromRGB(
                            math.floor(255*(1-pct)), math.floor(255*pct), 60
                        )

                        -- Línea
                        if espShowLines and espEnabled then
                            local spos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                            if onScreen then
                                obj.lineHolder.Enabled = true
                                local vp = camera.ViewportSize
                                local sx, sy = vp.X/2, vp.Y
                                local dx, dy = spos.X - sx, spos.Y - sy
                                local len = math.sqrt(dx*dx + dy*dy)
                                local ang = math.deg(math.atan2(dy, dx))
                                obj.lineFrame.Size = UDim2.new(0, len, 0, 1)
                                obj.lineFrame.Position = UDim2.new(0, sx, 0, sy)
                                obj.lineFrame.Rotation = ang
                                obj.lineFrame.BackgroundColor3 = espLineColor
                            else
                                obj.lineHolder.Enabled = false
                            end
                        else
                            obj.lineHolder.Enabled = false
                        end

                        -- Skeleton
                        local skelParts = {
                            "Head","UpperTorso","LowerTorso",
                            "LeftUpperArm","RightUpperArm",
                            "LeftLowerArm","RightLowerArm",
                            "LeftHand","RightHand",
                            "LeftUpperLeg","RightUpperLeg",
                            "LeftLowerLeg","RightLowerLeg",
                            "LeftFoot","RightFoot"
                        }
                        for _, pn in pairs(skelParts) do
                            local part = char:FindFirstChild(pn)
                            if part and part:IsA("BasePart") then
                                local sel = part:FindFirstChild("DSkel")
                                if espShowSkeleton and espEnabled then
                                    if not sel then
                                        sel = Instance.new("SelectionBox")
                                        sel.Name = "DSkel"
                                        sel.Color3 = espSkelColor
                                        sel.LineThickness = 0.04
                                        sel.SurfaceTransparency = 1
                                        sel.Adornee = part
                                        sel.Parent = part
                                    end
                                    sel.Visible = true
                                    sel.Color3 = espSkelColor
                                elseif sel then
                                    sel:Destroy()
                                end
                            end
                        end
                    end
                end
            end
        end

        local function toggleESP(on)
            espEnabled = on
            if on then
                for _, p in pairs(Players:GetPlayers()) do createESP(p) end
                espLoop = RunService.RenderStepped:Connect(updateESP)
                toast("ESP activado 📡", C.accentG)
            else
                if espLoop then espLoop:Disconnect() espLoop = nil end
                for _, obj in pairs(espObjects) do
                    pcall(function() obj.billboard.Enabled = false end)
                    pcall(function() obj.lineHolder.Enabled = false end)
                end
                for _, p in pairs(Players:GetPlayers()) do
                    local c = p.Character
                    if c then
                        for _, d in pairs(c:GetDescendants()) do
                            if d.Name == "DSkel" then d:Destroy() end
                        end
                    end
                end
                toast("ESP desactivado", C.accentR)
            end
        end

        Players.PlayerAdded:Connect(function(p)
            if espEnabled then task.wait(1) createESP(p) end
        end)

        secTitle(espPage, "ESP Global", 10)
        mkToggle(espPage, "Enable ESP", 46, toggleESP)

        secTitle(espPage, "Opciones", 102)
        mkToggle(espPage, "Mostrar Nombres", 138, function(on) espShowName = on end)
        mkToggle(espPage, "Mostrar Vida (HP)", 190, function(on) espShowHealth = on end)
        mkToggle(espPage, "Mostrar Líneas", 242, function(on) espShowLines = on end)
        mkToggle(espPage, "Mostrar Skeleton", 294, function(on)
            espShowSkeleton = on
            if not on then
                for _, p in pairs(Players:GetPlayers()) do
                    local c = p.Character
                    if c then
                        for _, d in pairs(c:GetDescendants()) do
                            if d.Name == "DSkel" then d:Destroy() end
                        end
                    end
                end
            end
        end)

        -- ══════════════════════════════════════
        --  MISC PAGE
        -- ══════════════════════════════════════
        secTitle(miscPage, "UI Controls", 10)

        local hideKeyLbl = Instance.new("TextLabel")
        hideKeyLbl.Size = UDim2.new(1, -20, 0, 32)
        hideKeyLbl.Position = UDim2.new(0, 10, 0, 46)
        hideKeyLbl.BackgroundColor3 = C.bg3
        hideKeyLbl.TextColor3 = C.textDim
        hideKeyLbl.Text = "  Hide Key: RightShift"
        hideKeyLbl.TextScaled = true
        hideKeyLbl.Font = Enum.Font.Gotham
        hideKeyLbl.TextXAlignment = Enum.TextXAlignment.Left
        hideKeyLbl.BorderSizePixel = 0
        hideKeyLbl.ZIndex = 5
        hideKeyLbl.Parent = miscPage
        Instance.new("UICorner", hideKeyLbl).CornerRadius = UDim.new(0, 8)

        local changingKey = false
        local ckBtn = mkButton(miscPage, "🎮  Cambiar Tecla de Esconder", 88, function()
            changingKey = true
            ckBtn.Text = "⌨  Presiona una tecla..."
            TweenService:Create(ckBtn, TweenInfo.new(0.2), {BackgroundColor3 = C.accentY}):Play()
        end)

        secTitle(miscPage, "Info", 144)
        local infoBox = Instance.new("TextLabel")
        infoBox.Size = UDim2.new(1, -20, 0, 120)
        infoBox.Position = UDim2.new(0, 10, 0, 180)
        infoBox.BackgroundColor3 = C.bg3
        infoBox.TextColor3 = C.textDim
        infoBox.Text = "  ⚡ Diogo Script v3\n  🏃 Fly: W/A/S/D + Espacio/Ctrl\n  🔑 Key default: RightShift\n  🌀 TP: busca arma por nombre\n  📡 ESP: SelectionBox + Billboard"
        infoBox.TextScaled = true
        infoBox.Font = Enum.Font.Gotham
        infoBox.TextXAlignment = Enum.TextXAlignment.Left
        infoBox.TextYAlignment = Enum.TextYAlignment.Top
        infoBox.BorderSizePixel = 0
        infoBox.ZIndex = 5
        infoBox.Parent = miscPage
        Instance.new("UICorner", infoBox).CornerRadius = UDim.new(0, 10)
        local ip = Instance.new("UIPadding", infoBox)
        ip.PaddingTop = UDim.new(0, 8)
        ip.PaddingLeft = UDim.new(0, 8)

        -- ══════════════════════════════════════
        --  MINIMIZAR / INPUT EVENTS
        -- ══════════════════════════════════════
        local minimized = false
        local savedPos, savedSize

        MinBtn.MouseButton1Click:Connect(function()
            minimized = not minimized
            if minimized then
                savedPos  = Main.Position
                savedSize = Main.Size

                for _, child in pairs(Main:GetChildren()) do
                    if child ~= MinBtn then child.Visible = false end
                end

                TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                    Size = UDim2.new(0, 46, 0, 46),
                    Position = UDim2.new(1, -60, 0, 12)
                }):Play()
                MinBtn.Text = "☰"
                TweenService:Create(MinBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.accent}):Play()
                MinBtn.Position = UDim2.new(0, 6, 0, 6)
                MinBtn.Size = UDim2.new(0, 34, 0, 34)
            else
                TweenService:Create(Main, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 610, 0, 420),
                    Position = UDim2.new(0.5, -305, 0.5, -210)
                }):Play()
                task.wait(0.15)
                for _, child in pairs(Main:GetChildren()) do child.Visible = true end
                MinBtn.Text = "✕"
                TweenService:Create(MinBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.accentR}):Play()
                MinBtn.Position = UDim2.new(1, -46, 0.5, -17)
                MinBtn.Size = UDim2.new(0, 34, 0, 34)
            end
        end)

        UserInputService.InputBegan:Connect(function(input, gpe)
            if changingKey and input.UserInputType == Enum.UserInputType.Keyboard then
                hideKey = input.KeyCode
                hideKeyLbl.Text = "  Hide Key: " .. input.KeyCode.Name
                ckBtn.Text = "🎮  Cambiar Tecla de Esconder"
                TweenService:Create(ckBtn, TweenInfo.new(0.2), {BackgroundColor3 = C.accent}):Play()
                changingKey = false
                toast("Tecla cambiada: " .. input.KeyCode.Name, C.accentB)
            elseif not changingKey and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == hideKey then
                uiVisible = not uiVisible
                Main.Visible = uiVisible
            end
        end)

        -- Drag
        local dragging, dStart, dPos
        Header.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dStart = i.Position
                dPos = Main.Position
            end
        end)
        Header.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local d = i.Position - dStart
                Main.Position = UDim2.new(dPos.X.Scale, dPos.X.Offset + d.X, dPos.Y.Scale, dPos.Y.Offset + d.Y)
            end
        end)

        toast("⚡ Diogo Script cargado!", C.accent)

    else
        -- Shake en error
        KStatus.TextColor3 = C.accentR
        KStatus.Text = "✗  Key incorrecta."
        for i = 1, 3 do
            TweenService:Create(KF, TweenInfo.new(0.05), {Position = UDim2.new(0.5, 8, 0.5, 0)}):Play()
            task.wait(0.06)
            TweenService:Create(KF, TweenInfo.new(0.05), {Position = UDim2.new(0.5, -8, 0.5, 0)}):Play()
            task.wait(0.06)
        end
        TweenService:Create(KF, TweenInfo.new(0.08), {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
        TweenService:Create(KStroke, TweenInfo.new(0.2), {Color = C.accentR}):Play()
        task.wait(1)
        TweenService:Create(KStroke, TweenInfo.new(0.4), {Color = C.accent}):Play()
    end
end)