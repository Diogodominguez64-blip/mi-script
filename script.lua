-- ==========================================
-- DZ STORE V4 - Neo-Green Framework (PRO)
-- Version: 4.1 (Device Detection, Custom Keybinds, Fixed TP)
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera or workspace:WaitForChild("Camera")
local LocalPlayer = Players.LocalPlayer

local Theme = {
    Background = Color3.fromRGB(18, 18, 22),
    PanelBg = Color3.fromRGB(25, 25, 30),
    NeonGreen = Color3.fromRGB(57, 255, 20),
    TextWhite = Color3.fromRGB(245, 245, 245),
    TextDim = Color3.fromRGB(150, 150, 150),
    ButtonBg = Color3.fromRGB(35, 35, 42),
    Separator = Color3.fromRGB(40, 40, 48)
}

-- Detección de Dispositivo
local isPC = UserInputService.KeyboardEnabled
local isBinding = false

-- Configuraciones base
local Aimbot = { enabled = false, fov = 150, smoothness = 70, teamCheck = false, wallCheck = false, showFov = true, silentAim = false }
local ESP = { nameEnabled = false, skeletonEnabled = false, lineEnabled = false, maxDistance = 3000 }
local Teleport = { autoTpEnabled = false, distanceBehind = 3 }
local NoRecoil = { enabled = false }

-- Sistema de Teclas Asignables (Keybinds)
local Keybinds = {
    MenuToggle = Enum.KeyCode.RightShift, -- Tecla por defecto para el menú
    Aimbot_enabled = nil,
    Aimbot_silentAim = nil,
    Teleport_autoTpEnabled = nil,
    NoRecoil_enabled = nil,
    ESP_nameEnabled = nil,
    ESP_lineEnabled = nil,
    ESP_skeletonEnabled = nil
}

-- Referencias a los botones UI para sincronización
local ToggleUIElements = {}

-- ==========================================
-- FOV & NOTIFICATIONS
-- ==========================================
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Theme.NeonGreen
fovCircle.Thickness = 1.5
fovCircle.NumSides = 64
fovCircle.Radius = Aimbot.fov
fovCircle.Filled = false
fovCircle.Visible = false

pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "DZ STORE V4",
        Text = isPC and "Cargado. Usa RightShift para ocultar." or "Cargado. Usa el botón flotante.",
        Duration = 5
    })
end)

-- ==========================================
-- LOGIC UTILITIES & TP FIX
-- ==========================================
local function IsValidTarget(player, ignoreWall)
    if player == LocalPlayer then return false end
    local char = player.Character
    if not char or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then return false end
    if Aimbot.teamCheck and player.Team == LocalPlayer.Team then return false end
    if not ignoreWall and Aimbot.wallCheck then
        local targetBone = char:FindFirstChild("HumanoidRootPart")
        if targetBone then
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {LocalPlayer.Character}
            params.FilterType = Enum.RaycastFilterType.Exclude
            local result = workspace:Raycast(Camera.CFrame.Position, targetBone.Position - Camera.CFrame.Position, params)
            if result and not result.Instance:IsDescendantOf(char) then return false end
        end
    end
    return true
end

local function GetClosestPlayerToCursor()
    local closest, minDistance = nil, Aimbot.fov
    for _, p in ipairs(Players:GetPlayers()) do
        if IsValidTarget(p, false) then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local dist = (Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2) - Vector2.new(pos.X, pos.Y)).Magnitude
                    if dist < minDistance then minDistance = dist; closest = p end
                end
            end
        end
    end
    return closest
end

local function GetClosestPlayerDistance()
    local closest, minDist = nil, math.huge
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if IsValidTarget(p, true) then -- TP ignora paredes para buscar
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local dist = (myRoot.Position - root.Position).Magnitude
                if dist < minDist then minDist = dist; closest = p end
            end
        end
    end
    return closest
end

local ESP_Drawings = {}
local function ClearPlayerESP(player)
    if ESP_Drawings[player] then
        ESP_Drawings[player].Line:Remove(); ESP_Drawings[player].Name:Remove()
        for _, obj in pairs(ESP_Drawings[player].Skeleton) do obj.line:Remove() end
        ESP_Drawings[player] = nil
    end
