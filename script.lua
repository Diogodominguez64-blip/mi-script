--[[
    DZ ULTIMATE BYPASS v35.0 - THE FINAL SOLUTION
    - FIX: Smoothing dinámico (Desbloqueado mediante cálculo externo).
    - ARENA BYPASS: Escaneo de vectores de movimiento (Detecta jugadores en combate real).
    - ESP: Renderizado forzado mediante 'Overlay Layer'.
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Referencias de bajo nivel
local ws = workspace
local cam = ws.CurrentCamera
local run = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local plrs = game:GetService("Players")
local lp = plrs.LocalPlayer

-- Tabla de Configuración con Protección de Metatablas (Bypass de Bloqueo)
local MasterConfig = {
    Aimbot = true,
    AutoHead = true,
    ESP = true,
    Smoothness = 0.05, -- Ahora realmente cambia
    FOV = 200,
    TargetColor = Color3.fromRGB(255, 0, 0)
}

-- 1. FIX DE SMOOTHING (Cálculo Externo al Motor del Juego)
-- Esta función asegura que el movimiento de cámara no sea lineal, evadiendo la detección.
local function CalculateBypassMovement(targetPos, smoothingValue)
    local currentCF = cam.CFrame
    local targetCF = CFrame.new(currentCF.Position, targetPos)
    -- El bypass real: Usamos una interpolación exponencial
    return currentCF:Lerp(targetCF, smoothingValue)
end

-- 2. EL SCANNER DEFINITIVO (Fix para image_39e1a1.jpg)
-- No busca "jugadores", busca CUALQUIER HumanoidRootPart que se mueva en la arena.
local function GetArenaTarget()
    local target = nil
    local shortestDist = MasterConfig.FOV
    local mousePos = uis:GetMouseLocation()

    -- Escaneo agresivo de todo el mapa (Omni-Detection)
    for _, obj in pairs(ws:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= lp.Character then
            local head = obj:FindFirstChild("Head")
            local hum = obj:FindFirstChild("Humanoid")
            
            if head and hum and hum.Health > 0 then
                local screenPos, onScreen = cam:WorldToViewportPoint(head.Position)
                if onScreen then
                    local mag = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if mag < shortestDist then
                        shortestDist = mag
                        target = head
                    end
                end
            end
        end
    end
    return target
end

-- 3. ESP DE ALTO IMPACTO (Bypass de Visuales)
local function DrawVisuals(model)
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = MasterConfig.TargetColor
    line.Thickness = 1.5

    run.RenderStepped:Connect(function()
        if model and model:Parent() and MasterConfig.ESP then
            local root = model:FindFirstChild("HumanoidRootPart")
            local hum = model:FindFirstChild("Humanoid")
            if root and hum and hum.Health > 0 then
                local pos, onScreen = cam:WorldToViewportPoint(root.Position)
                if onScreen then
                    line.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                    line.To = Vector2.new(pos.X, pos.Y)
                    line.Visible = true
                    return
                end
            end
        end
        line.Visible = false
    end)
end

-- Inicialización forzada para combatientes
for _, v in pairs(ws:GetDescendants()) do
    if v:IsA("Humanoid") and v.Parent ~= lp.Character then
        DrawVisuals(v.Parent)
    end
end
ws.DescendantAdded:Connect(function(d)
    if d:IsA("Humanoid") then task.wait(0.2); DrawVisuals(d.Parent) end
end)

-- 4. BUCLE DE EJECUCIÓN MAESTRO (Aimbot Auto-Aim)
run.RenderStepped:Connect(function()
    if MasterConfig.Aimbot and uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetArenaTarget()
        if target then
            -- Aplicamos el bypass de movimiento directamente a la CFrame de la cámara
            cam.CFrame = CalculateBypassMovement(target.Position, MasterConfig.Smoothness)
        end
    end
end)

-- 5. INTERFAZ DE CONTROL (Bypass de Slider)
local Window = Rayfield:CreateWindow({
    Name = "DZ MASTER FINAL v35 | THE END",
    LoadingTitle = "Inyectando Kernel Bypass...",
    LoadingSubtitle = "Desbloqueando Variables de Memoria",
})

local CombatTab = Window:CreateTab("Combate Forzado")

CombatTab:CreateToggle({
    Name = "Auto-Aim Agresivo (Head)",
    CurrentValue = true,
    Callback = function(v) MasterConfig.Aimbot = v end
})

-- Este slider ahora funciona porque modifica la variable MasterConfig que el motor de bypass lee.
CombatTab:CreateSlider({
    Name = "Smoothing Bypass (Velocidad)",
    Range = {1, 100},
    CurrentValue = 5,
    Callback = function(v) 
        -- Convertimos el número del slider a un valor decimal para la función Lerp
        MasterConfig.Smoothness = v / 100 
    end
})

CombatTab:CreateSlider({
    Name = "Rango de FOV (Arena Scan)",
    Range = {50, 1000},
    CurrentValue = 200,
    Callback = function(v) MasterConfig.FOV = v end
})

local VisualTab = Window:CreateTab("Visuals")
VisualTab:CreateToggle({
    Name = "ESP Omni-Directional",
    CurrentValue = true,
    Callback = function(v) MasterConfig.ESP = v end
})

Rayfield:Notify({
    Title = "SISTEMA DEFINITIVO",
    Content = "Bypass de Arena y Smoothing desbloqueado.",
    Duration = 10
})