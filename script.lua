-- Initialization & Globals
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

getgenv().XenoDeltaScript = { Connections = {}, ESP_Pool = {}, Drawings = {}, GUI = nil, Unloaded = false }
local State = getgenv().XenoDeltaScript

-- Settings
local Settings = {
    ESP = { Enabled = true, MaxDist = 500, TeamCheck = true, TracerOrigin = "Bottom" },
    Aimbot = { Enabled = true, FOV = 150, Smooth = 15, Bone = "Head", Hotkey = Enum.KeyCode.ButtonL2, TeamCheck = true, VisCheck = true, ToggleMode = false },
    AutoShoot = { Enabled = true },
    Misc = { AntiAFK = true }
}

-- Config Save/Load
local function SaveConfig()
    pcall(function()
        local json = HttpService:JSONEncode(Settings)
        writefile("xd_config.json", json)
    end)
end

local function LoadConfig()
    pcall(function()
        if isfile("xd_config.json") then
            local json = readfile("xd_config.json")
            local decoded = HttpService:JSONDecode(json)
            for k, v in pairs(decoded) do
                if Settings[k] then
                    for k2, v2 in pairs(v) do
                        Settings[k][k2] = v2
                    end
                end
            end
        end
    end)
end
LoadConfig()

-- Hookmetamethod
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    if checkcaller() or State.Unloaded then return oldNamecall(self, ...) end
    return oldNamecall(self, ...)
end)

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XenoDeltaHUD"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = game:GetService("CoreGui")
State.GUI = ScreenGui

-- Floating Button (Mobile + PC)
local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Size = UDim2.new(0, 50, 0, 50)
FloatingBtn.Position = UDim2.new(0, 20, 0.5, -25)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
FloatingBtn.Text = "XD"
FloatingBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
FloatingBtn.TextSize = 16
FloatingBtn.Font = Enum.Font.GothamBold
FloatingBtn.BorderSizePixel = 0
FloatingBtn.Parent = ScreenGui
FloatingBtn.AutoButtonColor = false

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatingBtn

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Color3.fromRGB(0, 255, 255)
FloatStroke.Thickness = 2
FloatStroke.Parent = FloatingBtn

-- Drag Floating Button
local fDragging, fDragInput, fDragStart, fStartPos
FloatingBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        fDragging = true
        fDragStart = input.Position
        fStartPos = FloatingBtn.Position
        local moveConn
        moveConn = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                fDragging = false
                moveConn:Disconnect()
            end
        end)
    end
end)
FloatingBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        fDragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == fDragInput and fDragging then
        local delta = input.Position - fDragStart
        FloatingBtn.Position = UDim2.new(
            fStartPos.X.Scale, fStartPos.X.Offset + delta.X,
            fStartPos.Y.Scale, fStartPos.Y.Offset + delta.Y
        )
    end
end)

-- Main Frame (hidden initially)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 320)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 255, 255)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 6)
TopBarCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Xeno / Delta Hub"
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar

-- Toggle GUI
local function ToggleGUI()
    MainFrame.Visible = not MainFrame.Visible
    FloatingBtn.Visible = not MainFrame.Visible
end

FloatingBtn.MouseButton1Click:Connect(ToggleGUI)
CloseBtn.MouseButton1Click:Connect(ToggleGUI)

-- Dragging MainFrame
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        local moveConn
        moveConn = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                moveConn:Disconnect()
            end
        end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Tabs
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 0, 35)
TabContainer.Position = UDim2.new(0, 0, 0, 30)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -20, 1, -85)
ContentContainer.Position = UDim2.new(0, 10, 0, 65)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local tabs = {"Visuals", "Combat", "Misc"}
local tabFrames = {}

local function CreateTabButton(name, index)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1/#tabs, -5, 1, 0)
    btn.Position = UDim2.new((1/#tabs) * (index-1), 2.5, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Text = name
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamSemibold
    btn.BorderSizePixel = 0
    btn.Parent = TabContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    local frame = Instance.new("ScrollingFrame")
    frame.Size = UDim2.new(1, -10, 1, 0)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.ScrollBarThickness = 3
    frame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255)
    frame.CanvasSize = UDim2.new(0, 0, 0, 0)
    frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    frame.Visible = (index == 1)
    frame.Parent = ContentContainer
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    layout.Parent = frame
    tabFrames[name] = frame
    
    btn.MouseButton1Click:Connect(function()
        for _, f in pairs(tabFrames) do f.Visible = false end
        frame.Visible = true
        for _, b in pairs(TabContainer:GetChildren()) do
            if b:IsA("TextButton") then
                b.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
                b.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        end
        btn.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
        btn.TextColor3 = Color3.fromRGB(15, 15, 20)
    end)
    if index == 1 then
        btn.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
        btn.TextColor3 = Color3.fromRGB(15, 15, 20)
    end
end

for i, name in ipairs(tabs) do CreateTabButton(name, i) end

-- UI Elements Helper
local function CreateToggle(parent, text, settingTable, settingKey, order)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 30)
    container.BackgroundTransparency = 1
    container.LayoutOrder = order or 0
    container.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 40, 0, 20)
    toggleBtn.Position = UDim2.new(1, -45, 0.5, -10)
    toggleBtn.BackgroundColor3 = settingTable[settingKey] and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(50, 50, 60)
    toggleBtn.Text = ""
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Parent = container
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
    
    toggleBtn.MouseButton1Click:Connect(function()
        settingTable[settingKey] = not settingTable[settingKey]
        toggleBtn.BackgroundColor3 = settingTable[settingKey] and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(50, 50, 60)
        SaveConfig()
    end)