end
Players.PlayerRemoving:Connect(ClearPlayerESP)

local function createDrawings(player)
    local d = { Line = Drawing.new("Line"), Name = Drawing.new("Text"), Skeleton = {} }
    d.Line.Thickness = 1.5; d.Line.Color = Theme.NeonGreen; d.Name.Size = 16; d.Name.Color = Theme.NeonGreen; d.Name.Center = true; d.Name.Outline = true
    local bones = {{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}}
    for i, _ in ipairs(bones) do
        local l = Drawing.new("Line"); l.Thickness = 1.5; l.Color = Color3.new(1,1,1); d.Skeleton[i] = {line = l, parts = bones[i]}
    end
    ESP_Drawings[player] = d
end

-- ==========================================
-- UI FRAMEWORK V4
-- ==========================================
local ScreenGui = Instance.new("ScreenGui", CoreGui or LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "DZ_STORE_V4"
ScreenGui.ResetOnSpawn = false

-- Botón Flotante para ocultar/mostrar menú
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(1, -70, 0, 30)
ToggleBtn.BackgroundColor3 = Theme.PanelBg
ToggleBtn.Text = "V4"
ToggleBtn.Font = Enum.Font.GothamBlack
ToggleBtn.TextSize = 16
ToggleBtn.TextColor3 = Theme.NeonGreen
ToggleBtn.BorderSizePixel = 0
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
ToggleStroke.Thickness = 2
ToggleStroke.Color = Theme.NeonGreen

local MainContainer = Instance.new("Frame", ScreenGui)
MainContainer.Size = UDim2.new(0, 540, 0, 360)
MainContainer.Position = UDim2.new(0.5, -270, 0.5, -180)
MainContainer.BackgroundTransparency = 1

ToggleBtn.MouseButton1Click:Connect(function() MainContainer.Visible = not MainContainer.Visible end)

-- Sidebar
local Sidebar = Instance.new("Frame", MainContainer)
Sidebar.Size = UDim2.new(0, 160, 1, 0)
Sidebar.BackgroundColor3 = Theme.Background
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local TitleLabel = Instance.new("TextLabel", Sidebar)
TitleLabel.Size = UDim2.new(1, 0, 0, 45)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "DZ STORE V4"
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextSize = 16
TitleLabel.TextColor3 = Theme.NeonGreen

local SidebarLine = Instance.new("Frame", Sidebar)
SidebarLine.Size = UDim2.new(1, 0, 0, 1)
SidebarLine.Position = UDim2.new(0, 0, 0, 45)
SidebarLine.BackgroundColor3 = Theme.NeonGreen
SidebarLine.BorderSizePixel = 0

local TabContainer = Instance.new("ScrollingFrame", Sidebar)
TabContainer.Size = UDim2.new(1, 0, 1, -50)
TabContainer.Position = UDim2.new(0, 0, 0, 50)
TabContainer.BackgroundTransparency = 1
TabContainer.ScrollBarThickness = 0
local TabListLayout = Instance.new("UIListLayout", TabContainer)
TabListLayout.Padding = UDim.new(0, 5)

-- Content Panel
local ContentPanel = Instance.new("Frame", MainContainer)
ContentPanel.Size = UDim2.new(0, 370, 1, 0)
ContentPanel.Position = UDim2.new(0, 170, 0, 0)
ContentPanel.BackgroundColor3 = Theme.Background
ContentPanel.BorderSizePixel = 0
Instance.new("UICorner", ContentPanel).CornerRadius = UDim.new(0, 8)

local ContentHeader = Instance.new("TextLabel", ContentPanel)
ContentHeader.Size = UDim2.new(1, -30, 0, 45)
ContentHeader.Position = UDim2.new(0, 15, 0, 0)
ContentHeader.BackgroundTransparency = 1
ContentHeader.Text = "Dashboard"
ContentHeader.Font = Enum.Font.GothamSemibold
ContentHeader.TextSize = 14
ContentHeader.TextColor3 = Theme.NeonGreen
ContentHeader.TextXAlignment = Enum.TextXAlignment.Left

local ContentLine = Instance.new("Frame", ContentPanel)
ContentLine.Size = UDim2.new(1, 0, 0, 1)
ContentLine.Position = UDim2.new(0, 0, 0, 45)
ContentLine.BackgroundColor3 = Theme.Separator
ContentLine.BorderSizePixel = 0

-- UI logic de pestañas
local Tabs, TabFrames = {}, {}
local function SwitchTab(tabName)
    ContentHeader.Text = tabName
    for name, frame in pairs(TabFrames) do frame.Visible = (name == tabName) end
    for name, btn in pairs(Tabs) do
        btn.TextColor3 = (name == tabName) and Theme.NeonGreen or Theme.TextDim
        btn:FindFirstChild("Marker").Visible = (name == tabName)
    end
end

local function CreateTab(name)
    local btn = Instance.new("TextButton", TabContainer)
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, 0)
    btn.BackgroundTransparency = 1
    btn.Text = "  " .. name
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.TextColor3 = Theme.TextDim
    btn.TextXAlignment = Enum.TextXAlignment.Left

    local marker = Instance.new("Frame", btn)
    marker.Name = "Marker"
    marker.Size = UDim2.new(0, 3, 0, 18)
    marker.Position = UDim2.new(0, 5, 0.5, -9)
    marker.BackgroundColor3 = Theme.NeonGreen
    marker.BorderSizePixel = 0
    marker.Visible = false

    local frame = Instance.new("Frame", ContentPanel)
    frame.Size = UDim2.new(1, 0, 1, -50)
    frame.Position = UDim2.new(0, 0, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Visible = false

    Tabs[name] = btn; TabFrames[name] = frame
    btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
    return frame
end

local function CreateColumn(parent, title, xPos)
    local col = Instance.new("Frame", parent)
    col.Size = UDim2.new(0.5, -15, 1, 0)
    col.Position = UDim2.new(xPos, xPos == 0 and 10 or 5, 0, 0)
    col.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", col)
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextColor3 = Theme.TextWhite

    local line = Instance.new("Frame", col)
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0, 25)
    line.BackgroundColor3 = Theme.Separator
    line.BorderSizePixel = 0

    local scroll = Instance.new("ScrollingFrame", col)
    scroll.Size = UDim2.new(1, 0, 1, -35)
    scroll.Position = UDim2.new(0, 0, 0, 35)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 2
    scroll.ScrollBarImageColor3 = Theme.NeonGreen
    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 8)
    return scroll
