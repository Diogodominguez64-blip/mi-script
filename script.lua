-- Diogo Script | NOA Style
-- Key: Diogo1234

local KEY_CORRECTA = "Diogo1234"
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer

-- ============ KEY SYSTEM ============
local KeyGui = Instance.new("ScreenGui")
KeyGui.Name = "KeySystem"
KeyGui.ResetOnSpawn = false
KeyGui.Parent = game:GetService("CoreGui")

local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(0, 380, 0, 220)
KeyFrame.Position = UDim2.new(0.5, -190, 0.5, -110)
KeyFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
KeyFrame.BorderSizePixel = 0
KeyFrame.Parent = KeyGui
Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 14)

-- Borde degradado simulado
local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(140, 60, 255)
Stroke.Thickness = 2
Stroke.Parent = KeyFrame

-- Título
local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1, 0, 0, 55)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "DIOGO SCRIPT"
KeyTitle.TextColor3 = Color3.fromRGB(0, 220, 255)
KeyTitle.TextScaled = true
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.Parent = KeyFrame

-- Caja de key
local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0.88, 0, 0, 42)
KeyBox.Position = UDim2.new(0.06, 0, 0, 65)
KeyBox.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.PlaceholderText = "Enter Key Here..."
KeyBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
KeyBox.Text = ""
KeyBox.TextScaled = true
KeyBox.Font = Enum.Font.Gotham
KeyBox.BorderSizePixel = 0
KeyBox.Parent = KeyFrame
Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 8)
local BoxStroke = Instance.new("UIStroke")
BoxStroke.Color = Color3.fromRGB(60, 60, 90)
BoxStroke.Thickness = 1
BoxStroke.Parent = KeyBox

-- Botón Get Key
local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Size = UDim2.new(0.41, 0, 0, 44)
GetKeyBtn.Position = UDim2.new(0.06, 0, 0, 120)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
GetKeyBtn.TextColor3 = Color3.fromRGB(0, 220, 255)
GetKeyBtn.Text = "Get Key"
GetKeyBtn.TextScaled = true
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.BorderSizePixel = 0
GetKeyBtn.Parent = KeyFrame
Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 8)
local GStroke = Instance.new("UIStroke")
GStroke.Color = Color3.fromRGB(0, 180, 220)
GStroke.Thickness = 1.5
GStroke.Parent = GetKeyBtn

-- Botón Verify
local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Size = UDim2.new(0.41, 0, 0, 44)
VerifyBtn.Position = UDim2.new(0.53, 0, 0, 120)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(130, 50, 255)
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.Text = "Verify"
VerifyBtn.TextScaled = true
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.BorderSizePixel = 0
VerifyBtn.Parent = KeyFrame
Instance.new("UICorner", VerifyBtn).CornerRadius = UDim.new(0, 8)

