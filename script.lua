--[[⊹˚₊‧───────────────‧₊˚⊹·͙⁺˚*•̩̩͙✩•̩̩͙*˚⁺‧͙⁺˚*•̩̩͙✩•̩̩͙*˚⁺‧͙⁺˚*•̩̩͙✩•̩̩͙*˚⁺‧͙⊹˚₊‧───────────────‧₊˚⊹

  _______   _______   __    __   __    __  .______   
 |       \ |       / |  |  |  | |  |  |  | |   _  \  
 |  .--.  | `---/  /  |  |__|  | |  |  |  | |  |_)  | 
 |  |  |  |    /  /   |   __   | |  |  |  | |   _  <  
 |  '--'  |   /  /----|  |  |  | |  `--'  | |  |_)  | 
 |_______/   /_______||__|  |__|  \______/  |______/  
                                                      
༺☆༻____________☾✧ ✩ ✧☽____________༺☆༻༺☆༻____________☾✧ ✩ ✧☽____________༺☆༻

    ✨DZ HUB Universal Framework✨
    Release 1.9.5

•───────•°•❀•°•───────•୧‿̩͙ ˖︵ꕀ ⠀𓏶 ̣̣̥⠀ ꕀ︵˖ ̩͙‿୨•───────•°•❀•°•───────•]]

--! Debugger
local DEBUG = false

if DEBUG then
    getfenv().getfenv = function()
        return setmetatable({}, {
            __index = function()
                return function() return true end
            end
        })
    end
end

--! Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

--! Interface Manager
local UISettings = {
    TabWidth = 160,
    Size = { 580, 460 },
    Theme = "VSC Dark High Contrast",
    Acrylic = false,
    Transparency = true,
    MinimizeKey = "RightShift",
    ShowNotifications = true,
    ShowWarnings = true,
    RenderingMode = "RenderStepped",
    AutoImport = true
}

local InterfaceManager = {}

function InterfaceManager:ImportSettings()
    pcall(function()
        if not DEBUG and getfenv().isfile and getfenv().readfile and getfenv().isfile("UISettings.dzhub") and getfenv().readfile("UISettings.dzhub") then
            for Key, Value in next, HttpService:JSONDecode(getfenv().readfile("UISettings.dzhub")) do
                UISettings[Key] = Value
            end
        end
    end)
end

function InterfaceManager:ExportSettings()
    pcall(function()
        if not DEBUG and getfenv().isfile and getfenv().readfile and getfenv().writefile then
            getfenv().writefile("UISettings.dzhub", HttpService:JSONEncode(UISettings))
        end
    end)
end

InterfaceManager:ImportSettings()
UISettings.__LAST_RUN__ = os.date()
InterfaceManager:ExportSettings()

--! Colors Handler
local ColorsHandler = {}
function ColorsHandler:PackColour(Colour)
    return typeof(Colour) == "Color3" and { R = Colour.R * 255, G = Colour.G * 255, B = Colour.B * 255 } or typeof(Colour) == "table" and Colour or { R = 255, G = 255, B = 255 }
end

function ColorsHandler:UnpackColour(Colour)
    return typeof(Colour) == "table" and Color3.fromRGB(Colour.R, Colour.G, Colour.B) or typeof(Colour) == "Color3" and Colour or Color3.fromRGB(255, 255, 255)
end

--! Configuration Importer
local ImportedConfiguration = {}
pcall(function()
    if not DEBUG and getfenv().isfile and getfenv().readfile and getfenv().isfile(string.format("%s.dzhub", game.GameId)) and getfenv().readfile(string.format("%s.dzhub", game.GameId)) and UISettings.AutoImport then
        ImportedConfiguration = HttpService:JSONDecode(getfenv().readfile(string.format("%s.dzhub", game.GameId)))
        for Key, Value in next, ImportedConfiguration do
            if Key == "FoVColour" or Key == "NameESPOutlineColour" or Key == "ESPColour" then
                ImportedConfiguration[Key] = ColorsHandler:UnpackColour(Value)
            end
        end
    end
end)

--! Configuration Initializer
local Configuration = {}

