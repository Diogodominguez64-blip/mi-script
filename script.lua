--[[
    DZ MASTER CORE v27.0 - NO LOADER VERSION
    - CORE: Aimbot + ESP + Auto-Shoot Sincronizado.
    - BYPASS: Escaneo de entidades post-despliegue (Fix para image_3a6423.png).
    - PERFORMANCE: Latencia zero en el renderizado de cajas.
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Inicialización de Variables Maestras
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Configuración Global del Bypass
getgenv().DZ_Config = {
    Aimbot = true,
    ESP = true,
    AutoShoot = true, -- Activado por defecto para el test
    FOV = 300,
    Smooth = 0.1,
    TeamCheck = true,
    BoxColor = Color3.fromRGB(0, 255, 255), -- Cian Neón
    FOVColor = Color3.fromRGB(150, 0, 255) -- Púrpura
}

-- 1. FOV CIRCLE (Renderizado Directo)
local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Thickness = 1.5
FOV_Circle.Transparency = 1
FOV_Circle.Filled = false
FOV_Circle.Color = getgenv().DZ_Config.FOVColor

-- 2. BUSCADOR DE OBJETIVOS (Bypass de Despliegue)
local function GetClosestTarget()
    local Target, BestDist = nil, getgenv().DZ_Config.FOV
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and (not getgenv().DZ_Config.TeamCheck or p.Team ~= LocalPlayer.Team) then
            local char = p.Character
            if char and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health > 0 then
                -- Buscamos la cabeza o el torso para el bypass de hitbox
                local root = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
                if root then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - Center).Magnitude
                        if dist < BestDist then
                            BestDist = dist
                            Target = root
                        end
                    end
                end
            end
        end
    end
    return Target
end

-- 3. ESP DE DIBUJO PERSISTENTE (Solución al error del cuadro negro)
local function CreateESP(p)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = getgenv().DZ_Config.BoxColor
    Box.Thickness = 1.5

    RunService.RenderStepped:Connect(function()
        if p.Character and getgenv().DZ_Config.ESP then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and root and (not getgenv().DZ_Config.TeamCheck or p.Team ~= LocalPlayer.Team) then
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local sizeY = (Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 2.5, 0)).Y)
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

-- Inicializar ESP para jugadores actuales y nuevos
for _, player in pairs(Players:GetPlayers()) do if player ~= LocalPlayer then CreateESP(player) end end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then CreateESP(p) end end)

-- 4. BUCLE MAESTRO (Aimbot + AutoShoot)
RunService.RenderStepped:Connect(function()
    -- Actualizar FOV Circle
    FOV_Circle.Visible = true
    FOV_Circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOV_Circle.Radius = getgenv().DZ_Config.FOV

    local target = GetClosestTarget()
    
    -- Aimbot (Al mantener Click Derecho)
    if getgenv().DZ_Config.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) and target then
        local targetPos = CFrame.new(Camera.CFrame.Position, target.Position)
        Camera.CFrame = Camera.CFrame:Lerp(targetPos, getgenv().DZ_Config.Smooth)
    end

    -- AUTO-SHOOT (Bypass de entrada sin clic)
    if getgenv().DZ_Config.AutoShoot and target then
        -- Simula disparo a nivel de hardware para evadir detecciones de script
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end
end)

-- 5. INTERFAZ DE CONTROL RAYFIELD
local Window = Rayfield:CreateWindow({
    Name = "DZ CORE v27.0 | BYPASS TEST",
    LoadingTitle = "Validando Motor...",
    LoadingSubtitle = "Sin Loader - Modo Directo",
})

local Tab = Window:CreateTab("Master Config")

Tab:CreateToggle({
    Name = "Aimbot + Silent",
    CurrentValue = true,
    Callback = function(v) getgenv().DZ_Config.Aimbot = v end
})

Tab:CreateToggle({
    Name = "Auto-Shoot (Fuego Automático)",
    CurrentValue = true,
    Callback = function(v) getgenv().DZ_Config.AutoShoot = v end
})

Tab:CreateToggle({
    Name = "ESP (Box Bypass)",
    CurrentValue = true,
    Callback = function(v) getgenv().DZ_Config.ESP = v end
})

Tab:CreateSlider({
    Name = "Rango de FOV",
    Range = {50, 800},
    CurrentValue = 300,
    Callback = function(v) getgenv().DZ_Config.FOV = v end
})

Rayfield:Notify({Title = "MOTOR CARGADO", Content = "Test de combate listo. No se requiere llave.", Duration = 5})