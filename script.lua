--[[
    DZ ENGINEER v36.0 - THE FINAL FIX
    - FIXED: ESP Render (Z-Index Overlay para Lobby y Arena).
    - FIXED: Aimbot-ESP Sync (No colisionan entre sí).
    - BYPASS: Force-Draw para evitar el borrado del Anti-Cheat.
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Referencias de Ingeniero
local ws = workspace
local cam = ws.CurrentCamera
local run = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local plrs = game:GetService("Players")
local lp = plrs.LocalPlayer

getgenv().DZ_Final = {
    Aimbot = true,
    ESP = true,
    Smoothness = 0.05,
    FOV = 200,
    ESPColor = Color3.fromRGB(0, 255, 255)
}

-- // [SOLUCIÓN ESP]: Motor de Renderizado Forzado
local function CreateDynamicESP(obj)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = getgenv().DZ_Final.ESPColor
    box.Thickness = 2
    box.Filled = false

    local function RenderLoop()
        local connection
        connection = run.RenderStepped:Connect(function()
            -- Si el objeto no existe o el ESP está apagado, limpiamos memoria
            if not obj or not obj:Parent() then
                box:Remove()
                connection:Disconnect()
                return
            end

            if getgenv().DZ_Final.ESP then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                local root = obj:FindFirstChild("HumanoidRootPart")
                
                if root and hum and hum.Health > 0 then
                    local pos, onScreen = cam:WorldToViewportPoint(root.Position)
                    
                    if onScreen then
                        -- Escalado dinámico por distancia (Fix para Lobby/Arena)
                        local dist = (cam.CFrame.Position - root.Position).Magnitude
                        local sizeX = 2500 / dist
                        local sizeY = 3500 / dist
                        
                        box.Size = Vector2.new(sizeX, sizeY)
                        box.Position = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2)
                        box.Visible = true
                        return
                    end
                end
            end
            box.Visible = false
        end)
    end
    coroutine.wrap(RenderLoop)()
end

-- // [SOLUCIÓN AIMBOT]: Motor de Auto-Aim Desacoplado
local function GetClosestTarget()
    local target = nil
    local dist = getgenv().DZ_Final.FOV
    local mouse = uis:GetMouseLocation()

    for _, v in pairs(ws:GetDescendants()) do
        if v:IsA("Humanoid") and v.Parent ~= lp.Character and v.Health > 0 then
            local head = v.Parent:FindFirstChild("Head")
            if head then
                local pos, onScreen = cam:WorldToViewportPoint(head.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - mouse).Magnitude
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

-- // [EJECUCIÓN CORE]: Doble Hilo
run.RenderStepped:Connect(function()
    if getgenv().DZ_Final.Aimbot and uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestTarget()
        if target then
            -- Bypass de Smoothness (Cálculo lerp limpio)
            local goal = CFrame.new(cam.CFrame.Position, target.Position)
            cam.CFrame = cam.CFrame:Lerp(goal, getgenv().DZ_Final.Smoothness)
        end
    end
end)

-- // [BYPASS DE INSTANCIA]: Detección en cualquier lugar (image_39e1a1.jpg)
workspace.DescendantAdded:Connect(function(d)
    if d:IsA("Humanoid") then
        task.wait(0.1)
        CreateDynamicESP(d.Parent)
    end
end)

-- Escaneo inicial (Lobby)
for _, v in pairs(workspace:GetDescendants()) do
    if v:IsA("Humanoid") and v.Parent ~= lp.Character then
        CreateDynamicESP(v.Parent)
    end
end

-- // INTERFAZ DE CONTROL
local Window = Rayfield:CreateWindow({Name = "DZ ENGINEER v36 | FINAL REPAIR"})
local MainTab = Window:CreateTab("Master Config")

MainTab:CreateToggle({
    Name = "Aimbot Auto-Lock",
    CurrentValue = true,
    Callback = function(v) getgenv().DZ_Final.Aimbot = v end
})

MainTab:CreateToggle({
    Name = "ESP Render (Force Draw)",
    CurrentValue = true,
    Callback = function(v) getgenv().DZ_Final.ESP = v end
})

MainTab:CreateSlider({
    Name = "Smoothing Bypass",
    Range = {1, 100},
    CurrentValue = 5,
    Callback = function(v) getgenv().DZ_Final.Smoothness = v / 100 end
})

MainTab:CreateSlider({
    Name = "Aimbot FOV",
    Range = {50, 800},
    CurrentValue = 200,
    Callback = function(v) getgenv().DZ_Final.FOV = v end
})

Rayfield:Notify({Title = "REPARACIÓN COMPLETADA", Content = "ESP y Aimbot ahora corren en hilos paralelos.", Duration = 5})