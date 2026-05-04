-- Script con Sistema de Key + UI
-- Key: Diogo1234

local KEY_CORRECTA = "Diogo1234"

-- ============ KEY SYSTEM ============
local KeyGui = Instance.new("ScreenGui")
local KeyFrame = Instance.new("Frame")
local KeyTitle = Instance.new("TextLabel")
local KeyBox = Instance.new("TextBox")
local KeyBtn = Instance.new("TextButton")
local KeyStatus = Instance.new("TextLabel")

KeyGui.Name = "KeySystem"
KeyGui.ResetOnSpawn = false
KeyGui.Parent = game:GetService("CoreGui")

KeyFrame.Size = UDim2.new(0, 350, 0, 200)
KeyFrame.Position = UDim2.new(0.5, -175, 0.5, -100)
KeyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
KeyFrame.BorderSizePixel = 0
KeyFrame.Parent = KeyGui

Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 12)

KeyTitle.Size = UDim2.new(1, 0, 0, 50)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "🔑 Key System"
KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyTitle.TextScaled = true
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.Parent = KeyFrame

KeyBox.Size = UDim2.new(0.85, 0, 0, 40)
KeyBox.Position = UDim2.new(0.075, 0, 0, 60)
KeyBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.PlaceholderText = "Ingresa tu key..."
KeyBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 130)
KeyBox.Text = ""
KeyBox.TextScaled = true
KeyBox.Font = Enum.Font.Gotham
KeyBox.BorderSizePixel = 0
KeyBox.Parent = KeyFrame
Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 8)

KeyBtn.Size = UDim2.new(0.85, 0, 0, 40)
KeyBtn.Position = UDim2.new(0.075, 0, 0, 110)
KeyBtn.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
KeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBtn.Text = "✅ Verificar"
KeyBtn.TextScaled = true
KeyBtn.Font = Enum.Font.GothamBold
KeyBtn.BorderSizePixel = 0
KeyBtn.Parent = KeyFrame
Instance.new("UICorner", KeyBtn).CornerRadius = UDim.new(0, 8)

KeyStatus.Size = UDim2.new(1, 0, 0, 30)
KeyStatus.Position = UDim2.new(0, 0, 0, 160)
KeyStatus.BackgroundTransparency = 1
KeyStatus.Text = ""
KeyStatus.TextScaled = true
KeyStatus.Font = Enum.Font.Gotham
KeyStatus.Parent = KeyFrame

