-- Diogo Script | NOA Style v2
-- Key: Diogo1234

local KEY_CORRECTA = "Diogo1234"
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local lp = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ============ KEY SYSTEM ============
local KeyGui = Instance.new("ScreenGui")
KeyGui.Name = "KeySystem"
KeyGui.ResetOnSpawn = false
KeyGui.IgnoreGuiInset = true
KeyGui.Parent = game:GetService("CoreGui")

local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(0, 400, 0, 240)
KeyFrame.Position = UDim2.new(0.5, -200, 0.5, -120)
KeyFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
KeyFrame.BorderSizePixel = 0
KeyFrame.Parent = KeyGui
Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 16)

local KStroke = Instance.new("UIStroke")
KStroke.Color = Color3.fromRGB(0, 180, 255)
KStroke.Thickness = 2
KStroke.Parent = KeyFrame

-- Top color bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 4)
TopBar.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
TopBar.BorderSizePixel = 0
TopBar.Parent = KeyFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 4)

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1, 0, 0, 50)
KeyTitle.Position = UDim2.new(0, 0, 0, 14)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "⚡  DIOGO SCRIPT"
KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyTitle.TextScaled = true
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.Parent = KeyFrame

local KeySub = Instance.new("TextLabel")
KeySub.Size = UDim2.new(1, 0, 0, 22)
KeySub.Position = UDim2.new(0, 0, 0, 62)
KeySub.BackgroundTransparency = 1
KeySub.Text = "Enter your key to continue"
KeySub.TextColor3 = Color3.fromRGB(100, 120, 160)
KeySub.TextScaled = true
KeySub.Font = Enum.Font.Gotham
KeySub.Parent = KeyFrame

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0.84, 0, 0, 44)
KeyBox.Position = UDim2.new(0.08, 0, 0, 96)
KeyBox.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.PlaceholderText = "Paste key here..."
KeyBox.PlaceholderColor3 = Color3.fromRGB(80, 90, 120)
KeyBox.Text = ""
KeyBox.TextScaled = true
KeyBox.Font = Enum.Font.Gotham
KeyBox.BorderSizePixel = 0
KeyBox.ClearTextOnFocus = false
KeyBox.Parent = KeyFrame
Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 10)
local BoxStroke2 = Instance.new("UIStroke")
BoxStroke2.Color = Color3.fromRGB(40, 50, 80)
BoxStroke2.Thickness = 1.5
BoxStroke2.Parent = KeyBox

local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Size = UDim2.new(0.38, 0, 0, 40)
GetKeyBtn.Position = UDim2.new(0.08, 0, 0, 154)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
GetKeyBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
GetKeyBtn.Text = "Get Key"
GetKeyBtn.TextScaled = true
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.BorderSizePixel = 0
GetKeyBtn.Parent = KeyFrame
Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 10)
local GStroke = Instance.new("UIStroke")
GStroke.Color = Color3.fromRGB(0, 160, 220)
GStroke.Thickness = 1.5
GStroke.Parent = GetKeyBtn

local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Size = UDim2.new(0.38, 0, 0, 40)
VerifyBtn.Position = UDim2.new(0.54, 0, 0, 154)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.Text = "Verify"
VerifyBtn.TextScaled = true
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.BorderSizePixel = 0
VerifyBtn.Parent = KeyFrame
Instance.new("UICorner", VerifyBtn).CornerRadius = UDim.new(0, 10)

local KeyStatus = Instance.new("TextLabel")
KeyStatus.Size = UDim2.new(1, 0, 0, 28)
KeyStatus.Position = UDim2.new(0, 0, 0, 204)
KeyStatus.BackgroundTransparency = 1
KeyStatus.Text = ""
KeyStatus.TextScaled = true
KeyStatus.Font = Enum.Font.Gotham
KeyStatus.Parent = KeyFrame

GetKeyBtn.MouseButton1Click:Connect(function()
    KeyStatus.TextColor3 = Color3.fromRGB(0, 220, 255)
    KeyStatus.Text = "Key: Diogo1234"
end)

