--[[
    DZ HUB v17.0 - FIX DE AIMBOT EN VIVO
    - CORRECCIÓN: El Aimbot ahora detecta entidades activas, no solo muertas[cite: 5].
    - BYPASS: Validación de visibilidad mediante Raycast para evitar muros[cite: 2].
    - SEGURIDAD: No interfiere con el sistema de ESP existente.
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Configuración de Combate Real
getgenv().DZ_Live = {
    Aimbot_Active = true,
    Silent_Active = true,
    FOV_Size = 250,
    Smoothness = 0.1, -- Valor ideal para seguimiento fluido[cite: 5]
    WallCheck = true, -- Evita apuntar a través de paredes[cite: 2]
    TeamCheck = true
}

-- 1. FOV CIRCLE (Actualizado dinámicamente)[cite: 5]
local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Thickness = 1.5
FOV_Circle.Color = Color3.fromRGB(0, 255, 0) -- Verde para indicar 'Live Ready'
FOV_Circle.Transparency = 1

-- 2. MOTOR DE SELECCIÓN EN VIVO (El Fix Definitivo)[cite: 5]
local function GetLiveTarget()
    local BestTarget, MaxDist = nil, getgenv().DZ_Live.FOV_Size
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            -- Buscamos el Humanoid para asegurar que esté VIVO[cite: 5]
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local part = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")

            if hum and hum.Health > 0 and part then
                if not getgenv().DZ_Live.TeamCheck or p.Team ~= LocalPlayer.Team then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - Center).Magnitude
                        
                        -- FIX: Verificación de visibilidad (Wallcheck)[cite: 2]
                        local visible = true
                        if getgenv().DZ_Live.WallCheck then
                            local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 500)
                            local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, p.Character})
                            if hit then visible = false end
                        end

                        if dist < MaxDist and visible then
                            MaxDist = dist
                            BestTarget = part
                        end
                    end
                end
            end
        end
    end
    return BestTarget
end

-- 3. INTERFAZ Y BUCLE DE SEGUIMIENTO (Aimbot Independiente)[cite: 1, 5]
RunService.RenderStepped:Connect(function()
    -- Mantener FOV centrado
    FOV_Circle.Visible = true
    FOV_Circle.Radius = getgenv().DZ_Live.FOV_Size
    FOV_Circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- Ejecución de Aimbot (Click Derecho)[cite: 5]
    if getgenv().DZ_Live.Aimbot_Active and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetLiveTarget()
        if target then
            -- Suavizado dinámico para el combate en vivo[cite: 5]
            local targetPos = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetPos, getgenv().DZ_Live.Smoothness)
        end
    end
end)

-- 4. SILENT AIM (Metamethod Hook)[cite: 2]
local OldMT
OldMT = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() and getgenv().DZ_Live.Silent_Active and key == "Hit" and self:IsA("Mouse") then
        local liveTarget = GetLiveTarget()
        if liveTarget then
            return liveTarget.CFrame -- Redirección de balas al objetivo vivo[cite: 2]
        end
    end
    return OldMT(self, key)
end)

-- 5. MENÚ DE CONTROL (Rayfield)[cite: 1]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "DZ HUB v17.0 | LIVE AIMFIX", LoadingTitle = "Sincronizando Aimbot con Enemigos Vivos..."})
local Combat = Window:CreateTab("Combate")

Combat:CreateToggle({Name = "Aimbot en Vivo", CurrentValue = true, Callback = function(v) getgenv().DZ_Live.Aimbot_Active = v end})
Combat:CreateToggle({Name = "Silent Aim (Bullet Fix)", CurrentValue = true, Callback = function(v) getgenv().DZ_Live.Silent_Active = v end})
Combat:CreateSlider({Name = "Radio FOV", Range = {50, 800}, CurrentValue = 250, Callback = function(v) getgenv().DZ_Live.FOV_Size = v end})
Combat:CreateSlider({Name = "Suavizado (Smooth)", Range = {1, 100}, CurrentValue = 10, Callback = function(v) getgenv().DZ_Live.Smoothness = v/100 end})

Rayfield:Notify({Title = "FIX APLICADO", Content = "El Aimbot ahora rastrea objetivos vivos. ESP intacto.", Duration = 5})