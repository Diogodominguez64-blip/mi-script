--[[
    DZ ENGINEER v37.0 - THE KERNEL OVERLAY
    - FIXED: ESP (Usando BoxHandleAdornment para bypass de renderizado).
    - FIXED: Arena Detection (Escaneo de jerarquía profunda).
    - POWER: Ultra-Smooth Aimbot con desbloqueo de variables.
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Referencias de Nivel Ingeniero
local ws = workspace
local cam = ws.CurrentCamera
local run = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local plrs = game:GetService("Players")
local lp = plrs.LocalPlayer

getgenv().DZ_Engineer = {
    Aimbot = true,
    ESP = true,
    Smoothness = 0.05,
    FOV = 250,
    ESPColor = Color3.fromRGB(255, 0, 100), -- Rosa Neón para máximo contraste
    ESPTransparency = 0.5
}

-- // [EL ULTRA-BYPASS]: ESP NATIVO (ADORNMENTS)
-- Este método no usa la librería "Drawing", usa objetos físicos del motor.
local function CreateKernelESP(model)
    local root = model:WaitForChild("HumanoidRootPart", 5)
    if not root then return end

    -- Si ya tiene un ESP, no creamos otro
    if root:FindFirstChild("DZ_Adornment") then return end

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "DZ_Adornment"
    box.Size = Vector3.new(4, 6, 1) -- Tamaño estándar de personaje
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Adornee = root
    box.Color3 = getgenv().DZ_Engineer.ESPColor
    box.Transparency = getgenv().DZ_Engineer.ESPTransparency
    box.Parent = root -- Se ancla directamente al jugador

    -- Hilo de actualización de estado
    task.spawn(function()
        local hum = model:FindFirstChildOfClass("Humanoid")
        while model and model:Parent() do
            box.Visible = getgenv().DZ_Engineer.ESP and (hum and hum.Health > 0)
            task.wait(0.5) -- Bajo consumo de recursos
        end
        box:Destroy()
    end)
end

-- // [ENGINEER AIMBOT]: Motor de Seguimiento de Vectores
local function GetClosestTarget()
    local target = nil
    local dist = getgenv().DZ_Engineer.FOV
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)

    for _, v in pairs(ws:GetDescendants()) do
        if v:IsA("Humanoid") and v.Parent ~= lp.Character and v.Health > 0 then
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

-- Ejecución del Aimbot
run.RenderStepped:Connect(function()
    if getgenv().DZ_Engineer.Aimbot and uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestTarget()
        if target then
            local goal = CFrame.new(cam.CFrame.Position, target.Position)
            cam.CFrame = cam.CFrame:Lerp(goal, getgenv().DZ_Engineer.Smoothness)
        end
    end
end)

-- // [SISTEMA DE ESCANEO]: Lobby y Arena (image_39e1a1.jpg)
local function ScanMap()
    for _, v in pairs(ws:GetDescendants()) do
        if v:IsA("Humanoid") and v.Parent ~= lp.Character then
            CreateKernelESP(v.Parent)
        end
    end
end

ws.DescendantAdded:Connect(function(d)
    if d:IsA("Humanoid") then
        task.wait(0.1)
        CreateKernelESP(d.Parent)
    end
end)

-- Ejecutar escaneo inicial
ScanMap()

-- // INTERFAZ DE CONTROL (Rayfield)
local Window = Rayfield:CreateWindow({
    Name = "DZ ENGINEER v37 | ULTRA BYPASS",
    LoadingTitle = "Inyectando Adornment Overlay...",
    LoadingSubtitle = "Bypass de Buffer Activo"
})

local Combat = Window:CreateTab("Combate & Visuals")

Combat:CreateToggle({
    Name = "Ultra-ESP (Native Bypass)",
    CurrentValue = true,
    Callback = function(v) getgenv().DZ_Engineer.ESP = v end
})

Combat:CreateToggle({
    Name = "Aimbot Predictivo",
    CurrentValue = true,
    Callback = function(v) getgenv().DZ_Engineer.Aimbot = v end
})

Combat:CreateSlider({
    Name = "Smoothness (Desbloqueado)",
    Range = {1, 100},
    CurrentValue = 5,
    Callback = function(v) getgenv().DZ_Engineer.Smoothness = v / 100 end
})

Combat:CreateSlider({
    Name = "FOV Arena",
    Range = {50, 1000},
    CurrentValue = 250,
    Callback = function(v) getgenv().DZ_Engineer.FOV = v end
})

Rayfield:Notify({Title = "BYPASS KERNEL", Content = "ESP inyectado mediante adornos físicos.", Duration = 5})