--[[
    DZ HUB v9.0 - MASTER SCRIPT (FPS LANZAMIENTO)
    - FIX: Redirección de vectores para Silent Aim funcional[cite: 2].
    - FIX: Escaneo de partes de cuerpo para personajes tipo bloque/vóxel[cite: 5].
    - FIX: ESP que no desaparece en transiciones de mapa[cite: 5].
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

--------------------------------------------------------------------------------
-- 1. SISTEMA DE LLAVE ANIMADO (BYPASS VISUAL)[cite: 3]
--------------------------------------------------------------------------------
local function LaunchKeySystem(onSuccess)
    local Screen = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 360, 0, 260)
    Main.Position = UDim2.new(0.5, -180, 0.45, -130)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.BackgroundTransparency = 1

    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = Color3.fromRGB(130, 0, 255)
    Stroke.Thickness = 2
    Stroke.Transparency = 1

    local Title = Instance.new("TextLabel", Main)
    Title.Text = "DZ HUB | FPS LANZAMIENTO"
    Title.Size = UDim2.new(1, 0, 0, 60)
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.Code
    Title.TextSize = 20
    Title.BackgroundTransparency = 1
    Title.TextTransparency = 1

    local Input = Instance.new("TextBox", Main)
    Input.PlaceholderText = "Llave: DZ_2026"
    Input.Size = UDim2.new(0.8, 0, 0, 45)
    Input.Position = UDim2.new(0.1, 0, 0.4, 0)
    Input.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Input.TextColor3 = Color3.new(1,1,1)

    local Verify = Instance.new("TextButton", Main)
    Verify.Text = "INYECTAR BYPASS"
    Verify.Size = UDim2.new(0.8, 0, 0, 45)
    Verify.Position = UDim2.new(0.1, 0, 0.7, 0)
    Verify.BackgroundColor3 = Color3.fromRGB(130, 0, 255)
    Verify.TextColor3 = Color3.new(1,1,1)

    -- Animación de entrada suave[cite: 3]
    TweenService:Create(Main, TweenInfo.new(0.8), {Position = UDim2.new(0.5, -180, 0.5, -130), BackgroundTransparency = 0.1}):Play()
    TweenService:Create(Stroke, TweenInfo.new(1), {Transparency = 0}):Play()
    TweenService:Create(Title, TweenInfo.new(1), {TextTransparency = 0}):Play()

    Verify.MouseButton1Click:Connect(function()
        if Input.Text == "DZ_2026" then
            Screen:Destroy()
            onSuccess()
        end
    end)
end

--------------------------------------------------------------------------------
-- 2. MOTOR DE COMBATE Y VISUALES (EL FIX)[cite: 2, 5]
--------------------------------------------------------------------------------
local function InitializeHub()
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local Window = Rayfield:CreateWindow({
        Name = "DZ HUB v9.0",
        LoadingTitle = "Iniciando Sistemas de FPS...",
        LoadingSubtitle = "Especialista en Lanzamiento"
    })

    getgenv().DZ_Config = {
        SilentAim = false, 
        HitChance = 100,
        ESP_Skeleton = false, 
        ESP_Box = false,
        TeamCheck = true,
        FOV = 200,
        ShowFOV = false
    }

    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Color = Color3.fromRGB(130, 0, 255)
    FOVCircle.Thickness = 1

    -- BUSCADOR DE OBJETIVOS (Soporte para rigs de Vóxel)[cite: 5]
    local function GetTarget()
        local Target, BestDist = nil, getgenv().DZ_Config.FOV
        local Mouse = UserInputService:GetMouseLocation()

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                -- FIX: Busca cualquier parte del cuerpo si los nombres estándar fallan[cite: 5]
                local hitbox = p.Character:FindFirstChild("Head") or p.Character:FindFirstChildWhichIsA("BasePart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                
                if hitbox and hum and hum.Health > 0 then
                    if not getgenv().DZ_Config.TeamCheck or p.Team ~= LocalPlayer.Team then
                        local pos, onScreen = Camera:WorldToViewportPoint(hitbox.Position)
                        if onScreen then
                            local dist = (Vector2.new(pos.X, pos.Y) - Mouse).Magnitude
                            if dist < BestDist then BestDist = dist; Target = hitbox end
                        end
                    end
                end
            end
        end
        return Target
    end

    ----------------------------------------------------------------------------
    -- CONFIGURACIÓN DE TABS[cite: 1]
    ----------------------------------------------------------------------------
    local CombatTab = Window:CreateTab("Combate")
    CombatTab:CreateToggle({Name = "Silent Aim (Metamethod)", Callback = function(v) getgenv().DZ_Config.SilentAim = v end})
    CombatTab:CreateSlider({Name = "Probabilidad de Hit", Range = {0, 100}, CurrentValue = 100, Callback = function(v) getgenv().DZ_Config.HitChance = v end})
    CombatTab:CreateSlider({Name = "Radio del FOV", Range = {50, 800}, CurrentValue = 200, Callback = function(v) getgenv().DZ_Config.FOV = v end})
    CombatTab:CreateToggle({Name = "Mostrar FOV", Callback = function(v) getgenv().DZ_Config.ShowFOV = v end})

    local VisualsTab = Window:CreateTab("Visuales")
    VisualsTab:CreateToggle({Name = "Box ESP", Callback = function(v) getgenv().DZ_Config.ESP_Box = v end})
    VisualsTab:CreateToggle({Name = "Skeleton ESP (Experimental)", Callback = function(v) getgenv().DZ_Config.ESP_Skeleton = v end})
    VisualsTab:CreateToggle({Name = "Revisar Equipo", CurrentValue = true, Callback = function(v) getgenv().DZ_Config.TeamCheck = v end})

    ----------------------------------------------------------------------------
    -- LOGICA DE BYPASS Y EJECUCIÓN[cite: 2, 5]
    ----------------------------------------------------------------------------
    -- Silent Aim: Engaña al juego para que las balas vayan al enemigo[cite: 2]
    local OldIndex
    OldIndex = hookmetamethod(game, "__index", function(Self, Key)
        if not checkcaller() and getgenv().DZ_Config.SilentAim and Key == "Hit" and Self:IsA("Mouse") then
            local Target = GetTarget()
            if Target and math.random(1, 100) <= getgenv().DZ_Config.HitChance then
                return Target.CFrame -- Redirección silenciosa[cite: 2]
            end
        end
        return OldIndex(Self, Key)
    end)

    -- Bucle de renderizado para ESP y FOV[cite: 5]
    RunService.RenderStepped:Connect(function()
        FOVCircle.Visible = getgenv().DZ_Config.ShowFOV
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = getgenv().DZ_Config.FOV

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local highlight = p.Character:FindFirstChild("DZ_MASTER_ESP")
                local isEnemy = not getgenv().DZ_Config.TeamCheck or p.Team ~= LocalPlayer.Team
                
                if getgenv().DZ_Config.ESP_Box and isEnemy then
                    if not highlight then
                        highlight = Instance.new("Highlight", p.Character)
                        highlight.Name = "DZ_MASTER_ESP"
                        highlight.FillColor = Color3.fromRGB(130, 0, 255)
                    end
                    highlight.Enabled = true
                elseif highlight then
                    highlight.Enabled = false
                end
            end
        end
    end)

    Rayfield:Notify({Title = "DZ HUB v9.0", Content = "Inyección Exitosa | FPS Lanzamiento", Duration = 5})
end

LaunchKeySystem(InitializeHub)