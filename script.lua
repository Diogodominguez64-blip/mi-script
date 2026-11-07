--[[
    Hypershot Menu - v6 (Reescritura completa)
    Desarrollador: 30 años de experiencia en Lua/Roblox.
    Enfoque: Silent Aim por table-scan, ESP sobre "Entities", UI oscura moderna.
    
    ¿Cómo funciona Hypershot?
    - Los jugadores y bots están en Workspace.Entities (carpeta).
    - El disparo se envía por un RemoteEvent con argumentos (string, table).
    - La tabla contiene la dirección (Vector3) o el objetivo (CFrame/Ray).
    - El silent aim debe reescribir esos valores DENTRO de la tabla.
    - El aimbot de cámara es independiente y usa CFrame:Lerp.
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- CONFIGURACIÓN
-- ============================================================
local Config = {
    -- Aimbot
    AimEnabled = false,
    AimMode = "Silent", -- "Silent" | "Camera"
    AimFOV = 250,
    AimSmooth = 12,
    AimPart = "Head",
    AimTeamCheck = true,
    AimWallCheck = false,
    AimHold = false,
    
    -- ESP
    EspEnabled = true,
    EspName = true,
    EspDistance = true,
    EspHealth = true,
    EspBox = true,
    EspMaxDist = 600,
    
    -- Misc
    SilentEnabled = true, -- Interruptor maestro del silent
    CameraEnabled = false, -- Aimbot de cámara separado
    FOVCircle = true,
}

local Colors = {
    Bg = Color3.fromRGB(15, 15, 20),
    Panel = Color3.fromRGB(25, 25, 32),
    Accent = Color3.fromRGB(0, 255, 180), -- Neón verde
    Text = Color3.fromRGB(240, 240, 245),
    Dim = Color3.fromRGB(140, 140, 155),
    Off = Color3.fromRGB(60, 60, 75),
    EspPlayer = Color3.fromRGB(0, 255, 180),
    EspBot = Color3.fromRGB(255, 160, 50),
}

-- ============================================================
-- UTILIDADES
-- ============================================================
local function Create(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props) do
        obj[k] = v
    end
    if parent then obj.Parent = parent end
    return obj
end

local function Corner(obj, radius)
    return Create("UICorner", { CornerRadius = UDim.new(0, radius or 6) }, obj)
end

local function Stroke(obj, color, thickness, transparency)
    return Create("UIStroke", {
        Color = color or Colors.Accent,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    }, obj)
end

-- ============================================================
-- UI PRINCIPAL
-- ============================================================
local ScreenGui = Create("ScreenGui", {
    Name = "HS_Menu_v6",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 9999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
pcall(function() if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end end)
ScreenGui.Parent = game:GetService("CoreGui")

-- Botón flotante
local ToggleBtn = Create("TextButton", {
    Size = UDim2.new(0, 50, 0, 50),
    Position = UDim2.new(0, 20, 0.5, -25),
    BackgroundColor3 = Colors.Bg,
    Text = "HS",
    TextColor3 = Colors.Accent,
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    AutoButtonColor = false,
    Parent = ScreenGui,
})
Corner(ToggleBtn, 25)
Stroke(ToggleBtn, Colors.Accent, 2)

-- Panel
local Panel = Create("Frame", {
    Size = UDim2.new(0, 300, 0, 500),
    Position = UDim2.new(0, 80, 0.5, -250),
    BackgroundColor3 = Colors.Bg,
    Visible = false,
    Parent = ScreenGui,
})
Corner(Panel, 12)
Stroke(Panel, Color3.fromRGB(50, 50, 65), 1)

local Header = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = Colors.Panel,
    Parent = Panel,
})
Corner(Header, 12)
Create("TextLabel", {
    Size = UDim2.new(1, -20, 1, 0),
    Position = UDim2.new(0, 15, 0, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = Colors.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
    Text = "Hypershot v6",
    Parent = Header,
})

local CloseBtn = Create("TextButton", {
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -35, 0.5, -15),
    BackgroundColor3 = Colors.Bg,
    Text = "×",
    TextColor3 = Colors.Dim,
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    AutoButtonColor = false,
    Parent = Header,
})
Corner(CloseBtn, 6)

local Content = Create("ScrollingFrame", {
    Size = UDim2.new(1, -20, 1, -60),
    Position = UDim2.new(0, 10, 0, 50),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Parent = Panel,
})
Create("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, Content)

-- Widgets
local function AddSection(text)
    local lbl = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = Colors.Dim,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = text,
        Parent = Content,
    })
    return lbl
end

local function AddToggle(text, default, callback)
    local btn = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Colors.Panel,
        AutoButtonColor = false,
        Text = "",
        Parent = Content,
    })
    Corner(btn, 6)
    Create("TextLabel", {
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = text,
        Parent = btn,
    })
    local knob = Create("Frame", {
        Size = UDim2.new(0, 36, 0, 18),
        Position = UDim2.new(1, -48, 0.5, -9),
        BackgroundColor3 = default and Colors.Accent or Colors.Off,
        Parent = btn,
    })
    Corner(knob, 9)
    local dot = Create("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = knob,
    })
    Corner(dot, 7)
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        knob.BackgroundColor3 = state and Colors.Accent or Colors.Off
        dot.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        callback(state)
    end)
    return btn
