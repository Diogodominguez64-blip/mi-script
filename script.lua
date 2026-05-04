--[[
    DZ HUB v14.0 - BYPASS DE DESPLIEGUE TOTAL
    - FIX: Escaneo Recursivo de Workspace (Detecta enemigos post-deploy).
    - FIX: Aimbot Autónomo (Funciona 100% sin depender del ESP).
    - FIX: ESP de Caja 2D con actualización forzada de visibilidad.
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Configuración Global Desvinculada
getgenv().DZ_Config = {
    Aimbot_Standalone = true, -- Aimbot independiente
    SilentAim = true,
    ESP_Bypass = true, -- Bypass de despliegue
    ESP_Boxes = true,
    TeamCheck = true,
    FOV_Radius = 250,
    Show_FOV = true
}

-- 1. FOV MAESTRO (Fijado al centro exacto del Viewport)[cite: 5]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(0, 255, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 1

-- 2. EL BYPASS: BUSCADOR DE ENTIDADES OCULTAS[cite: 5]
-- Esta función ignora la jerarquía del lobby y busca en la memoria del Workspace
local function FindGlobalTarget()
    local Target, BestDist = nil, getgenv().DZ_Config.FOV_Radius
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- Escaneo agresivo de todo el Workspace para detectar el Deploy[cite: 5]
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Humanoid") and obj.Parent and obj.Parent:IsA("Model") then
            local char = obj.Parent
            local p = Players:GetPlayerFromCharacter(char)
            
            -- Si es un jugador, no es el local y pasa el TeamCheck
            if p and p ~= LocalPlayer and (not getgenv().DZ_Config.TeamCheck or p.Team ~= LocalPlayer.Team) then
                local head = char:FindFirstChild("Head") or char:FindFirstChildWhichIsA("BasePart")
                if head and obj.Health > 0 then
                    local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - Center).Magnitude
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

-- 3. ESP INDEPENDIENTE (DIBUJO DIRECTO)[cite: 1, 5]
local function CreateBypassESP(Player)
    local Box = Drawing.new("Square")
    Box.Thickness = 1.5
    Box.Filled = false
    Box.Transparency = 1
    Box.Color = Color3.fromRGB(255, 0, 0)

    RunService.RenderStepped:Connect(function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and getgenv().DZ_Config.ESP_Bypass then
            local hrp = Player.Character.HumanoidRootPart
            local hum = Player.Character:FindFirstChildOfClass("Humanoid")
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

            if onScreen and hum and hum.Health > 0 and (not getgenv().DZ_Config.TeamCheck or Player.Team ~= LocalPlayer.Team) then
                local sizeY = (Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.6, 0)).Y)
                Box.Visible = getgenv().DZ_Config.ESP_Boxes
                Box.Size = Vector2.new(sizeY * 0.7, sizeY)
                Box.Position = Vector2.new(pos.X - Box.Size.X / 2, pos.Y - Box.Size.Y / 2)
            else
                Box.Visible = false
            end
        else
            Box.Visible = false
        end
    end)
end

-- Aplicar ESP a todos los que entren (incluso post-deploy)[cite: 5]
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateBypassESP(p) end end
Players.PlayerAdded:Connect(CreateBypassESP)

-- 4. INTERFAZ Y BUCLE DE CONTROL[cite: 1]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "DZ HUB v14.0 | SUPER BYPASS", LoadingTitle = "Rompiendo Instancias de FPS..."})

local Tab = Window:CreateTab("Master")
Tab:CreateToggle({Name = "Bypass ESP (Deploy Fix)", CurrentValue = true, Callback = function(v) getgenv().DZ_Config.ESP_Bypass = v end})
Tab:CreateToggle({Name = "Aimbot Independiente", CurrentValue = true, Callback = function(v) getgenv().DZ_Config.Aimbot_Standalone = v end})
Tab:CreateSlider({Name = "FOV Bypass", Range = {50, 800}, CurrentValue = 250, Callback = function(v) getgenv().DZ_Config.FOV_Radius = v end})

-- BUCLE DE AIMBOT Y FOV (Desvinculado del ESP)[cite: 2, 5]
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = getgenv().DZ_Config.Show_FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Radius = getgenv().DZ_Config.FOV_Radius

    if getgenv().DZ_Config.Aimbot_Standalone and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = FindGlobalTarget()
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), 0.18)
        end
    end
end)

-- SILENT AIM BYPASS[cite: 2]
local OldIndex
OldIndex = hookmetamethod(game, "__index", function(Self, Key)
    if not checkcaller() and getgenv().DZ_Config.SilentAim and Key == "Hit" and Self:IsA("Mouse") then
        local target = FindGlobalTarget()
        if target then return target.CFrame end
    end
    return OldIndex(Self, Key)
end)

Rayfield:Notify({Title = "BYPASS ACTIVADO", Content = "ESP y Aimbot ahora ignoran el estado del Lobby.", Duration = 5})