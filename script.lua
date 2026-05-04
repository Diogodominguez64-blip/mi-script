--[[
    DZ HUB v22.0 - ARCHITECTURE: SEPARATED UI
    - KEY SYSTEM: Interfaz minimalista de validación.
    - RIFLE ENGINE: Ejecución paralela post-autenticación.
    - BYPASS: Escaneo dinámico de entidades vivas (Fix Deploy).
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- 1. BASE DE DATOS DE SEGURIDAD
local AuthSettings = {
    Key = "DZ-MASTER-2026",
    Discord = "https://discord.gg/dz-hub-master",
    Verified = false
}

-- 2. MOTOR DE COMBATE (Encapsulado para ejecución post-key)
local function OpenRifleEngine()
    Rayfield:Notify({Title = "SISTEMA CARGADO", Content = "Inyectando Rifles y Bypasses...", Duration = 4})
    
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local VirtualInputManager = game:GetService("VirtualInputManager")

    getgenv().DZ_Master = {
        Aimbot = true,
        Silent = true,
        ESP = true,
        AutoShoot = false,
        FOV = 280,
        Smooth = 0.12,
        TeamCheck = true
    }

    -- FOV VISUAL
    local FOV_Circle = Drawing.new("Circle")
    FOV_Circle.Thickness = 2
    FOV_Circle.Color = Color3.fromRGB(0, 255, 255)
    FOV_Circle.Transparency = 1

    -- BUSCADOR DE OBJETIVOS (Bypass de Despliegue Crítico)
    local function GetValidTarget()
        local Target, BestDist = nil, getgenv().DZ_Master.FOV
        local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and (not getgenv().DZ_Master.TeamCheck or p.Team ~= LocalPlayer.Team) then
                local char = p.Character
                if char and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health > 0 then
                    local part = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
                    if part then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - Center).Magnitude
                            if dist < BestDist then BestDist = dist; Target = part end
                        end
                    end
                end
            end
        end
        return Target
    end

    -- ESP PERSISTENTE (Cajas Púrpura)
    local function ApplyESP(p)
        local Box = Drawing.new("Square")
        Box.Visible = false
        Box.Color = Color3.fromRGB(150, 0, 255)
        Box.Thickness = 1.5

        RunService.RenderStepped:Connect(function()
            if p.Character and getgenv().DZ_Master.ESP then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local root = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChildWhichIsA("BasePart")
                if hum and hum.Health > 0 and root then
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

    for _, player in pairs(Players:GetPlayers()) do if player ~= LocalPlayer then ApplyESP(player) end end
    Players.PlayerAdded:Connect(ApplyESP)

    -- BUCLE DE CONTROL: AIMBOT + AUTO-SHOOT
    RunService.RenderStepped:Connect(function()
        FOV_Circle.Visible = true
        FOV_Circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOV_Circle.Radius = getgenv().DZ_Master.FOV

        local target = GetValidTarget()

        -- Aimbot (Click Derecho)
        if getgenv().DZ_Master.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            if target then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), getgenv().DZ_Master.Smooth)
            end
        end

        -- AUTO-SHOOT (Extras)
        if getgenv().DZ_Master.AutoShoot and target then
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.01)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end
    end)

    -- INTERFAZ DE LOS RIFLES (Abierta tras la Key)
    local MainWin = Rayfield:CreateWindow({Name = "DZ RIFLE ENGINE | BYPASS ACTIVO"})
    local CombatTab = MainWin:CreateTab("Combate")
    local ExtrasTab = MainWin:CreateTab("Extras")

    CombatTab:CreateToggle({Name = "Aimbot + Silent", CurrentValue = true, Callback = function(v) getgenv().DZ_Master.Aimbot = v end})
    CombatTab:CreateSlider({Name = "Rango FOV", Range = {50, 800}, CurrentValue = 280, Callback = function(v) getgenv().DZ_Master.FOV = v end})
    CombatTab:CreateToggle({Name = "ESP Bypass (Post-Deploy)", CurrentValue = true, Callback = function(v) getgenv().DZ_Master.ESP = v end})

    ExtrasTab:CreateSection("Automatización")
    ExtrasTab:CreateToggle({Name = "Auto-Shoot Perpetuo", CurrentValue = false, Callback = function(v) getgenv().DZ_Master.AutoShoot = v end})
end

-- 3. INTERFAZ INDEPENDIENTE DEL KEY SYSTEM
local KeyWindow = Rayfield:CreateWindow({
    Name = "DZ HUB | KEY SYSTEM",
    LoadingTitle = "Esperando Validación...",
    LoadingSubtitle = "Acceso Restringido",
    ConfigurationSaving = {Enabled = false}
})

local KeyTab = KeyWindow:CreateTab("Acceso")

KeyTab:CreateInput({
    Name = "Introduce la Llave Maestra",
    PlaceholderText = "Key Here...",
    Callback = function(Value)
        if Value == AuthSettings.Key then
            KeyWindow:Destroy() -- Cierra la UI de la Key completamente
            OpenRifleEngine()   -- Abre la UI de combate y activa los bypasses
        else
            Rayfield:Notify({Title = "LLAVE INCORRECTA", Content = "Verifica tu acceso en Discord.", Duration = 3})
        end
    end,
})

KeyTab:CreateButton({
    Name = "Copiar Discord Link",
    Callback = function() 
        setclipboard(AuthSettings.Discord) 
        Rayfield:Notify({Title = "COPIADO", Content = "Link de Discord en el portapapeles.", Duration = 2})
    end
})