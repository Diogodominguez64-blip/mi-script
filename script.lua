-- Script con Sistema de Key
-- Key requerida: Diogo1234

local KEY_CORRECTA = "Diogo1234"

-- Interfaz de verificación de key
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local KeyBox = Instance.new("TextBox")
local VerifyBtn = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")

ScreenGui.Name = "KeySystem"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

Frame.Size = UDim2.new(0, 350, 0, 200)
Frame.Position = UDim2.new(0.5, -175, 0.5, -100)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = Frame

Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🔑 Sistema de Key"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

KeyBox.Size = UDim2.new(0.85, 0, 0, 40)
KeyBox.Position = UDim2.new(0.075, 0, 0, 65)
KeyBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.PlaceholderText = "Ingresa tu key aquí..."
KeyBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
KeyBox.Text = ""
KeyBox.TextScaled = true
KeyBox.Font = Enum.Font.Gotham
KeyBox.BorderSizePixel = 0
KeyBox.Parent = Frame

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 6)
KeyCorner.Parent = KeyBox

VerifyBtn.Size = UDim2.new(0.85, 0, 0, 40)
VerifyBtn.Position = UDim2.new(0.075, 0, 0, 115)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.Text = "Verificar Key"
VerifyBtn.TextScaled = true
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.BorderSizePixel = 0
VerifyBtn.Parent = Frame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = VerifyBtn

StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 0, 162)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = ""
StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
StatusLabel.TextScaled = true
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = Frame

-- Lógica de verificación
VerifyBtn.MouseButton1Click:Connect(function()
    local inputKey = KeyBox.Text

    if inputKey == KEY_CORRECTA then
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        StatusLabel.Text = "✅ Key correcta. Cargando..."
        task.wait(1.5)
        ScreenGui:Destroy()

        -- =============================================
        -- TU SCRIPT PRINCIPAL VA AQUÍ ABAJO
        -- =============================================

        print("✅ Script cargado correctamente para: " .. game.Players.LocalPlayer.Name)

        -- Ejemplo: notificación en pantalla
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Script Activado",
            Text = "¡Bienvenido! Script cargado con éxito.",
            Duration = 5
        })

        -- Aquí puedes añadir el resto de funciones de tu script...

    else
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        StatusLabel.Text = "❌ Key incorrecta. Intenta de nuevo."
    end
end)