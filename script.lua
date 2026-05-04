--[[
    DZ MASTER CORE v28.0 - ANTI-267 BYPASS
    - FIX: Eliminado VirtualInputManager (Detectado en Error 267).
    - NEW: Humanized Click Simulation & Variable Delays.
    - CORE: Aimbot, ESP, y Auto-Shoot Indetectable.
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Servicios de Bajo Perfil
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

getgenv().DZ_Config = {
    Aimbot = true,
    ESP = true,
    AutoShoot = true,
    FOV = 200, -- Reducido un poco para mayor seguridad
    Smooth = 0.15, -- Más suave para evitar "snapping" detectado por mods
    TeamCheck = true
}

-- 1. FOV CIRCLE (Bypass Visual)
local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Thickness = 1
FOV_Circle.Transparency = 0.8
FOV_Circle.Color = Color3.fromRGB(150, 0, 255)

-- 2. BUSCADOR DE OBJETIVOS (Optimizado)
local function GetSafeTarget()
    local Target, BestDist = nil, getgenv().DZ_Config.FOV
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and (not getgenv().DZ_Config.TeamCheck or p.Team ~= LocalPlayer.Team) then
            local char = p.Character
            if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local head = char:FindFirstChild("Head")
                if head then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - Center).Magnitude
                        if dist < BestDist then
                            BestDist = dist
                            Target = head
                        end
                    end
                end
            end
        end
    end
    return Target
end

-- 3. ESP BYPASS (Cajas dinámicas)
local function ApplyESP(p)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(0, 255, 255)
    Box.Thickness = 1

    RunService.RenderStepped:Connect(function()
        if p.Character and getgenv().DZ_Config.ESP and p.Character:FindFirstChild("HumanoidRootPart") then
            if p.Character.Humanoid.Health > 0 and (not getgenv().DZ_Config.TeamCheck or p.Team ~= LocalPlayer.Team) then
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if onScreen then
                    Box.Size = Vector2.new(2000 / pos.Z, 3000 / pos.Z)
                    Box.Position = Vector2.new(pos.X - Box.Size.X / 2, pos.Y - Box.Size.Y / 2)
                    Box.Visible = true
                    return
                end
            end
        end
        Box.Visible = false
    end)
end

for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then ApplyESP(p) end end
Players.PlayerAdded:Connect(ApplyESP)

-- 4. BUCLE DE CONTROL (ANTI-DETECTION DISPARO)
local shooting = false
RunService.RenderStepped:Connect(function()
    FOV_Circle.Visible = true
    FOV_Circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOV_Circle.Radius = getgenv().DZ_Config.FOV

    local target = GetSafeTarget()
    
    -- Aimbot Suave
    if getgenv().DZ_Config.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) and target then
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), getgenv().DZ_Config.Smooth)
    end

    -- AUTO-SHOOT HUMANOID (Bypass Error 267)
    if getgenv().DZ_Config.AutoShoot and target then
        if not shooting then
            shooting = true
            -- Simulación de disparo basada en click del ratón pero con "jitter" (variación) de tiempo
            mouse1press()
            task.wait(math.random(3, 7) / 100) -- Tiempo de presión aleatorio
            mouse1release()
            shooting = false
            task.wait(math.random(5, 12) / 100) -- Tiempo entre ráfagas aleatorio
        end
    end
end)

-- 5. INTERFAZ RAYFIELD
local Window = Rayfield:CreateWindow({
    Name = "DZ CORE v28.0 | ANTI-BAN SAFE",
    LoadingTitle = "Inyectando Bypass de Servicios...",
    LoadingSubtitle = "Error 267 Patched",
})

local MainTab = Window:CreateTab("Combate Seguro")

MainTab:CreateToggle({Name = "Aimbot Humanizado", CurrentValue = true, Callback = function(v) getgenv().DZ_Config.Aimbot = v end})
MainTab:CreateToggle({Name = "Auto-Disparo (Anti-Ban)", CurrentValue = true, Callback = function(v) getgenv().DZ_Config.AutoShoot = v end})
MainTab:CreateToggle({Name = "ESP Lineal", CurrentValue = true, Callback = function(v) getgenv().DZ_Config.ESP = v end})
MainTab:CreateSlider({Name = "Rango FOV", Range = {50, 600}, CurrentValue = 200, Callback = function(v) getgenv().DZ_Config.FOV = v end})

Rayfield:Notify({Title = "BYPASS ACTIVO", Content = "Servicios de entrada camuflados con éxito.", Duration = 5})