end

local function AddSlider(text, min, max, default, callback)
    local frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = Colors.Panel,
        Parent = Content,
    })
    Corner(frame, 6)
    local label = Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 12, 0, 2),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = text .. "  " .. tostring(default),
        Parent = frame,
    })
    local track = Create("Frame", {
        Size = UDim2.new(1, -24, 0, 4),
        Position = UDim2.new(0, 12, 1, -14),
        BackgroundColor3 = Colors.Off,
        Parent = frame,
    })
    Corner(track, 2)
    local fill = Create("Frame", {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Colors.Accent,
        Parent = track,
    })
    Corner(fill, 2)
    local value = default
    local dragging = false
    
    local function update(px)
        local abs = track.AbsolutePosition.X
        local size = track.AbsoluteSize.X
        local alpha = math.clamp((px - abs) / size, 0, 1)
        local val = math.floor(min + (max - min) * alpha + 0.5)
        if val ~= value then
            value = val
            fill.Size = UDim2.new(alpha, 0, 1, 0)
            label.Text = text .. "  " .. tostring(value)
            callback(value)
        end
    end
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input.Position.X)
        end
    end)
    track.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input.Position.X)
        end
    end)
    return frame
end

-- ============================================================
-- SISTEMA DE DETECCIÓN DE ENTIDADES Y REMOTOS
-- ============================================================
local Targets = {}
local ESP_Cache = {}
local SilentTarget = nil
local CameraTarget = nil

-- Obtiene la parte de impacto de un modelo (Head, Hitbox, etc.)
local function GetHitPart(model)
    if not model then return nil end
    local part = model:FindFirstChild(Config.AimPart)
    if part and part:IsA("BasePart") then return part end
    -- Fallback a Head o HumanoidRootPart
    for _, name in ipairs({"Head", "Hitbox", "HumanoidRootPart", "Torso"}) do
        local p = model:FindFirstChild(name)
        if p and p:IsA("BasePart") then return p end
    end
    -- Buscar en hijos directos
    for _, child in ipairs(model:GetChildren()) do
        if child:IsA("BasePart") then return child end
    end
    return nil
end

-- Verifica si el modelo está vivo
local function IsAlive(model)
    if not model or not model.Parent then return false end
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if humanoid.Health <= 0 then return false end
    end
    return true
end

-- Escanea Workspace.Entities y jugadores
local function CollectTargets()
    local list = {}
    local entitiesFolder = Workspace:FindFirstChild("Entities")
    
    -- Escanear Entities (bots y jugadores)
    if entitiesFolder then
        for _, child in ipairs(entitiesFolder:GetChildren()) do
            if child:IsA("Model") and IsAlive(child) then
                local part = GetHitPart(child)
                if part then
                    table.insert(list, { model = child, part = part, kind = "entity" })
                end
            end
        end
    end
    
    -- Escanear jugadores directamente en Workspace (por si acaso)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and IsAlive(plr.Character) then
            local part = GetHitPart(plr.Character)
            if part then
                table.insert(list, { model = plr.Character, part = part, kind = "player" })
            end
        end
    end
    
    return list
end

