--[[
    DZ HUB v25.0 - ESTRUCTURA DE CARGA INDEPENDIENTE
    - STAGE 1: Custom Loader UI (Independiente de Rayfield).
    - STAGE 2: Rifle Engine (Aimbot, ESP, Auto-Shoot, Bypasses).
    - COLOR PALETTE: Dark Purple & Cyan.
]]

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- 1. DATOS DE ACCESO
local SECRET_KEY = "DZ-MASTER-2026"
local DISCORD = "https://discord.gg/dz-hub-master"

-- 2. INTERFAZ DEL LOADER (Totalmente independiente)
local LoaderUI = Instance.new("ScreenGui", CoreGui)
LoaderUI.Name = "DZ_MasterLoader"

local Main = Instance.new("Frame", LoaderUI)
Main.Size = UDim2.new(0, 320, 0, 200)
Main.Position = UDim2.new(0.5, -160, 0.5, -100)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = BoxBlur -- Estilo suavizado

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(150, 0, 255)
Stroke.Thickness = 2

local Title = Instance.new("TextLabel", Main)
Title.Text = "DZ HUB | MASTER ACCESS"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20

local KeyInput = Instance.new("TextBox", Main)
KeyInput.Size = UDim2.new(0.8, 0, 0, 40)
KeyInput.Position = UDim2.new(0.1, 0, 0.35, 0)
KeyInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
KeyInput.TextColor3 = Color3.fromRGB(0, 255, 255)
KeyInput.PlaceholderText = "Paste your key here..."
KeyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
KeyInput.Text = ""
KeyInput.Font = Enum.Font.Gotham
KeyInput.TextSize = 14
Instance.new("UICorner", KeyInput)

local ExecuteBtn = Instance.new("TextButton", Main)
ExecuteBtn.Size = UDim2.new(0.8, 0, 0, 40)
ExecuteBtn.Position = UDim2.new(0.1, 0, 0.65, 0)
ExecuteBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
ExecuteBtn.Text = "ACTIVATE ENGINE"
ExecuteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ExecuteBtn.Font = Enum.Font.GothamBold
ExecuteBtn.TextSize = 14
Instance.new("UICorner", ExecuteBtn)

-- 3. MOTOR DE RIFLES Y BYPASSES (STAGE 2)
local function InjectRifleEngine()
    LoaderUI:Destroy() -- Eliminamos el loader para liberar memoria
    
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local Window = Rayfield:CreateWindow({Name = "DZ RIFLE v25 | DEFINITIVE BYPASS", LoadingTitle = "Inyectando Código Maestro..."})
    
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

    -- FOV VISUAL
    local FOV_Circle = Drawing.new("Circle")
    FOV_Circle.Thickness = 2
    FOV_Circle.Color = Color3.fromRGB(0, 255, 255)
    FOV_Circle.Transparency = 1

    -- BYPASS DE ESCANEO DE ENTIDADES
    local function GetTarget()
        local Target, MinDist = nil, getgenv().DZ_Master.FOV
        local Center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and (not getgenv().DZ_Master.TeamCheck or p.Team ~= LocalPlayer.Team) then
                local char = p.Character
                if char and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health > 0 then
                    local part = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
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

    -- ESP BYPASS (Cajas)
    local function CreateESP(p)
        local Box = Drawing.new("Square")
        Box.Visible = false
        Box.Color = Color3.fromRGB(150, 0, 255)
        Box.Thickness = 1.5

        RunService.RenderStepped:Connect(function()
            if p.Character and getgenv().DZ_Master.ESP then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local root = p.Character:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and root then
                    local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        local sizeY = (Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.5, 0)).Y - Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 2.5, 0)).Y)
                        Box.Visible = true
                        Box.Size = Vector2.new(sizeY * 0.7, sizeY)
                        Box.Position = Vector2.new(pos.X - Box.Size.X/2, pos.Y - Box.Size.Y/2)
                        return
                    end
                end
            end
            Box.Visible = false
        end)
    end

    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end
    Players.PlayerAdded:Connect(CreateESP)

    -- ACCIÓN: AIMBOT + AUTO-SHOOT
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

    -- UI DE RAYFIELD (Post-Key)
    local MainTab = Window:CreateTab("Combate")
    MainTab:CreateToggle({Name = "Aimbot + Silent", CurrentValue = true, Callback = function(v) getgenv().DZ_Master.Aimbot = v end})
    MainTab:CreateToggle({Name = "ESP Bypass", CurrentValue = true, Callback = function(v) getgenv().DZ_Master.ESP = v end})
    MainTab:CreateToggle({Name = "Auto-Shoot (Perpetuo)", CurrentValue = false, Callback = function(v) getgenv().DZ_Master.AutoShoot = v end})
    MainTab:CreateSlider({Name = "Radio FOV", Range = {50, 800}, CurrentValue = 250, Callback = function(v) getgenv().DZ_Master.FOV = v end})
end

-- 4. LÓGICA DEL LOADER
ExecuteBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text == SECRET_KEY then
        ExecuteBtn.Text = "KEY VALIDATED!"
        ExecuteBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        task.wait(1)
        InjectRifleEngine()
    else
        ExecuteBtn.Text = "INVALID KEY"
        ExecuteBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        task.wait(1.5)
        ExecuteBtn.Text = "ACTIVATE ENGINE"
        ExecuteBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
    end
end)