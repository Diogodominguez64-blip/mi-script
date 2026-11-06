--==============================================================
-- DIOGO DRAG v1 · v1.3.0
-- Panel flotante · rail de iconos · vista previa ESP funcional
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
local LAYOUT

local T = {
	bg        = Color3.fromRGB(12, 9, 10),
	surface   = Color3.fromRGB(22, 16, 17),
	surface2  = Color3.fromRGB(31, 23, 24),
	rail      = Color3.fromRGB(17, 12, 13),
	border    = Color3.fromRGB(74, 22, 24),
	accent    = Color3.fromRGB(226, 38, 34),
	accentHot = Color3.fromRGB(255, 94, 58),
	text      = Color3.fromRGB(236, 228, 226),
	dim       = Color3.fromRGB(128, 114, 112),
	ok        = Color3.fromRGB(78, 196, 120),
}

local DIM = {
	MOBILE = { rowH = 46, railW = 56, iconS = 20, pad = 8,  headH = 54, footH = 16, font = Enum.Font.GothamMedium, fs = 14 },
	PC     = { rowH = 34, railW = 62, iconS = 18, pad = 8,  headH = 40, footH = 14, font = Enum.Font.Gotham,       fs = 12 },
}

local function mk(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props or {}) do o[k] = v end
	if parent then o.Parent = parent end
	return o
end
local function corner(p, r) mk("UICorner", { CornerRadius = UDim.new(0, r) }, p) end
local function stroke(p, c, t) mk("UIStroke", { Color = c or T.border, Thickness = t or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, p) end
local function pad(p, a) mk("UIPadding", { PaddingTop = UDim.new(0, a), PaddingBottom = UDim.new(0, a), PaddingLeft = UDim.new(0, a), PaddingRight = UDim.new(0, a) }, p) end

local gui = mk("ScreenGui", {
	Name = "DiogoDragUI", ResetOnSpawn = false, IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 9999,
})
pcall(function()
	if gethui then gui.Parent = gethui() else gui.Parent = game:GetService("CoreGui") end
end)
if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

--==============================================================
-- GATE
--==============================================================
local gate = mk("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = T.bg, BackgroundTransparency = 0.12, ZIndex = 50 }, gui)

mk("TextLabel", {
	Text = "DIOGO DRAG v1", Font = Enum.Font.GothamBlack, TextSize = 28, TextColor3 = T.text,
	BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0.18, 0), Size = UDim2.new(1, -40, 0, 36), ZIndex = 51,
}, gate)

mk("TextLabel", {
	Text = "SELECCIONA TU DISPOSITIVO", Font = Enum.Font.GothamBold, TextSize = 10,
	TextColor3 = T.accent, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0.18, 0), Size = UDim2.new(1, -40, 0, 54), ZIndex = 51,
}, gate)

mk("TextLabel", {
	Text = "DETECTADO: " .. (SUGGESTED == "MOBILE" and "TELÉFONO" or "PC"),
	Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = T.ok, TextTransparency = 0.15,
	BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0.18, 0), Size = UDim2.new(1, -40, 0, 76), ZIndex = 51,
}, gate)

local wide = viewport().X >= 800
local wrap = mk("Frame", {
	BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
	Size = wide and UDim2.fromOffset(480, 170) or UDim2.new(0.86, 0, 0, 300), ZIndex = 51,
}, gate)
mk("UIListLayout", {
	FillDirection = wide and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
	HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center,
	Padding = UDim.new(0, 14), SortOrder = Enum.SortOrder.LayoutOrder,
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
		Text = "", AutoButtonColor = false, BackgroundColor3 = T.surface,
		BackgroundTransparency = 0.1, BorderSizePixel = 0, LayoutOrder = order,
		Size = wide and UDim2.new(0.5, -7, 1, 0) or UDim2.new(1, 0, 0, 128), ZIndex = 52,
	}, wrap)
	corner(card, 12)
	local st = stroke(card, kind == SUGGESTED and T.accentHot or T.border, kind == SUGGESTED and 2 or 1)

	local icon = mk("Frame", {
		BackgroundColor3 = T.border, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, -16), Size = isPc and UDim2.fromOffset(56, 36) or UDim2.fromOffset(26, 44), ZIndex = 53,
	}, card)
	corner(icon, isPc and 4 or 6)
	stroke(icon, T.accent, 1)
	if isPc then
		mk("Frame", { Size = UDim2.fromOffset(20, 3), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 1, 4), BackgroundColor3 = T.border, BorderSizePixel = 0, ZIndex = 53 }, icon)
	else
		mk("Frame", { Size = UDim2.fromOffset(10, 2), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0, 5), BackgroundColor3 = T.accent, BorderSizePixel = 0, ZIndex = 54 }, icon)
	end

	mk("TextLabel", {
		Text = label, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = T.text,
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 74), Size = UDim2.new(1, 0, 0, 18), ZIndex = 53,
	}, card)
	mk("TextLabel", {
		Text = isPc and "Ratón y teclado" or "Táctil", Font = Enum.Font.Gotham, TextSize = 10,
		TextColor3 = T.dim, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 94), Size = UDim2.new(1, 0, 0, 14), ZIndex = 53,
	}, card)

	if kind == SUGGESTED or kind == lastUsed then
		mk("TextLabel", {
			Text = kind == lastUsed and "ÚLTIMO USO" or "DETECTADO", Font = Enum.Font.GothamBold,
			TextSize = 8, TextColor3 = kind == lastUsed and T.dim or T.ok, BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 8),
			Size = UDim2.fromOffset(80, 12), TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 53,
		}, card)
	end
	return card
