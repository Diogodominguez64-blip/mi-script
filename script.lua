--[[
    DZ HUB v12.0 - SUPREMACÍA VISUAL
    FIX: ESP Drawing 2D (Funciona post-deploy y en lobby).
    NUEVAS FUNCIONES: Box ESP, Snaplines (Líneas), y Nombres.
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Configuración Avanzada
getgenv().DZ_Config = {
    ESP_Enabled = true,
    ESP_Boxes = true,
    ESP_Lines = true,
    ESP_Names = true,
    TeamCheck = true,
    SilentAim = true,
    FOV_Radius = 200,
    Show_FOV = true
}

-- FOV FIX (Centrado y funcional)[cite: 5]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(130, 0, 255)
FOVCircle.Transparency = 1

-- SISTEMA DE DIBUJO ESP (EL FIX DEFINITIVO)[cite: 5]
local function CreateESP(Player)
    local Box = Drawing.new("Square")
    local Line = Drawing.new("Line")
    local Name = Drawing.new("Text")

    local function Update()
        local Connection
        Connection = RunService.RenderStepped:Connect(function()
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                local RootPart = Player.Character.HumanoidRootPart
                local Pos, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)
                
                -- Verificación de Equipo[cite: 5]
                local IsEnemy = not getgenv().DZ_Config.TeamCheck or Player.Team ~= LocalPlayer.Team

                if OnScreen and getgenv().DZ_Config.ESP_Enabled and IsEnemy then
                    -- Calculo de tamaño de caja basado en distancia[cite: 5]
                    local Size = (Camera:WorldToViewportPoint(RootPart.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(RootPart.Position + Vector3.new(0, 2.6, 0)).Y)
                    
                    -- Configurar Caja
                    Box.Visible = getgenv().DZ_Config.ESP_Boxes
                    Box.Size = Vector2.new(Size * 0.7, Size)
                    Box.Position = Vector2.new(Pos.X - Box.Size.X / 2, Pos.Y - Box.Size.Y / 2)
                    Box.Color = Color3.fromRGB(255, 0, 0)
                    Box.Thickness = 1

                    -- Configurar Líneas (Snaplines)
                    Line.Visible = getgenv().DZ_Config.ESP_Lines
                    Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    Line.To = Vector2.new(Pos.X, Pos.Y + (Size/2))
                    Line.Color = Color3.fromRGB(255, 255, 255)

                    -- Configurar Nombres
                    Name.Visible = getgenv().DZ_Config.ESP_Names
                    Name.Text = Player.Name
                    Name.Position = Vector2.new(Pos.X, Pos.Y - (Size/2) - 15)
                    Name.Color = Color3.new(1, 1, 1)
                    Name.Center = true
                    Name.Outline = true
                else
                    Box.Visible = false
                    Line.Visible = false
                    Name.Visible = false
                end
            else
                Box.Visible = false
                Line.Visible = false
                Name.Visible = false
                if not Player.Parent then Connection:Disconnect() end
            end
        end)
    end
    coroutine.wrap(Update)()
end

-- Inicializar ESP para todos[cite: 5]
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CreateESP(p) end
end
Players.PlayerAdded:Connect(function(p) CreateESP(p) end)

-- UI MASTER (Rayfield)[cite: 1]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "DZ HUB v12.0 | ESP UNLIMITED",
    LoadingTitle = "Bypassing FPS Lanzamiento...",
    LoadingSubtitle = "Master Script"
})

local CombatTab = Window:CreateTab("Combate")
CombatTab:CreateToggle({Name = "Silent Aim", Callback = function(v) getgenv().DZ_Config.SilentAim = v end})
CombatTab:CreateSlider({Name = "FOV Radius", Range = {50, 800}, CurrentValue = 200, Callback = function(v) getgenv().DZ_Config.FOV_Radius = v end})
CombatTab:CreateToggle({Name = "Show FOV", Callback = function(v) getgenv().DZ_Config.Show_FOV = v end})

local VisualsTab = Window:CreateTab("Visuales")
VisualsTab:CreateToggle({Name = "Activar ESP", CurrentValue = true, Callback = function(v) getgenv().DZ_Config.ESP_Enabled = v end})
VisualsTab:CreateToggle({Name = "Cajas (Boxes)", CurrentValue = true, Callback = function(v) getgenv().DZ_Config.ESP_Boxes = v end})
VisualsTab:CreateToggle({Name = "Líneas (Lines)", CurrentValue = true, Callback = function(v) getgenv().DZ_Config.ESP_Lines = v end})
VisualsTab:CreateToggle({Name = "Nombres", CurrentValue = true, Callback = function(v) getgenv().DZ_Config.ESP_Names = v end})

-- BUCLE DE ACTUALIZACIÓN FOV Y AIMBOT[cite: 2, 5]
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = getgenv().DZ_Config.Show_FOV
    FOVCircle.Radius = getgenv().DZ_Config.FOV_Radius
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end)

local OldIndex
OldIndex = hookmetamethod(game, "__index", function(Self, Key)
    if not checkcaller() and getgenv().DZ_Config.SilentAim and Key == "Hit" and Self:IsA("Mouse") then
        -- Lógica de búsqueda de objetivo integrada
        local Target, BestDist = nil, getgenv().DZ_Config.FOV_Radius
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local Pos, OnScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                local Dist = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                if OnScreen and Dist < BestDist then
                    BestDist = Dist
                    Target = p.Character.Head
                end
            end
        end
        if Target then return Target.CFrame end
    end
    return OldIndex(Self, Key)
end)

Rayfield:Notify({Title = "DZ HUB v12.0", Content = "ESP de Dibujo 2D Activado. Funcional tras Deploy.", Duration = 5})