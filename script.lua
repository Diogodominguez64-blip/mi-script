--[[
    DZ MASTER CORE v30.0 - OMNI-COMBAT (FINAL BYPASS)
    - FIX: Escaneo de instancias dinámicas (Detecta jugadores en arena/combate).
    - AIMBOT: Algoritmo de "Prediction" suave para evitar el baneo por Error 267.
    - ESP: 3D Box dinámico que se auto-actualiza si el personaje reaparece.
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local plrs = game:GetService("Players")
local lplr = plrs.LocalPlayer
local cam = workspace.CurrentCamera
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")

getgenv().DZ_Omni = {
    Aimbot = true,
    ESP = true,
    FOV = 250,
    Smoothness = 0.1, -- Valor optimizado para balance entre velocidad y bypass
    TeamCheck = false, -- Cambiar a true si el juego tiene equipos definidos
    AutoPredict = true
}

-- 1. MOTOR DE ESCANEO RECURSIVO (El Bypass Definitivo)
-- Esto busca en TODO el mapa, no solo en la lista de jugadores, para hallar los modelos de combate.
local function GetCharacterFromPart(part)
    local char = part.Parent
    if char:FindFirstChildOfClass("Humanoid") then return char end
    if char.Parent:FindFirstChildOfClass("Humanoid") then return char.Parent end
    return nil
end

-- 2. ESP DE CAJAS 3D (RECONSTRUIDO PARA COMBATE)
local function CreateCombatESP(model)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(255, 0, 100)
    box.Thickness = 2
    box.Transparency = 1

    local connection
    connection = rs.RenderStepped:Connect(function()
        if not model or not model:Parent() or not getgenv().DZ_Omni.ESP then
            box.Visible = false
            if not model:Parent() then connection:Disconnect() end
            return
        end

        local root = model:FindFirstChild("HumanoidRootPart")
        local hum = model:FindFirstChildOfClass("Humanoid")
        
        if root and hum and hum.Health > 0 then
            local pos, onScreen = cam:WorldToViewportPoint(root.Position)
            if onScreen then
                local sizeY = (cam:WorldToViewportPoint(root.Position - Vector3.new(0, 3.5, 0)).Y - cam:WorldToViewportPoint(root.Position + Vector3.new(0, 2.5, 0)).Y)
                box.Size = Vector2.new(sizeY * 0.7, sizeY)
                box.Position = Vector2.new(pos.X - box.Size.X / 2, pos.Y - box.Size.Y / 2)
                box.Visible = true
                return
            end
        end
        box.Visible = false
    end)
end

-- Escáner de Arena: Detecta modelos que aparecen de la nada
workspace.DescendantAdded:Connect(function(d)
    if d:IsA("Humanoid") then
        task.wait(0.5) -- Delay de seguridad para que el modelo cargue
        local char = d.Parent
        if char ~= lplr.Character then CreateCombatESP(char) end
    end
end)

-- Inicializar para lo que ya existe en el mapa
for _, v in pairs(workspace:GetDescendants()) do
    if v:IsA("Humanoid") and v.Parent ~= lplr.Character then
        CreateCombatESP(v.Parent)
    end
end

-- 3. AIMBOT DE PREDICCIÓN (ULTRA BYPASS)
local function GetCombatTarget()
    local target = nil
    local dist = getgenv().DZ_Omni.FOV
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Humanoid") and v.Parent ~= lplr.Character and v.Health > 0 then
            local head = v.Parent:FindFirstChild("Head")
            if head then
                local pos, onScreen = cam:WorldToViewportPoint(head.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if mag < dist then
                        dist = mag
                        target = head
                    end
                end
            end
        end
    end
    return target
end

-- 4. BUCLE MAESTRO
rs.RenderStepped:Connect(function()
    if getgenv().DZ_Omni.Aimbot and uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetCombatTarget()
        if target then
            -- Bypass de predicción: compensa el movimiento del enemigo en combate
            local prediction = target.Velocity * (target.Position - cam.CFrame.Position).Magnitude / 500
            local targetPos = target.Position + (getgenv().DZ_Omni.AutoPredict and prediction or Vector3.new(0,0,0))
            
            cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, targetPos), getgenv().DZ_Omni.Smoothness)
        end
    end
end)

-- 5. INTERFAZ DE CONTROL
local Window = Rayfield:CreateWindow({
    Name = "DZ OMNI-CORE v30 | COMBAT READY",
    LoadingTitle = "Inyectando Omni-Scanner...",
    LoadingSubtitle = "Bypass de Instancia Activo",
})

local Tab = Window:CreateTab("Combate Real")

Tab:CreateToggle({
    Name = "Aimbot Predictivo (Combate)",
    CurrentValue = true,
    Callback = function(v) getgenv().DZ_Omni.Aimbot = v end
})

Tab:CreateToggle({
    Name = "Omni-ESP (Detecta Arena)",
    CurrentValue = true,
    Callback = function(v) getgenv().DZ_Omni.ESP = v end
})

Tab:CreateSlider({
    Name = "Suavizado (Anti-Ban)",
    Range = {0.01, 0.5},
    CurrentValue = 0.1,
    Callback = function(v) getgenv().DZ_Omni.Smoothness = v end
})

Rayfield:Notify({Title = "OMNI-BYPASS LISTO", Content = "Buscando enemigos en la arena y combate...", Duration = 5})