KeyBtn.MouseButton1Click:Connect(function()
    if KeyBox.Text == KEY_CORRECTA then
        KeyStatus.TextColor3 = Color3.fromRGB(0, 255, 100)
        KeyStatus.Text = "✅ Correcta! Cargando..."
        task.wait(1.5)
        KeyGui:Destroy()

        -- ============ MAIN UI ============
        local Players = game:GetService("Players")
        local lp = Players.LocalPlayer
        local char = lp.Character or lp.CharacterAdded:Wait()
        local humanoid = char:WaitForChild("Humanoid")

        local speedEnabled = false
        local invisEnabled = false
        local currentSpeed = 50

        local MainGui = Instance.new("ScreenGui")
        MainGui.Name = "MainScript"
        MainGui.ResetOnSpawn = false
        MainGui.Parent = game:GetService("CoreGui")

        -- Ventana principal
        local Main = Instance.new("Frame")
        Main.Size = UDim2.new(0, 280, 0, 320)
        Main.Position = UDim2.new(0, 20, 0.5, -160)
        Main.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
        Main.BorderSizePixel = 0
        Main.Parent = MainGui
        Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

        -- Barra de título
        local TitleBar = Instance.new("Frame")
        TitleBar.Size = UDim2.new(1, 0, 0, 45)
        TitleBar.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
        TitleBar.BorderSizePixel = 0
        TitleBar.Parent = Main
        Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 14)

        local TitleText = Instance.new("TextLabel")
        TitleText.Size = UDim2.new(1, 0, 1, 0)
        TitleText.BackgroundTransparency = 1
        TitleText.Text = "⚡ Diogo Script"
        TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
        TitleText.TextScaled = true
        TitleText.Font = Enum.Font.GothamBold
        TitleText.Parent = TitleBar

        -- Función para crear botones toggle
        local function crearBoton(texto, posY, color)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.88, 0, 0, 45)
            btn.Position = UDim2.new(0.06, 0, 0, posY)
            btn.BackgroundColor3 = color or Color3.fromRGB(35, 35, 50)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Text = texto
            btn.TextScaled = true
            btn.Font = Enum.Font.GothamBold
            btn.BorderSizePixel = 0
            btn.Parent = Main
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
            return btn
        end

        -- ======= SPEED BUTTON =======
        local speedBtn = crearBoton("⚡ Speed: OFF", 60)
        local speedLoop

        speedBtn.MouseButton1Click:Connect(function()
            speedEnabled = not speedEnabled
            if speedEnabled then
                speedBtn.Text = "⚡ Speed: ON"
                speedBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                speedLoop = game:GetService("RunService").Heartbeat:Connect(function()
                    if lp.Character then
                        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
                        if hum then hum.WalkSpeed = currentSpeed end
                    end
                end)
            else
                speedBtn.Text = "⚡ Speed: OFF"
                speedBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
                if speedLoop then speedLoop:Disconnect() end
                if lp.Character then
                    local hum = lp.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.WalkSpeed = 16 end
                end
            end
        end)

        -- ======= SPEED SLIDER LABEL =======
        local speedLabel = Instance.new("TextLabel")
        speedLabel.Size = UDim2.new(0.88, 0, 0, 25)
        speedLabel.Position = UDim2.new(0.06, 0, 0, 112)
        speedLabel.BackgroundTransparency = 1
        speedLabel.Text = "Velocidad: 50"
        speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        speedLabel.TextScaled = true
        speedLabel.Font = Enum.Font.Gotham
        speedLabel.Parent = Main

        -- Botones + y - para speed
        local minusBtn = crearBoton("➖", 140, Color3.fromRGB(200, 60, 60))
        minusBtn.Size = UDim2.new(0.38, 0, 0, 38)
        minusBtn.Position = UDim2.new(0.06, 0, 0, 140)

        local plusBtn = crearBoton("➕", 140, Color3.fromRGB(60, 180, 60))
        plusBtn.Size = UDim2.new(0.38, 0, 0, 38)
        plusBtn.Position = UDim2.new(0.5, 0, 0, 140)

        minusBtn.MouseButton1Click:Connect(function()
            currentSpeed = math.max(16, currentSpeed - 10)
            speedLabel.Text = "Velocidad: " .. currentSpeed
        end)

        plusBtn.MouseButton1Click:Connect(function()
            currentSpeed = math.min(500, currentSpeed + 10)
            speedLabel.Text = "Velocidad: " .. currentSpeed
        end)

        -- ======= INVISIBILITY BUTTON =======
        local invisBtn = crearBoton("👻 Invisible: OFF", 195)

        invisBtn.MouseButton1Click:Connect(function()
            invisEnabled = not invisEnabled
            if lp.Character then
                for _, part in pairs(lp.Character:GetDescendants()) do
                    if part:IsA("BasePart") or part:IsA("Decal") then
                        part.Transparency = invisEnabled and 1 or 0
                    end
                end
            end
            if invisEnabled then
                invisBtn.Text = "👻 Invisible: ON"
                invisBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            else
                invisBtn.Text = "👻 Invisible: OFF"
                invisBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
            end
        end)

        -- ======= NOCLIP BUTTON =======
        local noclipEnabled = false
        local noclipBtn = crearBoton("🔮 Noclip: OFF", 250)
        local noclipLoop

        noclipBtn.MouseButton1Click:Connect(function()
            noclipEnabled = not noclipEnabled
            if noclipEnabled then
                noclipBtn.Text = "🔮 Noclip: ON"
                noclipBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                noclipLoop = game:GetService("RunService").Stepped:Connect(function()
                    if lp.Character then
                        for _, part in pairs(lp.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
            else
                noclipBtn.Text = "🔮 Noclip: OFF"
                noclipBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
                if noclipLoop then noclipLoop:Disconnect() end
            end
        end)

        -- Drag para mover la ventana
        local dragging, dragInput, dragStart, startPos
        TitleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = Main.Position
            end
        end)
        TitleBar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)

    else
        KeyStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
        KeyStatus.Text = "❌ Key incorrecta!"
    end
end)