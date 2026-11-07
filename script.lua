--==================================================================
-- DIAGNOSTICO HYPO — ESP / AIMBOT
-- No modifica nada permanente. Quita el hook al terminar.
--==================================================================

local Players = game:GetService("Players")
local RS      = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LOG, CAUSAS = {}, {}
local function log(s)   table.insert(LOG, tostring(s)) end
local function causa(s) table.insert(CAUSAS, tostring(s)) end
local function try(f, ...) local ok, r = pcall(f, ...) if ok then return r end end

local function dumpTree(root, depth, maxDepth)
    if depth > maxDepth then return end
    for _, v in ipairs(root:GetChildren()) do
        log(string.rep("   ", depth) .. v.ClassName .. " :: " .. v.Name)
        if depth < maxDepth then dumpTree(v, depth + 1, maxDepth) end
    end
end

log("########## DIAGNOSTICO HYPO ##########")

--================= 1. ENTORNO =================
log("\n[1] ENTORNO")
log("Executor: " .. tostring(try(identifyexecutor)))
log("Drawing: " .. tostring(Drawing ~= nil))
log("hookmetamethod: " .. tostring(hookmetamethod ~= nil))
log("checkcaller: " .. tostring(checkcaller ~= nil))
log("getconnections: " .. tostring(getconnections ~= nil))
log("gethui: " .. tostring(gethui ~= nil))

if not Drawing then
    causa("El executor NO tiene Drawing. El ESP con Drawing no puede dibujar nada; hay que rehacerlo con ScreenGui + Frame.")
end
if not hookmetamethod then
    causa("Sin hookmetamethod no hay silent aim posible en este executor.")
end

--================= 2. JUEGO =================
log("\n[2] JUEGO")
log("PlaceId: " .. tostring(game.PlaceId))
log("StreamingEnabled: " .. tostring(workspace.StreamingEnabled))
log("CameraSubject: " .. tostring(try(function() return workspace.CurrentCamera.CameraSubject:GetFullName() end)))

if workspace.StreamingEnabled then
    causa("StreamingEnabled activo: los enemigos lejanos NO existen en el cliente. El ESP solo puede ver lo ya cargado y el aimbot no puede apuntar a distancia.")
end

--================= 3. WORKSPACE =================
log("\n[3] ESTRUCTURA DE WORKSPACE (2 niveles)")
dumpTree(workspace, 0, 2)

--================= 4. JUGADORES =================
log("\n[4] ESTRUCTURA DE PERSONAJES")
local lp = Players.LocalPlayer
local conChar, sinChar, conHead, enOtraCarpeta = 0, 0, 0, 0

