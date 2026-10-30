local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- 1. DETECTOR DE CUENTA (El "Welcome")
Player.ChildAdded:Connect(function(character)
	if character and character:FindFirstChild("Humanoid") then
		-- Pequeño delay para que el carácter cargue bien
		character:WaitForChild("HumanoidRootPart")
		
		-- Aquí es donde bounded al Model o al ScreenGui
		-- Asumimos que el executor crea un ScreenGui, pero forzamos su aparición
		-- Si usas 'luau' en el executor, usa: local Module = loadstring(game:HttpGet("..."))
		
		-- --- INICIO DEL MENÚ (Ajusta si tu executor tiene un sistema de Cards o Frames) ---
		
		local Style = {
			Size = UDim2.new(0, 280, 0, 220),
			BackgroundColor3 = Color3.fromRGB(20, 25, 40), -- Fondo oscuro
			Position = UDim2.new(0.5, 0, 0.5, 0),
			StrokeColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 2,
			Padding = UDim2.new(0, 10, 0, 10)
		}

		-- Creamos un Frame principal llamado "ModMenu"
		local Main = Instance.new("Frame")
		Main.Name = "OneShotModMenu"
		Main.Parent = Player:FindFirstChild("PlayerGui") or playergui
		Main:SetProperties(Style)
		Main.LoopAnim = true -- Especial para animaciones

		-- Título y Nombre
		local Title = Instance.new("TextLabel")
		Title.Name = "Title"
		Title.Position = UDim2.new(0, 10, 0, 10)
		Title.Size = UDim2.new(1, -20, 0, 40)
		Title.BackgroundTransparency = 1
		Title.Font = Enum.Font.GothamBold
		Title.Text = "[ ONE SHOT ]"
		Title.TextColor3 = Color3.fromRGB(0, 200, 255)
		Title.Parent = Main
		
		local Account = Instance.new("TextLabel")
		Account.Name = "Account"
		Account.Position = UDim2.new(0, 10, 0, 50)
		Account.Size = UDim2.new(1, -20, 0, 30)
		Account.Text = "Welcome, " .. Player.Name
		Account.Font = Enum.Font.GothamMedium
		Account.TextColor3 = Color3.fromRGB(255, 255, 255)
		Account.BackgroundTransparency = 1
		Account StrokeColor3 = Style.StrokeColor3
		Account.BorderSizePixel = 1
		Account.Parent = Main

		-- Creamos un Frame para los Botones (Cards)
		local Content = Instance.new("Frame")
		Content.Name = "Content"
		Content.Position = UDim2.new(0, 10, 0, 90)
		Content.Size = UDim2.new(1, -20, 0, 100)
		Content.BackgroundColor3 = Color3.fromRGB(30, 36, 54)
		Content.BackgroundTransparency = 1
		Content.BorderSizePixel = 0
		Content.Parent = Main

		local Card = Instance.new("Frame") -- Estilo de botón
		Card.Name = "Card"
		Card.Size = UDim2.new(1, 0, 0, 40)
		Card.BackgroundColor3 = Color3.fromRGB(30, 36, 54)
		Card.BorderColor3 = Color3.fromRGB(255, 255, 255)
		Card.BorderSizePixel = 2
		Card.BorderSizeEnabled = false
		Card.Parent = Content

		-- FUNCIÓN PARA CREAR BOTONES
		local function CreateButton(name,特效)
			local Btn = Instance.new("TextButton")
			Btn.Name = name
			Btn.Parent = Content
			Btn.Size = UDim2.new(1, -20, 0, 40)
			Btn.BackgroundColor3 = Color3.fromRGB(30, 36, 54)
			Btn.BorderSizePixel = 1
			Btn.Text = name..""
			Btn.TextColor3 = Color3.fromRGB(220, 225, 230)
			Btn.Font = Enum.Font.GothamMedium
			Btn.TextScaled = true
			
			-- Animación al hacer clic
			Btn.MouseButton1Click:Connect(function()
				local t = Card.Glowing
				Card.Glowing = not t
			end)
		end

		-- --- 1. ESP (ELECTRONIC SIGHT) ---
		CreateButton("ESP", 1)
		local ESP = Card
		ESP.Glowing = true
		ESP.BackgroundColor3 = Color3.fromRGB(0, 239, 193) -- Verde Neón
		ESP.BorderSizePixel = 2
		ESP.BorderSizeEnabled = true

		-- --- 2. SILENT (FROG WALK) ---
		CreateButton("SILENT", 2)
		local Silent = Card
		Silent.Glowing = true
		Silent.BackgroundColor3 = Color3.fromRGB(255, 215, 0) -- Oro
		Silent.BorderSizePixel = 2
		Silent.BorderSizeEnabled = true

		-- --- 3. AIMBOT (SOFT LOCK) ---
		CreateButton("AIMBOT", 3)
		local Aimbo = Card
		Aimbo.Glowing = true
		Aimbo.BackgroundColor3 = Color3.fromRGB(255, 100, 100) -- Rojo
		Aimbo.BorderSizePixel = 2
		Aimbo.BorderSizeEnabled = true

		-- --- 4. KILL ALL (CLEAR) ---
		CreateButton("KILL ALL", 4)
		local Kill = Card
		Kill.Glowing = true
		Kill.BackgroundColor3 = Color3.fromRGB(255, 80, 50) -- Rojo Fuerte
		Kill.BorderSizePixel = 2
		Kill.BorderSizeEnabled = true

		-- --- LÓGICA DE PERNE (DONDE ACTUA ESP/ARMBOT) ---
		
		-- Detectar Head C0 (Crucial para One Shot)
		local Head = Character:FindFirstChild("Head") or Character:FindFirstChild("HumanoidRootPart")
		if not Head then
			WaitForChild(Head, Character, Enumчасти("Head") or EnumParte("HumanoidRootPart"))
		end

		local function isTouching(touch)
			local part = touch:FindFirstChildOfClass("Part")
			if part and part:IsA("Part") then
				if part.Name == "Toxin" or part.Name == "Jawpod" or part.Name == "Cannon" then
					return true
				end
			end
			return false
		end

		-- LÓGICA ESP
		card.ESP = true -- Referencia a nuestro frame Card
		Card.ESP = true -- Corregir referencia
		local function OnMouseLook()
			Card.ESP = Card.ESP.Value
		end

		local Mouse = Player:GetMouse()

		-- LÓGICA AIMBOT
		Card.Aimbo = true
		local function OnAim(player)
			Card.Aimbo = Card.Aimbo.Value
			
			if Card.Aimbo then
				local LookVector = player:GetMouseLocation()
				local Target = camera.LookAtPlayer.PlayerGui
				if Target:FindFirstChild("AimHandle") then
					Target.AimHandle.CFrame = LookVector * CFrame.new(0, 0, -6)
				end
			end
		end

		-- LÓGICA KILL ALL