VerifyBtn.MouseButton1Click:Connect(function()
    if KeyBox.Text == KEY_CORRECTA then
        KeyStatus.TextColor3 = Color3.fromRGB(0, 255, 120)
        KeyStatus.Text = "✓ Verificado! Cargando..."
        task.wait(1)
        KeyGui:Destroy()

        -- ============================================================
        --                      VARIABLES GLOBALES
        -- ============================================================
        local speedEnabled = false
        local noclipEnabled = false
        local flyEnabled = false
        local espEnabled = false
        local fullbrightEnabled = false
        local invisEnabled = false
        local currentSpeed = 50
        local currentJump = 50
        local jumpEnabled = false
        local hideKey = Enum.KeyCode.RightShift
        local uiVisible = true

        local speedLoop, noclipLoop, flyLoop
        local espObjects = {} -- { player = { box, name, healthBar, lines, skeleton } }

        -- ============================================================
        --                          MAIN GUI
        -- ============================================================
        local MainGui = Instance.new("ScreenGui")
        MainGui.Name = "DiogoScript"
        MainGui.ResetOnSpawn = false
        MainGui.IgnoreGuiInset = true
        MainGui.Parent = game:GetService("CoreGui")

        local Main = Instance.new("Frame")
        Main.Size = UDim2.new(0, 580, 0, 400)
        Main.Position = UDim2.new(0.5, -290, 0.5, -200)
        Main.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
        Main.BorderSizePixel = 0
        Main.ClipsDescendants = true
        Main.Parent = MainGui
        Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
        local MainStroke = Instance.new("UIStroke")
        MainStroke.Color = Color3.fromRGB(0, 160, 255)
        MainStroke.Thickness = 1.5
        MainStroke.Parent = Main

        -- Barra de color top
        local ColorBar = Instance.new("Frame")
        ColorBar.Size = UDim2.new(1, 0, 0, 3)
        ColorBar.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
        ColorBar.BorderSizePixel = 0
        ColorBar.ZIndex = 10
        ColorBar.Parent = Main

        -- Header
        local Header = Instance.new("Frame")
        Header.Size = UDim2.new(1, 0, 0, 44)
        Header.Position = UDim2.new(0, 0, 0, 3)
        Header.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
        Header.BorderSizePixel = 0
        Header.ZIndex = 5
        Header.Parent = Main

        local HeaderTitle = Instance.new("TextLabel")
        HeaderTitle.Size = UDim2.new(0, 160, 1, 0)
        HeaderTitle.Position = UDim2.new(0, 16, 0, 0)
        HeaderTitle.BackgroundTransparency = 1
        HeaderTitle.Text = "⚡ DIOGO SCRIPT"
        HeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        HeaderTitle.TextScaled = true
        HeaderTitle.Font = Enum.Font.GothamBold
        HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
        HeaderTitle.ZIndex = 5
        HeaderTitle.Parent = Header

        local FreeBadge = Instance.new("TextLabel")
        FreeBadge.Size = UDim2.new(0, 50, 0, 20)
        FreeBadge.Position = UDim2.new(0, 178, 0.5, -10)
        FreeBadge.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        FreeBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
        FreeBadge.Text = "FREE"
        FreeBadge.TextScaled = true
        FreeBadge.Font = Enum.Font.GothamBold
        FreeBadge.ZIndex = 5
        FreeBadge.Parent = Header
        Instance.new("UICorner", FreeBadge).CornerRadius = UDim.new(0, 5)

        -- Botón X / minimizar
        local MinBtn = Instance.new("TextButton")
        MinBtn.Size = UDim2.new(0, 34, 0, 34)
        MinBtn.Position = UDim2.new(1, -44, 0.5, -17)
        MinBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        MinBtn.Text = "✕"
        MinBtn.TextScaled = true
        MinBtn.Font = Enum.Font.GothamBold
        MinBtn.BorderSizePixel = 0
        MinBtn.ZIndex = 10
        MinBtn.Parent = Header
        Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(1, 0)

        -- Línea separadora header
        local HLine = Instance.new("Frame")
        HLine.Size = UDim2.new(1, 0, 0, 1)
        HLine.Position = UDim2.new(0, 0, 0, 47)
        HLine.BackgroundColor3 = Color3.fromRGB(25, 30, 50)
        HLine.BorderSizePixel = 0
        HLine.Parent = Main

        -- Sidebar
        local Sidebar = Instance.new("Frame")
        Sidebar.Size = UDim2.new(0, 120, 1, -48)
        Sidebar.Position = UDim2.new(0, 0, 0, 48)
        Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
        Sidebar.BorderSizePixel = 0
        Sidebar.Parent = Main

        -- Línea separadora sidebar
        local SLine = Instance.new("Frame")
        SLine.Size = UDim2.new(0, 1, 1, -48)
        SLine.Position = UDim2.new(0, 120, 0, 48)
        SLine.BackgroundColor3 = Color3.fromRGB(25, 30, 50)
        SLine.BorderSizePixel = 0
        SLine.Parent = Main

        -- Contenido
        local Content = Instance.new("Frame")
        Content.Size = UDim2.new(1, -121, 1, -50)
        Content.Position = UDim2.new(0, 121, 0, 50)
        Content.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
        Content.BorderSizePixel = 0
        Content.ClipsDescendants = true
        Content.Parent = Main

        -- ============ TABS ============
        local tabs = {}
        local tabPages = {}

        local tabDefs = {
            {name = "Movement", icon = "🏃"},
            {name = "Visuals",  icon = "👁"},
            {name = "ESP",      icon = "📡"},
            {name = "Misc",     icon = "⚙"},
        }

        local function crearTab(def, index)
            local tabBtn = Instance.new("TextButton")
            tabBtn.Size = UDim2.new(1, -8, 0, 44)
            tabBtn.Position = UDim2.new(0, 4, 0, (index-1)*48 + 10)
            tabBtn.BackgroundColor3 = Color3.fromRGB(14, 14, 24)
            tabBtn.BackgroundTransparency = 1
            tabBtn.TextColor3 = Color3.fromRGB(130, 140, 170)
            tabBtn.Text = def.icon .. "  " .. def.name
            tabBtn.TextScaled = true
            tabBtn.Font = Enum.Font.GothamBold
            tabBtn.BorderSizePixel = 0
            tabBtn.ZIndex = 4
            tabBtn.Parent = Sidebar
            Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 8)

            local indicator = Instance.new("Frame")
            indicator.Size = UDim2.new(0, 3, 0.55, 0)
            indicator.Position = UDim2.new(0, 0, 0.225, 0)
            indicator.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
            indicator.BorderSizePixel = 0
            indicator.Visible = false
            indicator.ZIndex = 5
            indicator.Parent = tabBtn
            Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

            local page = Instance.new("ScrollingFrame")
            page.Size = UDim2.new(1, 0, 1, 0)
            page.BackgroundTransparency = 1
            page.BorderSizePixel = 0
            page.ScrollBarThickness = 3
            page.ScrollBarImageColor3 = Color3.fromRGB(0, 140, 220)
            page.CanvasSize = UDim2.new(0, 0, 0, 600)
            page.Visible = false
            page.ZIndex = 3
            page.Parent = Content

            tabs[def.name] = {btn = tabBtn, indicator = indicator}
            tabPages[def.name] = page

            tabBtn.MouseButton1Click:Connect(function()
                for n, t in pairs(tabs) do
                    t.btn.TextColor3 = Color3.fromRGB(130, 140, 170)
                    t.btn.BackgroundTransparency = 1
                    t.indicator.Visible = false
                    tabPages[n].Visible = false
                end
                tabBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
                tabBtn.BackgroundTransparency = 0
                indicator.Visible = true
                page.Visible = true
            end)

            return page
        end

        local movPage  = crearTab(tabDefs[1], 1)
        local visPage  = crearTab(tabDefs[2], 2)
        local espPage  = crearTab(tabDefs[3], 3)
        local miscPage = crearTab(tabDefs[4], 4)

        tabs["Movement"].btn.TextColor3 = Color3.fromRGB(0, 200, 255)
        tabs["Movement"].btn.BackgroundTransparency = 0
        tabs["Movement"].indicator.Visible = true
        movPage.Visible = true

        -- ============ HELPERS ============

        local function crearSectionTitle(parent, texto, posY)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -20, 0, 22)
            lbl.Position = UDim2.new(0, 14, 0, posY)
            lbl.BackgroundTransparency = 1
            lbl.Text = texto
            lbl.TextColor3 = Color3.fromRGB(0, 180, 255)
            lbl.TextScaled = true
            lbl.Font = Enum.Font.GothamBold
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 4
            lbl.Parent = parent
            -- subline
            local line = Instance.new("Frame")
            line.Size = UDim2.new(0.9, 0, 0, 1)
            line.Position = UDim2.new(0, 14, 0, posY + 24)
            line.BackgroundColor3 = Color3.fromRGB(20, 30, 55)
            line.BorderSizePixel = 0
            line.ZIndex = 4
            line.Parent = parent
        end

        local function crearToggle(parent, texto, posY, callback)
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, -28, 0, 40)
            row.Position = UDim2.new(0, 14, 0, posY)
            row.BackgroundColor3 = Color3.fromRGB(16, 16, 28)
            row.BorderSizePixel = 0
            row.ZIndex = 4
            row.Parent = parent
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.65, 0, 1, 0)
            label.Position = UDim2.new(0, 12, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = texto
            label.TextColor3 = Color3.fromRGB(210, 215, 230)
            label.TextScaled = true
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.ZIndex = 5
            label.Parent = row

            local toggleBg = Instance.new("Frame")
            toggleBg.Size = UDim2.new(0, 46, 0, 24)
            toggleBg.Position = UDim2.new(1, -56, 0.5, -12)
            toggleBg.BackgroundColor3 = Color3.fromRGB(30, 30, 48)
            toggleBg.BorderSizePixel = 0
            toggleBg.ZIndex = 5
            toggleBg.Parent = row
            Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

            local toggleCircle = Instance.new("Frame")
            toggleCircle.Size = UDim2.new(0, 18, 0, 18)
            toggleCircle.Position = UDim2.new(0, 3, 0.5, -9)
            toggleCircle.BackgroundColor3 = Color3.fromRGB(140, 150, 180)
            toggleCircle.BorderSizePixel = 0
            toggleCircle.ZIndex = 6
            toggleCircle.Parent = toggleBg
            Instance.new("UICorner", toggleCircle).CornerRadius = UDim.new(1, 0)

            local enabled = false
            local toggleBtn = Instance.new("TextButton")
            toggleBtn.Size = UDim2.new(1, 0, 1, 0)
            toggleBtn.BackgroundTransparency = 1
            toggleBtn.Text = ""
            toggleBtn.ZIndex = 7
            toggleBtn.Parent = toggleBg

            toggleBtn.MouseButton1Click:Connect(function()
                enabled = not enabled
                local tween = TweenService:Create(toggleBg, TweenInfo.new(0.15), {
                    BackgroundColor3 = enabled and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(30, 30, 48)
                })
                tween:Play()
                local tween2 = TweenService:Create(toggleCircle, TweenInfo.new(0.15), {
                    Position = enabled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
                    BackgroundColor3 = enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 150, 180)
                })
                tween2:Play()
                callback(enabled)
            end)

            return row
        end

        local function crearSlider(parent, texto, posY, minVal, maxVal, defVal, callback)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, -28, 0, 60)
            frame.Position = UDim2.new(0, 14, 0, posY)
            frame.BackgroundColor3 = Color3.fromRGB(16, 16, 28)
            frame.BorderSizePixel = 0
            frame.ZIndex = 4
            frame.Parent = parent
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0.65, 0, 0, 22)
            lbl.Position = UDim2.new(0, 12, 0, 6)
            lbl.BackgroundTransparency = 1
            lbl.Text = texto
            lbl.TextColor3 = Color3.fromRGB(210, 215, 230)
            lbl.TextScaled = true
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 5
            lbl.Parent = frame

            local valLbl = Instance.new("TextLabel")
            valLbl.Size = UDim2.new(0.3, 0, 0, 22)
            valLbl.Position = UDim2.new(0.68, 0, 0, 6)
            valLbl.BackgroundTransparency = 1
            valLbl.Text = tostring(defVal)
            valLbl.TextColor3 = Color3.fromRGB(0, 180, 255)
            valLbl.TextScaled = true
            valLbl.Font = Enum.Font.GothamBold
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.ZIndex = 5
            valLbl.Parent = frame

            local trackBg = Instance.new("Frame")
            trackBg.Size = UDim2.new(1, -24, 0, 6)
            trackBg.Position = UDim2.new(0, 12, 0, 38)
            trackBg.BackgroundColor3 = Color3.fromRGB(28, 28, 46)
            trackBg.BorderSizePixel = 0
            trackBg.ZIndex = 5
            trackBg.Parent = frame
            Instance.new("UICorner", trackBg).CornerRadius = UDim.new(1, 0)

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((defVal - minVal)/(maxVal - minVal), 0, 1, 0)
            fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            fill.BorderSizePixel = 0
            fill.ZIndex = 6
            fill.Parent = trackBg
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 14, 0, 14)
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.Position = UDim2.new((defVal - minVal)/(maxVal - minVal), 0, 0.5, 0)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.BorderSizePixel = 0
            knob.ZIndex = 7
            knob.Parent = trackBg
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            local sliding = false
            local sliderVal = defVal

            trackBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local tp = trackBg.AbsolutePosition.X
                    local ts = trackBg.AbsoluteSize.X
                    local rel = math.clamp((input.Position.X - tp) / ts, 0, 1)
                    sliderVal = math.round(minVal + (maxVal - minVal) * rel)
                    fill.Size = UDim2.new(rel, 0, 1, 0)
                    knob.Position = UDim2.new(rel, 0, 0.5, 0)
                    valLbl.Text = tostring(sliderVal)
                    callback(sliderVal)
                end
            end)
        end

        -- ============================================================
        --                    MOVEMENT PAGE
        -- ============================================================
        crearSectionTitle(movPage, "Speed", 10)
        crearToggle(movPage, "Enable Speed", 42, function(on)
            speedEnabled = on
            if on then
                speedLoop = RunService.Heartbeat:Connect(function()
                    local char = lp.Character
                    if char then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then hum.WalkSpeed = currentSpeed end
                    end
                end)
            else
                if speedLoop then speedLoop:Disconnect() speedLoop = nil end
                local char = lp.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum.WalkSpeed = 16 end
                end
            end
        end)
        crearSlider(movPage, "Speed Value", 92, 16, 300, 50, function(val)
            currentSpeed = val
        end)

        crearSectionTitle(movPage, "Jump", 166)
        crearToggle(movPage, "Enable Jump Power", 198, function(on)
            jumpEnabled = on
            local char = lp.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.UseJumpPower = true
                    hum.JumpPower = on and currentJump or 50
                end
            end
        end)
        crearSlider(movPage, "Jump Value", 248, 50, 500, 50, function(val)
            currentJump = val
            if jumpEnabled then
                local char = lp.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.UseJumpPower = true
                        hum.JumpPower = val
                    end
                end
            end
        end)

        crearSectionTitle(movPage, "Fly", 322)
        crearToggle(movPage, "Enable Fly", 354, function(on)
            flyEnabled = on
            local char = lp.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            if on then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = true end

                local bv = Instance.new("BodyVelocity")
                bv.Name = "FlyVelocity"
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
                    local vel = root:FindFirstChild("FlyVelocity")
                    local gyro = root:FindFirstChild("FlyGyro")
                    if not vel or not gyro then return end

                    local moveDir = Vector3.zero
                    local spd = 60

                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        moveDir = moveDir + camera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        moveDir = moveDir - camera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        moveDir = moveDir - camera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        moveDir = moveDir + camera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        moveDir = moveDir + Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        moveDir = moveDir - Vector3.new(0, 1, 0)
                    end

                    if moveDir.Magnitude > 0 then
                        vel.Velocity = moveDir.Unit * spd
                    else
                        vel.Velocity = Vector3.zero
                    end

                    gyro.CFrame = camera.CFrame
                end)
            else
                if flyLoop then flyLoop:Disconnect() flyLoop = nil end
                local vel = hrp:FindFirstChild("FlyVelocity")
                local gyro = hrp:FindFirstChild("FlyGyro")
                if vel then vel:Destroy() end
                if gyro then gyro:Destroy() end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = false end
            end
        end)

        crearSectionTitle(movPage, "Noclip", 408)
        crearToggle(movPage, "Enable Noclip", 440, function(on)
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
            else
                if noclipLoop then noclipLoop:Disconnect() noclipLoop = nil end
            end
        end)

        -- ============================================================
        --                    VISUALS PAGE
        -- ============================================================
        crearSectionTitle(visPage, "Player", 10)
        crearToggle(visPage, "Invisible (Local)", 42, function(on)
            local char = lp.Character
            if char then
                for _, p in pairs(char:GetDescendants()) do
                    if p:IsA("BasePart") or p:IsA("Decal") then
                        p.Transparency = on and 1 or 0
                    end
                end
            end
        end)

        crearSectionTitle(visPage, "World", 96)
        crearToggle(visPage, "Fullbright", 128, function(on)
            fullbrightEnabled = on
            Lighting.Brightness = on and 8 or 1
            Lighting.ClockTime = on and 14 or 14
            Lighting.FogEnd = on and 9e8 or 100000
            for _, v in pairs(Lighting:GetChildren()) do
                if v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") then
                    v.Enabled = not on
                end
            end
        end)

        -- ============================================================
        --                       ESP PAGE
        -- ============================================================

        -- Colores ESP configurables
        local espBoxColor     = Color3.fromRGB(255, 50, 50)
        local espNameColor    = Color3.fromRGB(255, 255, 255)
        local espHealthColor  = Color3.fromRGB(50, 255, 80)
        local espLineColor    = Color3.fromRGB(255, 255, 0)
        local espSkeletonColor= Color3.fromRGB(255, 150, 50)
        local espShowBox      = true
        local espShowName     = true
        local espShowHealth   = true
        local espShowLines    = true
        local espShowSkeleton = true

        -- Función para crear ESP de un jugador
        local function createESP(player)
            if player == lp then return end
            if espObjects[player] then return end

            local folder = Instance.new("Folder")
            folder.Name = player.Name .. "_ESP"
            folder.Parent = MainGui

            -- Billboard para nombre y vida
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "ESP_Billboard"
            billboard.Size = UDim2.new(0, 120, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 3.2, 0)
            billboard.AlwaysOnTop = true
            billboard.Enabled = false
            billboard.Parent = folder

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = player.Name
            nameLabel.TextColor3 = espNameColor
            nameLabel.TextScaled = true
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextStrokeTransparency = 0
            nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            nameLabel.Parent = billboard

            local healthLabel = Instance.new("TextLabel")
            healthLabel.Size = UDim2.new(1, 0, 0.5, 0)
            healthLabel.Position = UDim2.new(0, 0, 0.5, 0)
            healthLabel.BackgroundTransparency = 1
            healthLabel.Text = "HP: 100"
            healthLabel.TextColor3 = espHealthColor
            healthLabel.TextScaled = true
            healthLabel.Font = Enum.Font.Gotham
            healthLabel.TextStrokeTransparency = 0
            healthLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            healthLabel.Parent = billboard

            -- Línea al jugador (DrawingLib si disponible, sino Frame básico)
            local lineGui = Instance.new("ScreenGui")
            lineGui.Name = "ESPLine_" .. player.Name
            lineGui.ResetOnSpawn = false
            lineGui.IgnoreGuiInset = true
            lineGui.Enabled = false
            lineGui.Parent = game:GetService("CoreGui")

            espObjects[player] = {
                folder = folder,
                billboard = billboard,
                nameLabel = nameLabel,
                healthLabel = healthLabel,
                lineGui = lineGui,
            }

            -- Limpiar si el player deja el juego
            player.AncestryChanged:Connect(function()
                if not player:IsDescendantOf(game) then
                    if espObjects[player] then
                        pcall(function() folder:Destroy() end)
                        pcall(function() lineGui:Destroy() end)
                        espObjects[player] = nil
                    end
                end
            end)
        end

        local function removeESP(player)
            if espObjects[player] then
                pcall(function() espObjects[player].folder:Destroy() end)
                pcall(function() espObjects[player].lineGui:Destroy() end)
                espObjects[player] = nil
            end
        end

        local function updateESP()
            for player, obj in pairs(espObjects) do
                local char = player.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    local head = char:FindFirstChild("Head")

                    if hrp and hum and head then
                        -- Billboard
                        obj.billboard.Adornee = head
                        obj.billboard.Enabled = espEnabled and espShowName

                        -- Nombre
                        obj.nameLabel.Visible = espShowName
                        obj.nameLabel.Text = player.Name

                        -- HP
                        obj.healthLabel.Visible = espShowHealth
                        local hp = math.floor(hum.Health)
                        local maxHp = math.floor(hum.MaxHealth)
                        obj.healthLabel.Text = "HP: " .. hp .. "/" .. maxHp
                        local pct = (maxHp > 0) and (hp / maxHp) or 0
                        obj.healthLabel.TextColor3 = Color3.fromRGB(
                            math.floor(255 * (1 - pct)),
                            math.floor(255 * pct),
                            50
                        )

                        -- Línea al centro de pantalla
                        if espShowLines and espEnabled then
                            local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                            if onScreen then
                                -- Dibujamos una Frame-line simple
                                local lineFrame = obj.lineGui:FindFirstChild("Line")
                                if not lineFrame then
                                    lineFrame = Instance.new("Frame")
                                    lineFrame.Name = "Line"
                                    lineFrame.BackgroundColor3 = espLineColor
                                    lineFrame.BorderSizePixel = 0
                                    lineFrame.AnchorPoint = Vector2.new(0.5, 0)
                                    local lGui = Instance.new("ScreenGui")
                                    lGui.Name = "LineHolder"
                                    lGui.ResetOnSpawn = false
                                    lGui.IgnoreGuiInset = true
                                    lGui.Parent = obj.lineGui
                                    lineFrame.Parent = lGui
                                end
                                obj.lineGui.Enabled = true

                                local vp = camera.ViewportSize
                                local startX = vp.X / 2
                                local startY = vp.Y
                                local endX = screenPos.X
                                local endY = screenPos.Y
                                local dx = endX - startX
                                local dy = endY - startY
                                local len = math.sqrt(dx*dx + dy*dy)
                                local angle = math.atan2(dy, dx)

                                local lineHolder = obj.lineGui:FindFirstChild("LineHolder")
                                if lineHolder then
                                    local lf = lineHolder:FindFirstChild("Line")
                                    if lf then
                                        lf.Size = UDim2.new(0, len, 0, 1)
                                        lf.Position = UDim2.new(0, startX, 0, startY)
                                        lf.Rotation = math.deg(angle)
                                        lf.BackgroundColor3 = espLineColor
                                    end
                                end
                            else
                                obj.lineGui.Enabled = false
                            end
                        else
                            obj.lineGui.Enabled = false
                        end

                        -- Skeleton (highlights en partes del body)
                        if espShowSkeleton and espEnabled then
                            local skeletonParts = {"Head","UpperTorso","LowerTorso","LeftUpperArm","RightUpperArm","LeftUpperLeg","RightUpperLeg","LeftLowerLeg","RightLowerLeg","LeftFoot","RightFoot","LeftHand","RightHand"}
                            for _, partName in pairs(skeletonParts) do
                                local part = char:FindFirstChild(partName)
                                if part and part:IsA("BasePart") then
                                    local sel = part:FindFirstChild("ESPSkeleton")
                                    if not sel then
                                        sel = Instance.new("SelectionBox")
                                        sel.Name = "ESPSkeleton"
                                        sel.Color3 = espSkeletonColor
                                        sel.LineThickness = 0.04
                                        sel.SurfaceTransparency = 1
                                        sel.Adornee = part
                                        sel.Parent = part
                                    end
                                    sel.Visible = true
                                end
                            end
                        else
                            -- Remover skeleton
                            for _, char2 in pairs({player.Character}) do
                                if char2 then
                                    for _, d in pairs(char2:GetDescendants()) do
                                        if d.Name == "ESPSkeleton" then d:Destroy() end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        -- Toggle ESP master
        local espLoop

        local function toggleESP(on)
            espEnabled = on
            if on then
                for _, p in pairs(Players:GetPlayers()) do
                    createESP(p)
                end
                Players.PlayerAdded:Connect(function(p)
                    if espEnabled then createESP(p) end
                end)
                espLoop = RunService.RenderStepped:Connect(updateESP)
            else
                if espLoop then espLoop:Disconnect() espLoop = nil end
                for _, obj in pairs(espObjects) do
                    pcall(function() obj.billboard.Enabled = false end)
                    pcall(function() obj.lineGui.Enabled = false end)
                end
                -- Limpiar skeleton
                for _, p in pairs(Players:GetPlayers()) do
                    local char = p.Character
                    if char then
                        for _, d in pairs(char:GetDescendants()) do
                            if d.Name == "ESPSkeleton" then d:Destroy() end
                        end
                    end
                end
            end
        end

        -- UI del ESP page
        crearSectionTitle(espPage, "ESP Global", 10)
        crearToggle(espPage, "Enable ESP", 42, function(on)
            toggleESP(on)
        end)

        crearSectionTitle(espPage, "ESP Options", 96)
        crearToggle(espPage, "Show Names", 128, function(on)
            espShowName = on
        end)
        crearToggle(espPage, "Show Health", 178, function(on)
            espShowHealth = on
        end)
        crearToggle(espPage, "Show Lines", 228, function(on)
            espShowLines = on
        end)
        crearToggle(espPage, "Show Skeleton", 278, function(on)
            espShowSkeleton = on
            if not on then
                for _, p in pairs(Players:GetPlayers()) do
                    local char = p.Character
                    if char then
                        for _, d in pairs(char:GetDescendants()) do
                            if d.Name == "ESPSkeleton" then d:Destroy() end
                        end
                    end
                end
            end
        end)

        -- ============================================================
        --                      MISC PAGE
        -- ============================================================
        crearSectionTitle(miscPage, "UI Controls", 10)

        local hideKeyLabel = Instance.new("TextLabel")
        hideKeyLabel.Size = UDim2.new(1, -28, 0, 30)
        hideKeyLabel.Position = UDim2.new(0, 14, 0, 46)
        hideKeyLabel.BackgroundTransparency = 1
        hideKeyLabel.Text = "Hide Key: RightShift"
        hideKeyLabel.TextColor3 = Color3.fromRGB(160, 170, 200)
        hideKeyLabel.TextScaled = true
        hideKeyLabel.Font = Enum.Font.Gotham
        hideKeyLabel.TextXAlignment = Enum.TextXAlignment.Left
        hideKeyLabel.ZIndex = 4
        hideKeyLabel.Parent = miscPage

        local changingKey = false
        local changeKeyBtn = Instance.new("TextButton")
        changeKeyBtn.Size = UDim2.new(1, -28, 0, 38)
        changeKeyBtn.Position = UDim2.new(0, 14, 0, 84)
        changeKeyBtn.BackgroundColor3 = Color3.fromRGB(16, 16, 28)
        changeKeyBtn.TextColor3 = Color3.fromRGB(0, 190, 255)
        changeKeyBtn.Text = "Cambiar Tecla de Esconder"
        changeKeyBtn.TextScaled = true
        changeKeyBtn.Font = Enum.Font.GothamBold
        changeKeyBtn.BorderSizePixel = 0
        changeKeyBtn.ZIndex = 5
        changeKeyBtn.Parent = miscPage
        Instance.new("UICorner", changeKeyBtn).CornerRadius = UDim.new(0, 8)
        local CKS = Instance.new("UIStroke")
        CKS.Color = Color3.fromRGB(0, 140, 210)
        CKS.Thickness = 1.5
        CKS.Parent = changeKeyBtn

        crearSectionTitle(miscPage, "Info", 138)

        local infoLabel = Instance.new("TextLabel")
        infoLabel.Size = UDim2.new(1, -28, 0, 70)
        infoLabel.Position = UDim2.new(0, 14, 0, 174)
        infoLabel.BackgroundColor3 = Color3.fromRGB(14, 14, 26)
        infoLabel.TextColor3 = Color3.fromRGB(130, 145, 180)
        infoLabel.Text = "Script: Diogo Script v2\nFly: W/A/S/D + Space/Ctrl\nNoclip: atraviesa paredes\nESP: ver jugadores"
        infoLabel.TextScaled = true
        infoLabel.Font = Enum.Font.Gotham
        infoLabel.TextXAlignment = Enum.TextXAlignment.Left
        infoLabel.ZIndex = 4
        infoLabel.Parent = miscPage
        Instance.new("UICorner", infoLabel).CornerRadius = UDim.new(0, 8)
        local il = Instance.new("UIPadding", infoLabel)
        il.PaddingLeft = UDim.new(0, 10)
        il.PaddingTop = UDim.new(0, 6)

        -- Botón minimizar / mostrar
        local hidden = false
        MinBtn.MouseButton1Click:Connect(function()
            hidden = not hidden
            if hidden then
                TweenService:Create(Main, TweenInfo.new(0.2), {
                    Size = UDim2.new(0, 44, 0, 44),
                    Position = UDim2.new(1, -56, 0, 10)
                }):Play()
                task.wait(0.15)
                for _, child in pairs(Main:GetChildren()) do
                    if child ~= MinBtn and child ~= ColorBar then
                        child.Visible = false
                    end
                end
                MinBtn.Text = "☰"
                MinBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
                MinBtn.Position = UDim2.new(0, 5, 0, 5)
                MinBtn.Size = UDim2.new(0, 34, 0, 34)
            else
                for _, child in pairs(Main:GetChildren()) do
                    child.Visible = true
                end
                TweenService:Create(Main, TweenInfo.new(0.2), {
                    Size = UDim2.new(0, 580, 0, 400),
                    Position = UDim2.new(0.5, -290, 0.5, -200)
                }):Play()
                MinBtn.Text = "✕"
                MinBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
                MinBtn.Position = UDim2.new(1, -44, 0.5, -17)
            end
        end)

        -- Cambiar tecla
        changeKeyBtn.MouseButton1Click:Connect(function()
            changingKey = true
            changeKeyBtn.Text = "Presiona una tecla..."
            changeKeyBtn.TextColor3 = Color3.fromRGB(255, 200, 0)
        end)

        UserInputService.InputBegan:Connect(function(input, gpe)
            if changingKey and input.UserInputType == Enum.UserInputType.Keyboard then
                hideKey = input.KeyCode
                hideKeyLabel.Text = "Hide Key: " .. input.KeyCode.Name
                changeKeyBtn.Text = "Cambiar Tecla de Esconder"
                changeKeyBtn.TextColor3 = Color3.fromRGB(0, 190, 255)
                changingKey = false
            elseif not changingKey and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == hideKey then
                uiVisible = not uiVisible
                Main.Visible = uiVisible
            end
        end)

        -- Drag header
        local dragging, dragStart, startPos2
        Header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos2 = Main.Position
            end
        end)
        Header.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                Main.Position = UDim2.new(
                    startPos2.X.Scale, startPos2.X.Offset + delta.X,
                    startPos2.Y.Scale, startPos2.Y.Offset + delta.Y
                )
            end
        end)

    else
        KeyStatus.TextColor3 = Color3.fromRGB(255, 70, 70)
        KeyStatus.Text = "✗ Key incorrecta. Intenta de nuevo."
        TweenService:Create(KeyFrame, TweenInfo.new(0.05, Enum.EasingStyle.Bounce), {
            Position = UDim2.new(0.5, -195, 0.5, -120)
        }):Play()
        task.wait(0.08)
        TweenService:Create(KeyFrame, TweenInfo.new(0.05, Enum.EasingStyle.Bounce), {
            Position = UDim2.new(0.5, -205, 0.5, -120)
        }):Play()
        task.wait(0.08)
        TweenService:Create(KeyFrame, TweenInfo.new(0.05), {
            Position = UDim2.new(0.5, -200, 0.5, -120)
        }):Play()
    end
end)