for i, p in ipairs(Players:GetPlayers()) do
    if p == lp then continue end
    if i > 12 then break end

    local ch = p.Character
    if not ch then
        sinChar += 1
        log(p.Name .. " -> SIN Character (nil)")
        continue
    end
    conChar += 1

    local parent = try(function() return ch.Parent:GetFullName() end)
    log(p.Name .. " -> Character parenteado en: " .. tostring(parent))
    if parent and parent ~= "Workspace" then enOtraCarpeta += 1 end

    local head = ch:FindFirstChild("Head") or ch:FindFirstChild("head")
    local hrp  = ch:FindFirstChild("HumanoidRootPart")
    local hum  = ch:FindFirstChildOfClass("Humanoid")

    log("   Head: " .. tostring(head ~= nil) ..
        " | HumanoidRootPart: " .. tostring(hrp ~= nil) ..
        " | Humanoid: " .. tostring(hum ~= nil) ..
        " | Partes: " .. tostring(#ch:GetChildren()))
    if head then conHead += 1 end

    if hum then
        log("   Vida: " .. tostring(try(function() return hum.Health end)) ..
            " | Transparencia HRP: " .. tostring(hrp and hrp.Transparency))
    end

    if head and workspace.CurrentCamera then
        local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(head.Position)
        log("   WorldToViewportPoint: en pantalla=" .. tostring(onScreen) ..
            " pos=" .. tostring(math.floor(pos.X)) .. "," .. tostring(math.floor(pos.Y)))
    end
end

if sinChar > 0 then
    causa(sinChar .. " jugador(es) sin Character. Si son todos, el juego no usa el rig estándar: el ESP debe leer su propio contenedor de entidades.")
end
if conChar > 0 and conHead == 0 then
    causa("Hay Character pero SIN parte 'Head'. El ESP/aim apunta a una parte que no existe.")
end
if enOtraCarpeta > 0 then
    causa("Los personajes NO cuelgan de Workspace sino de otra carpeta: hay que iterar ese contenedor, no Players:GetPlayers().")
end

--================= 5. CONTENEDORES DE ENTIDADES =================
log("\n[5] BUSQUEDA DE CONTENEDOR DE ENTIDADES")
local nombres = {}
for _, p in ipairs(Players:GetPlayers()) do
    nombres[p.Name] = true
    nombres[p.DisplayName] = true
end

local function buscarContenedor(root, depth)
    if depth > 3 then return end
    for _, v in ipairs(root:GetChildren()) do
        if v:IsA("Folder") or v:IsA("Model") then
            local aciertos = 0
            for _, c in ipairs(v:GetChildren()) do
                if nombres[c.Name] or c:FindFirstChildOfClass("Humanoid") then aciertos += 1 end
            end
            if aciertos >= 2 then
                log("   POSIBLE CONTENEDOR: " .. v:GetFullName() .. " (" .. aciertos .. " coincidencias)")
                causa("Contenedor de entidades detectado: " .. v:GetFullName())
            end
        end
        buscarContenedor(v, depth + 1)
    end
end
buscarContenedor(workspace, 0)

--================= 6. REMOTES =================
log("\n[6] REMOTES")
log("RemoteEvents/RemoteFunctions en ReplicatedStorage (2 niveles):")
dumpTree(ReplicatedStorage, 0, 2)

local capturados, hookHits = {}, 0
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local m = getnamecallmethod()
    if not checkcaller() and (m == "FireServer" or m == "InvokeServer") then
        hookHits += 1
        local args = {...}
        local tipos = {}
        for i = 1, math.min(#args, 4) do tipos[i] = typeof(args[i]) end
        local k = try(function() return self:GetFullName() end) or "?"
        capturados[k] = capturados[k] or { n = 0, tipos = tipos }
        capturados[k].n += 1
    end
    return oldNamecall(self, ...)
end)

log("\n>>> DISPARA VARIAS VECES AHORA (10s) <<<")
for i = 10, 1, -1 do
    log("   " .. i .. "...")
    task.wait(1)
end

local hitsA = hookHits
task.wait(1.5)
local hitsB = hookHits
if hitsB == hitsA then
    causa("El hook de __namecall dejo de contar: el juego rehokea o elimina hooks. El silent aim se rompe solo.")
end

log("\nRemotes capturados al disparar:")
local cframes = 0
for k, v in pairs(capturados) do
    log("   [" .. v.n .. "x] " .. k .. " | args: " .. table.concat(v.tipos, ", "))
    for _, t in ipairs(v.tipos) do
        if t == "CFrame" then cframes += 1 end
    end
end
if next(capturados) == nil then
    causa("No se capturo NINGUN remote al disparar: el disparo no pasa por el cliente (todo server-side) o usa un sistema sin remotes.")
elseif cframes == 0 then
    causa("Los remotes de disparo NO llevan CFrame: el silent aim por sustitucion de CFrame no puede funcionar.")
else
    log("   -> Hay argumentos CFrame: el silent aim por sustitucion es viable.")
end

-- restaura el hook
pcall(function() hookmetamethod(game, "__namecall", oldNamecall) end)

--================= 7. CAMARA =================
log("\n[7] CONTROL DE CAMARA")
local cam = workspace.CurrentCamera
local orig = cam.CFrame
local prueba = orig * CFrame.Angles(0, math.rad(2), 0)
cam.CFrame = prueba
RS.RenderStepped:Wait()
RS.RenderStepped:Wait()
local ahora = cam.CFrame

if (ahora.Position - prueba.Position).Magnitude < 0.05
   and ahora.LookVector:Dot(prueba.LookVector) > 0.999 then
    log("   La escritura de Camera.CFrame PERSISTE")
else
    log("   La escritura de Camera.CFrame es SOBRESCRITA por el juego")
    causa("El juego controla la camara cada frame. Un aimbot que escriba Camera.CFrame sin BindToRenderStep en RenderPriority.Camera+1 no tendra efecto visible.")
end
cam.CFrame = orig

--================= 8. ANTICHEAT =================
log("\n[8] INDICIOS DE ANTICHEAT")
local pss = try(function() return lp:FindFirstChild("PlayerScripts") end)
if pss then
    for _, v in ipairs(pss:GetDescendants()) do
        if v:IsA("LocalScript") then
            local n = v.Name:lower()
            if n:find("anti") or n:find("guard") or n:find("detect")
               or n:find("citadel") or n:find("shield") or n:find("secur") then
                log("   SOSPECHOSO: " .. v:GetFullName())
                causa("Posible anticheat de cliente: " .. v:GetFullName())
            end
        end
    end
end
log("   Contador de hooks tras restaurar: " .. tostring(hookHits))

--================= 9. RESUMEN =================
log("\n########## CAUSAS DETECTADAS ##########")
if #CAUSAS == 0 then
    log("No se detectaron causas estructurales. El fallo esta en el codigo de ESP/aim, no en el juego.")
else
    for i, c in ipairs(CAUSAS) do
        log(i .. ". " .. c)
    end
end
log("########## FIN ##########")

for _, l in ipairs(LOG) do
    print(l)
end
