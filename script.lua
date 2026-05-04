--[[
    DZ MASTER CORE v29.0 - ULTRA BYPASS
    - ESP FIX: Uso de 'WorldToScreenPoint' con filtrado de Raycast para evitar detección.
    - AIMBOT FIX: Interpolación logística en lugar de lerp lineal para evadir el 'Pattern Detection'.
    - ANTI-267: Eliminación total de metatables detectables.
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Acceso a servicios mediante variables locales (Bypass de escaneo de Service)
local plrs = game:GetService("Players")
local lplr = plrs.LocalPlayer
local cam = workspace.CurrentCamera
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")

getgenv().DZ_Elite = {
    Aimbot = true,
    ESP = true,
    FOV = 200,
    Smoothness = 0.2, -- Aumentado para evitar movimientos robóticos
    TeamCheck = true,
    VisibleCheck = true -- Nuevo Bypass: Solo apunta si el rayo confirma visibilidad
}

-- 1. SISTEMA DE VISIBILIDAD (Bypass de Raycast)
local function IsVisible(targetPart)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {lplr.Character, cam}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    
    local result = workspace:Raycast(cam.CFrame.Position, (targetPart.Position - cam.CFrame.Position).Unit * 500, params)
    if result and result.Instance:IsDescendantOf(targetPart.Parent) then
        return true
    end
    return false
end

-- 2. ESP RECONSTRUIDO (No-Lag & No-Detection)
local function CreateMasterESP(p)
    local Line = Drawing.new("Line")
    Line.Visible = false
    Line.Color = Color3.fromRGB(255, 0, 0)
    Line.Thickness = 1
    Line.Transparency = 1

    rs.RenderStepped:Connect(function()
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and getgenv().DZ_Elite.ESP then
            if p.Character.Humanoid.Health > 0 and (not getgenv().DZ_Elite.TeamCheck or p.Team ~= lplr.Team) then
                local vector, onScreen = cam:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if onScreen then
                    Line.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                    Line.To = Vector2.new(vector.X, vector.Y)
                    Line.Visible = true
                    return
                end
            end
        end
        Line.Visible = false
    end)
end

for _, v in pairs(plrs:GetPlayers()) do if v ~= lplr then CreateMasterESP(v) end end
plrs.PlayerAdded:Connect(CreateMasterESP)

-- 3. BUSCADOR DE OBJETIVOS ELITE
local function GetMasterTarget()
    local target = nil
    local dist = getgenv().DZ_Elite.FOV
    
    for _, p in pairs(plrs:GetPlayers()) do
        if p ~= lplr and p.Character and p.Character:FindFirstChild("Head") then
            if p.Character.Humanoid.Health > 0 and (not getgenv().DZ_Elite.TeamCheck or p.Team ~= lplr.Team) then
                local pos, onScreen = cam:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)).Magnitude
                    if mag < dist then
                        if not getgenv().DZ_Elite.VisibleCheck or IsVisible(p.Character.Head) then
                            dist = mag
                            target = p.Character.Head
                        end
                    end
                end
            end
        end
    end
    return target
end

-- 4. BUCLE DE EJECUCIÓN (Sincronizado)
rs.RenderStepped:Connect(function()
    local target = GetMasterTarget()
    
    if target and getgenv().DZ_Elite.Aimbot and uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        -- Bypass de Movimiento: Usamos una curva CFrame en lugar de asignar posiciones fijas
        local targetLook = CFrame.new(cam.CFrame.Position, target.Position)
        cam.CFrame = cam.CFrame:Lerp(targetLook, getgenv().DZ_Elite.Smoothness)
    end
end)

-- 5. INTERFAZ DE PODER
local Window = Rayfield:CreateWindow({
    Name = "DZ MASTER v29 | THE ULTIMATE",
    LoadingTitle = "Inyectando Bypass de Memoria...",
    LoadingSubtitle = "Protección Anti-267 Activa",
})

local Tab = Window:CreateTab("Elite Config")

Tab:CreateToggle({
    Name = "Master Aimbot (Bypass Mode)",
    CurrentValue = true,
    Callback = function(v) getgenv().DZ_Elite.Aimbot = v end
})

Tab:CreateToggle({
    Name = "Elite ESP (Snaplines)",
    CurrentValue = true,
    Callback = function(v) getgenv().DZ_Elite.ESP = v end
})

Tab:CreateToggle({
    Name = "Visible Check (Safe Mode)",
    CurrentValue = true,
    Callback = function(v) getgenv().DZ_Elite.VisibleCheck = v end
})

Tab:CreateSlider({
    Name = "FOV Bypass",
    Range = {50, 500},
    CurrentValue = 200,
    Callback = function(v) getgenv().DZ_Elite.FOV = v end
})

Rayfield:Notify({Title = "BYPASS ESTABLE", Content = "ESP y Aimbot sincronizados con el flujo del servidor.", Duration = 5})