--? Aimbot
Configuration.Aimbot = ImportedConfiguration["Aimbot"] or false
Configuration.OnePressAimingMode = ImportedConfiguration["OnePressAimingMode"] or false
Configuration.AimKey = ImportedConfiguration["AimKey"] or "RMB"
Configuration.AimMode = ImportedConfiguration["AimMode"] or "Camera"
Configuration.SilentAimMethods = ImportedConfiguration["SilentAimMethods"] or { "Mouse.Hit / Mouse.Target", "GetMouseLocation" }
Configuration.SilentAimChance = ImportedConfiguration["SilentAimChance"] or 100
Configuration.OffAimbotAfterKill = ImportedConfiguration["OffAimbotAfterKill"] or false
Configuration.AimPartDropdownValues = ImportedConfiguration["AimPartDropdownValues"] or { "Head", "HumanoidRootPart" }
Configuration.AimPart = ImportedConfiguration["AimPart"] or "HumanoidRootPart"
Configuration.RandomAimPart = ImportedConfiguration["RandomAimPart"] or false

Configuration.UseOffset = ImportedConfiguration["UseOffset"] or false
Configuration.OffsetType = ImportedConfiguration["OffsetType"] or "Static"
Configuration.StaticOffsetIncrement = ImportedConfiguration["StaticOffsetIncrement"] or 10
Configuration.DynamicOffsetIncrement = ImportedConfiguration["DynamicOffsetIncrement"] or 10
Configuration.AutoOffset = ImportedConfiguration["AutoOffset"] or false
Configuration.MaxAutoOffset = ImportedConfiguration["MaxAutoOffset"] or 50

Configuration.UseSensitivity = ImportedConfiguration["UseSensitivity"] or false
Configuration.Sensitivity = ImportedConfiguration["Sensitivity"] or 50
Configuration.UseNoise = ImportedConfiguration["UseNoise"] or false
Configuration.NoiseFrequency = ImportedConfiguration["NoiseFrequency"] or 50

--? Bots
Configuration.SpinBot = ImportedConfiguration["SpinBot"] or false
Configuration.OnePressSpinningMode = ImportedConfiguration["OnePressSpinningMode"] or false
Configuration.SpinKey = ImportedConfiguration["SpinKey"] or "Q"
Configuration.SpinBotVelocity = ImportedConfiguration["SpinBotVelocity"] or 50
Configuration.SpinPartDropdownValues = ImportedConfiguration["SpinPartDropdownValues"] or { "Head", "HumanoidRootPart" }
Configuration.SpinPart = ImportedConfiguration["SpinPart"] or "HumanoidRootPart"
Configuration.RandomSpinPart = ImportedConfiguration["RandomSpinPart"] or false

Configuration.TriggerBot = ImportedConfiguration["TriggerBot"] or false
Configuration.OnePressTriggeringMode = ImportedConfiguration["OnePressTriggeringMode"] or false
Configuration.SmartTriggerBot = ImportedConfiguration["SmartTriggerBot"] or false
Configuration.TriggerKey = ImportedConfiguration["TriggerKey"] or "E"
Configuration.TriggerBotChance = ImportedConfiguration["TriggerBotChance"] or 100

--? Checks
Configuration.AliveCheck = ImportedConfiguration["AliveCheck"] or false
Configuration.GodCheck = ImportedConfiguration["GodCheck"] or false
Configuration.TeamCheck = ImportedConfiguration["TeamCheck"] or false
Configuration.FriendCheck = ImportedConfiguration["FriendCheck"] or false
Configuration.FollowCheck = ImportedConfiguration["FollowCheck"] or false
Configuration.VerifiedBadgeCheck = ImportedConfiguration["VerifiedBadgeCheck"] or false
Configuration.WallCheck = ImportedConfiguration["WallCheck"] or false
Configuration.WaterCheck = ImportedConfiguration["WaterCheck"] or false

