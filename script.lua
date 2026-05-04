--[[
    UNIVERSAL COMBAT FRAMEWORK v2.0
    Consolidated Aimbot + ESP System
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--! CONFIGURACIÓN MAESTRA
local Settings = {
    Aimbot = {
        Enabled = true,
        Mode = "Camera", -- "Camera", "Mouse", "Silent"
        TargetPart = "HumanoidRootPart",
        Bind = Enum.UserInputType.MouseButton2,
        
        -- Dinámica de Apuntado
        Smoothness = 0.25, -- 0 a 1 (Menor es más suave)
        Prediction = 0.165,
        FieldOfView = 150,
        
        -- Filtros de Seguridad
        TeamCheck = true,
        WallCheck = true,
        AliveCheck = true,
    },
    ESP = {
        Enabled = true,
        Boxes = true,
        Names = true,
        Tracers = false,
        TeamColor = true,
        MaxDistance = 1000,
    }
}

--! ESTADO DEL SISTEMA
local State = {
    IsAiming = false,
    CurrentTarget = nil,
    Objects = {}
}

--! LÓGICA DE VERIFICACIÓN (CHECK SYSTEM)
local function GetTargetStatus(Character)
    if not Character then return false end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character:FindFirstChild(Settings.Aimbot.TargetPart)
    local TargetPlayer = Players:GetPlayerFromCharacter(Character)

    if not (Humanoid and RootPart and TargetPlayer) then return false end
    if Settings.Aimbot.AliveCheck and Humanoid.Health <= 0 then return false end
    if Settings.Aimbot.TeamCheck and TargetPlayer.Team == LocalPlayer.Team then return false end

    -- Verificación de Visibilidad (Wall Check)
    if Settings.Aimbot.WallCheck then
        local Params = RaycastParams.new()
        Params.FilterType = Enum.RaycastFilterType.Exclude
        Params.FilterDescendantsInstances = {LocalPlayer.Character, Character}
        
        local Direction = RootPart.Position - Camera.CFrame.Position
        local Result = workspace:Raycast(Camera.CFrame.Position, Direction, Params)
        
        if Result then return false end
    end

    -- Verificación de FOV
    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)
    if not OnScreen then return false end
    
    local MousePos = UserInputService:GetMouseLocation()
    local DistanceToMouse = (Vector2.new(ScreenPos.X, ScreenPos.Y) - MousePos).Magnitude
    
    if DistanceToMouse > Settings.Aimbot.FieldOfView then return false end

    return true, RootPart, DistanceToMouse
end

--! LÓGICA DEL AIMBOT
local function GetClosestPlayer()
    local ClosestDistance = math.huge
    local TargetPart = nil

    for _, p in next, Players:GetPlayers() do
        if p ~= LocalPlayer then
            local isValid, part, dist = GetTargetStatus(p.Character)
            if isValid and dist < ClosestDistance then
                ClosestDistance = dist
                TargetPart = part
            end
        end
    end
    return TargetPart
end

--! SISTEMA ESP (DIBUJO VECTORIAL)
local function CreateESP(player)
    local Box = Drawing.new("Square")
    local Name = Drawing.new("Text")
    
    local function Update()
        local Connection
        Connection = RunService.RenderStepped:Connect(function()
            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not Settings.ESP.Enabled then
                Box.Visible = false
                Name.Visible = false
                if not player.Parent then Connection:Disconnect() end
                return
            end

            local Root = player.Character.HumanoidRootPart
            local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
            
            if OnScreen then
                Box.Size = Vector2.new(2500 / Pos.Z, 3500 / Pos.Z)
                Box.Position = Vector2.new(Pos.X - Box.Size.X / 2, Pos.Y - Box.Size.Y / 2)
                Box.Color = player.TeamColor.Color
                Box.Visible = Settings.ESP.Boxes

                Name.Text = player.Name
                Name.Position = Vector2.new(Box.Position.X + Box.Size.X / 2, Box.Position.Y - 15)
                Name.Visible = Settings.ESP.Names
                Name.Center = true
                Name.Outline = true
            else
                Box.Visible = false
                Name.Visible = false
            end
        end)
    end
    coroutine.wrap(Update)()
end

--! ENLACE DE ENTRADAS
UserInputService.InputBegan:Connect(function(i)
    if i.UserInputType == Settings.Aimbot.Bind then State.IsAiming = true end
end)

UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Settings.Aimbot.Bind then State.IsAiming = false end
end)

--! BUCLE DE RENDERIZADO (EJECUCIÓN)
RunService.RenderStepped:Connect(function()
    if Settings.Aimbot.Enabled and State.IsAiming then
        local Target = GetClosestPlayer()
        if Target then
            local TargetPos = Target.Position + (Target.Velocity * Settings.Aimbot.Prediction)
            
            if Settings.Aimbot.Mode == "Camera" then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, TargetPos), Settings.Aimbot.Smoothness)
            end
        end
    end
end)

-- Inicializar ESP para jugadores actuales y futuros
for _, p in next, Players:GetPlayers() do if p ~= LocalPlayer then CreateESP(p) end end
Players.PlayerAdded:Connect(CreateESP)

print("Combat Framework Loaded Successfully.")