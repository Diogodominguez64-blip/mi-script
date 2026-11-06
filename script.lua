--==============================================================
-- DIOGO DRAG v1 · v1.2.0
-- Pantalla de selección de dispositivo -> menú adaptado
-- Sin lógica de funciones
--==============================================================

local Players = game:GetService("Players")
local UIS     = game:GetService("UserInputService")
local TS      = game:GetService("TweenService")
local LP      = Players.LocalPlayer

local function viewport()
	local cam = workspace.CurrentCamera
	return cam and cam.ViewportSize or Vector2.new(1280, 720)
end

local function suggest()
	local vp = viewport()
	local narrow = vp.X < 900 or (vp.Y / math.max(vp.X, 1)) > 1.05
	return (UIS.TouchEnabled and not UIS.KeyboardEnabled) or narrow and "MOBILE" or "PC"
end

local SUGGESTED = suggest()
local LAYOUT    -- se fija al elegir

--==============================================================
-- THEME
--==============================================================
local T = {
	bg        = Color3.fromRGB(9, 7, 8),
	surface   = Color3.fromRGB(18, 13, 14),
	surface2  = Color3.fromRGB(26, 18, 19),
	border    = Color3.fromRGB(96, 18, 20),
	accent    = Color3.fromRGB(226, 38, 34),
	accentHot = Color3.fromRGB(255, 94, 58),
	text      = Color3.fromRGB(236, 228, 226),
	dim       = Color3.fromRGB(138, 124, 122),
	ok        = Color3.fromRGB(78, 196, 120),
}

local DIM = {
	MOBILE = { rowH = 46, tabH = 54, pad = 8, font = Enum.Font.GothamMedium, fs = 14, panelW = nil, panelH = nil },
	PC     = { rowH = 30, tabH = 36, pad = 6, font = Enum.Font.Gotham,       fs = 12, panelW = 408, panelH = 566 },
}

--==============================================================
-- HELPERS
--==============================================================
local function mk(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props or {}) do o[k] = v end
	if parent then o.Parent = parent end
	return o
end

local function corner(p, r) mk("UICorner", { CornerRadius = UDim.new(0, r) }, p) end
local function stroke(p, c, t) mk("UIStroke", { Color = c or T.border, Thickness = t or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, p) end
local function pad(p, a) mk("UIPadding", { PaddingTop = UDim.new(0, a), PaddingBottom = UDim.new(0, a), PaddingLeft = UDim.new(0, a), PaddingRight = UDim.new(0, a) }, p) end

--==============================================================
-- RAÍZ + FONDO
--==============================================================
local gui = mk("ScreenGui", {
	Name = "DiogoDragUI", ResetOnSpawn = false, IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 9999,
})
pcall(function()
	if gethui then gui.Parent = gethui() else gui.Parent = game:GetService("CoreGui") end
end)
if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

local bgLayer = mk("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = T.bg, BorderSizePixel = 0, ZIndex = 1 }, gui)

local dragon = mk("ImageLabel", {
	Size = UDim2.fromScale(1.15, 1.15), Position = UDim2.fromScale(-0.08, -0.05),
	BackgroundTransparency = 1, Image = "rbxassetid://0",
	ImageColor3 = Color3.fromRGB(150, 22, 22), ImageTransparency = 0.5,
	ScaleType = Enum.ScaleType.Crop, ZIndex = 1,
}, bgLayer)
mk("UIGradient", {
	Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.15), NumberSequenceKeypoint.new(1, 0.95) }),
	Rotation = 90,
}, dragon)

mk("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(6, 4, 5), BackgroundTransparency = 0.3, BorderSizePixel = 0, ZIndex = 2 }, bgLayer)

--==============================================================
-- PANTALLA DE SELECCIÓN
--==============================================================
local gate = mk("Frame", { Name = "Gate", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 50 }, gui)

mk("TextLabel", {
	Text = "DIOGO DRAG v1",
	Font = Enum.Font.GothamBlack, TextSize = 30, TextColor3 = T.text,
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 0.16),
	Size = UDim2.new(1, -40, 0, 40),
	ZIndex = 51,
}, gate)

mk("TextLabel", {
	Text = "SELECCIONA TU DISPOSITIVO",
	Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = T.accent,
	TextTransparency = 0.1, BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 0.16),
	Size = UDim2.new(1, -40, 0, 62),
	ZIndex = 51,
}, gate)