Configuration.FoVCheck = ImportedConfiguration["FoVCheck"] or false
Configuration.FoVRadius = ImportedConfiguration["FoVRadius"] or 100
Configuration.MagnitudeCheck = ImportedConfiguration["MagnitudeCheck"] or false
Configuration.TriggerMagnitude = ImportedConfiguration["TriggerMagnitude"] or 500
Configuration.TransparencyCheck = ImportedConfiguration["TransparencyCheck"] or false
Configuration.IgnoredTransparency = ImportedConfiguration["IgnoredTransparency"] or 0.5
Configuration.WhitelistedGroupCheck = ImportedConfiguration["WhitelistedGroupCheck"] or false
Configuration.WhitelistedGroup = ImportedConfiguration["WhitelistedGroup"] or 0
Configuration.BlacklistedGroupCheck = ImportedConfiguration["BlacklistedGroupCheck"] or false
Configuration.BlacklistedGroup = ImportedConfiguration["BlacklistedGroup"] or 0

Configuration.IgnoredPlayersCheck = ImportedConfiguration["IgnoredPlayersCheck"] or false
Configuration.IgnoredPlayersDropdownValues = ImportedConfiguration["IgnoredPlayersDropdownValues"] or {}
Configuration.IgnoredPlayers = ImportedConfiguration["IgnoredPlayers"] or {}
Configuration.TargetPlayersCheck = ImportedConfiguration["TargetPlayersCheck"] or false
Configuration.TargetPlayersDropdownValues = ImportedConfiguration["TargetPlayersDropdownValues"] or {}
Configuration.TargetPlayers = ImportedConfiguration["TargetPlayers"] or {}
Configuration.PremiumCheck = ImportedConfiguration["PremiumCheck"] or false

--? Visuals
Configuration.FoV = ImportedConfiguration["FoV"] or false
Configuration.FoVKey = ImportedConfiguration["FoVKey"] or "R"
Configuration.FoVThickness = ImportedConfiguration["FoVThickness"] or 2
Configuration.FoVOpacity = ImportedConfiguration["FoVOpacity"] or 0.8
Configuration.FoVFilled = ImportedConfiguration["FoVFilled"] or false
Configuration.FoVColour = ImportedConfiguration["FoVColour"] or Color3.fromRGB(255, 255, 255)

Configuration.SmartESP = ImportedConfiguration["SmartESP"] or false
Configuration.ESPKey = ImportedConfiguration["ESPKey"] or "T"
Configuration.ESPBox = ImportedConfiguration["ESPBox"] or false
Configuration.ESPBoxFilled = ImportedConfiguration["ESPBoxFilled"] or false
Configuration.NameESP = ImportedConfiguration["NameESP"] or false
Configuration.NameESPFont = ImportedConfiguration["NameESPFont"] or "Monospace"
Configuration.NameESPSize = ImportedConfiguration["NameESPSize"] or 16
Configuration.NameESPOutlineColour = ImportedConfiguration["NameESPOutlineColour"] or Color3.fromRGB(0, 0, 0)
Configuration.HealthESP = ImportedConfiguration["HealthESP"] or false
Configuration.MagnitudeESP = ImportedConfiguration["MagnitudeESP"] or false
Configuration.TracerESP = ImportedConfiguration["TracerESP"] or false
Configuration.ESPThickness = ImportedConfiguration["ESPThickness"] or 2
Configuration.ESPOpacity = ImportedConfiguration["ESPOpacity"] or 0.8
Configuration.ESPColour = ImportedConfiguration["ESPColour"] or Color3.fromRGB(255, 255, 255)
Configuration.ESPUseTeamColour = ImportedConfiguration["ESPUseTeamColour"] or false

Configuration.RainbowVisuals = ImportedConfiguration["RainbowVisuals"] or false
Configuration.RainbowDelay = ImportedConfiguration["RainbowDelay"] or 5

--! Constants
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local IsComputer = UserInputService.KeyboardEnabled and UserInputService.MouseEnabled
local MonthlyLabels = { "🎅%s❄️", "☃️%s🏂", "🌷%s☘️", "🌺%s🎀", "🐝%s🌼", "🌈%s😎", "🌞%s🏖️", "☀️%s💐", "🌦%s🍁", "🎃%s💀", "🍂%s☕", "🎄%s🎁" }
local PremiumLabels = { "💫PREMIUM💫", "✨PREMIUM✨", "🌟PREMIUM🌟", "⭐PREMIUM⭐", "🤩PREMIUM🤩" }