-- Proyecta los objetivos a la pantalla
local function ProjectTargets(list)
    local cam = Workspace.CurrentCamera
    if not cam then return list end
    for _, t in ipairs(list) do
        local pos = t.part.Position
        local screenPos, onScreen = cam:WorldToScreenPoint(pos)
        t.distance = (pos - cam.CFrame.Position).Magnitude
        t.screenPos = onScreen and Vector2.new(screenPos.X, screenPos.Y) or nil
        t.onScreen = onScreen and screenPos.Z > 0
    end
    return list
end

-- Selecciona el mejor objetivo dentro del FOV
local function PickTarget(list, origin)
    local best, bestDist = nil, math.huge
    for _, t in ipairs(list) do
        if t.onScreen and t.distance <= 1000 then -- Límite de distancia
            local dist = (t.screenPos - origin).Magnitude
            if dist <= Config.AimFOV and dist < bestDist then
                -- Verificar equipo si es jugador
                if t.kind == "player" and Config.AimTeamCheck then
                    if Players:GetPlayerFromCharacter(t.model) and Players:GetPlayerFromCharacter(t.model).Team == LocalPlayer.Team then
                        continue
                    end
                end
                -- Verificar pared si está activado
                if Config.AimWallCheck then
                    local ray = Ray.new(Workspace.CurrentCamera.CFrame.Position, (t.part.Position - Workspace.CurrentCamera.CFrame.Position).Unit * t.distance)
                    local hit = Workspace:FindPartOnRay(ray, LocalPlayer.Character)
                    if hit and not hit:IsDescendantOf(t.model) then
                        continue
                    end
                end
                best, bestDist = t, dist
            end
        end
    end
    return best
end

-- ============================================================
-- SILENT AIM: HOOK DE TABLA PROFUNDA
-- ============================================================
local SilentConnection = nil
local OriginalNamecall = nil

local function IsShootRemote(name)
    local lower = string.lower(name)
    return lower:find("shoot") or lower:find("fire") or lower:find("hit") or lower:find("attack") or lower:find("bullet")
end

local function RetargetTable(tbl)
    if type(tbl) ~= "table" then return false end
    local changed = false
    local targetPos = SilentTarget and SilentTarget.part.Position
    
    for k, v in pairs(tbl) do
        local t = typeof(v)
        if t == "Vector3" then
            if v.Magnitude > 0.5 and v.Magnitude < 1.5 then
                -- Es una dirección unitaria, reemplazar por dirección al objetivo
                if targetPos then
                    local dir = (targetPos - Workspace.CurrentCamera.CFrame.Position).Unit
                    tbl[k] = dir
                    changed = true
                end
            elseif targetPos then
                -- Es una posición, reemplazar por la posición del objetivo
                tbl[k] = targetPos
                changed = true
            end
        elseif t == "CFrame" then
            if targetPos then
                tbl[k] = CFrame.lookAt(v.Position, targetPos)
                changed = true
            end
        elseif t == "Ray" then
            if targetPos then
                local dir = (targetPos - v.Origin).Unit
                tbl[k] = Ray.new(v.Origin, dir * math.max(v.Direction.Magnitude, 100))
                changed = true
            end
        end
    end
    return changed
end

local function SetupSilentAim()
    if SilentConnection then return end
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" or method == "InvokeServer" then
            -- Verificar si el remoto es de disparo
            if self:IsA("RemoteEvent") and IsShootRemote(self.Name) then
                if Config.SilentEnabled and SilentTarget then
                    local args = {...}
                    local changed = false
                    for i = 1, #args do
                        local arg = args[i]
                        if type(arg) == "table" then
                            if RetargetTable(arg) then changed = true end
                        elseif typeof(arg) == "Vector3" then
                            -- Vector3 directo (dirección o posición)
                            if arg.Magnitude > 0.5 and arg.Magnitude < 1.5 then
                                local dir = (SilentTarget.part.Position - Workspace.CurrentCamera.CFrame.Position).Unit
                                args[i] = dir
                                changed = true
                            else
                                args[i] = SilentTarget.part.Position
                                changed = true
                            end
                        elseif typeof(arg) == "CFrame" then
                            args[i] = CFrame.lookAt(arg.Position, SilentTarget.part.Position)
                            changed = true
                        elseif typeof(arg) == "Ray" then
                            local dir = (SilentTarget.part.Position - arg.Origin).Unit
                            args[i] = Ray.new(arg.Origin, dir * math.max(arg.Direction.Magnitude, 100))
                            changed = true
                        end
                    end
                    if changed then
                        return oldNamecall(self, unpack(args))
                    end
                end
            end
        end
        return oldNamecall(self, ...)
    end)
    SilentConnection = true
