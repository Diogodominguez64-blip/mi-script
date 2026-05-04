--[[
    DZ HUB v13.0 - RECONSTRUCCIÓN MAESTRA
    - FIX: ESP 2D Drawing con persistencia en combate (Post-Deploy).
    - FIX: Aimbot Independiente (No requiere ESP activo).
    - FIX: FOV dinámico ajustado al Viewport real.
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Configuración de Memoria Independiente
getgenv().DZ_Settings = {
    Aimbot_Enabled = true,
    Aimbot_Smoothness = 0.1,
    SilentAim = true,
    ESP_Enabled = true,
    ESP_Boxes = true,
    ESP_Names = true,
    TeamCheck = true,
    FOV_Radius = 200,
    Show_FOV = true
}

-- 1. FOV CIRCLE (Independiente y Centrado)[cite: 5]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(130, 0, 255)
FOVCircle.Transparency = 1
FOVCircle.Visible = false

-- 2. FUNCIÓN DE RASTREO UNIVERSAL (El Fix del Deploy)[cite: 5]
-- Busca en todo el Workspace sin importar carpetas de Lobby o Combate
local function GetClosestPlayer()
    local Target = nil
    local MaxDist = getgenv().DZ_Settings.FOV_Radius
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and (not getgenv().DZ_Settings.TeamCheck or p.Team ~= LocalPlayer.Team) then
            -- Verificación de personaje en cualquier parte del Workspace[cite: 5]
            local char = p.Character
            local head = char and char:FindFirstChild("Head")
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            if head and hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Center).Magnitude
                    if dist < MaxDist then
                        MaxDist = dist
                        Target = head
                    end
                end
            end
        end
    end
    return Target
end

-- 3. ESP DE DIBUJO 2D (Renderizado sobre el motor gráfico)[cite: 1, 5]
local function ManageESP(Player)
    local Box = Drawing.new("Square")
    local Name = Drawing.new("Text")
    
    local Render = RunService.RenderStepped:Connect(function()
        local char = Player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if hrp and hum and hum.Health > 0 and (not getgenv().DZ_Settings.TeamCheck or Player.Team ~= LocalPlayer.Team) then
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            
            if onScreen and getgenv().DZ_Settings.ESP_Enabled then
                local sizeY = (Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.5, 0)).Y - Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.8, 0)).Y)
                local sizeX = sizeY * 0.6
                
                -- Box ESP[cite: 5]
                Box.Visible = getgenv().DZ_Settings.ESP_Boxes
                Box.Size = Vector2.new(sizeX, sizeY)
                Box.Position = Vector2.new(pos.X - sizeX/2, pos.Y - sizeY/2)
                Box.Color = Color3.fromRGB(255, 50, 50)
                Box.Thickness = 1

                -- Name ESP[cite: 5]
                Name.Visible = getgenv().DZ_Settings.ESP_Names
                Name.Text = Player.Name
                Name.Position = Vector2.new(pos.X, pos.Y - sizeY/2 - 15)
                Name.Size = 14
                Name.Center = true
                Name.Outline = true
                Name.Color = Color3.new(1,1,1)
            else
                Box.Visible = false; Name.Visible = false
            end
        else
            Box.Visible = false; Name.Visible = false
            if not Player.Parent then Box:Remove(); Name:Remove() end
        end
    end)
end

-- Inicialización de ESP
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then ManageESP(p) end end
Players.PlayerAdded:Connect(ManageESP)

-- 4. INTERFAZ MAESTRA (Rayfield)[cite: 1]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "DZ HUB v13.0 | COMBAT READY",
    LoadingTitle = "Bypassing Instanciación de FPS...",
    LoadingSubtitle = "Master Script"
})

local CombatTab = Window:CreateTab("Aimbot")
CombatTab:CreateToggle({Name = "Aimbot de Seguimiento", Callback = function(v) getgenv().DZ_Settings.Aimbot_Enabled = v end})
CombatTab:CreateToggle({Name = "Silent Aim (Metamethod)", Callback = function(v) getgenv().DZ_Settings.SilentAim = v end})
CombatTab:CreateSlider({Name = "Radio FOV", Range = {50, 800}, CurrentValue = 200, Callback = function(v) getgenv().DZ_Settings.FOV_Radius = v end})
CombatTab:CreateToggle({Name = "Mostrar FOV", Callback = function(v) getgenv().DZ_Settings.Show_FOV = v end})

local VisualsTab = Window:CreateTab("Visuales")
VisualsTab:CreateToggle({Name = "Activar ESP", CurrentValue = true, Callback = function(v) getgenv().DZ_Settings.ESP_Enabled = v end})
VisualsTab:CreateToggle({Name = "Cajas (Boxes)", CurrentValue = true, Callback = function(v) getgenv().DZ_Settings.ESP_Boxes = v end})
VisualsTab:CreateToggle({Name = "Nombres", CurrentValue = true, Callback = function(v) getgenv().DZ_Settings.ESP_Names = v end})

-- 5. LÓGICA DE ACTUALIZACIÓN (Independiente)[cite: 2, 5]
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = getgenv().DZ_Settings.Show_FOV
    FOVCircle.Radius = getgenv().DZ_Settings.FOV_Radius
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- Aimbot de Seguimiento (Solo funciona al apuntar con Click Derecho)[cite: 5]
    if getgenv().DZ_Settings.Aimbot_Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestPlayer()
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), getgenv().DZ_Settings.Aimbot_Smoothness)
        end
    end
end)

-- Silent Aim Independiente (Intercepta la red del juego)[cite: 2]
local OldIndex
OldIndex = hookmetamethod(game, "__index", function(Self, Key)
    if not checkcaller() and getgenv().DZ_Settings.SilentAim and Key == "Hit" and Self:IsA("Mouse") then
        local target = GetClosestPlayer()
        if target then return target.CFrame end
    end
    return OldIndex(Self, Key)
end)

Rayfield:Notify({Title = "DZ HUB v13.0", Content = "Fix de Deploy activo. Aimbot y ESP sincronizados.", Duration = 5})