--! Names Handler
local function GetPlayerName(String)
    if typeof(String) == "string" and #String > 0 then
        for _, _Player in next, Players:GetPlayers() do
            if string.sub(string.lower(_Player.Name), 1, #string.lower(String)) == string.lower(String) then
                return _Player.Name
            end
        end
    end
    return ""
end

--! Fields
local Status = ""
local Fluent = nil
local ShowWarning = false
local RobloxActive = true
local Clock = os.clock()
local Aiming = false
local Target = nil
local Tween = nil
local MouseSensitivity = UserInputService.MouseDeltaSensitivity
local Spinning = false
local Triggering = false
local ShowingFoV = false
local ShowingESP = false

do
    if typeof(script) == "Instance" and script:FindFirstChild("Fluent") and script:FindFirstChild("Fluent"):IsA("ModuleScript") then
        Fluent = require(script:FindFirstChild("Fluent"))
    else
        local Success, Result = pcall(function()
            return game:HttpGet("https://twix.cyou/Fluent.txt", true)
        end)
        if Success and typeof(Result) == "string" and string.find(Result, "dawid") then
            Fluent = getfenv().loadstring(Result)()
        else
            return
        end
    end
end

local SensitivityChanged; SensitivityChanged = UserInputService:GetPropertyChangedSignal("MouseDeltaSensitivity"):Connect(function()
    if not Fluent then
        SensitivityChanged:Disconnect()
    elseif not Aiming or not DEBUG and (getfenv().mousemoverel and IsComputer and Configuration.AimMode == "Mouse" or getfenv().hookmetamethod and getfenv().newcclosure and getfenv().checkcaller and getfenv().getnamecallmethod and Configuration.AimMode == "Silent") then
        MouseSensitivity = UserInputService.MouseDeltaSensitivity
    end
end)

--! UI Initializer
do
    local Window = Fluent:CreateWindow({
        Title = string.format("%s <b><i>%s</i></b>", string.format(MonthlyLabels[os.date("*t").month], "DZ HUB"), #Status > 0 and Status or "🔥FREE🔥"),
        SubTitle = "Aimbot & ESP Framework",
        TabWidth = UISettings.TabWidth,
        Size = UDim2.fromOffset(table.unpack(UISettings.Size)),
        Theme = UISettings.Theme,
        Acrylic = UISettings.Acrylic,
        MinimizeKey = UISettings.MinimizeKey
    })

    local Tabs = { Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "crosshair" }) }
    Window:SelectTab(1)
    Tabs.Aimbot:AddParagraph({ Title = string.format("%s 🔥FREE🔥", string.format(MonthlyLabels[os.date("*t").month], "DZ HUB")), Content = "✨Universal Aim Assist Framework✨" })

    local AimbotSection = Tabs.Aimbot:AddSection("Aimbot")
    local AimbotToggle = AimbotSection:AddToggle("Aimbot", { Title = "Aimbot", Description = "Toggles the Aimbot", Default = Configuration.Aimbot })
    AimbotToggle:OnChanged(function(Value)
        Configuration.Aimbot = Value
        if not IsComputer then Aiming = Value end
    end)

    if IsComputer then
        local OnePressAimingModeToggle = AimbotSection:AddToggle("OnePressAimingMode", { Title = "One-Press Mode", Description = "Uses the One-Press Mode instead of the Holding Mode", Default = Configuration.OnePressAimingMode })
        OnePressAimingModeToggle:OnChanged(function(Value) Configuration.OnePressAimingMode = Value end)
        local AimKeybind = AimbotSection:AddKeybind("AimKey", { Title = "Aim Key", Description = "Changes the Aim Key", Default = Configuration.AimKey, ChangedCallback = function(Value) Configuration.AimKey = Value end })
        Configuration.AimKey = AimKeybind.Value ~= "RMB" and Enum.KeyCode[AimKeybind.Value] or Enum.UserInputType.MouseButton2
    end

    local AimModeDropdown = AimbotSection:AddDropdown("AimMode", { Title = "Aim Mode", Description = "Changes the Aim Mode", Values = { "Camera" }, Default = Configuration.AimMode, Callback = function(Value) Configuration.AimMode = Value end })
    
    local OffAimbotAfterKillToggle = AimbotSection:AddToggle("OffAimbotAfterKill", { Title = "Off After Kill", Description = "Disables the Aiming Mode after killing a Target", Default = Configuration.OffAimbotAfterKill })
    OffAimbotAfterKillToggle:OnChanged(function(Value) Configuration.OffAimbotAfterKill = Value end)

    local AimPartDropdown = AimbotSection:AddDropdown("AimPart", { Title = "Aim Part", Description = "Changes the Aim Part", Values = Configuration.AimPartDropdownValues, Default = Configuration.AimPart, Callback = function(Value) Configuration.AimPart = Value end })

    Tabs.Checks = Window:AddTab({ Title = "Checks", Icon = "list-checks" })
    local SimpleChecksSection = Tabs.Checks:AddSection("Simple Checks")
    local AliveCheckToggle = SimpleChecksSection:AddToggle("AliveCheck", { Title = "Alive Check", Description = "Toggles the Alive Check", Default = Configuration.AliveCheck })
    AliveCheckToggle:OnChanged(function(Value) Configuration.AliveCheck = Value end)
    local TeamCheckToggle = SimpleChecksSection:AddToggle("TeamCheck", { Title = "Team Check", Description = "Toggles the Team Check", Default = Configuration.TeamCheck })
    TeamCheckToggle:OnChanged(function(Value) Configuration.TeamCheck = Value end)

    if DEBUG or getfenv().Drawing and getfenv().Drawing.new then
        Tabs.Visuals = Window:AddTab({ Title = "Visuals", Icon = "box" })
        local ESPSection = Tabs.Visuals:AddSection("ESP")
        local ESPBoxToggle = ESPSection:AddToggle("ESPBox", { Title = "ESP Box", Description = "Creates the ESP Box around the Players", Default = Configuration.ESPBox })
        ESPBoxToggle:OnChanged(function(Value)
            Configuration.ESPBox = Value
            if not IsComputer then
                if Value then ShowingESP = true elseif not Configuration.ESPBox and not Configuration.NameESP and not Configuration.HealthESP then ShowingESP = false end
            end
        end)
        
        local NameESPToggle = ESPSection:AddToggle("NameESP", { Title = "Name ESP", Description = "Creates the Name ESP above the Players", Default = Configuration.NameESP })
        NameESPToggle:OnChanged(function(Value)
            Configuration.NameESP = Value
            if not IsComputer then
                if Value then ShowingESP = true elseif not Configuration.ESPBox and not Configuration.NameESP and not Configuration.HealthESP then ShowingESP = false end
            end
        end)

        local HealthESPToggle = ESPSection:AddToggle("HealthESP", { Title = "Health ESP", Description = "Creates the Health ESP in the ESP Box", Default = Configuration.HealthESP })
        HealthESPToggle:OnChanged(function(Value)
            Configuration.HealthESP = Value
            if not IsComputer then
                if Value then ShowingESP = true elseif not Configuration.ESPBox and not Configuration.NameESP and not Configuration.HealthESP then ShowingESP = false end
            end
        end)
        
        local TracerESPToggle = ESPSection:AddToggle("TracerESP", { Title = "Tracer ESP", Description = "Creates the Tracer ESP in the direction of the Players", Default = Configuration.TracerESP })
        TracerESPToggle:OnChanged(function(Value)
            Configuration.TracerESP = Value
            if not IsComputer then
                if Value then ShowingESP = true elseif not Configuration.ESPBox and not Configuration.NameESP and not Configuration.HealthESP and not Configuration.TracerESP then ShowingESP = false end
            end
        end)
    end
