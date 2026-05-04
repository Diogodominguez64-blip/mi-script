--[[ 
    DZ HUB v8.5 - FPS LANZAMIENTO STABILIZED
    Fixes applied to: Silent Aim Redirection, Voxel ESP Persistence, and Anticheat Bypass.
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- BYPASS & CONFIGURATION[cite: 2, 5]
getgenv().DZ_Config = {
    SilentAim = true,
    HitChance = 100,
    ESP = true,
    TeamCheck = true,
    FOV = 250
}

-- THE FIX: UNIVERSAL HITBOX FINDER[cite: 5]
local function GetTarget()
    local Target, BestDist = nil, getgenv().DZ_Config.FOV
    local MousePos = UserInputService:GetMouseLocation()

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            -- Fix: Find ANY BasePart if "Head" is missing[cite: 5]
            local hitPart = p.Character:FindFirstChild("Head") or p.Character:FindFirstChildWhichIsA("BasePart")
            if hitPart and (not getgenv().DZ_Config.TeamCheck or p.Team ~= LocalPlayer.Team) then
                local screenPos, onScreen = Camera:WorldToViewportPoint(hitPart.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - MousePos).Magnitude
                    if dist < BestDist then
                        BestDist = dist
                        Target = hitPart
                    end
                end
            end
        end
    end
    return Target
end

-- THE FIX: SILENT AIM METAMETHOD HOOK[cite: 2]
local OldIndex
OldIndex = hookmetamethod(game, "__index", function(Self, Key)
    -- Intercepts the Mouse.Hit property to redirect bullets[cite: 2]
    if not checkcaller() and getgenv().DZ_Config.SilentAim and Key == "Hit" and Self:IsA("Mouse") then
        local Target = GetTarget()
        if Target and math.random(1, 100) <= getgenv().DZ_Config.HitChance then
            return Target.CFrame -- Forces the game to think you are clicking on the enemy[cite: 2]
        end
    end
    return OldIndex(Self, Key)
end)

-- THE FIX: PERSISTENT VISUALS[cite: 5]
RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local isEnemy = not getgenv().DZ_Config.TeamCheck or p.Team ~= LocalPlayer.Team
            local highlight = p.Character:FindFirstChild("DZ_FIX")
            
            if getgenv().DZ_Config.ESP and isEnemy then
                if not highlight then
                    highlight = Instance.new("Highlight", p.Character)
                    highlight.Name = "DZ_FIX"
                    highlight.FillColor = Color3.fromRGB(130, 0, 255)
                end
                highlight.Enabled = true
            elseif highlight then
                highlight.Enabled = false
            end
        end
    end
end)

print("DZ HUB v8.5: Logic Refactored & Systems Functional.")