end

-- ==========================================
-- UI COMPONENTS (Toggle, Slider, Keybind)
-- ==========================================
local function CreateToggle(parent, text, tableRef, key, bindKey)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 32)
    row.BackgroundTransparency = 1

    local btn = Instance.new("TextButton", row)
    btn.Size = isPC and UDim2.new(1, -45, 1, 0) or UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = tableRef[key] and Theme.NeonGreen or Theme.ButtonBg
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextColor3 = tableRef[key] and Color3.fromRGB(10,10,10) or Theme.TextWhite
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    ToggleUIElements[bindKey] = btn -- Para sincronizar cuando se use la tecla

    local function ToggleState()
        tableRef[key] = not tableRef[key]
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = tableRef[key] and Theme.NeonGreen or Theme.ButtonBg,
            TextColor3 = tableRef[key] and Color3.fromRGB(10,10,10) or Theme.TextWhite
        }):Play()
        if key == "showFov" or key == "enabled" then fovCircle.Visible = Aimbot.enabled and Aimbot.showFov end
    end

    btn.MouseButton1Click:Connect(ToggleState)

    -- Sistema de asignación de teclas (Solo si es PC)
    if isPC and bindKey then
        local bindBtn = Instance.new("TextButton", row)
        bindBtn.Size = UDim2.new(0, 40, 1, 0)
        bindBtn.Position = UDim2.new(1, -40, 0, 0)
        bindBtn.BackgroundColor3 = Theme.Separator
        bindBtn.Text = Keybinds[bindKey] and "["..Keybinds[bindKey].Name.."]" or "[+]"
        bindBtn.Font = Enum.Font.Gotham
        bindBtn.TextSize = 10
        bindBtn.TextColor3 = Theme.NeonGreen
        Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0, 6)

        bindBtn.MouseButton1Click:Connect(function()
            if isBinding then return end
            isBinding = true
            bindBtn.Text = "[...]"
            local conn
            conn = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    local keycode = input.KeyCode
                    if keycode == Enum.KeyCode.Escape or keycode == Enum.KeyCode.Backspace then
                        Keybinds[bindKey] = nil
                        bindBtn.Text = "[+]"
                    else
                        Keybinds[bindKey] = keycode
                        bindBtn.Text = "["..keycode.Name.."]"
                    end
                    isBinding = false
                    conn:Disconnect()
                end
            end)
        end)
    end