end

--! Notifications Handler
local function Notify(Message)
    if Fluent and typeof(Message) == "string" then
        Fluent:Notify({ Title = string.format("%s 🔥FREE🔥", string.format(MonthlyLabels[os.date("*t").month], "DZ HUB")), Content = Message, Duration = 1.5 })
    end
end
Notify("DZ HUB Successfully Loaded!")

--! Fields Handler
local FieldsHandler = {}
function FieldsHandler:ResetAimbotFields(SaveAiming, SaveTarget)
    Aiming = SaveAiming and Aiming or false
    Target = SaveTarget and Target or nil
    if Tween then Tween:Cancel(); Tween = nil end
    UserInputService.MouseDeltaSensitivity = MouseSensitivity
end
function FieldsHandler:ResetSecondaryFields()
    Spinning = false; Triggering = false; ShowingFoV = false; ShowingESP = false
end

--! Input Handler
do
    if IsComputer then
        local InputBegan; InputBegan = UserInputService.InputBegan:Connect(function(Input)
            if not Fluent then InputBegan:Disconnect()
            elseif not UserInputService:GetFocusedTextBox() then
                if Configuration.Aimbot and (Input.KeyCode == Configuration.AimKey or Input.UserInputType == Configuration.AimKey) then
                    if Aiming then FieldsHandler:ResetAimbotFields(); Notify("[Aiming Mode]: OFF") else Aiming = true; Notify("[Aiming Mode]: ON") end
                elseif not DEBUG and getfenv().Drawing and getfenv().Drawing.new and (Configuration.ESPBox or Configuration.NameESP or Configuration.HealthESP or Configuration.TracerESP) and (Input.KeyCode == Configuration.ESPKey or Input.UserInputType == Configuration.ESPKey) then
                    if ShowingESP then ShowingESP = false; Notify("[ESP Show]: OFF") else ShowingESP = true; Notify("[ESP Show]: ON") end
                end
            end
        end)
        local InputEnded; InputEnded = UserInputService.InputEnded:Connect(function(Input)
            if not Fluent then InputEnded:Disconnect()
            elseif not UserInputService:GetFocusedTextBox() then
                if Aiming and not Configuration.OnePressAimingMode and (Input.KeyCode == Configuration.AimKey or Input.UserInputType == Configuration.AimKey) then
                    FieldsHandler:ResetAimbotFields(); Notify("[Aiming Mode]: OFF")
                end
            end
        end)
    end