end

local function CreateSlider(parent, text, settingTable, settingKey, min, max, order)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 40)
    container.BackgroundTransparency = 1
    container.LayoutOrder = order or 0
    container.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. settingTable[settingKey]
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 0, 8)
    bg.Position = UDim2.new(0, 0, 0, 25)
    bg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    bg.BorderSizePixel = 0
    bg.Parent = container
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((settingTable[settingKey] - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    fill.BorderSizePixel = 0
    fill.Parent = bg
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    
    local draggingSlider = false
    local function updateSlider(input)
        local relX = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(relX, 0, 1, 0)
        local val = math.floor(min + (max - min) * relX)
        settingTable[settingKey] = val
        label.Text = text .. ": " .. val
        SaveConfig()
    end
    
    bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
            updateSlider(input)
        end
    end)
    local moveConn
    moveConn = UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = false
        end
    end)
    table.insert(State.Connections, moveConn)
end

local function CreateDropdown(parent, text, settingTable, settingKey, options, order)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 30)
    container.BackgroundTransparency = 1
    container.LayoutOrder = order or 0
    container.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local dropBtn = Instance.new("TextButton")
    dropBtn.Size = UDim2.new(0.45, 0, 1, 0)
    dropBtn.Position = UDim2.new(0.55, 0, 0, 0)
    dropBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    dropBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
    dropBtn.Text = tostring(settingTable[settingKey])
    dropBtn.TextSize = 12
    dropBtn.Font = Enum.Font.GothamSemibold
    dropBtn.BorderSizePixel = 0
    dropBtn.Parent = container
    Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0, 4)
    
    dropBtn.MouseButton1Click:Connect(function()
        local currentIdx = table.find(options, settingTable[settingKey]) or 1
        local nextIdx = (currentIdx % #options) + 1
        settingTable[settingKey] = options[nextIdx]
        dropBtn.Text = tostring(settingTable[settingKey])
        SaveConfig()
    end)
end

-- Populate Tabs
CreateToggle(tabFrames["Visuals"], "ESP Enabled", Settings.ESP, "Enabled", 1)
CreateToggle(tabFrames["Visuals"], "Team Check", Settings.ESP, "TeamCheck", 2)
CreateSlider(tabFrames["Visuals"], "Max Distance", Settings.ESP, "MaxDist", 100, 2000, 3)

CreateToggle(tabFrames["Combat"], "Aimbot Enabled", Settings.Aimbot, "Enabled", 1)
CreateToggle(tabFrames["Combat"], "Team Check", Settings.Aimbot, "TeamCheck", 2)
CreateToggle(tabFrames["Combat"], "Visibility Check", Settings.Aimbot, "VisCheck", 3)
CreateToggle(tabFrames["Combat"], "Toggle Mode (Mobile)", Settings.Aimbot, "ToggleMode", 4)
CreateSlider(tabFrames["Combat"], "FOV Radius", Settings.Aimbot, "FOV", 50, 500, 5)
CreateSlider(tabFrames["Combat"], "Smoothing", Settings.Aimbot, "Smooth", 0, 100, 6)
CreateDropdown(tabFrames["Combat"], "Target Bone", Settings.Aimbot, "Bone", {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, 7)

CreateToggle(tabFrames["Combat"], "Auto Shoot", Settings.AutoShoot, "Enabled", 8)

CreateToggle(tabFrames["Misc"], "Anti AFK", Settings.Misc, "AntiAFK", 1)

local unloadBtn = Instance.new("TextButton")
unloadBtn.Size = UDim2.new(1, -10, 0, 30)
unloadBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
unloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
unloadBtn.Text = "Unload Script"
unloadBtn.Font = Enum.Font.GothamBold
unloadBtn.BorderSizePixel = 0
unloadBtn.LayoutOrder = 2
unloadBtn.Parent = tabFrames["Misc"]
Instance.new("UICorner", unloadBtn).CornerRadius = UDim.new(0, 4)

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(1, -10, 0, 30)
copyBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
copyBtn.TextColor3 = Color3.fromRGB(15, 15, 20)
copyBtn.Text = "Copy Config to Clipboard"
copyBtn.Font = Enum.Font.GothamBold
copyBtn.BorderSizePixel = 0
copyBtn.LayoutOrder = 3
copyBtn.Parent = tabFrames["Misc"]
Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 4)
copyBtn.MouseButton1Click:Connect(function()
    pcall(function() setclipboard(HttpService:JSONEncode(Settings)) end)
end)

-- ESP Logic
local function CreateESPObjects()
    local obj = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        HealthBar = Drawing.new("Line"),
        HealthBG = Drawing.new("Line"),
        Distance = Drawing.new("Text"),
        Tracer = Drawing.new("Line")
    }
    obj.Box.Thickness = 1
    obj.Box.Color = Color3.fromRGB(0, 255, 255)
    obj.Box.Filled = false
    
    obj.Name.Size = 13
    obj.Name.Center = true
    obj.Name.Outline = true
    obj.Name.Color = Color3.fromRGB(255, 255, 255)
    
    obj.HealthBar.Thickness = 2
    obj.HealthBar.Color = Color3.fromRGB(0, 255, 0)
    obj.HealthBG.Thickness = 3
    obj.HealthBG.Color = Color3.fromRGB(0, 0, 0)
    
    obj.Distance.Size = 12
    obj.Distance.Center = true
    obj.Distance.Outline = true
    obj.Distance.Color = Color3.fromRGB(200, 200, 200)
    
    obj.Tracer.Thickness = 1
    obj.Tracer.Color = Color3.fromRGB(0, 255, 255)
    
    for _, drawing in pairs(obj) do
        drawing.Visible = false
        table.insert(State.Drawings, drawing)
    end
    return obj