end

-- Input Maestro para activar las funciones configuradas
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or isBinding or not isPC then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local k = input.KeyCode
        
        if k == Keybinds.MenuToggle then
            MainContainer.Visible = not MainContainer.Visible
            return
        end

        for bindKey, keycode in pairs(Keybinds) do
            if k == keycode then
                local parts = string.split(bindKey, "_")
                local tableStr, varKey = parts[1], parts[2]
                
                local tbl = nil
                if tableStr == "Aimbot" then tbl = Aimbot
                elseif tableStr == "ESP" then tbl = ESP
                elseif tableStr == "Teleport" then tbl = Teleport
                elseif tableStr == "NoRecoil" then tbl = NoRecoil end

                if tbl and varKey then
                    tbl[varKey] = not tbl[varKey]
                    -- Actualizar UI visualmente
                    if ToggleUIElements[bindKey] then
                        local btn = ToggleUIElements[bindKey]
                        btn.BackgroundColor3 = tbl[varKey] and Theme.NeonGreen or Theme.ButtonBg
                        btn.TextColor3 = tbl[varKey] and Color3.fromRGB(10,10,10) or Theme.TextWhite
                    end
                    if varKey == "showFov" or varKey == "enabled" then fovCircle.Visible = Aimbot.enabled and Aimbot.showFov end
                end
            end
        end
    end
end)

