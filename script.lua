--[[
    DZ HUB v20.0 - DEFINITIVE COMBAT BYPASS
    - FIX: Sincronización total entre Aimbot y ESP.
    - BYPASS: Escaneo de entidades vivas post-despliegue (Live-Entity Scanner).
    - PERFORMANCE: Latencia zero en el dibujado de cajas.
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Configuración de Seguridad
local KeySystem = {
    Enabled = true,
    Key = "DZ-FINAL-2026",
    Discord = "https://discord.gg/dz-hub-master"
}

local Window = Rayfield:CreateWindow({
    Name = "DZ HUB v20.0 | FINAL BYPASS",
    LoadingTitle = "Inyectando Protocolo de Combate...",
    LoadingSubtitle = "Estilo: Rifle Master",
    ConfigurationSaving = {Enabled = false}
})

local AuthTab = Window:CreateTab("Autenticación")

-- MOTOR DE COMBATE DEFINITIVO (La Solución)
local function ExecuteFinalBypass()
    Rayfield:Notify({Title = "BYPASS EXITOSO", Content = "ESP y Aimbot Sincronizados.", Duration = 5})

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")

    getgenv().DZ_Settings = {
        Aimbot = true,
        Silent = true,
        ESP = true,
        FOV = 250,
        Smooth = 0.1, -- Suavizado optimizado para combate en vivo
        TeamCheck = true
    }

    -- 1. DIBUJO DE FOV (Estilo Rifle Pro)
    local FOV_Circle = Drawing.new("Circle")
    FOV_Circle.Thickness = 1.5
    FOV_Circle.Color = Color3.fromRGB(0, 255, 150) -- Verde Esmeralda
    FOV_Circle.Transparency = 0.8

    -- 2. ESCÁNER DE ENTIDADES EN TIEMPO REAL (El Fix definitivo)
    local function GetCombatEntity()
        local Target, BestDist = nil, getgenv().DZ_Settings.FOV
        local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and (not getgenv().DZ_Settings.TeamCheck or p.Team ~= LocalPlayer.Team) then
                local char = p.Character
                if char and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health > 0 then
                    -- Bypass de Partes: Buscamos cualquier parte física válida mientras está vivo
                    local root = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
                    if root then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                        if onScreen then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - Center).Magnitude
                            if dist < BestDist then
                                BestDist = dist
                                Target = root
                            end
                        end
                    end
                end
            end
        end
        return Target
    end

    -- 3. ESP DE DIBUJO PERSISTENTE (No se rompe al desplegar)
    local function CreateESP(Player)
        local Box = Drawing.new("Square")
        Box.Visible = false
        Box.Color = Color3.fromRGB(150, 0, 255) -- Púrpura Neón
        Box.Thickness = 1.2

        RunService.RenderStepped:Connect(function()
            if Player.Character and getgenv().DZ_Settings.ESP then
                local hum = Player.Character:FindFirstChildOfClass("Humanoid")
                local root = Player.Character:FindFirstChild("HumanoidRootPart") or Player.Character:FindFirstChildWhichIsA("BasePart")

                if hum and hum.Health > 0 and root and (not getgenv().DZ_Settings.TeamCheck or Player.Team ~= LocalPlayer.Team) then
                    local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        local sizeY = (Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.5, 0)).Y - Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 2.5, 0)).Y)
                        Box.Visible = true
                        Box.Size = Vector2.new(sizeY * 0.7, sizeY)
                        Box.Position = Vector2.new(pos.X - Box.Size.X / 2, pos.Y - Box.Size.Y / 2)
                        return
                    end
                end
            end
            Box.Visible = false
        end)
    end

    -- Inicializar ESP
    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end
    Players.PlayerAdded:Connect(CreateESP)

    -- 4. BUCLE DE AIMBOT (Hilo de Ejecución Independiente)
    RunService.RenderStepped:Connect(function()
        FOV_Circle.Visible = true
        FOV_Circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOV_Circle.Radius = getgenv().DZ_Settings.FOV

        if getgenv().DZ_Settings.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local target = GetCombatEntity()
            if target then
                -- Movimiento suave para enemigos en vivo
                local aimPos = CFrame.new(Camera.CFrame.Position, target.Position)
                Camera.CFrame = Camera.CFrame:Lerp(aimPos, getgenv().DZ_Settings.Smooth)
            end
        end
    end)

    -- 5. SILENT AIM (Metamethod Hook)
    local OldMT
    OldMT = hookmetamethod(game, "__index", function(self, key)
        if not checkcaller() and getgenv().DZ_Settings.Silent and key == "Hit" and self:IsA("Mouse") then
            local liveTarget = GetCombatEntity()
            if liveTarget then return liveTarget.CFrame end
        end
        return OldMT(self, key)
    end)

    -- MENÚ DE CONTROL
    local MainWin = Rayfield:CreateWindow({Name = "DZ RIFLE v20 | COMBAT READY"})
    local CombatTab = MainWin:CreateTab("Combate")

    CombatTab:CreateToggle({Name = "Aimbot + Silent Aim", CurrentValue = true, Callback = function(v) getgenv().DZ_Settings.Aimbot = v; getgenv().DZ_Settings.Silent = v end})
    CombatTab:CreateSlider({Name = "Radio FOV", Range = {50, 800}, CurrentValue = 250, Callback = function(v) getgenv().DZ_Settings.FOV = v end})
    CombatTab:CreateToggle({Name = "ESP Bypass (Post-Deploy)", CurrentValue = true, Callback = function(v) getgenv().DZ_Settings.ESP = v end})
end

-- UI DE LLAVES
AuthTab:CreateInput({
    Name = "Introduce la Key",
    PlaceholderText = "DZ-FINAL-XXXX",
    Callback = function(t)
        if t == KeySystem.Key then
            Window:Destroy()
            ExecuteFinalBypass()
        else
            Rayfield:Notify({Title = "ERROR", Content = "Llave inválida.", Duration = 3})
        end
    end,
})

AuthTab:CreateButton({
    Name = "Copiar Discord",
    Callback = function() setclipboard(KeySystem.Discord) end
})