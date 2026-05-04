--[[
    DZ HUB v10.0 - RECONSTRUCCIÓN TOTAL
    CORRECCIONES:
    1. FOV dinámico centrado (Fix esquina).
    2. Slider de Radio vinculado (Fix estático).
    3. ESP Persistente (Fix Deploy/Lobby).
    4. Aimbot de Seguimiento + Silent Aim.
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- Configuración Maestra
getgenv().DZ_Config = {
    Aimbot_Tracking = false, -- Nuevo: Seguimiento de cámara
    SilentAim = false,
    HitChance = 100,
    ESP_Enabled = false,
    FOV_Radius = 200,
    Show_FOV = false,
    TeamCheck = true
}

-- 1. FIX DEL FOV (Centrado y Radio Dinámico)[cite: 5]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(130, 0, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 1

-- 2. BUSCADOR DE OBJETIVOS MEJORADO[cite: 5]
local function GetClosestTarget()
    local Target, BestDist = nil, getgenv().DZ_Config.FOV_Radius
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            -- Fix para rigs de vóxel: busca la cabeza o la parte más alta
            local hitPart = p.Character:FindFirstChild("Head") or p.Character:FindFirstChildWhichIsA("BasePart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")

            if hitPart and hum and hum.Health > 0 then
                if not getgenv().DZ_Config.TeamCheck or p.Team ~= LocalPlayer.Team then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(hitPart.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - Center).Magnitude
                        if dist < BestDist then
                            BestDist = dist
                            Target = hitPart
                        end
                    end
                end
            end
        end
    end
    return Target
end

-- 3. INICIALIZACIÓN DE UI (Rayfield)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "DZ HUB v10.0 | FIX TOTAL",
    LoadingTitle = "Inyectando Lógica Funcional...",
    LoadingSubtitle = "FPS Lanzamiento Edition"
})

local CombatTab = Window:CreateTab("Combate")
CombatTab:CreateToggle({
    Name = "Aimbot de Seguimiento (Tracking)",
    Callback = function(v) getgenv().DZ_Config.Aimbot_Tracking = v end
})
CombatTab:CreateToggle({
    Name = "Silent Aim (Metamethod)",
    Callback = function(v) getgenv().DZ_Config.SilentAim = v end
})
CombatTab:CreateSlider({
    Name = "Radio del FOV",
    Range = {50, 800},
    Increment = 10,
    CurrentValue = 200,
    Callback = function(v) getgenv().DZ_Config.FOV_Radius = v end -- FIX: Actualización instantánea[cite: 5]
})
CombatTab:CreateToggle({
    Name = "Mostrar FOV",
    Callback = function(v) getgenv().DZ_Config.Show_FOV = v end
})

local VisualsTab = Window:CreateTab("Visuales")
VisualsTab:CreateToggle({
    Name = "ESP Enemigos (Highlights)",
    Callback = function(v) getgenv().DZ_Config.ESP_Enabled = v end
})

-- 4. BUCLE DE RENDERIZADO (FIX FOV Y ESP)[cite: 5]
RunService.RenderStepped:Connect(function()
    -- Fix FOV: Siempre centrado y con radio actualizado
    FOVCircle.Visible = getgenv().DZ_Config.Show_FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Radius = getgenv().DZ_Config.FOV_Radius

    -- Fix ESP: Aplicación constante para sobrevivir al Deploy
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local highlight = p.Character:FindFirstChild("DZ_Master_ESP")
            local isEnemy = not getgenv().DZ_Config.TeamCheck or p.Team ~= LocalPlayer.Team
            
            if getgenv().DZ_Config.ESP_Enabled and isEnemy then
                if not highlight then
                    highlight = Instance.new("Highlight", p.Character)
                    highlight.Name = "DZ_Master_ESP"
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                end
                highlight.Enabled = true
            elseif highlight then
                highlight.Enabled = false
            end
        end
    end

    -- Tracking Aimbot: Suavizado[cite: 5]
    if getgenv().DZ_Config.Aimbot_Tracking then
        local target = GetClosestTarget()
        if target and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), 0.15)
        end
    end
end)

-- 5. SILENT AIM (METAMETHOD BYPASS)[cite: 2]
local OldIndex
OldIndex = hookmetamethod(game, "__index", function(Self, Key)
    if not checkcaller() and getgenv().DZ_Config.SilentAim and Key == "Hit" and Self:IsA("Mouse") then
        local Target = GetClosestTarget()
        if Target then
            return Target.CFrame
        end
    end
    return OldIndex(Self, Key)
end)

Rayfield:Notify({Title = "DZ HUB v10.0", Content = "Sistemas Corregidos y Operativos", Duration = 5})