local function CreateSlider(parent, text, tableRef, key, min, max)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, 0, 0, 45)
    container.BackgroundTransparency = 1
    
    local lbl = Instance.new("TextLabel", container)
    lbl.Size = UDim2.new(0.7, 0, 0, 15)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextColor3 = Theme.TextDim
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local valLbl = Instance.new("TextLabel", container)
    valLbl.Size = UDim2.new(0.3, 0, 0, 15)
    valLbl.Position = UDim2.new(0.7, 0, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(tableRef[key])
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 11
    valLbl.TextColor3 = Theme.TextWhite
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    
    local track = Instance.new("TextButton", container)
    track.Size = UDim2.new(1, 0, 0, 4)
    track.Position = UDim2.new(0, 0, 0, 30)
    track.BackgroundColor3 = Theme.ButtonBg
    track.Text = ""
    
    local fill = Instance.new("Frame", track)
    local ratio = (tableRef[key] - min) / (max - min)
    fill.Size = UDim2.new(ratio, 0, 1, 0)
    fill.BackgroundColor3 = Theme.NeonGreen
    fill.BorderSizePixel = 0
    
    local isSliding = false
    local function updateSlider(input)
        local pct = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        local val = math.floor(min + (pct * (max - min)))
        tableRef[key] = val
        valLbl.Text = tostring(val)
        if key == "fov" then fovCircle.Radius = val end
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = true; updateSlider(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isSliding = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
end

-- ==========================================
-- POPULATE TABS
-- ==========================================
local TabMain = CreateTab("Main")
local MainLeft = CreateColumn(TabMain, "Combat", 0)
local MainRight = CreateColumn(TabMain, "Extras", 0.5)

CreateToggle(MainLeft, "Habilitar Aimbot", Aimbot, "enabled", "Aimbot_enabled")
CreateToggle(MainLeft, "Silent Aim", Aimbot, "silentAim", "Aimbot_silentAim")
CreateToggle(MainRight, "Auto TP", Teleport, "autoTpEnabled", "Teleport_autoTpEnabled")
CreateToggle(MainRight, "No Recoil", NoRecoil, "enabled", "NoRecoil_enabled")

local TabVis = CreateTab("Visuals")
local VisLeft = CreateColumn(TabVis, "ESP Menu", 0)
local VisRight = CreateColumn(TabVis, "Settings", 0.5)

CreateToggle(VisLeft, "ESP Nombre/Dist", ESP, "nameEnabled", "ESP_nameEnabled")
CreateToggle(VisLeft, "ESP Líneas", ESP, "lineEnabled", "ESP_lineEnabled")
CreateToggle(VisLeft, "ESP Esqueleto", ESP, "skeletonEnabled", "ESP_skeletonEnabled")
CreateToggle(VisRight, "Mostrar FOV", Aimbot, "showFov", nil)
CreateSlider(VisRight, "Radio FOV", Aimbot, "fov", 10, 600)

local TabConf = CreateTab("CONF")
local ConfLeft = CreateColumn(TabConf, "Checks", 0)
local ConfRight = CreateColumn(TabConf, "Ajustes Aim", 0.5)

CreateToggle(ConfLeft, "Team Check", Aimbot, "teamCheck", nil)
CreateToggle(ConfLeft, "Wall Check", Aimbot, "wallCheck", nil)
CreateSlider(ConfRight, "Suavidad Aim", Aimbot, "smoothness", 1, 100)
CreateSlider(ConfRight, "Distancia AutoTP", Teleport, "distanceBehind", 1, 15)

-- Bind especial para abrir/cerrar menú
if isPC then
    local menuBindRow = Instance.new("Frame", ConfLeft)
    menuBindRow.Size = UDim2.new(1, 0, 0, 32)
    menuBindRow.BackgroundTransparency = 1
    
    local lblBind = Instance.new("TextLabel", menuBindRow)
    lblBind.Size = UDim2.new(0.6, 0, 1, 0)
    lblBind.BackgroundTransparency = 1
    lblBind.Text = "Tecla Menú:"
    lblBind.TextColor3 = Theme.TextWhite
    lblBind.Font = Enum.Font.GothamBold
    lblBind.TextSize = 12
    lblBind.TextXAlignment = Enum.TextXAlignment.Left

    local bindBtnMenu = Instance.new("TextButton", menuBindRow)
    bindBtnMenu.Size = UDim2.new(0.4, 0, 1, 0)
    bindBtnMenu.Position = UDim2.new(0.6, 0, 0, 0)
    bindBtnMenu.BackgroundColor3 = Theme.Separator
    bindBtnMenu.Text = "["..Keybinds.MenuToggle.Name.."]"
    bindBtnMenu.Font = Enum.Font.Gotham
    bindBtnMenu.TextSize = 10
    bindBtnMenu.TextColor3 = Theme.NeonGreen
    Instance.new("UICorner", bindBtnMenu).CornerRadius = UDim.new(0, 6)

    bindBtnMenu.MouseButton1Click:Connect(function()
        if isBinding then return end
        isBinding = true
        bindBtnMenu.Text = "[...]"
        local conn
        conn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local keycode = input.KeyCode
                if keycode ~= Enum.KeyCode.Escape and keycode ~= Enum.KeyCode.Backspace then
                    Keybinds.MenuToggle = keycode
                    bindBtnMenu.Text = "["..keycode.Name.."]"
                end
                isBinding = false
                conn:Disconnect()
            end
        end)
    end)
end

SwitchTab("Main")

-- ==========================================
-- DRAGGING LOGIC
-- ==========================================
local dragging, dragInput, dragStart, startPos
Sidebar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainContainer.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
Sidebar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainContainer.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ==========================================
-- MAIN LOOPS
-- ==========================================
local targetLock = nil

RunService.Heartbeat:Connect(function()
    -- Lógica Auto TP Mejorada (Evita Flinging y Glitches de Física)
    if Teleport.autoTpEnabled then
        if not targetLock or not IsValidTarget(targetLock, true) then
            targetLock = GetClosestPlayerDistance() -- Buscar nuevo si muere o nos alejamos mucho
        end

        if targetLock and targetLock.Character then
            local targetRoot = targetLock.Character:FindFirstChild("HumanoidRootPart")
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot and myRoot then
                -- Teletransporta detrás y un poco arriba, anula la velocidad para evitar salir volando
                myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 1.5, Teleport.distanceBehind)
                myRoot.AssemblyLinearVelocity = Vector3.zero 
                myRoot.AssemblyAngularVelocity = Vector3.zero
            end
        end
    else
        targetLock = nil
    end

    -- Silent Aim
    if Aimbot.silentAim then
        local enemy = GetClosestPlayerToCursor()
        if enemy and enemy.Character then
            local hum = enemy.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                local fakeHit = Instance.new("RemoteEvent", LocalPlayer)
                fakeHit.Name = "FakeHit"; fakeHit:FireServer(enemy.Character, hum); fakeHit:Destroy()
            end
        end
    end
    
    -- No Recoil
    if NoRecoil.enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        local handle = tool and tool:FindFirstChildOfClass("BasePart")
        if handle then handle.CFrame = CFrame.new(handle.CFrame.Position, LocalPlayer:GetMouse().Hit.Position) end
    end
end)