end

local function GetPlayerESP(player)
    if State.ESP_Pool[player] then return State.ESP_Pool[player] end
    local obj = CreateESPObjects()
    State.ESP_Pool[player] = obj
    return obj
end

local function RemovePlayerESP(player)
    if State.ESP_Pool[player] then
        for _, drawing in pairs(State.ESP_Pool[player]) do
            drawing.Visible = false
            drawing:Remove()
        end
        State.ESP_Pool[player] = nil
    end
end

-- Aimbot Logic
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 50
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(0, 255, 255)
FOVCircle.Transparency = 0.5
FOVCircle.Visible = false
table.insert(State.Drawings, FOVCircle)

local aimbotToggled = false

local function GetBonePosition(character, boneName)
    local part = character:FindFirstChild(boneName)
    if not part then part = character:FindFirstChild("Head") end
    return part
end

local function IsVisible(targetPart)
    if not Settings.Aimbot.VisCheck then return true end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    
    local success, result = pcall(function()
        return Workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position), rayParams)
    end)
    
    if success and result then
        return result.Instance:IsDescendantOf(targetPart.Parent)
    end
    return false
end

local function GetTarget()
    local closest = nil
    local closestDist = Settings.Aimbot.FOV
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if Settings.Aimbot.TeamCheck and player.Team == LocalPlayer.Team then continue end
            
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then continue end
            
            local part = GetBonePosition(player.Character, Settings.Aimbot.Bone)
            if not part then continue end
            
            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if not onScreen then continue end
            
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            if dist < closestDist then
                if IsVisible(part) then
                    closest = part
                    closestDist = dist
                end
            end
        end
    end
    return closest
end

-- Hotkey handling (PC + Mobile gamepad/touch toggle)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Settings.Aimbot.Hotkey or input.UserInputType == Settings.Aimbot.Hotkey then
        if Settings.Aimbot.ToggleMode then
            aimbotToggled = not aimbotToggled
        end
    end
end)