local detectedLbl = mk("TextLabel", {
	Text = "DETECTADO: " .. (SUGGESTED == "MOBILE" and "TELÉFONO" or "PC"),
	Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = T.ok,
	TextTransparency = 0.2, BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 0.16),
	Size = UDim2.new(1, -40, 0, 84),
	ZIndex = 51,
}, gate)

local wide = viewport().X >= 800

local wrap = mk("Frame", {
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = wide and UDim2.fromOffset(520, 190) or UDim2.new(0.86, 0, 0, 300),
	ZIndex = 51,
}, gate)
mk("UIListLayout", {
	FillDirection = wide and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	Padding = UDim.new(0, 14),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, wrap)

local lastUsed
pcall(function()
	if readfile and isfile and isfile("DiogoDrag.layout") then
		local v = readfile("DiogoDrag.layout")
		if v == "PC" or v == "MOBILE" then lastUsed = v end
	end
end)

local function deviceCard(order, kind, label)
	local isPc = kind == "PC"
	local card = mk("TextButton", {
		Text = "", AutoButtonColor = false,
		BackgroundColor3 = T.surface2, BackgroundTransparency = 0.15,
		BorderSizePixel = 0, LayoutOrder = order,
		Size = wide and UDim2.new(0.5, -7, 1, 0) or UDim2.new(1, 0, 0, 132),
		ZIndex = 52,
	}, wrap)
	corner(card, 12)
	local st = stroke(card, kind == SUGGESTED and T.accentHot or T.border, kind == SUGGESTED and 2 or 1)

	-- icono dibujado
	local icon = mk("Frame", {
		BackgroundColor3 = T.border, BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, -14),
		Size = isPc and UDim2.fromOffset(58, 38) or UDim2.fromOffset(28, 48),
		ZIndex = 53,
	}, card)
	corner(icon, isPc and 4 or 6)
	stroke(icon, T.accent, 1)

	if isPc then
		mk("Frame", { Size = UDim2.fromOffset(22, 3), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 1, 4), BackgroundColor3 = T.border, BorderSizePixel = 0, ZIndex = 53 }, icon)
	else
		mk("Frame", { Size = UDim2.fromOffset(12, 2), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0, 5), BackgroundColor3 = T.accent, BorderSizePixel = 0, ZIndex = 54 }, icon)
	end

	mk("TextLabel", {
		Text = label, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = T.text,
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 78), Size = UDim2.new(1, 0, 0, 18), ZIndex = 53,
	}, card)

	mk("TextLabel", {
		Text = isPc and "Ratón y teclado" or "Táctil",
		Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = T.dim,
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 98), Size = UDim2.new(1, 0, 0, 14), ZIndex = 53,
	}, card)

	if kind == SUGGESTED or kind == lastUsed then
		mk("TextLabel", {
			Text = kind == lastUsed and "ÚLTIMO USO" or "DETECTADO",
			Font = Enum.Font.GothamBold, TextSize = 8,
			TextColor3 = kind == lastUsed and T.dim or T.ok,
			BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -10, 0, 8), Size = UDim2.fromOffset(80, 12),
			TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 53,
		}, card)
	end

	card.MouseEnter:Connect(function()
		TS:Create(st, TweenInfo.new(0.15), { Color = T.accentHot }):Play()
		TS:Create(card, TweenInfo.new(0.15), { BackgroundTransparency = 0 }):Play()
	end)
	card.MouseLeave:Connect(function()
		TS:Create(st, TweenInfo.new(0.15), { Color = kind == SUGGESTED and T.accentHot or T.border }):Play()
		TS:Create(card, TweenInfo.new(0.15), { BackgroundTransparency = 0.15 }):Play()
	end)

	return card
end

local cardPc = deviceCard(1, "PC", "PC")
local cardPhone = deviceCard(2, "MOBILE", "TELÉFONO")

--==============================================================
-- MENÚ (se construye tras elegir)
--==============================================================
local panel, fab

