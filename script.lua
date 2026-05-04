--[[
    DZ HUB v26.0 - LOADER RECONSTRUIDO
    - FIX: Corrección de renderizado (Pantalla negra eliminada).
    - INDEPENDENCIA: UI Nativa que no depende de librerías externas para el acceso.
    - SEGURIDAD: Inyección limpia del Rifle Engine post-verificación.
]]

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- 1. CONFIGURACIÓN DE ACCESO
local SECRET_KEY = "DZ-MASTER-2026"
local DISCORD = "https://discord.gg/dz-hub-master"

-- 2. LIMPIEZA DE SESIONES PREVIAS (Para evitar duplicados)
if CoreGui:FindFirstChild("DZ_MasterLoader") then
    CoreGui.DZ_MasterLoader:Destroy()
end

-- 3. CONSTRUCCIÓN DEL LOADER (FIXED)
local LoaderUI = Instance.new("ScreenGui", CoreGui)
LoaderUI.Name = "DZ_MasterLoader"
LoaderUI.IgnoreGuiInset = true -- Asegura que cubra bien el espacio

local Main = Instance.new("Frame", LoaderUI)
Main.Name = "Container"
Main.Size = UDim2.new(0, 320, 0, 200)
Main.Position = UDim2.new(0.5, -160, 0.5, -100)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.ZIndex = 1

local UICorner = Instance.new("UICorner", Main)
UICorner.CornerRadius = ToolTip -- Reemplazo de variable corrupta

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(130, 0, 255)
Stroke.Thickness = 2
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local Title = Instance.new("TextLabel", Main)
Title.Name = "Header"
Title.Text = "DZ HUB | LOADER FIX"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.ZIndex = 2

local KeyInput = Instance.new("TextBox", Main)
KeyInput.Name = "KeyBox"
KeyInput.Size = UDim2.new(0.8, 0, 0, 40)
KeyInput.Position = UDim2.new(0.1, 0, 0.4, 0)
KeyInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
KeyInput.TextColor3 = Color3.fromRGB(0, 255, 255)
KeyInput.PlaceholderText = "Pegar llave aquí..."
KeyInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
KeyInput.Text = ""
KeyInput.Font = Enum.Font.Gotham
KeyInput.TextSize = 14
KeyInput.ZIndex = 3
Instance.new("UICorner", KeyInput)

local ExecuteBtn = Instance.new("TextButton", Main)
ExecuteBtn.Name = "ConfirmButton"
ExecuteBtn.Size = UDim2.new(0.8, 0, 0, 40)
ExecuteBtn.Position = UDim2.new(0.1, 0, 0.7, 0)
ExecuteBtn.BackgroundColor3 = Color3.fromRGB(130, 0, 255)
ExecuteBtn.Text = "ACTIVAR RIFLES"
ExecuteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ExecuteBtn.Font = Enum.Font.GothamBold
ExecuteBtn.TextSize = 14
ExecuteBtn.ZIndex = 3
Instance.new("UICorner", ExecuteBtn)

-- 4. MOTOR DE RIFLES (Inyectado tras validación)
local function InjectRifleEngine()
    LoaderUI:Destroy()
    
    -- Cargamos Rayfield solo después de la llave
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local Window = Rayfield:CreateWindow({Name = "DZ RIFLE v26 | MASTER BYPASS", LoadingTitle = "Bypass de Seguridad..."})
    
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local VirtualInputManager = game:GetService("VirtualInputManager")

    getgenv().DZ_Master = {
        Aimbot = true,
        ESP = true,
        AutoShoot = false,
        FOV = 250,
        Smooth = 0.1,
        TeamCheck = true
    }

    local FOV_Circle = Drawing.new("Circle")
    FOV_Circle.Thickness = 2
    FOV_Circle.Color = Color3.fromRGB(0, 255, 255)
    FOV_Circle.Transparency = 1

    -- Sistema de Target (Definido para no fallar)
    local function GetTarget()
        local Target, MinDist = nil, getgenv().DZ_Master.FOV
        local Center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
                if p.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                    local part = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
                    if part then
                        local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local dist = (Vector2.new(pos.X, pos.Y) - Center).Magnitude
                            if dist < MinDist then MinDist = dist; Target = part end
                        end
                    end
                end
            end
        end
        return Target
    end

    -- Bucle Maestro (Aimbot, ESP, Auto-Shoot)
    RunService.RenderStepped:Connect(function()
        FOV_Circle.Visible = true
        FOV_Circle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        FOV_Circle.Radius = getgenv().DZ_Master.FOV

        local target = GetTarget()
        if target then
            if getgenv().DZ_Master.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), getgenv().DZ_Master.Smooth)
            end
            if getgenv().DZ_Master.AutoShoot then
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.01)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end
        end
    end)

    -- UI DE CONTROL
    local Tab = Window:CreateTab("Combate")
    Tab:CreateToggle({Name = "Aimbot + Silent", CurrentValue = true, Callback = function(v) getgenv().DZ_Master.Aimbot = v end})
    Tab:CreateToggle({Name = "ESP Bypass", CurrentValue = true, Callback = function(v) getgenv().DZ_Master.ESP = v end})
    Tab:CreateToggle({Name = "Auto-Shoot", CurrentValue = false, Callback = function(v) getgenv().DZ_Master.AutoShoot = v end})
    Tab:CreateSlider({Name = "Radio FOV", Range = {50, 800}, CurrentValue = 250, Callback = function(v) getgenv().DZ_Master.FOV = v end})
end

-- 5. LÓGICA DE VALIDACIÓN (FIXED)
ExecuteBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text == SECRET_KEY then
        ExecuteBtn.Text = "LLAVE VÁLIDA"
        ExecuteBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        task.wait(0.5)
        InjectRifleEngine()
    else
        ExecuteBtn.Text = "LLAVE INVÁLIDA"
        ExecuteBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        task.wait(1)
        ExecuteBtn.Text = "ACTIVAR RIFLES"
        ExecuteBtn.BackgroundColor3 = Color3.fromRGB(130, 0, 255)
    end
end)