end

local function RemoveSilentAim()
    if SilentConnection then
        -- Restaurar el metamétodo original
        if OriginalNamecall then
            pcall(function()
                getrawmetatable(game).__namecall = OriginalNamecall
            end)
        end
        SilentConnection = false
    end
end

-- ============================================================
-- AIMBOT DE CÁMARA (INDEPENDIENTE)
-- ============================================================
local CameraConnection = nil
local function UpdateCameraAim()
    if not Config.CameraEnabled or not CameraTarget then return end
    local cam = Workspace.CurrentCamera
    local targetPos = CameraTarget.part.Position
    local goal = CFrame.lookAt(cam.CFrame.Position, targetPos)
    cam.CFrame = cam.CFrame:Lerp(goal, math.clamp(RunService.RenderStepped:Wait() * Config.AimSmooth, 0.05, 1))
end

-- ============================================================
-- ESP
-- ============================================================
local function CreateESP(t)
    local part = t.part
    local model = t.model
    
    local billboard = Create("BillboardGui", {
        Name = "HS_ESP",
        Size = UDim2.new(0, 200, 0, 50),
        StudsOffset = Vector3.new(0, 3, 0),
        AlwaysOnTop = true,
        MaxDistance = Config.EspMaxDist,
        Adornee = part,
        Parent = part,
    })
    
    if Config.EspName then
        Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = t.kind == "player" and Colors.EspPlayer or Colors.EspBot,
            TextStrokeTransparency = 0.5,
            Text = model.Name,
            Parent = billboard,
        })
    end
    
    if Config.EspDistance then
        Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 14),
            Position = UDim2.new(0, 0, 0, 16),
            BackgroundTransparency = 1,
            Font = Enum.Font.Code,
            TextSize = 12,
            TextColor3 = Colors.Text,
            TextStrokeTransparency = 0.5,
            Text = "",
            Name = "DistLabel",
            Parent = billboard,
        })
    end
    
    if Config.EspHealth then
        local barBg = Create("Frame", {
            Size = UDim2.new(1, -40, 0, 6),
            Position = UDim2.new(0, 20, 0, 32),
            BackgroundColor3 = Color3.fromRGB(40, 40, 45),
            Parent = billboard,
        })
        Corner(barBg, 3)
        local barFill = Create("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Colors.Accent,
            Name = "HealthFill",
            Parent = barBg,
        })
        Corner(barFill, 3)
    end
    
    if Config.EspBox then
        local box = Create("Frame", {
            Size = UDim2.new(0, 40, 0, 60),
            BackgroundTransparency = 1,
            Parent = billboard,
        })
        Stroke(box, t.kind == "player" and Colors.EspPlayer or Colors.EspBot, 1.5)
    end
    
    return billboard
end

local function UpdateESP(list)
    -- Limpiar ESPs viejos
    for model, gui in pairs(ESP_Cache) do
        if not model.Parent or not table.find(list, model) then
            gui:Destroy()
            ESP_Cache[model] = nil
        end
    end
    
    -- Crear/actualizar ESPs
    for _, t in ipairs(list) do
        if t.distance <= Config.EspMaxDist then
            local gui = ESP_Cache[t.model]
            if not gui or not gui.Parent then
                gui = CreateESP(t)
                ESP_Cache[t.model] = gui
            end
            
            -- Actualizar distancia
            local distLabel = gui:FindFirstChild("DistLabel", true)
            if distLabel then
                distLabel.Text = string.format("%d m", math.floor(t.distance))
            end
            
            -- Actualizar salud
            local healthFill = gui:FindFirstChild("HealthFill", true)
            if healthFill then
                local humanoid = t.model:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    local frac = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                    healthFill.Size = UDim2.new(frac, 0, 1, 0)
                    healthFill.BackgroundColor3 = frac > 0.5 and Colors.Accent or (frac > 0.2 and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(255, 50, 50))
                end
            end
        end
    end