end

--! Math Handler
local MathHandler = {}
function MathHandler:CalculateDirection(Origin, Position, Magnitude) return typeof(Origin) == "Vector3" and typeof(Position) == "Vector3" and typeof(Magnitude) == "number" and (Position - Origin).Unit * Magnitude or Vector3.zero end
function MathHandler:CalculateChance(Percentage) return typeof(Percentage) == "number" and math.round(math.clamp(Percentage, 1, 100)) / 100 >= math.round(Random.new():NextNumber() * 100) / 100 or false end
function MathHandler:Abbreviate(Number) return typeof(Number) == "number" and tostring(math.round(Number)) or Number end

--! Targets Handler
local function IsReady(TargetPlayer)
    if TargetPlayer and TargetPlayer:FindFirstChildWhichIsA("Humanoid") and Configuration.AimPart and TargetPlayer:FindFirstChild(Configuration.AimPart) and Player.Character and Player.Character:FindFirstChild(Configuration.AimPart) then
        local _Player = Players:GetPlayerFromCharacter(TargetPlayer)
        if not _Player or _Player == Player then return false end
        local Humanoid = TargetPlayer:FindFirstChildWhichIsA("Humanoid")
        if Configuration.AliveCheck and Humanoid.Health <= 0 then return false end
        if Configuration.TeamCheck and _Player.TeamColor == Player.TeamColor then return false end
        
        local TargetPart = TargetPlayer:FindFirstChild(Configuration.AimPart)
        local NativePart = Player.Character:FindFirstChild(Configuration.AimPart)
        local ScreenPos, OnScreen = workspace.CurrentCamera:WorldToViewportPoint(TargetPart.Position)
        
        return true, TargetPlayer, { ScreenPos, OnScreen }, TargetPart.Position, (TargetPart.Position - NativePart.Position).Magnitude, CFrame.new(TargetPart.Position), TargetPart
    end
    return false
end