-- Status
local KeyStatus = Instance.new("TextLabel")
KeyStatus.Size = UDim2.new(1, 0, 0, 28)
KeyStatus.Position = UDim2.new(0, 0, 0, 178)
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
        task.wait(1.2)
        KeyGui:Destroy()

        -- ============ VARIABLES ============
        local speedEnabled = false
        local invisEnabled = false
        local noclipEnabled = false
        local flyEnabled = false
        local currentSpeed = 50
        local currentJump = 50
        local hideKey = Enum.KeyCode.RightShift
        local uiVisible = true
        local speedLoop, noclipLoop, flyLoop, bodyVel, bodyGyro

        -- ============ MAIN GUI ============
        local MainGui = Instance.new("ScreenGui")
        MainGui.Name = "DiogoScript"
        MainGui.ResetOnSpawn = false
        MainGui.Parent = game:GetService("CoreGui")

        -- Ventana principal
        local Main = Instance.new("Frame")
        Main.Size = UDim2.new(0, 560, 0, 370)
        Main.Position = UDim2.new(0.5, -280, 0.5, -185)
        Main.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
        Main.BorderSizePixel = 0
        Main.Parent = MainGui
        Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
        local MainStroke = Instance.new("UIStroke")
        MainStroke.Color = Color3.fromRGB(0, 180, 255)
        MainStroke.Thickness = 1.5
        MainStroke.Parent = Main

        -- Header
        local Header = Instance.new("Frame")
        Header.Size = UDim2.new(1, 0, 0, 38)
        Header.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
        Header.BorderSizePixel = 0
        Header.Parent = Main
        Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

        local HeaderTitle = Instance.new("TextLabel")
        HeaderTitle.Size = UDim2.new(0, 180, 1, 0)
        HeaderTitle.Position = UDim2.new(0, 14, 0, 0)
        HeaderTitle.BackgroundTransparency = 1
        HeaderTitle.Text = "DIOGO SCRIPT"
        HeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        HeaderTitle.TextScaled = true
        HeaderTitle.Font = Enum.Font.GothamBold
        HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
        HeaderTitle.Parent = Header

        local PremiumLabel = Instance.new("TextLabel")
        PremiumLabel.Size = UDim2.new(0, 80, 0, 20)
        PremiumLabel.Position = UDim2.new(0, 196, 0.5, -10)
        PremiumLabel.BackgroundTransparency = 1
        PremiumLabel.Text = "FREE"
        PremiumLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
        PremiumLabel.TextScaled = true
        PremiumLabel.Font = Enum.Font.GothamBold
        PremiumLabel.Parent = Header

        -- Línea azul debajo del header
        local HeaderLine = Instance.new("Frame")
        HeaderLine.Size = UDim2.new(1, 0, 0, 2)
        HeaderLine.Position = UDim2.new(0, 0, 0, 38)
        HeaderLine.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
        HeaderLine.BorderSizePixel = 0
        HeaderLine.Parent = Main

        -- Sidebar
        local Sidebar = Instance.new("Frame")
        Sidebar.Size = UDim2.new(0, 110, 1, -40)
        Sidebar.Position = UDim2.new(0, 0, 0, 40)
        Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
        Sidebar.BorderSizePixel = 0
        Sidebar.Parent = Main

        -- Contenido principal
        local Content = Instance.new("Frame")
        Content.Size = UDim2.new(1, -110, 1, -40)
        Content.Position = UDim2.new(0, 110, 0, 40)
        Content.BackgroundColor3 = Color3.fromRGB(14, 14, 22)
        Content.BorderSizePixel = 0
        Content.Parent = Main
        Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 8)

        -- ======= TABS =======
        local tabs = {}
        local tabPages = {}
        local activeTab = nil

        local tabNames = {"Movement", "Visuals", "Misc"}

        local function crearTab(nombre, index)
            local tabBtn = Instance.new("TextButton")
            tabBtn.Size = UDim2.new(1, 0, 0, 42)
            tabBtn.Position = UDim2.new(0, 0, 0, (index-1)*42 + 10)
            tabBtn.BackgroundTransparency = 1
            tabBtn.TextColor3 = Color3.fromRGB(160, 160, 180)
            tabBtn.Text = nombre
            tabBtn.TextScaled = true
            tabBtn.Font = Enum.Font.GothamBold
            tabBtn.BorderSizePixel = 0
            tabBtn.Parent = Sidebar

            local indicator = Instance.new("Frame")
            indicator.Size = UDim2.new(0, 3, 0.6, 0)
            indicator.Position = UDim2.new(0, 0, 0.2, 0)
            indicator.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
            indicator.BorderSizePixel = 0
            indicator.Visible = false
            indicator.Parent = tabBtn

            local page = Instance.new("Frame")
            page.Size = UDim2.new(1, 0, 1, 0)
            page.BackgroundTransparency = 1
            page.Visible = false
            page.Parent = Content

            tabs[nombre] = {btn = tabBtn, indicator = indicator}
            tabPages[nombre] = page

            tabBtn.MouseButton1Click:Connect(function()
                for name, t in pairs(tabs) do
                    t.btn.TextColor3 = Color3.fromRGB(160, 160, 180)
                    t.indicator.Visible = false
                    tabPages[name].Visible = false
                end
                tabBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
                indicator.Visible = true
                page.Visible = true
                activeTab = nombre
            end)

            return page
        end

        local movPage = crearTab("Movement", 1)
        local visPage = crearTab("Visuals", 2)
        local miscPage = crearTab("Misc", 3)

        -- Activar primera tab
        tabs["Movement"].btn.TextColor3 = Color3.fromRGB(0, 200, 255)
        tabs["Movement"].indicator.Visible = true
        movPage.Visible = true

        -- ======= TOGGLE HELPER =======
        local function crearToggle(parent, texto, posY, callback)
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, -20, 0, 38)
            row.Position = UDim2.new(0, 10, 0, posY)
            row.BackgroundTransparency = 1
            row.Parent = parent

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.7, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = texto
            label.TextColor3 = Color3.fromRGB(220, 220, 220)
            label.TextScaled = true
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = row

            local toggleBg = Instance.new("Frame")
            toggleBg.Size = UDim2.new(0, 44, 0, 24)
            toggleBg.Position = UDim2.new(1, -50, 0.5, -12)
            toggleBg.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            toggleBg.BorderSizePixel = 0
            toggleBg.Parent = row
            Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

            local toggleCircle = Instance.new("Frame")
            toggleCircle.Size = UDim2.new(0, 18, 0, 18)
            toggleCircle.Position = UDim2.new(0, 3, 0.5, -9)
            toggleCircle.BackgroundColor3 = Color3.fromRGB(160, 160, 180)
            toggleCircle.BorderSizePixel = 0
            toggleCircle.Parent = toggleBg
            Instance.new("UICorner", toggleCircle).CornerRadius = UDim.new(1, 0)

            local enabled = false
            local toggleBtn = Instance.new("TextButton")
            toggleBtn.Size = UDim2.new(1, 0, 1, 0)
            toggleBtn.BackgroundTransparency = 1
            toggleBtn.Text = ""
            toggleBtn.Parent = toggleBg

            toggleBtn.MouseButton1Click:Connect(function()
                enabled = not enabled
                if enabled then
                    toggleBg.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
                    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    toggleCircle.Position = UDim2.new(1, -21, 0.5, -9)
                else
                    toggleBg.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
                    toggleCircle.BackgroundColor3 = Color3.fromRGB(160, 160, 180)
                    toggleCircle.Position = UDim2.new(0, 3, 0.5, -9)
                end
                callback(enabled)
            end)

            return row
        end

        local function crearSectionTitle(parent, texto, posY)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -20, 0, 26)
            lbl.Position = UDim2.new(0, 10, 0, posY)
            lbl.BackgroundTransparency = 1
            lbl.Text = texto
            lbl.TextColor3 = Color3.fromRGB(0, 200, 255)
            lbl.TextScaled = true
            lbl.Font = Enum.Font.GothamBold
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = parent
        end

        local function crearSlider(parent, texto, posY, minVal, maxVal, defVal, callback)
            local sliderVal = defVal
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, -20, 0, 50)
            frame.Position = UDim2.new(0, 10, 0, posY)
            frame.BackgroundTransparency = 1
            frame.Parent = parent

            local topRow = Instance.new("Frame")
            topRow.Size = UDim2.new(1, 0, 0, 20)
            topRow.BackgroundTransparency = 1
            topRow.Parent = frame

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0.7, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = texto
            lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
            lbl.TextScaled = true
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = topRow

            local valLbl = Instance.new("TextLabel")
            valLbl.Size = UDim2.new(0.3, 0, 1, 0)
            valLbl.Position = UDim2.new(0.7, 0, 0, 0)
            valLbl.BackgroundTransparency = 1
            valLbl.Text = tostring(defVal)
            valLbl.TextColor3 = Color3.fromRGB(0, 200, 255)
            valLbl.TextScaled = true
            valLbl.Font = Enum.Font.GothamBold
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.Parent = topRow

            local track = Instance.new("Frame")
            track.Size = UDim2.new(1, 0, 0, 6)
            track.Position = UDim2.new(0, 0, 0, 30)
            track.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
            track.BorderSizePixel = 0
            track.Parent = frame
            Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((defVal - minVal)/(maxVal - minVal), 0, 1, 0)
            fill.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
            fill.BorderSizePixel = 0
            fill.Parent = track
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

            local sliding = false
            track.InputBegan:Connect(function(input)
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
                    local trackPos = track.AbsolutePosition.X
                    local trackSize = track.AbsoluteSize.X
                    local rel = math.clamp((input.Position.X - trackPos) / trackSize, 0, 1)
                    sliderVal = math.floor(minVal + (maxVal - minVal) * rel)
                    fill.Size = UDim2.new(rel, 0, 1, 0)
                    valLbl.Text = tostring(sliderVal)
                    callback(sliderVal)
                end
            end)
        end

        -- ======= MOVEMENT PAGE =======
        crearSectionTitle(movPage, "Speed", 8)
        crearToggle(movPage, "Enable Speed", 36, function(on)
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
                if speedLoop then speedLoop:Disconnect() end
                local char = lp.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum.WalkSpeed = 16 end
                end
            end
        end)
        crearSlider(movPage, "Speed Value", 80, 16, 300, 50, function(val)
            currentSpeed = val
        end)

        crearSectionTitle(movPage, "Jump", 142)
        crearToggle(movPage, "Enable Jump Power", 170, function(on)
            local char = lp.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.JumpPower = on and currentJump or 50 end
            end
        end)
        crearSlider(movPage, "Jump Value", 214, 50, 300, 50, function(val)
            currentJump = val
            local char = lp.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.JumpPower = val end
            end
        end)

        crearSectionTitle(movPage, "Other", 276)
        crearToggle(movPage, "Noclip", 304, function(on)
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
                if noclipLoop then noclipLoop:Disconnect() end
            end
        end)

        -- ======= VISUALS PAGE =======
        crearSectionTitle(visPage, "Players", 8)
        crearToggle(visPage, "Invisible (Local)", 36, function(on)
            local char = lp.Character
            if char then
                for _, p in pairs(char:GetDescendants()) do
                    if p:IsA("BasePart") or p:IsA("Decal") then
                        p.Transparency = on and 1 or 0
                    end
                end
            end
        end)

        crearSectionTitle(visPage, "World", 86)
        crearToggle(visPage, "Fullbright", 114, function(on)
            game:GetService("Lighting").Brightness = on and 10 or 1
            game:GetService("Lighting").ClockTime = on and 14 or game:GetService("Lighting").ClockTime
        end)

        -- ======= MISC PAGE =======
        crearSectionTitle(miscPage, "UI Controls", 8)

        local hideKeyLabel = Instance.new("TextLabel")
        hideKeyLabel.Size = UDim2.new(1, -20, 0, 30)
        hideKeyLabel.Position = UDim2.new(0, 10, 0, 40)
        hideKeyLabel.BackgroundTransparency = 1
        hideKeyLabel.Text = "Hide Key: RightShift (click para cambiar)"
        hideKeyLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
        hideKeyLabel.TextScaled = true
        hideKeyLabel.Font = Enum.Font.Gotham
        hideKeyLabel.TextXAlignment = Enum.TextXAlignment.Left
        hideKeyLabel.Parent = miscPage

        local changingKey = false
        local changeKeyBtn = Instance.new("TextButton")
        changeKeyBtn.Size = UDim2.new(0.88, 0, 0, 36)
        changeKeyBtn.Position = UDim2.new(0.06, 0, 0, 76)
        changeKeyBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
        changeKeyBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
        changeKeyBtn.Text = "Cambiar Tecla de Esconder"
        changeKeyBtn.TextScaled = true
        changeKeyBtn.Font = Enum.Font.GothamBold
        changeKeyBtn.BorderSizePixel = 0
        changeKeyBtn.Parent = miscPage
        Instance.new("UICorner", changeKeyBtn).CornerRadius = UDim.new(0, 8)
        local CKStroke = Instance.new("UIStroke")
        CKStroke.Color = Color3.fromRGB(0, 160, 220)
        CKStroke.Thickness = 1.5
        CKStroke.Parent = changeKeyBtn

        changeKeyBtn.MouseButton1Click:Connect(function()
            changingKey = true
            changeKeyBtn.Text = "Presiona una tecla..."
            changeKeyBtn.TextColor3 = Color3.fromRGB(255, 200, 0)
        end)

        UserInputService.InputBegan:Connect(function(input, gpe)
            if changingKey and input.UserInputType == Enum.UserInputType.Keyboard then
                hideKey = input.KeyCode
                hideKeyLabel.Text = "Hide Key: " .. tostring(hideKey.Name) .. " (click para cambiar)"
                changeKeyBtn.Text = "Cambiar Tecla de Esconder"
                changeKeyBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
                changingKey = false
            elseif not changingKey and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == hideKey then
                uiVisible = not uiVisible
                Main.Visible = uiVisible
            end
        end)

        -- Botón X para móvil
        local MobileX = Instance.new("TextButton")
        MobileX.Size = UDim2.new(0, 38, 0, 38)
        MobileX.Position = UDim2.new(1, -48, 0, 5)
        MobileX.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        MobileX.TextColor3 = Color3.fromRGB(255, 255, 255)
        MobileX.Text = "✕"
        MobileX.TextScaled = true
        MobileX.Font = Enum.Font.GothamBold
        MobileX.BorderSizePixel = 0
        MobileX.Parent = Main
        Instance.new("UICorner", MobileX).CornerRadius = UDim.new(1, 0)

        local hidden = false
        MobileX.MouseButton1Click:Connect(function()
            hidden = not hidden
            if hidden then
                Main.Size = UDim2.new(0, 38, 0, 38)
                Main.Position = UDim2.new(1, -55, 0, 10)
                MobileX.Text = "☰"
                MobileX.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
                for _, child in pairs(Main:GetChildren()) do
                    if child ~= MobileX then child.Visible = false end
                end
            else
                Main.Size = UDim2.new(0, 560, 0, 370)
                Main.Position = UDim2.new(0.5, -280, 0.5, -185)
                MobileX.Text = "✕"
                MobileX.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                MobileX.Position = UDim2.new(1, -48, 0, 5)
                for _, child in pairs(Main:GetChildren()) do
                    child.Visible = true
                end
            end
        end)

        -- Drag
        local dragging, dragStart, startPos
        Header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = Main.Position
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
                Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)

    else
        KeyStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
        KeyStatus.Text = "✗ Key incorrecta. Intenta de nuevo."
    end
end)