end

-- ============================================================
-- LOOP PRINCIPAL
-- ============================================================
RunService.RenderStepped:Connect(function(dt)
    -- Actualizar objetivos
    Targets = CollectTargets()
    ProjectTargets(Targets)
    
    -- Origen del FOV (centro de la pantalla)
    local cam = Workspace.CurrentCamera
    local viewport = cam.ViewportSize
    local origin = Vector2.new(viewport.X / 2, viewport.Y / 2)
    
    -- Seleccionar objetivo para silent y cámara
    local bestTarget = PickTarget(Targets, origin)
    SilentTarget = bestTarget
    CameraTarget = bestTarget
    
    -- Actualizar ESP
    if Config.EspEnabled then
        UpdateESP(Targets)
    else
        for model, gui in pairs(ESP_Cache) do
            gui:Destroy()
            ESP_Cache[model] = nil
        end
    end
    
    -- Actualizar aimbot de cámara
    if Config.CameraEnabled and CameraTarget then
        local goal = CFrame.lookAt(cam.CFrame.Position, CameraTarget.part.Position)
        cam.CFrame = cam.CFrame:Lerp(goal, math.clamp(dt * Config.AimSmooth, 0.05, 1))
    end
end)

-- ============================================================
-- PANEL: CONSTRUCCIÓN
-- ============================================================
AddSection("AIMBOT")
AddToggle("Enable Aimbot", Config.AimEnabled, function(v)
    Config.AimEnabled = v
    Config.SilentEnabled = v
    Config.CameraEnabled = (Config.AimMode == "Camera")
end)
AddToggle("Silent Aim", Config.SilentEnabled, function(v)
    Config.SilentEnabled = v
    if v then
        SetupSilentAim()
    else
        RemoveSilentAim()
    end
end)
AddToggle("Camera Aim", Config.CameraEnabled, function(v)
    Config.CameraEnabled = v
end)
AddSlider("FOV Radius", 50, 600, Config.AimFOV, function(v)
    Config.AimFOV = v
end)
AddSlider("Smooth", 1, 30, Config.AimSmooth, function(v)
    Config.AimSmooth = v
end)
AddToggle("Team Check", Config.AimTeamCheck, function(v)
    Config.AimTeamCheck = v
end)
AddToggle("Wall Check", Config.AimWallCheck, function(v)
    Config.AimWallCheck = v
end)

AddSection("ESP")
AddToggle("Enable ESP", Config.EspEnabled, function(v)
    Config.EspEnabled = v
end)
AddToggle("Show Names", Config.EspName, function(v)
    Config.EspName = v
end)
AddToggle("Show Distance", Config.EspDistance, function(v)
    Config.EspDistance = v
end)
AddToggle("Show Health", Config.EspHealth, function(v)
    Config.EspHealth = v
end)
AddToggle("Show Box", Config.EspBox, function(v)
    Config.EspBox = v
end)
AddSlider("ESP Max Distance", 100, 1500, Config.EspMaxDist, function(v)
    Config.EspMaxDist = v
end)

AddSection("DIAGNÓSTICO")
local function AddButton(text, callback)
    local btn = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Colors.Panel,
        AutoButtonColor = false,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = Colors.Text,
        Text = text,
        Parent = Content,
    })
    Corner(btn, 6)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

AddButton("Dump Remotes", function()
    print("=== REMOTES ===")
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            print(obj:GetFullName())
        end
    end
end)

AddButton("Print Target Info", function()
    print("Targets:", #Targets)
    for _, t in ipairs(Targets) do
        print(t.model.Name, t.distance, t.onScreen)
    end
end)

-- Iniciar silent aim por defecto
if Config.SilentEnabled then
    SetupSilentAim()
end

-- ============================================================
-- EVENTOS DE UI
-- ============================================================
ToggleBtn.MouseButton1Click:Connect(function()
    Panel.Visible = not Panel.Visible
    ToggleBtn.Text = Panel.Visible and "<" or "HS"
end)

CloseBtn.MouseButton1Click:Connect(function()
    Panel.Visible = false
    ToggleBtn.Text = "HS"
end)

-- Arrastrar panel
local dragging, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Panel.Position
    end
end)
Header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

print("[HS v6] Cargado. Silent aim listo.")
