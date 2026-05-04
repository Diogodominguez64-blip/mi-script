--[[
    DZ HUB v15.0 - ULTRA BYPASS EDITION
    SOLUCIÓN DEFINITIVA PARA COMBATE POST-DESPLIEGUE:
    - FIX: Aimbot por Escaneo de Partes Dinámicas (Ignora cambios de nombre).
    - FIX: ESP de Dibujo Directo (Bypassa el contenedor del Lobby).
    - FIX: Independencia Total de hilos (Aimbot corre solo, ESP corre solo).
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- CONFIGURACIÓN DE NÚCLEO
getgenv().DZ_Core = {
    Aimbot_Active = true,
    SilentAim = true,
    ESP_Active = true,
    FOV_Size = 250,
    TeamCheck = true,
    Smoothness = 0.12 -- Suavizado para evitar detecciones[cite: 5]
}

-- 1. FOV DINÁMICO (Anclado al Viewport real)[cite: 5]
local FOV = Drawing.new("Circle")
FOV.Thickness = 2
FOV.Color = Color3.fromRGB(0, 255, 255)
FOV.Visible = true

-- 2. EL BYPASS MAESTRO: BUSCADOR DE OBJETIVOS EN TIEMPO REAL[cite: 5]
local function GetCombatTarget()
    local Closest, MinDist = nil, getgenv().DZ_Core.FOV_Size
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- Escaneo recursivo de TODOS los modelos con Humanoid en Workspace[cite: 5]
    for _, model in pairs(workspace:GetDescendants()) do
        if model:IsA("Humanoid") and model.Health > 0 and model.Parent:IsA("Model") then
            local char = model.Parent
            local p = Players:GetPlayerFromCharacter(char)
            
            -- Validar que sea un enemigo vivo y no sea el local
            if char ~= LocalPlayer.Character and (not p or not getgenv().DZ_Core.TeamCheck or p.Team ~= LocalPlayer.Team) then
                -- Bypass de nombre: Buscamos la parte más alta o la raíz[cite: 5]
                local targetPart = char:FindFirstChild("Head") or char:FindFirstChildWhichIsA("BasePart")
                
                if targetPart then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - Center).Magnitude
                        if dist < MinDist then
                            MinDist = dist
                            Closest = targetPart
                        end
                    end
                end
            end
        end
    end
    return Closest
end

-- 3. ESP DE DIBUJO DIRECTO (Totalmente independiente)[cite: 5]
local function CreateCombatESP(p)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Thickness = 1
    Box.Color = Color3.fromRGB(255, 0, 0)

    RunService.RenderStepped:Connect(function()
        if p.Character and p.Character:FindFirstChildOfClass("Humanoid") and getgenv().DZ_Core.ESP_Active then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChildWhichIsA("BasePart")
            
            if hum.Health > 0 and hrp and (not getgenv().DZ_Core.TeamCheck or p.Team ~= LocalPlayer.Team) then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local sizeY = (Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.6, 0)).Y)
                    Box.Visible = true
                    Box.Size = Vector2.new(sizeY * 0.7, sizeY)
                    Box.Position = Vector2.new(pos.X - Box.Size.X / 2, pos.Y - Box.Size.Y / 2)
                    return
                end
            end
        end
        Box.Visible = false
    end)
end

-- Inyectar ESP en jugadores actuales y nuevos[cite: 5]
for _, player in pairs(Players:GetPlayers()) do if player ~= LocalPlayer then CreateCombatESP(player) end end
Players.PlayerAdded:Connect(CreateCombatESP)

-- 4. CONTROLADORES DE AIMBOT (Hilo de Ejecución Independiente)[cite: 2, 5]
RunService.RenderStepped:Connect(function()
    -- Actualizar FOV
    FOV.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOV.Radius = getgenv().DZ_Core.FOV_Size

    -- Aimbot de Seguimiento (Click Derecho)[cite: 5]
    if getgenv().DZ_Core.Aimbot_Active and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetCombatTarget()
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), getgenv().DZ_Core.Smoothness)
        end
    end
end)

-- SILENT AIM (Metamethod Hook)[cite: 2]
local OldHook
OldHook = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() and getgenv().DZ_Core.SilentAim and key == "Hit" and self:IsA("Mouse") then
        local target = GetCombatTarget()
        if target then return target.CFrame end
    end
    return OldHook(self, key)
end)

-- 5. INTERFAZ DE USUARIO (Rayfield)[cite: 1]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "DZ HUB v15.0 | ULTRA BYPASS", LoadingTitle = "Bypassing FPS Lanzamiento..."})
local Main = Window:CreateTab("Combate")
Main:CreateToggle({Name = "Aimbot + Silent Aim", CurrentValue = true, Callback = function(v) getgenv().DZ_Core.Aimbot_Active = v; getgenv().DZ_Core.SilentAim = v end})
Main:CreateSlider({Name = "Radio FOV", Range = {50, 800}, CurrentValue = 250, Callback = function(v) getgenv().DZ_Core.FOV_Size = v end})
Main:CreateToggle({Name = "Activar ESP", CurrentValue = true, Callback = function(v) getgenv().DZ_Core.ESP_Active = v end})

Rayfield:Notify({Title = "BYPASS EXITOSO", Content = "Método de escaneo recursivo activado. Funcional en combate.", Duration = 5})