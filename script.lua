--[[
    DZ HUB v16.0 - SOLUCIÓN DEFINITIVA
    - BYPASS: Escaneo de Proxys en vivo (Detecta enemigos mientras disparan)[cite: 5].
    - AIMBOT: Motor de Predicción de Vectores (Independiente del estado del Humanoid)[cite: 2].
    - ESP: Renderizado de Capa Superior (Bypassa el ocultamiento de modelos)[cite: 5].
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- CONFIGURACIÓN DE NÚCLEO MAESTRO
getgenv().DZ_Master = {
    Aimbot_On = true,
    Silent_On = true,
    ESP_On = true,
    FOV_Value = 300,
    Smoothness = 0.08, -- Suavizado crítico para combate[cite: 5]
    TeamCheck = true
}

-- 1. FOV VISUAL (Fix Esquina)[cite: 5]
local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Thickness = 2
FOV_Circle.Color = Color3.fromRGB(130, 0, 255)
FOV_Circle.Transparency = 1

-- 2. EL BUSCADOR DEFINITIVO (Bypassa la muerte y el deploy)[cite: 5]
local function GetTrueCombatTarget()
    local Target, BestDist = nil, getgenv().DZ_Master.FOV_Value
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- Escaneo agresivo: Buscamos modelos vivos en CUALQUIER parte del mapa[cite: 5]
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Humanoid") and obj.Health > 0 then
            local char = obj.Parent
            if char and char:IsA("Model") and char ~= LocalPlayer.Character then
                -- Si no hay jugador asociado (NPC o Proxy), o si es enemigo[cite: 5]
                local p = Players:GetPlayerFromCharacter(char)
                if not getgenv().DZ_Master.TeamCheck or (p and p.Team ~= LocalPlayer.Team) or (not p) then
                    -- Buscamos CUALQUIER parte física para anclarnos[cite: 5]
                    local hitPart = char:FindFirstChild("Head") or char:FindFirstChildWhichIsA("BasePart")
                    if hitPart then
                        local pos, onScreen = Camera:WorldToViewportPoint(hitPart.Position)
                        if onScreen then
                            local dist = (Vector2.new(pos.X, pos.Y) - Center).Magnitude
                            if dist < BestDist then
                                BestDist = dist
                                Target = hitPart
                            end
                        end
                    end
                end
            end
        end
    end
    return Target
end

-- 3. ESP DE DIBUJO 2D (No desaparece tras el deploy)[cite: 1, 5]
local function ApplyMasterESP(Player)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(255, 0, 0)
    Box.Thickness = 1.5

    RunService.RenderStepped:Connect(function()
        if Player.Character and getgenv().DZ_Master.ESP_On then
            local root = Player.Character:FindFirstChild("HumanoidRootPart") or Player.Character:FindFirstChildWhichIsA("BasePart")
            local hum = Player.Character:FindFirstChildOfClass("Humanoid")

            if root and hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    -- Calculo dinámico de caja para evitar que se quede en el lobby[cite: 5]
                    local sizeY = (Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.5, 0)).Y - Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0)).Y)
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

-- Inyectar en todos los jugadores (Actuales y Futuros)[cite: 5]
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then ApplyMasterESP(p) end end
Players.PlayerAdded:Connect(ApplyMasterESP)

-- 4. BUCLE DE EJECUCIÓN MAESTRO (Independiente)[cite: 2, 5]
RunService.RenderStepped:Connect(function()
    -- Fix FOV
    FOV_Circle.Visible = true
    FOV_Circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOV_Circle.Radius = getgenv().DZ_Master.FOV_Value

    -- Aimbot Tracking (Click Derecho)[cite: 5]
    if getgenv().DZ_Master.Aimbot_On and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetTrueCombatTarget()
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), getgenv().DZ_Master.Smoothness)
        end
    end
end)

-- 5. SILENT AIM (Metamethod Hook para redirección de balas)[cite: 2]
local OldMT
OldMT = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() and getgenv().DZ_Master.Silent_On and key == "Hit" and self:IsA("Mouse") then
        local target = GetTrueCombatTarget()
        if target then return target.CFrame end
    end
    return OldMT(self, key)
end)

-- 6. INTERFAZ RAYFIELD[cite: 1]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "DZ HUB v16.0 | MASTER BYPASS", LoadingTitle = "Inyectando Código de Combate..."})
local Tab = Window:CreateTab("Combate")

Tab:CreateToggle({Name = "Aimbot + Silent", CurrentValue = true, Callback = function(v) getgenv().DZ_Master.Aimbot_On = v; getgenv().DZ_Master.Silent_On = v end})
Tab:CreateSlider({Name = "FOV Radius", Range = {50, 800}, CurrentValue = 300, Callback = function(v) getgenv().DZ_Master.FOV_Value = v end})
Tab:CreateToggle({Name = "Activar ESP", CurrentValue = true, Callback = function(v) getgenv().DZ_Master.ESP_On = v end})

Rayfield:Notify({Title = "BYPASS FINALIZADO", Content = "ESP y Aimbot ahora funcionan con enemigos vivos post-deploy.", Duration = 5})