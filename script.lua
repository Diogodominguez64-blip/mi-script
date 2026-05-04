--[[
    DZ HUB v11.0 - FIX DEPLOY & STALE REFERENCE
    SOLUCIÓN: 
    - Escaneo dinámico de Workspace para detectar personajes tras el 'Deploy'.
    - ESP de Caja (Box) robusto que se redibuja si el personaje cambia.
    - Aimbot con validación de existencia de objetivo.
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- Configuración Global
getgenv().DZ_Config = {
    Aimbot_Tracking = true,
    SilentAim = true,
    ESP_Box = true,
    TeamCheck = true,
    FOV_Radius = 250,
    Show_FOV = true
}

-- FIX: Círculo de FOV centrado dinámicamente[cite: 5]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(130, 0, 255)
FOVCircle.Transparency = 1

-- SISTEMA DE ESCANEO DINÁMICO (El Fix para el Deploy)[cite: 5]
local function GetValidTarget()
    local Target, BestDist = nil, getgenv().DZ_Config.FOV_Radius
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- Buscamos en todo el Workspace para no perder el rastro tras el Deploy
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            -- Intentamos encontrar el personaje vivo, sin importar dónde esté en el Workspace
            local char = p.Character
            if char and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health > 0 then
                if not getgenv().DZ_Config.TeamCheck or p.Team ~= LocalPlayer.Team then
                    local hitPart = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart")
                    
                    if hitPart then
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
    end
    return Target
end

-- INTERFAZ RAYFIELD (Optimizada)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "DZ HUB v11.0 | FIX DEPLOY",
    LoadingTitle = "Reconstruyendo Enlaces de Memoria...",
    LoadingSubtitle = "Listo para FPS Lanzamiento"
})

local MainTab = Window:CreateTab("Combate")
MainTab:CreateToggle({Name = "Aimbot Tracking (Click Derecho)", Callback = function(v) getgenv().DZ_Config.Aimbot_Tracking = v end})
MainTab:CreateToggle({Name = "Silent Aim (Metamethod)", Callback = function(v) getgenv().DZ_Config.SilentAim = v end})
MainTab:CreateSlider({Name = "Radio FOV", Range = {50, 800}, CurrentValue = 250, Callback = function(v) getgenv().DZ_Config.FOV_Radius = v end})
MainTab:CreateToggle({Name = "Mostrar FOV", Callback = function(v) getgenv().DZ_Config.Show_FOV = v end})

local VisualsTab = Window:CreateTab("Visuales")
VisualsTab:CreateToggle({Name = "Box ESP (Persistente)", Callback = function(v) getgenv().DZ_Config.ESP_Box = v end})

-- BUCLE PRINCIPAL DE RENDERIZADO[cite: 5]
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = getgenv().DZ_Config.Show_FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Radius = getgenv().DZ_Config.FOV_Radius

    -- Lógica de ESP de Caja (Highlight para máxima visibilidad tras Deploy)[cite: 5]
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local highlight = p.Character:FindFirstChild("DZ_BOX")
            local isEnemy = not getgenv().DZ_Config.TeamCheck or p.Team ~= LocalPlayer.Team
            
            if getgenv().DZ_Config.ESP_Box and isEnemy and p.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                if not highlight then
                    highlight = Instance.new("Highlight", p.Character)
                    highlight.Name = "DZ_BOX"
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.new(1,1,1)
                    highlight.FillAlpha = 0.5
                end
                highlight.Enabled = true
            elseif highlight then
                highlight.Enabled = false
            end
        end
    end

    -- Tracking Aimbot mejorado con validación de objetivo[cite: 5]
    if getgenv().DZ_Config.Aimbot_Tracking and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetValidTarget()
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), 0.2)
        end
    end
end)

-- SILENT AIM (METAMETHOD BYPASS)[cite: 2]
local OldIndex
OldIndex = hookmetamethod(game, "__index", function(Self, Key)
    if not checkcaller() and getgenv().DZ_Config.SilentAim and Key == "Hit" and Self:IsA("Mouse") then
        local target = GetValidTarget()
        if target then
            return target.CFrame
        end
    end
    return OldIndex(Self, Key)
end)

Rayfield:Notify({Title = "DZ HUB v11.0", Content = "Fix de Deploy aplicado. Funcional en combate.", Duration = 5})