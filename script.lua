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
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = AimRadius
FOVCircle.Color = Color3.new(0, 1, 1)
FOVCircle.Thickness = 1
FOVCircle.Filled = false

-- Tablas para almacenar elementos de ESP
local ESPObjects = {}
local LineObjects = {}

-- Creación de la interfaz de usuario
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DZ_STORE_GUI"
ScreenGui.Parent = game.CoreGui
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
    MainFrame.Visible = false
    
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
    RadiusSlider.Position = UDim2.new(0.05, 0, 0.6, 0)
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
    SliderButton.Size = UDim2.new(0, 20, 0, 