end

local cardPc = deviceCard(1, "PC", "PC")
local cardPhone = deviceCard(2, "MOBILE", "TELÉFONO")

--==============================================================
-- MENÚ
--==============================================================
local panel, fab

local function buildMenu(layout)
	local isMobile = layout == "MOBILE"
	local D = DIM[layout]

	panel = mk("Frame", { Name = "Panel", BackgroundColor3 = T.surface, BorderSizePixel = 0, ZIndex = 5 }, gui)
	corner(panel, 14)
	stroke(panel, T.border, 1)
	mk("UIGradient", {
		Color = ColorSequence.new(T.surface, Color3.fromRGB(15, 10, 11)),
		Rotation = 90,
	}, panel)

	if isMobile then
		panel.AnchorPoint = Vector2.new(0.5, 0.5)
		panel.Position = UDim2.fromScale(0.5, 0.5)
		panel.Size = UDim2.new(0.94, 0, 1, -150)
	else
		panel.AnchorPoint = Vector2.new(1, 0.5)
		panel.Position = UDim2.new(1, -26, 0.5, 0)
		panel.Size = UDim2.fromOffset(430, 590)
	end
	pad(panel, D.pad)

	-- dragón dentro del panel
	local dragon = mk("ImageLabel", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = "rbxassetid://0",
		ImageColor3 = Color3.fromRGB(150, 20, 20), ImageTransparency = 0.55,
		ScaleType = Enum.ScaleType.Crop, ZIndex = 6,
	}, panel)
	corner(dragon, 14)
	mk("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(0.55, 0.85), NumberSequenceKeypoint.new(1, 1),
		}),
		Rotation = 90,
	}, dragon)

	-- cabecera
	local header = mk("Frame", {
		Size = UDim2.new(1, 0, 0, D.headH), BackgroundColor3 = T.surface2,
		BackgroundTransparency = 0.25, BorderSizePixel = 0, ZIndex = 8,
	}, panel)
	corner(header, 10)
	mk("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.fromScale(0, 1), BackgroundColor3 = T.accent, BorderSizePixel = 0, ZIndex = 9 }, header)

	mk("TextLabel", {
		Text = "DIOGO DRAG v1", Font = Enum.Font.GothamBlack, TextSize = isMobile and 17 or 14,
		TextColor3 = T.text, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -120, 1, 0), ZIndex = 9,
	}, header)

	mk("TextLabel", {
		Text = layout, Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = T.dim,
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -44, 0.5, 0), Size = UDim2.fromOffset(42, 14),
		TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 9,
	}, header)

	local closeBtn = mk("TextButton", {
		Text = "✕", Font = Enum.Font.GothamBold, TextSize = isMobile and 19 or 15, TextColor3 = T.dim,
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(32, 32), ZIndex = 9,
	}, header)

	-- cuerpo
	local bodyY = D.headH + 8
	local bodyH = D.headH + 8 + D.footH + 8

	local body = mk("Frame", {
		Position = UDim2.fromOffset(0, bodyY), Size = UDim2.new(1, 0, 1, -bodyH),
		BackgroundTransparency = 1, ZIndex = 8,
	}, panel)

	local rail = mk("Frame", { Size = UDim2.fromOffset(D.railW, 0), Size2 = nil, BackgroundColor3 = T.rail, BackgroundTransparency = 0.2, BorderSizePixel = 0, ZIndex = 8 }, body)
	rail.Size = UDim2.new(0, D.railW, 1, 0)
	corner(rail, 10)
	mk("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Top }, rail)
	pad(rail, 7)

	local content = mk("ScrollingFrame", {
		Position = UDim2.fromOffset(D.railW + 8, 0), Size = UDim2.new(1, -(D.railW + 8), 1, 0),
		BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
		ScrollBarImageColor3 = T.border, CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 8,
	}, body)
	mk("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) }, content)
	pad(content, 2)

	-- widgets
	local function section(txt)
		return mk("TextLabel", {
			Text = string.upper(txt), Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = T.accent,
			TextTransparency = 0.1, TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20),
		}, content)
	end

	local function row(h)
		local r = mk("Frame", {
			Size = UDim2.new(1, 0, 0, h or D.rowH), BackgroundColor3 = T.surface2,
			BackgroundTransparency = 0.3, BorderSizePixel = 0,
		}, content)
		corner(r, 9)
		pad(r, 11)
		return r
	end

	local function toggle(label, on, cb)
		local r = row()
		mk("TextLabel", {
			Text = label, Font = D.font, TextSize = D.fs, TextColor3 = T.text,
			TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Size = UDim2.new(1, -50, 1, 0),
		}, r)
		local track = mk("Frame", {
			Size = UDim2.fromOffset(38, 21), AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			BackgroundColor3 = on and T.accent or Color3.fromRGB(50, 39, 40), BorderSizePixel = 0,
		}, r)
		corner(track, 11)
		local knob = mk("Frame", { Size = UDim2.fromOffset(15, 15), Position = UDim2.fromOffset(on and 20 or 3, 3), BackgroundColor3 = T.text, BorderSizePixel = 0 }, track)
		corner(knob, 8)
		local btn = mk("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) }, r)
		local state = on or false
		btn.MouseButton1Click:Connect(function()
			state = not state
			TS:Create(track, TweenInfo.new(0.15), { BackgroundColor3 = state and T.accent or Color3.fromRGB(50, 39, 40) }):Play()
			TS:Create(knob, TweenInfo.new(0.15), { Position = UDim2.fromOffset(state and 20 or 3, 3) }):Play()
			if cb then cb(state) end
		end)
		return r
	end

	local function slider(label, value, min, max)
		local r = row(isMobile and 60 or 46)
		mk("TextLabel", { Text = label, Font = D.font, TextSize = D.fs, TextColor3 = T.text, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Size = UDim2.new(1, -46, 0, 17) }, r)
		local valBox = mk("TextLabel", { Text = tostring(value), Font = Enum.Font.GothamBold, TextSize = D.fs, TextColor3 = T.accentHot, TextXAlignment = Enum.TextXAlignment.Right, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(42, 17) }, r)
		local track = mk("Frame", { Size = UDim2.new(1, 0, 0, 7), Position = UDim2.new(0, 0, 1, -11), BackgroundColor3 = Color3.fromRGB(46, 35, 36), BorderSizePixel = 0 }, r)
		corner(track, 4)
		local fill = mk("Frame", { Size = UDim2.fromScale((value - min) / (max - min), 1), BackgroundColor3 = T.accent, BorderSizePixel = 0 }, track)
		corner(fill, 4)
		local hit = mk("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, isMobile and 26 or 18), Position = UDim2.new(0, 0, 1, isMobile and -20 or -14) }, r)
		local function set(px)
			local a = math.clamp(px / math.max(track.AbsoluteSize.X, 1), 0, 1)
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
		mk("TextLabel", { Text = label, Font = D.font, TextSize = D.fs, TextColor3 = T.text, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Size = UDim2.new(1, -76, 1, 0) }, r)
		local box = mk("TextButton", { Text = key, Font = Enum.Font.GothamBold, TextSize = isMobile and 12 or 10, TextColor3 = T.accentHot, BackgroundColor3 = Color3.fromRGB(48, 30, 31), BorderSizePixel = 0, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(62, isMobile and 30 or 22) }, r)
		corner(box, 6)
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

	-- rail
	local PAGES = {}
	local function icon(parent, kind)
		local f = mk("Frame", { Size = UDim2.fromOffset(D.iconS, D.iconS), BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) }, parent)
		if kind == "aim" then
			local ring = mk("Frame", { Size = UDim2.fromOffset(13, 13), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 1 }, f)
			corner(ring, 7); stroke(ring, T.dim, 1.5)
			for _, p in ipairs({ { 0.5, 0, 1, 4 }, { 0.5, 1, 1, 4 }, { 0, 0.5, 4, 1 }, { 1, 0.5, 4, 1 } }) do
				mk("Frame", { AnchorPoint = Vector2.new(p[1], p[2]), Position = UDim2.fromScale(p[1], p[2]), Size = UDim2.fromOffset(p[3], p[4]), BackgroundColor3 = T.dim, BorderSizePixel = 0 }, f)
			end
		elseif kind == "eye" then
			local e = mk("Frame", { Size = UDim2.fromOffset(17, 11), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 1 }, f)
			corner(e, 6); stroke(e, T.dim, 1.5)
			local pupil = mk("Frame", { Size = UDim2.fromOffset(5, 5), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), BackgroundColor3 = T.dim, BorderSizePixel = 0 }, e)
			corner(pupil, 3)
		elseif kind == "person" then
			local h = mk("Frame", { Size = UDim2.fromOffset(7, 7), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 1), BackgroundColor3 = T.dim, BorderSizePixel = 0 }, f)
			corner(h, 4)
			local b = mk("Frame", { Size = UDim2.fromOffset(14, 8), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 10), BackgroundColor3 = T.dim, BorderSizePixel = 0 }, f)
			corner(b, 5)
		else
			local c = mk("Frame", { Size = UDim2.fromOffset(13, 13), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 1 }, f)
			corner(c, 7); stroke(c, T.dim, 1.5)
			local d = mk("Frame", { Size = UDim2.fromOffset(5, 5), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), BackgroundColor3 = T.dim, BorderSizePixel = 0 }, c)
			corner(d, 3)
		end
		return f
	end

	local function paint(f, color)
		for _, d in ipairs(f:GetDescendants()) do
			if d:IsA("Frame") then
				if d.BackgroundTransparency == 0 then d.BackgroundColor3 = color end
				local s = d:FindFirstChildOfClass("UIStroke")
				if s then s.Color = color end
			end
		end
	end

	local function page(kind)
		local btn = mk("TextButton", {
			Text = "", BackgroundColor3 = T.surface2, BackgroundTransparency = 0.5,
			BorderSizePixel = 0, LayoutOrder = #PAGES,
			Size = UDim2.new(1, 0, 0, isMobile and 44 or 38),
		}, rail)
		corner(btn, 9)
		local ic = icon(btn, kind)
		local frame = mk("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = #PAGES, Visible = false }, content)
		mk("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) }, frame)
		table.insert(PAGES, { btn = btn, frame = frame, ic = ic })
	end

	local function select(i)
		for n, p in ipairs(PAGES) do
			local on = n == i
			p.frame.Visible = on
			paint(p.ic, on and Color3.new(1, 1, 1) or T.dim)
			TS:Create(p.btn, TweenInfo.new(0.12), {
				BackgroundColor3 = on and T.accent or T.surface2,
				BackgroundTransparency = on and 0 or 0.5,
			}):Play()
		end
		content.CanvasPosition = Vector2.new()
	end

	page("aim"); page("eye"); page("person"); page("gear")

	-- AIMBOT
	section("Aimbot"); toggle("Activar", true); slider("Smoothing", 85, 1, 100); slider("Predicción", 40, 0, 100)
	toggle("Hitbox prioritario", false); keybind("Tecla de apuntado", isMobile and "TOCAR" or "MOUSE2")
	section("FOV / Objetivo"); toggle("Mostrar círculo FOV", true); slider("Radio FOV", 120, 20, 400); toggle("Ignorar aliados", true)

	-- VISUAL + PREVIEW
	section("ESP")
	local prev = mk("Frame", { Size = UDim2.new(1, 0, 0, 128), BackgroundColor3 = Color3.fromRGB(14, 10, 11), BackgroundTransparency = 0.15, BorderSizePixel = 0, ClipsDescendants = true }, content)
	corner(prev, 9); stroke(prev, T.border, 1)

	local pName = mk("TextLabel", { Text = "Enemigo_01", Font = Enum.Font.GothamMedium, TextSize = 10, TextColor3 = T.text, BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 6), Size = UDim2.new(1, -16, 0, 14), TextXAlignment = Enum.TextXAlignment.Left }, prev)
	local pDist = mk("TextLabel", { Text = "84 studs", Font = Enum.Font.Gotham, TextSize = 9, TextColor3 = T.accentHot, BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 20), Size = UDim2.new(1, -16, 0, 12), TextXAlignment = Enum.TextXAlignment.Left }, prev)

	local target = mk("Frame", { Size = UDim2.fromOffset(46, 68), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.58), BackgroundTransparency = 1 }, prev)
	local tStroke = stroke(target, T.accent, 1.5)
	for _, c in ipairs({ { 0, 0 }, { 1, 0 }, { 0, 1 }, { 1, 1 } }) do
		local br = mk("Frame", { AnchorPoint = Vector2.new(c[1], c[2]), Position = UDim2.fromScale(c[1], c[2]), Size = UDim2.fromOffset(9, 9), BackgroundTransparency = 1 }, target)
		stroke(br, T.accentHot, 2)
	end
	local head = mk("Frame", { Size = UDim2.fromOffset(13, 13), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 8), BackgroundColor3 = T.dim, BorderSizePixel = 0 }, target)
	corner(head, 7)
	local torso = mk("Frame", { Size = UDim2.fromOffset(22, 34), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 24), BackgroundColor3 = T.dim, BorderSizePixel = 0 }, target)
	corner(torso, 5)

	local pLine = mk("Frame", { Size = UDim2.fromOffset(2, 70), AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0.5, -60, 1, -12), BackgroundColor3 = T.accent, BackgroundTransparency = 0.35, BorderSizePixel = 0, Rotation = 28 }, prev)

	toggle("Cajas", true, function(s) target.Visible = s end)
	toggle("Nombres", true, function(s) pName.Visible = s end)
	toggle("Distancia", true, function(s) pDist.Visible = s end)
	toggle("Línea de trazado", true, function(s) pLine.Visible = s end)
	toggle("Esqueleto", false)
	slider("Grosor", 2, 1, 6)

	-- JUGADORES
	section("Lista de jugadores"); listRow("Enemigo_01", 84, "ENEMIGO"); listRow("Jugador_Ana", 142, "AMIGO"); listRow("Xx_Rival_xX", 203, "ENEMIGO")

	-- AJUSTES
	section("General"); toggle("Marca de agua", true); toggle("Partículas de brasas", not isMobile); keybind("Tecla ocultar menú", isMobile and "FAB" or "INSERT")
	section("Interfaz"); slider("Opacidad del panel", 100, 30, 100); slider("Desenfoque del fondo", 14, 0, 30)
	section("Rendimiento"); toggle("FPS Boost", false); slider("Nivel de optimización", 2, 1, 3)
	section("Perfiles"); keybind("Perfil activo", "DEFAULT")
	section("Exportar")

	for i, p in ipairs(PAGES) do p.btn.MouseButton1Click:Connect(function() select(i) end) end
	select(1)

	-- pie
	local foot = mk("Frame", { Position = UDim2.new(0, 0, 1, -D.footH), Size = UDim2.new(1, 0, 0, D.footH), BackgroundTransparency = 1, ZIndex = 9 }, panel)
	mk("TextLabel", { Text = "DIOGO DRAG v1", Font = Enum.Font.GothamBlack, TextSize = 9, TextColor3 = T.accent, TextTransparency = 0.6, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Size = UDim2.new(1, -50, 1, 0) }, foot)
	mk("TextLabel", { Text = "v1.3.0", Font = Enum.Font.Gotham, TextSize = 9, TextColor3 = T.dim, TextXAlignment = Enum.TextXAlignment.Right, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0) }, foot)

	-- FAB
	fab = mk("TextButton", {
		Text = "DRAG", Font = Enum.Font.GothamBlack, TextSize = 11, TextColor3 = T.text,
		BackgroundColor3 = T.accent, BorderSizePixel = 0, Size = UDim2.fromOffset(56, 56),
		AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -16, 1, -16), ZIndex = 20, Visible = false,
	}, gui)
	corner(fab, 28); stroke(fab, T.accentHot, 1)

	closeBtn.MouseButton1Click:Connect(function() panel.Visible = false; fab.Visible = true end)
	fab.MouseButton1Click:Connect(function() panel.Visible = true; fab.Visible = false end)

	-- arrastre
	local dragging, offset = false, nil
	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			offset = input.Position - panel.AbsolutePosition
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			panel.Position = UDim2.fromOffset(input.Position.X - offset.X, input.Position.Y - offset.Y)
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
	end)

	if not isMobile then
		UIS.InputBegan:Connect(function(input, processed)
			if processed then return end
			if input.KeyCode == Enum.KeyCode.Insert then
				panel.Visible = not panel.Visible
				fab.Visible = not panel.Visible
			end
		end)
	end
end

local function choose(kind)
	if LAYOUT then return end
	LAYOUT = kind
	pcall(function() if writefile then writefile("DiogoDrag.layout", kind) end end)
	buildMenu(kind)
	panel.BackgroundTransparency = 1
	TS:Create(panel, TweenInfo.new(0.22), { BackgroundTransparency = 0 }):Play()
	TS:Create(gate, TweenInfo.new(0.22), { BackgroundTransparency = 1 }):Play()
	task.delay(0.22, function() gate:Destroy() end)
end

cardPc.MouseButton1Click:Connect(function() choose("PC") end)
cardPhone.MouseButton1Click:Connect(function() choose("MOBILE") end)
