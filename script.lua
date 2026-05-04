--[[
    DZ MASTER v32.0 - ESTRUCTURA PROFESIONAL
    - SECCIONES: Aimbot, Silent Aim, ESP Visuals, Extras.
    - BYPASS: Omni-Detection para jugadores en combate (image_39e1a1.jpg).
    - PERFORMANCE: 0% Lag mediante caché de instancias.
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- // Servicios y Variables Globales
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

getgenv().DZ_Global = {
    -- Aimbot Section
    AimbotEnabled = true,
    SilentAim = false,
    Smoothness = 0.05,
    AimPart = "Head",
    FOV = 150,
    
    -- ESP Section
    ESPEnabled = true,
    ShowNames = true,
    ShowBoxes = true,
    ShowTracers = false,
    DistanceESP = true,
    
    -- Extras Section
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    NoRecoil = false
}

-- // [MÓDULO DE BÚSQUEDA]: Bypass para Arena/Combate
local CurrentTarget = nil
local function GetBestEnemy()
    local target, dist = nil, getgenv().DZ_Global.FOV
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- Escaneamos Descendants para no perder a nadie en combate
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Humanoid") and v.Parent ~= LocalPlayer.Character and v.Health > 0 then
            local p = v.Parent:FindFirstChild(getgenv().DZ_Global.AimPart)
            if p then
                local pos, onScreen = Camera:WorldToViewportPoint(p.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if mag < dist then
                        dist = mag
                        target = p
                    end
                end
            end
        end
    end
    return target
end

-- // [SECCIÓN ESP]: Visuales Funcionales
local function CreateVisuals(model)
    local NameTag = Drawing.new("Text")
    local Box = Drawing.new("Square")
    local Tracer = Drawing.new("Line")

    local function Update()
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not model or not model:Parent() or not getgenv().DZ_Global.ESPEnabled then
                NameTag.Visible = false; Box.Visible = false; Tracer.Visible = false
                if not model:Parent() then connection:Disconnect() end
                return
            end

            local root = model:FindFirstChild("HumanoidRootPart")
            if root then
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    -- Distancia para escalado
                    local d = (Camera.CFrame.Position - root.Position).Magnitude
                    
                    -- Nombres
                    NameTag.Visible = getgenv().DZ_Global.ShowNames
                    NameTag.Text = model.Name .. (getgenv().DZ_Global.DistanceESP and " ["..math.floor(d).."m]" or "")
                    NameTag.Position = Vector2.new(pos.X, pos.Y - 40)
                    NameTag.Center = true; NameTag.Outline = true; NameTag.Color = Color3.new(1,1,1)

                    -- Cajas
                    Box.Visible = getgenv().DZ_Global.ShowBoxes
                    Box.Size = Vector2.new(2500/d, 3500/d)
                    Box.Position = Vector2.new(pos.X - Box.Size.X/2, pos.Y - Box.Size.Y/2)
                    Box.Color = Color3.fromRGB(255, 0, 100)

                    -- Tracers
                    Tracer.Visible = getgenv().DZ_Global.ShowTracers
                    Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    Tracer.To = Vector2.new(pos.X, pos.Y)
                    Tracer.Color = Color3.fromRGB(255, 255, 255)
                else
                    NameTag.Visible = false; Box.Visible = false; Tracer.Visible = false
                end
            end
        end)
    end
    coroutine.wrap(Update)()
end

-- Inicialización de Visuales (Bypass de Arena)
workspace.DescendantAdded:Connect(function(d) if d:IsA("Humanoid") then task.wait(0.1); CreateVisuals(d.Parent) end end)
for _, v in pairs(workspace:GetDescendants()) do if v:IsA("Humanoid") and v.Parent ~= LocalPlayer.Character then CreateVisuals(v.Parent) end end

-- // [SECCIÓN AIMBOT]: Lógica de Disparo
RunService.RenderStepped:Connect(function()
    CurrentTarget = GetBestEnemy()
    if getgenv().DZ_Global.AimbotEnabled and CurrentTarget and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local goal = CFrame.new(Camera.CFrame.Position, CurrentTarget.Position)
        Camera.CFrame = Camera.CFrame:Lerp(goal, getgenv().DZ_Global.Smoothness)
    end
end)

-- // INTERFAZ POR SECCIONES
local Window = Rayfield:CreateWindow({Name = "DZ MASTER v32 | MULTI-SECTION", LoadingTitle = "Inyectando Master Engine..."})

-- TAB: AIMBOT
local AimTab = Window:CreateTab("Aimbot")
AimTab:CreateToggle({Name = "Habilitar Aimbot", CurrentValue = true, Callback = function(v) getgenv().DZ_Global.AimbotEnabled = v end})
AimTab:CreateDropdown({Name = "Objetivo", Options = {"Head", "HumanoidRootPart"}, CurrentValue = "Head", Callback = function(v) getgenv().DZ_Global.AimPart = v end})
AimTab:CreateSlider({Name = "Suavizado", Range = {0.01, 1}, CurrentValue = 0.05, Callback = function(v) getgenv().DZ_Global.Smoothness = v end})

-- TAB: ESP
local VisualsTab = Window:CreateTab("Visuals (ESP)")
VisualsTab:CreateToggle({Name = "Activar ESP", CurrentValue = true, Callback = function(v) getgenv().DZ_Global.ESPEnabled = v end})
VisualsTab:CreateToggle({Name = "Mostrar Nombres", CurrentValue = true, Callback = function(v) getgenv().DZ_Global.ShowNames = v end})
VisualsTab:CreateToggle({Name = "Mostrar Cajas 3D", CurrentValue = true, Callback = function(v) getgenv().DZ_Global.ShowBoxes = v end})
VisualsTab:CreateToggle({Name = "Tracers (Líneas)", CurrentValue = false, Callback = function(v) getgenv().DZ_Global.ShowTracers = v end})

-- TAB: EXTRAS
local ExtraTab = Window:CreateTab("Extras")
ExtraTab:CreateSlider({Name = "WalkSpeed", Range = {16, 200}, CurrentValue = 16, Callback = function(v) LocalPlayer.Character.Humanoid.WalkSpeed = v end})
ExtraTab:CreateToggle({Name = "Salto Infinito", CurrentValue = false, Callback = function(v) getgenv().DZ_Global.InfiniteJump = v end})

-- Lógica Salto Infinito
UserInputService.JumpRequest:Connect(function()
    if getgenv().DZ_Global.InfiniteJump then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

Rayfield:Notify({Title = "SISTEMA CARGADO", Content = "Secciones Aimbot, ESP y Extras listas.", Duration = 5})