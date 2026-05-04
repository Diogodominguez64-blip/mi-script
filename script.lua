--[[
    DZ MASTER CORE v31.0 - ULTRA PERFORMANCE
    - FIX LAG: Motor de búsqueda optimizado con task.wait() controlado.
    - HEADSHOT: Prioridad absoluta al Bone "Head" con suavizado adaptativo.
    - OMNI-ESP: Renderizado de alta velocidad para jugadores en arena (image_39e1a1.jpg).
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local plrs = game:GetService("Players")
local lplr = plrs.LocalPlayer
local cam = workspace.CurrentCamera
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")

getgenv().DZ_Ultra = {
    Aimbot = true,
    ESP = true,
    FOV = 200,
    Smoothness = 0.08, -- Reducido para mayor velocidad de "snap" a la cabeza
    HeadPriority = true,
    AntiLag = true
}

-- 1. MOTOR DE BÚSQUEDA OPTIMIZADO (Elimina el Lag)
local Target = nil
task.spawn(function()
    while task.wait(0.1) do -- Escaneo cada 100ms en lugar de cada frame para evitar lag
        local closestDist = getgenv().DZ_Ultra.FOV
        local potentialTarget = nil
        local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)

        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Humanoid") and v.Parent ~= lplr.Character and v.Health > 0 then
                local head = v.Parent:FindFirstChild("Head")
                if head then
                    local pos, onScreen = cam:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if mag < closestDist then
                            closestDist = mag
                            potentialTarget = head
                        end
                    end
                end
            end
        end
        Target = potentialTarget
    end
end)

-- 2. ESP DE ALTO RENDIMIENTO (V2)
local function CreatePowerESP(model)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(0, 255, 0) -- Verde neón para visibilidad clara
    box.Thickness = 2
    
    local conn
    conn = rs.RenderStepped:Connect(function()
        if not model or not model:Parent() or not getgenv().DZ_Ultra.ESP then
            box.Visible = false
            if model and not model:Parent() then conn:Disconnect() end
            return
        end

        local root = model:FindFirstChild("HumanoidRootPart")
        if root then
            local pos, onScreen = cam:WorldToViewportPoint(root.Position)
            if onScreen then
                -- El tamaño se ajusta dinámicamente a la distancia para evitar lag visual
                local dist = (cam.CFrame.Position - root.Position).Magnitude
                local size = 2000 / dist
                box.Size = Vector2.new(size, size * 1.2)
                box.Position = Vector2.new(pos.X - box.Size.X / 2, pos.Y - box.Size.Y / 2)
                box.Visible = true
            else
                box.Visible = false
            end
        end
    end)
end

-- Escaneo de combatientes (image_39e1a1.jpg)
for _, v in pairs(workspace:GetDescendants()) do
    if v:IsA("Humanoid") and v.Parent ~= lplr.Character then
        CreatePowerESP(v.Parent)
    end
end

workspace.DescendantAdded:Connect(function(d)
    if d:IsA("Humanoid") then
        task.wait(0.1)
        CreatePowerESP(d.Parent)
    end
end)

-- 3. MOTOR DE APUNTADO AGRESIVO (AUTO-HEAD)
rs.RenderStepped:Connect(function()
    if getgenv().DZ_Ultra.Aimbot and Target and uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        -- Cálculo de CFrame directo para máxima precisión
        local goal = CFrame.new(cam.CFrame.Position, Target.Position)
        cam.CFrame = cam.CFrame:Lerp(goal, getgenv().DZ_Ultra.Smoothness)
    end
end)

-- 4. INTERFAZ DE USUARIO (BOLD DESIGN)
local Window = Rayfield:CreateWindow({
    Name = "DZ ULTRA v31 | LAG-FREE",
    LoadingTitle = "Optimizando Kernel de Disparo...",
    LoadingSubtitle = "Headshot Priority Active",
})

local Tab = Window:CreateTab("Master Combat")

Tab:CreateToggle({
    Name = "Auto-Head Aim (Agresivo)",
    CurrentValue = true,
    Callback = function(v) getgenv().DZ_Ultra.Aimbot = v end
})

Tab:CreateToggle({
    Name = "Power ESP (Sin Lag)",
    CurrentValue = true,
    Callback = function(v) getgenv().DZ_Ultra.ESP = v end
})

Tab:CreateSlider({
    Name = "Fuerza de Atracción (Smooth)",
    Range = {0.01, 1},
    CurrentValue = 0.08,
    Callback = function(v) getgenv().DZ_Ultra.Smoothness = v end
})

Tab:CreateSlider({
    Name = "Campo de Visión (FOV)",
    Range = {50, 800},
    CurrentValue = 200,
    Callback = function(v) getgenv().DZ_Ultra.FOV = v end
})

Rayfield:Notify({Title = "MOTOR OPTIMIZADO", Content = "Lag eliminado. Prioridad de cabeza activa.", Duration = 5})