--! Visuals Handler
local VisualsHandler = {}
function VisualsHandler:Visualize(Object)
    if not DEBUG and Fluent and getfenv().Drawing and getfenv().Drawing.new and typeof(Object) == "string" then
        if string.lower(Object) == "fov" then
            local FoV = getfenv().Drawing.new("Circle")
            FoV.Visible = false; FoV.ZIndex = 4; FoV.NumSides = 100; FoV.Radius = Configuration.FoVRadius; FoV.Thickness = Configuration.FoVThickness; FoV.Color = Configuration.FoVColour
            return FoV
        elseif string.lower(Object) == "espbox" then
            local ESPBox = getfenv().Drawing.new("Square")
            ESPBox.Visible = false; ESPBox.ZIndex = 2; ESPBox.Thickness = Configuration.ESPThickness; ESPBox.Color = Configuration.ESPColour
            return ESPBox
        elseif string.lower(Object) == "nameesp" then
            local NameESP = getfenv().Drawing.new("Text")
            NameESP.Visible = false; NameESP.ZIndex = 3; NameESP.Center = true; NameESP.Outline = true; NameESP.Color = Configuration.ESPColour; NameESP.Size = Configuration.NameESPSize
            return NameESP
        elseif string.lower(Object) == "traceresp" then
            local TracerESP = getfenv().Drawing.new("Line")
            TracerESP.Visible = false; TracerESP.ZIndex = 1; TracerESP.Thickness = Configuration.ESPThickness; TracerESP.Color = Configuration.ESPColour
            return TracerESP
        end
    end
    return nil
end

local Visuals = { FoV = VisualsHandler:Visualize("FoV") }

function VisualsHandler:ClearVisual(Visual, Key)
    local FoundVisual = table.find(Visuals, Visual)
    if Visual and (FoundVisual or Key == "FoV") then
        if Visual.Destroy then Visual:Destroy() elseif Visual.Remove then Visual:Remove() end
        if FoundVisual then table.remove(Visuals, FoundVisual) elseif Key == "FoV" then Visuals.FoV = nil end
    end
end

function VisualsHandler:ClearVisuals()
    for Key, Visual in next, Visuals do self:ClearVisual(Visual, Key) end
end

--! ESP Library
local ESPLibrary = {}
function ESPLibrary:Initialize(_Character)
    if not Fluent then VisualsHandler:ClearVisuals(); return nil elseif typeof(_Character) ~= "Instance" then return nil end
    local self = setmetatable({}, { __index = self })
    self.Player = Players:GetPlayerFromCharacter(_Character)
    self.Character = _Character
    self.ESPBox = VisualsHandler:Visualize("ESPBox")
    self.NameESP = VisualsHandler:Visualize("NameESP")
    self.HealthESP = VisualsHandler:Visualize("NameESP")
    self.TracerESP = VisualsHandler:Visualize("TracerESP")
    table.insert(Visuals, self.ESPBox)
    table.insert(Visuals, self.NameESP)
    table.insert(Visuals, self.HealthESP)
    table.insert(Visuals, self.TracerESP)
    return self
end

function ESPLibrary:Visualize()
    if not Fluent then return VisualsHandler:ClearVisuals() elseif not self.Character then return self:Disconnect() end
    local Head = self.Character:FindFirstChild("Head")
    local HumanoidRootPart = self.Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = self.Character:FindFirstChildWhichIsA("Humanoid")
    if Head and HumanoidRootPart and Humanoid then
        local HumanoidRootPartPosition, IsInViewport = workspace.CurrentCamera:WorldToViewportPoint(HumanoidRootPart.Position)
        local HeadPosition = workspace.CurrentCamera:WorldToViewportPoint(Head.Position)
        local TopPosition = workspace.CurrentCamera:WorldToViewportPoint(Head.Position + Vector3.new(0, 0.5, 0))
        local BottomPosition = workspace.CurrentCamera:WorldToViewportPoint(HumanoidRootPart.Position - Vector3.new(0, 3, 0))
        
        if IsInViewport then
            self.ESPBox.Size = Vector2.new(2350 / HumanoidRootPartPosition.Z, TopPosition.Y - BottomPosition.Y)
            self.ESPBox.Position = Vector2.new(HumanoidRootPartPosition.X - self.ESPBox.Size.X / 2, HumanoidRootPartPosition.Y - self.ESPBox.Size.Y / 2)
            self.NameESP.Text = string.format("@%s", self.Player.Name)
            self.NameESP.Position = Vector2.new(HumanoidRootPartPosition.X, HumanoidRootPartPosition.Y + self.ESPBox.Size.Y / 2 - 25)
            self.HealthESP.Text = string.format("[%s%%]", MathHandler:Abbreviate(Humanoid.Health))
            self.HealthESP.Position = Vector2.new(HumanoidRootPartPosition.X, HeadPosition.Y)
            self.TracerESP.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
            self.TracerESP.To = Vector2.new(HumanoidRootPartPosition.X, HumanoidRootPartPosition.Y - self.ESPBox.Size.Y / 2)
        end
        local ShowESP = ShowingESP and IsInViewport
        self.ESPBox.Visible = Configuration.ESPBox and ShowESP
        self.NameESP.Visible = Configuration.NameESP and ShowESP
        self.HealthESP.Visible = Configuration.HealthESP and ShowESP
        self.TracerESP.Visible = Configuration.TracerESP and ShowESP
    else
        self.ESPBox.Visible = false
        self.NameESP.Visible = false
        self.HealthESP.Visible = false
        self.TracerESP.Visible = false
    end