local function buildMenu(layout)
	local isMobile = layout == "MOBILE"
	local D = DIM[layout]

	panel = mk("Frame", {
		Name = "Panel", BackgroundColor3 = T.surface, BackgroundTransparency = 0.06,
		BorderSizePixel = 0, ZIndex = 5,
	}, gui)
	corner(panel, isMobile and 0 or 10)
	stroke(panel, T.border, 1)

	if isMobile then
		panel.Size = UDim2.fromScale(1, 1)
	else
		panel.AnchorPoint = Vector2.new(1, 0.5)
		panel.Position = UDim2.new(1, -24, 0.5, 0)
		panel.Size = UDim2.fromOffset(D.panelW, D.panelH)
	end
	pad(panel, D.pad)

	local header = mk("Frame", {
		Size = UDim2.new(1, 0, 0, isMobile and 56 or 38),
		BackgroundColor3 = T.surface2, BackgroundTransparency = 0.2,
		BorderSizePixel = 0, ZIndex = 6,
	}, panel)
	corner(header, 8)
	mk("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.fromScale(0, 1), BackgroundColor3 = T.accent, BorderSizePixel = 0, ZIndex = 7 }, header)

	mk("TextLabel", {
		Text = "DIOGO DRAG v1", Font = Enum.Font.GothamBlack,
		TextSize = isMobile and 18 or 15, TextColor3 = T.text,
		TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -130, 1, 0), ZIndex = 7,
	}, header)

	mk("TextLabel", {
		Text = layout, Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = T.dim,
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -46, 0.5, 0), Size = UDim2.fromOffset(44, 14),
		TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 7,
	}, header)

	local closeBtn = mk("TextButton", {
		Text = "✕", Font = Enum.Font.GothamBold, TextSize = isMobile and 20 or 16,
		TextColor3 = T.dim, BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(30, 30), ZIndex = 7,
	}, header)

	local tabBar = mk("Frame", { BackgroundColor3 = T.surface2, BackgroundTransparency = 0.35, BorderSizePixel = 0, ZIndex = 6 }, panel)
	local body = mk("Frame", { BackgroundTransparency = 1, ZIndex = 6 }, panel)

	if isMobile then
		tabBar.Size = UDim2.new(1, 0, 0, D.tabH)
		tabBar.Position = UDim2.new(0, 0, 1, 0)
		tabBar.AnchorPoint = Vector2.new(0, 1)
		body.Position = UDim2.fromOffset(0, 56 + D.pad)
		body.Size = UDim2.new(1, 0, 1, -(56 + D.tabH + D.pad * 2))
	else
		tabBar.Size = UDim2.new(0, 96, 1, -(38 + D.pad * 2))
		tabBar.Position = UDim2.fromOffset(0, 38 + D.pad)
		body.Position = UDim2.fromOffset(96 + D.pad, 38 + D.pad)
		body.Size = UDim2.new(1, -(96 + D.pad * 2), 1, -(38 + D.pad * 2))
	end
	corner(tabBar, 8)
	mk("UIListLayout", {
		FillDirection = isMobile and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, isMobile and 4 or 3),
		HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center,
	}, tabBar)
	pad(tabBar, 6)

	local content = mk("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
		ScrollBarThickness = isMobile and 3 or 2, ScrollBarImageColor3 = T.border,
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 6,
	}, body)
	mk("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, isMobile and 6 or 4) }, content)
	pad(content, 2)

	-- widgets
	local function section(txt)
		return mk("TextLabel", {
			Text = string.upper(txt), Font = Enum.Font.GothamBold,
			TextSize = isMobile and 11 or 10, TextColor3 = T.accent,
			TextTransparency = 0.1, TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22),
		}, content)
	end

	local function row(h)
		local r = mk("Frame", {
			Size = UDim2.new(1, 0, 0, h or D.rowH), BackgroundColor3 = T.surface2,
			BackgroundTransparency = 0.35, BorderSizePixel = 0,
		}, content)
		corner(r, 6)
		pad(r, 10)
		return r
	end

	local function toggle(label, on)
		local r = row()
		mk("TextLabel", { Text = label, Font = D.font, TextSize = D.fs, TextColor3 = T.text, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Size = UDim2.new(1, -52, 1, 0) }, r)
		local track = mk("Frame", { Size = UDim2.fromOffset(40, 22), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), BackgroundColor3 = on and T.accent or Color3.fromRGB(46, 36, 37), BorderSizePixel = 0 }, r)
		corner(track, 11)
		local knob = mk("Frame", { Size = UDim2.fromOffset(16, 16), Position = UDim2.fromOffset(on and 21 or 3, 3), BackgroundColor3 = T.text, BorderSizePixel = 0 }, track)
		corner(knob, 8)
		local btn = mk("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) }, r)
		local state = on or false
		btn.MouseButton1Click:Connect(function()
			state = not state
			TS:Create(track, TweenInfo.new(0.15), { BackgroundColor3 = state and T.accent or Color3.fromRGB(46, 36, 37) }):Play()
			TS:Create(knob, TweenInfo.new(0.15), { Position = UDim2.fromOffset(state and 21 or 3, 3) }):Play()
		end)
		return r
	end

	local function slider(label, value, min, max)
		local r = row(isMobile and 62 or 46)
		mk("TextLabel", { Text = label, Font = D.font, TextSize = D.fs, TextColor3 = T.text, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Size = UDim2.new(1, -50, 0, 18) }, r)
		local valBox = mk("TextLabel", { Text = tostring(value), Font = Enum.Font.GothamBold, TextSize = D.fs, TextColor3 = T.accentHot, TextXAlignment = Enum.TextXAlignment.Right, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(44, 18) }, r)
		local track = mk("Frame", { Size = UDim2.new(1, 0, 0, isMobile and 8 or 6), Position = UDim2.new(0, 0, 1, isMobile and -10 or -8), BackgroundColor3 = Color3.fromRGB(40, 30, 31), BorderSizePixel = 0 }, r)
		corner(track, 4)
		local fill = mk("Frame", { Size = UDim2.fromScale((value - min) / (max - min), 1), BackgroundColor3 = T.accent, BorderSizePixel = 0 }, track)
		corner(fill, 4)
		local hit = mk("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, isMobile and 26 or 18), Position = UDim2.new(0, 0, 1, isMobile and -20 or -14) }, r)
		local function set(px)
			local a = math.clamp(px / track.AbsoluteSize.X, 0, 1)
			fill.Size = UDim2.fromScale(a, 1)
			valBox.Text = tostring(math.floor(min + (max - min) * a + 0.5))
		end
		hit.MouseButton1Down:Connect(function() set(UIS:GetMouseLocation().X - track.AbsolutePosition.X) end)
		hit.MouseMoved:Connect(function()
			if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or #UIS:GetTouches() > 0 then
				set(UIS:GetMouseLocation().X - track.AbsolutePosition.X)
			end
		end)
		return r
	end

	local function keybind(label, key)
		local r = row()
		mk("TextLabel", { Text = label, Font = D.font, TextSize = D.fs, TextColor3 = T.text, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Size = UDim2.new(1, -80, 1, 0) }, r)
		local box = mk("TextButton", { Text = key, Font = Enum.Font.GothamBold, TextSize = isMobile and 12 or 10, TextColor3 = T.accentHot, BackgroundColor3 = Color3.fromRGB(40, 28, 29), BorderSizePixel = 0, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(64, isMobile and 30 or 22) }, r)
		corner(box, 5)
		stroke(box, T.border, 1)
		return r
	end

	local function listRow(name, dist, state)
		local r = row()
		mk("TextLabel", { Text = name, Font = Enum.Font.GothamMedium, TextSize = D.fs, TextColor3 = T.text, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Size = UDim2.new(0.5, 0, 1, 0) }, r)
		mk("TextLabel", { Text = dist .. " studs", Font = Enum.Font.Gotham, TextSize = D.fs - 1, TextColor3 = T.dim, BackgroundTransparency = 1, Size = UDim2.new(0.25, 0, 1, 0) }, r)
		mk("TextLabel", { Text = state, Font = Enum.Font.GothamBold, TextSize = D.fs - 2, TextColor3 = state == "ENEMIGO" and T.accentHot or T.ok, TextXAlignment = Enum.TextXAlignment.Right, BackgroundTransparency = 1, Size = UDim2.new(0.25, 0, 1, 0) }, r)
		return r
	end

	-- pestañas
	local PAGES = {}
	local function page(label)
		local btn = mk("TextButton", {
			Text = label, Font = Enum.Font.GothamBold, TextSize = isMobile and 9 or 10,
			TextColor3 = T.dim, BackgroundColor3 = T.surface2, BackgroundTransparency = 0.6,
			BorderSizePixel = 0, LayoutOrder = #PAGES,
			Size = isMobile and UDim2.new(0.24, 0, 1, -12) or UDim2.new(1, 0, 0, D.tabH - 8),
		}, tabBar)
		corner(btn, 6)
		local frame = mk("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = #PAGES, Visible = false }, content)
		mk("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, isMobile and 6 or 4) }, frame)
		table.insert(PAGES, { btn = btn, frame = frame })
	end

	local function select(i)
		for n, p in ipairs(PAGES) do
			local on = n == i
			p.frame.Visible = on
			TS:Create(p.btn, TweenInfo.new(0.12), {
				BackgroundColor3 = on and T.accent or T.surface2,
				TextColor3 = on and Color3.new(1, 1, 1) or T.dim,
			}):Play()
		end
	end

	-- contenido
	local aim = PAGES[1] or nil
	page("AIMBOT"); page("VISUAL"); page("JUGADORES"); page("AJUSTES")

	section("Aimbot"); toggle("Activar", true); slider("Smoothing", 35, 1, 100); slider("Predicción", 12, 0, 50)
	toggle("Hitbox prioritario", false); keybind("Tecla de apuntado", isMobile and "TOCAR" or "MOUSE2"); toggle("Ignorar aliados", true)
	section("FOV / Objetivo"); toggle("Mostrar círculo FOV", true); slider("Radio FOV", 120, 20, 400); toggle("Verificar visibilidad", false)

	local p2 = PAGES[2].frame
	section("ESP"); toggle("Cajas", true); toggle("Nombres", true); toggle("Distancia", false); toggle("Línea de trazado", true); slider("Grosor", 2, 1, 6)
	section("Vista previa"); local prev = row(isMobile and 72 or 60)
	mk("TextLabel", { Text = "Enemigo_01 · 84 studs", Font = Enum.Font.GothamMedium, TextSize = D.fs, TextColor3 = T.text, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16) }, prev)
	local box = mk("Frame", { Size = UDim2.fromOffset(34, 34), Position = UDim2.fromOffset(0, 22), BackgroundTransparency = 1 }, prev)
	stroke(box, T.accent, 1); corner(box, 4)

	section("Lista de jugadores"); listRow("Enemigo_01", 84, "ENEMIGO"); listRow("Jugador_Ana", 142, "AMIGO"); listRow("Xx_Rival_xX", 203, "ENEMIGO")

	local p4 = PAGES[4].frame
	section("General"); toggle("Marca de agua", true); toggle("Partículas de brasas", not isMobile); keybind("Tecla ocultar menú", isMobile and "FAB" or "INSERT")
	section("Interfaz"); slider("Opacidad del panel", 100, 30, 100); slider("Desenfoque del fondo", 14, 0, 30)
	section("Rendimiento"); toggle("FPS Boost", false); slider("Nivel de optimización", 2, 1, 3)
	section("Perfiles"); keybind("Perfil activo", "DEFAULT")
	section("Exportar")

	for i, p in ipairs(PAGES) do p.btn.MouseButton1Click:Connect(function() select(i) end) end
	select(1)

	-- marca de agua
	mk("TextLabel", {
		Text = "DIOGO DRAG v1", Font = Enum.Font.GothamBlack, TextSize = isMobile and 9 or 8,
		TextColor3 = T.accent, TextTransparency = 0.72, TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 1),
		Position = isMobile and UDim2.new(0, 12, 1, -D.tabH - 6) or UDim2.new(0, 12, 1, -10),
		Size = UDim2.fromOffset(160, 12), ZIndex = 7,
	}, panel)

	-- botón flotante
	fab = mk("TextButton", {
		Text = "DRAG", Font = Enum.Font.GothamBlack, TextSize = 11, TextColor3 = T.text,
		BackgroundColor3 = T.accent, BorderSizePixel = 0, Size = UDim2.fromOffset(58, 58),
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 84),
		ZIndex = 20, Visible = false,
	}, gui)
	corner(fab, 29); stroke(fab, T.accentHot, 1)

	closeBtn.MouseButton1Click:Connect(function() panel.Visible = false; fab.Visible = true end)
	fab.MouseButton1Click:Connect(function() panel.Visible = true; fab.Visible = false end)

	if not isMobile then
		local dragging, offset = false, nil
		header.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				offset = input.Position - panel.AbsolutePosition
			end
		end)
		UIS.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				panel.Position = UDim2.fromOffset(input.Position.X - offset.X, input.Position.Y - offset.Y)
			end
		end)
		UIS.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
		end)
		UIS.InputBegan:Connect(function(input, processed)
			if processed then return end
			if input.KeyCode == Enum.KeyCode.Insert then
				panel.Visible = not panel.Visible
				fab.Visible = not panel.Visible
			end
		end)
	end
end

--==============================================================
-- ELECCIÓN
--==============================================================
local function choose(kind)
	if LAYOUT then return end
	LAYOUT = kind
	pcall(function()
		if writefile then writefile("DiogoDrag.layout", kind) end
	end)
	local fade = TS:Create(gate, TweenInfo.new(0.25), { BackgroundTransparency = 1 })
	buildMenu(kind)
	panel.BackgroundTransparency = 1
	TS:Create(panel, TweenInfo.new(0.25), { BackgroundTransparency = 0.06 }):Play()
	task.delay(0.2, function() gate:Destroy() end)
end

cardPc.MouseButton1Click:Connect(function() choose("PC") end)
cardPhone.MouseButton1Click:Connect(function() choose("MOBILE") end)