RunService.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    -- Aimbot Cursor Logic
    if Aimbot.enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestPlayerToCursor()
        if target and target.Character then
            local targetBone = target.Character:FindFirstChild("HumanoidRootPart") or target.Character:FindFirstChild("Head")
            if targetBone then
                local lerpStep = math.clamp(1 - ((Aimbot.smoothness - 1) / 99), 0.01, 1)
                local targetDir = (targetBone.Position - Camera.CFrame.Position).Unit
                local newLook = Camera.CFrame.LookVector:Lerp(targetDir, lerpStep)
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + newLook)
            end
        end
    end

    -- Render ESP
    for _, player in ipairs(Players:GetPlayers()) do
        if not IsValidTarget(player, true) then ClearPlayerESP(player); continue end
        if not ESP_Drawings[player] then createDrawings(player) end
        
        local drawings = ESP_Drawings[player]
        local char = player.Character
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        local headPart = char:FindFirstChild("Head")
        
        if rootPart and headPart then
            local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            local headPos = Camera:WorldToViewportPoint(headPart.Position + Vector3.new(0, 1.5, 0))
            local dist = (Camera.CFrame.Position - rootPart.Position).Magnitude
            
            if onScreen and dist < ESP.maxDistance then
                if ESP.lineEnabled then
                    drawings.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    drawings.Line.To = Vector2.new(rootPos.X, rootPos.Y)
                    drawings.Line.Visible = true
                else drawings.Line.Visible = false end
                
                if ESP.nameEnabled then
                    drawings.Name.Text = string.format("[%s] [%dm]", player.Name, math.floor(dist))
                    drawings.Name.Position = Vector2.new(headPos.X, headPos.Y - 20)
                    drawings.Name.Visible = true
                else drawings.Name.Visible = false end
                
                if ESP.skeletonEnabled then
                    for _, bd in ipairs(drawings.Skeleton) do
                        local p1 = char:FindFirstChild(bd.parts[1]) or char:FindFirstChild("Torso")
                        local p2 = char:FindFirstChild(bd.parts[2]) or char:FindFirstChild("Torso")
                        if p1 and p2 then
                            local pos1, v1 = Camera:WorldToViewportPoint(p1.Position)
                            local pos2, v2 = Camera:WorldToViewportPoint(p2.Position)
                            if v1 or v2 then
                                bd.line.From = Vector2.new(pos1.X, pos1.Y); bd.line.To = Vector2.new(pos2.X, pos2.Y); bd.line.Visible = true
                            else bd.line.Visible = false end
                        else bd.line.Visible = false end
                    end
                else for _, bd in ipairs(drawings.Skeleton) do bd.line.Visible = false end end
            else
                drawings.Line.Visible = false; drawings.Name.Visible = false
                for _, bd in ipairs(drawings.Skeleton) do bd.line.Visible = false end
            end
        end
    end
end)