-- Main Loop
local renderConn = RunService.RenderStepped:Connect(function()
    if State.Unloaded then return end
    
    -- ESP Update
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local esp = GetPlayerESP(player)
        
        if not Settings.ESP.Enabled or not player.Character then
            for _, drawing in pairs(esp) do drawing.Visible = false end
            continue
        end
        
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        local head = player.Character:FindFirstChild("Head")
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        
        if not hrp or not head or not humanoid or humanoid.Health <= 0 then
            for _, drawing in pairs(esp) do drawing.Visible = false end
            continue
        end
        
        if Settings.ESP.TeamCheck and player.Team == LocalPlayer.Team then
            for _, drawing in pairs(esp) do drawing.Visible = false end
            continue
        end
        
        local dist = (hrp.Position - Camera.CFrame.Position).Magnitude
        if dist > Settings.ESP.MaxDist then
            for _, drawing in pairs(esp) do drawing.Visible = false end
            continue
        end
        
        local headPos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local rootPos = Camera:WorldToViewportPoint(hrp.Position)
        
        if onScreen then
            local height = math.abs(headPos.Y - rootPos.Y)
            local width = height * 0.6
            
            esp.Box.Size = Vector2.new(width, height)
            esp.Box.Position = Vector2.new(headPos.X - width / 2, headPos.Y)
            esp.Box.Visible = true
            
            esp.Name.Text = player.Name
            esp.Name.Position = Vector2.new(headPos.X, headPos.Y - 15)
            esp.Name.Visible = true
            
            local hpPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
            esp.HealthBG.From = Vector2.new(headPos.X - width / 2 - 5, headPos.Y)
            esp.HealthBG.To = Vector2.new(headPos.X - width / 2 - 5, headPos.Y + height)
            esp.HealthBG.Visible = true
            
            esp.HealthBar.From = Vector2.new(headPos.X - width / 2 - 5, headPos.Y + height * (1 - hpPercent))
            esp.HealthBar.To = Vector2.new(headPos.X - width / 2 - 5, headPos.Y + height)
            esp.HealthBar.Color = Color3.fromRGB(255 * (1 - hpPercent), 255 * hpPercent, 0)
            esp.HealthBar.Visible = true
            
            esp.Distance.Text = math.floor(dist) .. "m"
            esp.Distance.Position = Vector2.new(headPos.X, headPos.Y + height + 5)
            esp.Distance.Visible = true
            
            local screenSize = Camera.ViewportSize
            esp.Tracer.From = Vector2.new(screenSize.X / 2, screenSize.Y)
            esp.Tracer.To = Vector2.new(headPos.X, headPos.Y + height)
            esp.Tracer.Visible = true
        else
            for _, drawing in pairs(esp) do drawing.Visible = false end
        end
    end
    
    -- Aimbot Update
    local hotkeyDown = UserInputService:IsKeyDown(Settings.Aimbot.Hotkey) or UserInputService:IsMouseButtonPressed(Settings.Aimbot.Hotkey)
    local aimbotActive = Settings.Aimbot.Enabled and (hotkeyDown or (Settings.Aimbot.ToggleMode and aimbotToggled))
    
    FOVCircle.Visible = Settings.Aimbot.Enabled
    FOVCircle.Radius = Settings.Aimbot.FOV
    FOVCircle.Position = UserInputService:GetMouseLocation()
    
    if aimbotActive then
        local target = GetTarget()
        if target then
            local targetPos = Camera:WorldToViewportPoint(target.Position)
            local mousePos = UserInputService:GetMouseLocation()
            local delta = Vector2.new(targetPos.X, targetPos.Y) - mousePos
            
            local smoothFactor = 1 - (Settings.Aimbot.Smooth / 100)
            smoothFactor = math.clamp(smoothFactor, 0.01, 0.99)
            
            local newCFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + Vector3.new(delta.X, -delta.Y, 1))
            Camera.CFrame = Camera.CFrame:Lerp(newCFrame, smoothFactor)
            
            if Settings.AutoShoot.Enabled then
                -- TODO: Fire weapon remote here (game-specific)
                pcall(function()
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                end)
            end
        end
    end
end)
table.insert(State.Connections, renderConn)

-- Player Cleanup
local playerRemovingConn = Players.PlayerRemoving:Connect(function(player)
    RemovePlayerESP(player)
end)
table.insert(State.Connections, playerRemovingConn)

-- Anti AFK
local virtualUser = game:GetService("VirtualUser")
local antiAfkConn
antiAfkConn = LocalPlayer.Idled:Connect(function()
    if Settings.Misc.AntiAFK then
        pcall(function() virtualUser:Button2Down() virtualUser:Button2Up() end)
    end
end)
table.insert(State.Connections, antiAfkConn)

-- Unload Function
local function Unload()
    State.Unloaded = true
    for _, conn in pairs(State.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    for _, player in pairs(Players:GetPlayers()) do
        RemovePlayerESP(player)
    end
    for _, drawing in pairs(State.Drawings) do
        pcall(function() drawing:Remove() end)
    end
    pcall(function() ScreenGui:Destroy() end)
    getgenv().XenoDeltaScript = nil
end

unloadBtn.MouseButton1Click:Connect(Unload)

-- Cleanup previous instance if re-executed
pcall(function()
    if getgenv().XenoDeltaScript and getgenv().XenoDeltaScript ~= State and not getgenv().XenoDeltaScript.Unloaded then
        getgenv().XenoDeltaScript.Unloaded = true
        for _, conn in pairs(getgenv().XenoDeltaScript.Connections) do
            pcall(function() conn:Disconnect() end)
        end
        for _, drawing in pairs(getgenv().XenoDeltaScript.Drawings) do
            pcall(function() drawing:Remove() end)
        end
        pcall(function() getgenv().XenoDeltaScript.GUI:Destroy() end)
    end
end)
