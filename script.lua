--[[
    DZ HUB v18.0 - RECONSTRUCCIÓN DE EMERGENCIA
    - RESTAURADO: ESP Bypass de Despliegue (Funciona en combate).
    - FIX: Aimbot para enemigos vivos (Sincronizado con el ESP).
    - PERFORMANCE: Optimización de hilos para evitar lag al usar ambos.
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Configuración Unificada
getgenv().DZ_Master = {
    Aimbot_Active = true,
    Silent_Active = true,
    ESP_Active = true,
    FOV_Size = 250,
    Smoothness = 0.12,
    TeamCheck = true
}

-- 1. FOV RECONSTRUIDO (Centrado Exacto)
local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Thickness = 1.5
FOV_Circle.Color = Color3.fromRGB(255, 0, 255)
FOV_Circle.Transparency = 1

-- 2. EL MOTOR DE BÚSQUEDA UNIVERSAL (Bypass de Deploy)
-- Este motor alimenta TANTO al ESP como al Aimbot para que nunca fallen
local function GetTargetData()
    local Target, BestDist = nil, getgenv().DZ_Master.FOV_Size
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and (not getgenv().DZ_Master.TeamCheck or p.Team ~= LocalPlayer.Team) then
            local char = p.Character
            -- Buscamos cualquier parte del cuerpo si el modelo está vivo
            if char and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health > 0 then
                local part = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart")
                
                if part then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - Center).Magnitude
                        if dist < BestDist then
                            BestDist = dist
                            Target = part
                        end
                    end
                end
            end
        end
    end
    return Target
end

-- 3. ESP BYPASS RESTAURADO (Dibujo 2D Directo)
local function CreatePersistentESP(Player)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(255, 0, 0)
    Box.Thickness = 1.5

    local Connection
    Connection = RunService.RenderStepped:Connect(function()
        if Player.Character and getgenv().DZ_Master.ESP_Active then
            local hum = Player.Character:FindFirstChildOfClass("Humanoid")
            local root = Player.Character:FindFirstChild("HumanoidRootPart") or Player.Character:FindFirstChildWhichIsA("BasePart")

            if hum and hum.Health > 0 and root and (not getgenv().DZ_Master.TeamCheck or Player.Team ~= LocalPlayer.Team) then
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    -- Cálculo de caja persistente post-deploy
                    local sizeY = (Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.5, 0)).Y - Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0)).Y)
                    Box.Visible = true
                    Box.Size = Vector2.new(sizeY * 0.7, sizeY)
                    Box.Position = Vector2.new(pos.X - Box.Size.X/2, pos.Y - Box.Size.Y/2)
                else
                    Box.Visible = false
                end
            else
                Box.Visible = false
            end
        else
            Box.Visible = false
            if not Player.Parent then Box:Remove(); Connection:Disconnect() end
        end
    end)
end

-- Iniciar ESP para todos (incluyendo los que entren después)
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreatePersistentESP(p) end end
Players.PlayerAdded:Connect(CreatePersistentESP)

-- 4. BUCLE DE AIMBOT SINCRONIZADO
RunService.RenderStepped:Connect(function()
    FOV_Circle.Visible = true
    FOV_Circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOV_Circle.Radius = getgenv().DZ_Master.FOV_Size

    if getgenv().DZ_Master.Aimbot_Active and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetTargetData() -- Usa la misma lógica de bypass que el ESP
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), getgenv().DZ_Master.Smoothness)
        end
    end
end)

-- 5. SILENT AIM (Hook)
local OldMT
OldMT = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() and getgenv().DZ_Master.Silent_Active and key == "Hit" and self:IsA("Mouse") then
        local target = GetTargetData()
        if target then return target.CFrame end
    end
    return OldMT(self, key)
end)

-- 6. MENÚ RAYFIELD
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "DZ HUB v18.0 | FIX TOTAL", LoadingTitle = "Restaurando Bypass de ESP..."})
local Main = Window:CreateTab("Master")

Main:CreateToggle({Name = "Aimbot + Silent", CurrentValue = true, Callback = function(v) getgenv().DZ_Master.Aimbot_Active = v; getgenv().DZ_Master.Silent_Active = v end})
Main:CreateToggle({Name = "ESP Bypass (Cajas)", CurrentValue = true, Callback = function(v) getgenv().DZ_Master.ESP_Active = v end})
Main:CreateSlider({Name = "FOV Bypass", Range = {50, 800}, CurrentValue = 250, Callback = function(v) getgenv().DZ_Master.FOV_Size = v end})

Rayfield:Notify({Title = "SISTEMAS RESTAURADOS", Content = "ESP y Aimbot ahora funcionan en vivo.", Duration = 5})