end

function ESPLibrary:Disconnect()
    self.Player = nil; self.Character = nil
    VisualsHandler:ClearVisual(self.ESPBox)
    VisualsHandler:ClearVisual(self.NameESP)
    VisualsHandler:ClearVisual(self.HealthESP)
    VisualsHandler:ClearVisual(self.TracerESP)
end

--! Tracking Handler
local TrackingHandler = {}
local Tracking = {}
local Connections = {}

function TrackingHandler:VisualizeESP()
    for _, Tracked in next, Tracking do Tracked:Visualize() end
end

local function CharacterAdded(_Character)
    if typeof(_Character) == "Instance" then
        local _Player = Players:GetPlayerFromCharacter(_Character)
        Tracking[_Player.UserId] = ESPLibrary:Initialize(_Character)
    end
end

function TrackingHandler:InitializePlayers()
    if not DEBUG and getfenv().Drawing and getfenv().Drawing.new then
        for _, _Player in next, Players:GetPlayers() do
            if _Player ~= Player then
                if _Player.Character then CharacterAdded(_Player.Character) end
                Connections[_Player.UserId] = { _Player.CharacterAdded:Connect(CharacterAdded) }
            end
        end
    end
end
TrackingHandler:InitializePlayers()

Players.PlayerAdded:Connect(function(_Player)
    Connections[_Player.UserId] = { _Player.CharacterAdded:Connect(CharacterAdded) }
end)

--! Aimbot Handler (Completed Loop)
local AimbotLoop; AimbotLoop = RunService[UISettings.RenderingMode]:Connect(function()
    if Fluent and Fluent.Unloaded then
        Fluent = nil
        TrackingHandler:DisconnectAimbot()
        AimbotLoop:Disconnect()
    end
    if RobloxActive then
        if not DEBUG and getfenv().Drawing and getfenv().Drawing.new then
            TrackingHandler:VisualizeESP()
        end
        if Aiming then
            local OldTarget = Target
            local Closest = math.huge
            Target = nil
            
            for _, _Player in next, Players:GetPlayers() do
                if _Player.Character then
                    local IsCharacterReady, Character, PartViewportPosition, TargetPosition, Magnitude = IsReady(_Player.Character)
                    if IsCharacterReady and PartViewportPosition[2] then
                        -- Calculate 2D Screen Distance from mouse
                        local MouseLocation = UserInputService:GetMouseLocation()
                        local ScreenDistance = (Vector2.new(MouseLocation.X, MouseLocation.Y) - Vector2.new(PartViewportPosition[1].X, PartViewportPosition[1].Y)).Magnitude
                        
                        if ScreenDistance < Closest and (not Configuration.FoVCheck or ScreenDistance <= Configuration.FoVRadius) then
                            Closest = ScreenDistance
                            Target = Character
                        end
                    end
                end
            end
            
            if Target and Configuration.AimMode == "Camera" then
                local TargetPart = Target:FindFirstChild(Configuration.AimPart)
                if TargetPart then
                    workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, TargetPart.Position)
                end
            end
        end
    end
end)