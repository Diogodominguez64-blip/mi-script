-- DZ STORE Script para Roblox Fluxo PvP
-- Creado para proporcionar ventajas competitivas en el juego

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Variables para el script
local AimbotEnabled = false
local SilentAimEnabled = false
local ESPEnabled = false
local LineEnabled = false
local AimPart = "Head"
local AimRadius = 50
local AimSmoothness = 0.2

-- Creación de la interfaz de usuario
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DZ_STORE_GUI"
ScreenGui.Parent = game:GetService("CoreGui") -- Mejor usar CoreGui en exploits
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Función para crear el menú principal
local function createMenu()
    -- Marco principal
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    MainFrame.Size = UDim2.new(0, 400, 0, 300)
    MainFrame.Visible = true
    
    -- Efecto de redondeo
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame
    
    -- Título del menú
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundColor3 = Color3.fromRGB(255, 0, 100)
    Title.BorderSizePixel = 0
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "DZ STORE"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 20
    
    local UICorner2 = Instance.new("UICorner")
    UICorner2.CornerRadius = UDim.new(0, 10)
    UICorner2.Parent = Title
    
    -- Botones de funciones
    local AimbotButton = Instance.new("TextButton")
    AimbotButton.Name = "AimbotButton"
    AimbotButton.Parent = MainFrame
    AimbotButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    AimbotButton.BorderSizePixel = 0
    AimbotButton.Position = UDim2.new(0.05, 0, 0.2, 0)
    AimbotButton.Size = UDim2.new(0.4, 0, 0, 30)
    AimbotButton.Font = Enum.Font.Gotham
    AimbotButton.Text = "Aimbot: OFF"
    AimbotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    AimbotButton.TextSize = 14
    
    local UICorner3 = Instance.new("UICorner")
    UICorner3.CornerRadius = UDim.new(0, 5)
    UICorner3.Parent = AimbotButton
    
    local SilentAimButton = Instance.new("TextButton")
    SilentAimButton.Name = "SilentAimButton"
    SilentAimButton.Parent = MainFrame
    SilentAimButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    SilentAimButton.BorderSizePixel = 0
    SilentAimButton.Position = UDim2.new(0.55, 0, 0.2, 0)
    SilentAimButton.Size = UDim2.new(0.4, 0, 0, 30)
    SilentAimButton.Font = Enum.Font.Gotham
    SilentAimButton.Text = "Silent Aim: OFF"
    SilentAimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SilentAimButton.TextSize = 14
    
    local UICorner4 = Instance.new("UICorner")
    UICorner4.CornerRadius = UDim.new(0, 5)
    UICorner4.Parent = SilentAimButton
    
    local ESPButton = Instance.new("TextButton")
    ESPButton.Name = "ESPButton"
    ESPButton.Parent = MainFrame
    ESPButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    ESPButton.BorderSizePixel = 0
    ESPButton.Position = UDim2.new(0.05, 0, 0.35, 0)
    ESPButton.Size = UDim2.new(0.4, 0, 0, 30)
    ESPButton.Font = Enum.Font.Gotham
    ESPButton.Text = "Skeleton ESP: OFF"
    ESPButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ESPButton.TextSize = 14
    
    local UICorner5 = Instance.new("UICorner")
    UICorner5.CornerRadius = UDim.new(0, 5)
    UICorner5.Parent = ESPButton
    
    local LineButton = Instance.new("TextButton")
    LineButton.Name = "LineButton"
    LineButton.Parent = MainFrame
    LineButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    LineButton.BorderSizePixel = 0
    LineButton.Position = UDim2.new(0.55, 0, 0.35, 0)
    LineButton.Size = UDim2.new(0.4, 0, 0, 30)
    LineButton.Font = Enum.Font.Gotham
    LineButton.Text = "Line ESP: OFF"
    LineButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    LineButton.TextSize = 14
    
    local UICorner6 = Instance.new("UICorner")
    UICorner6.CornerRadius = UDim.new(0, 5)
    UICorner6.Parent = LineButton
    
    -- Control deslizante para el radio de aim
    local RadiusLabel = Instance.new("TextLabel")
    RadiusLabel.Name = "RadiusLabel"
    RadiusLabel.Parent = MainFrame
    RadiusLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    RadiusLabel.BorderSizePixel = 0
    RadiusLabel.Position = UDim2.new(0.05, 0, 0.5, 0)
    RadiusLabel.Size = UDim2.new(0.9, 0, 0, 25)
    RadiusLabel.Font = Enum.Font.Gotham
    RadiusLabel.Text = "Aim Radius: 50"
    RadiusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    RadiusLabel.TextSize = 14
    
    local UICorner7 = Instance.new("UICorner")
    UICorner7.CornerRadius = UDim.new(0, 5)
    UICorner7.Parent = RadiusLabel
    
    local RadiusSlider = Instance.new("TextButton")
    RadiusSlider.Name = "RadiusSlider"
    RadiusSlider.Parent = MainFrame
    RadiusSlider.BackgroundColor3 = Color3.fromRGB(255, 0, 100)
    RadiusSlider.BorderSizePixel = 0
    RadiusSlider.Position = UDim2.new(0.05, 0, 0.65, 0)
    RadiusSlider.Size = UDim2.new(0.9, 0, 0, 10)
    RadiusSlider.AutoButtonColor = false
    RadiusSlider.Font = Enum.Font.SourceSans
    RadiusSlider.Text = ""
    RadiusSlider.TextSize = 0
    
    local UICorner8 = Instance.new("UICorner")
    UICorner8.CornerRadius = UDim.new(0, 5)
    UICorner8.Parent = RadiusSlider
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Name = "SliderButton"
    SliderButton.Parent = RadiusSlider
    SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderButton.BorderSizePixel = 0
    SliderButton.Position = UDim2.new(0.5, -10, 0.5, -10)
    SliderButton.Size = UDim2.new(0, 20, 0, 20)
    SliderButton.AutoButtonColor = false
    SliderButton.Font = Enum.Font.SourceSans
    SliderButton.Text = ""
    SliderButton.TextSize = 0
    
    local UICorner9 = Instance.new("UICorner")
    UICorner9.CornerRadius = UDim.new(0, 10)
    UICorner9.Parent = SliderButton

    -- Círculo visual del campo de visión (FOV)
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1.5
    FOVCircle.Color = Color3.fromRGB(255, 0, 100)
    FOVCircle.Transparency = 0.8
    FOVCircle.Filled = false
    FOVCircle.Visible = false
    FOVCircle.Radius = AimRadius

    -- Lógica de arrastre para el menú principal (Drag)
    local dragging, dragInput, dragStart, startPos
    local function updateInput(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateInput(input)
        end
    end)

    -- Interacciones y lógica de los Toggles del Menú
    AimbotButton.MouseButton1Click:Connect(function()
        AimbotEnabled = not AimbotEnabled
        AimbotButton.Text = AimbotEnabled and "Aimbot: ON" or "Aimbot: OFF"
        AimbotButton.BackgroundColor3 = AimbotEnabled and Color3.fromRGB(255, 0, 100) or Color3.fromRGB(45, 45, 55)
        FOVCircle.Visible = AimbotEnabled or SilentAimEnabled
    end)

    SilentAimButton.MouseButton1Click:Connect(function()
        SilentAimEnabled = not SilentAimEnabled
        SilentAimButton.Text = SilentAimEnabled and "Silent Aim: ON" or "Silent Aim: OFF"
        SilentAimButton.BackgroundColor3 = SilentAimEnabled and Color3.fromRGB(255, 0, 100) or Color3.fromRGB(45, 45, 55)
        FOVCircle.Visible = AimbotEnabled or SilentAimEnabled
    end)

    ESPButton.MouseButton1Click:Connect(function()
        ESPEnabled = not ESPEnabled
        ESPButton.Text = ESPEnabled and "Skeleton ESP: ON" or "Skeleton ESP: OFF"
        ESPButton.BackgroundColor3 = ESPEnabled and Color3.fromRGB(255, 0, 100) or Color3.fromRGB(45, 45, 55)
    end)

    LineButton.MouseButton1Click:Connect(function()
        LineEnabled = not LineEnabled
        LineButton.Text = LineEnabled and "Line ESP: ON" or "Line ESP: OFF"
        LineButton.BackgroundColor3 = LineEnabled and Color3.fromRGB(255, 0, 100) or Color3.fromRGB(45, 45, 55)
    end)

    -- Lógica del Slider de Radio (FOV)
    local isSliding = false
    local function updateSlider()
        local mousePos = UserInputService:GetMouseLocation()
        local relativeX = mousePos.X - RadiusSlider.AbsolutePosition.X
        local percentage = math.clamp(relativeX / RadiusSlider.AbsoluteSize.X, 0, 1)
        SliderButton.Position = UDim2.new(percentage, -10, 0.5, -10)
        AimRadius = math.floor(percentage * 300)
        RadiusLabel.Text = "Aim Radius: " .. tostring(AimRadius)
        FOVCircle.Radius = AimRadius
    end

    SliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider()
        end
    end)

    -- Alternar visibilidad de la interfaz completa con la tecla Insert
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    -- Obtener el jugador más cercano dentro del radio definido (FOV)
    local function getClosestPlayer()
        local target = nil
        local shortestDistance = AimRadius
        local mouseLocation = UserInputService:GetMouseLocation()

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(AimPart) and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                local point, onScreen = Camera:WorldToViewportPoint(player.Character[AimPart].Position)
                if onScreen then
                    local distance = (Vector2.new(point.X, point.Y) - mouseLocation).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        target = player.Character[AimPart]
                    end
                end
            end
        end
        return target
    end

    -- Bucle principal del sistema
    RunService.RenderStepped:Connect(function()
        local mouseLocation = UserInputService:GetMouseLocation()
        FOVCircle.Position = mouseLocation

        if AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local targetPart = getClosestPlayer()
            if targetPart then
                -- Lógica corregida para mover la cámara
                local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, AimSmoothness)
            end
        end
    end)
end

-- Inicialización
createMenu()
