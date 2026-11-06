--==============================================================
-- DIOGO DRAG v1 · v2.0.0
--==============================================================
local Players    = game:GetService("Players")
local UIS        = game:GetService("UserInputService")
local TS         = game:GetService("TweenService")
local RS         = game:GetService("RunService")
local HS         = game:GetService("HttpService")
local LP         = Players.LocalPlayer

local DRAGON_PORTRAIT  = "rbxassetid://0"
local DRAGON_LANDSCAPE = "rbxassetid://0"

local function cam() return workspace.CurrentCamera end
local function vp() local c = cam() return c and c.ViewportSize or Vector2.new(1280, 720) end
local function touchy()
	local v = vp()
	return (UIS.TouchEnabled and not UIS.KeyboardEnabled) or v.X < 900 or v.Y / math.max(v.X, 1) > 1.05
end

local LAYOUT = touchy() and "MOBILE" or "PC"

local T = {
	bg = Color3.fromRGB(10, 7, 8), surface = Color3.fromRGB(21, 15, 16), surface2 = Color3.fromRGB(31, 22, 23),
	rail = Color3.fromRGB(16, 11, 12), border = Color3.fromRGB(78, 22, 24),
	accent = Color3.fromRGB(224, 36, 32), hot = Color3.fromRGB(255, 96, 58),
	text = Color3.fromRGB(238, 230, 228), dim = Color3.fromRGB(126, 112, 110), ok = Color3.fromRGB(74, 194, 118),
}

local DIM = {
	MOBILE = { row = 46, rail = 58, pad = 9, head = 56, foot = 16, font = Enum.Font.GothamMedium, fs = 14 },
	PC     = { row = 34, rail = 64, pad = 9, head = 42, foot = 14, font = Enum.Font.Gotham,       fs = 12 },
}
local D = DIM[LAYOUT]

local function mk(c, p, parent)
	local o = Instance.new(c)
	for k, v in pairs(p or {}) do o[k] = v end
	if parent then o.Parent = parent end
	return o
end
local function corner(p, r) mk("UICorner", { CornerRadius = UDim.new(0, r) }, p) end
local function stroke(p, c, t) mk("UIStroke", { Color = c or T.border, Thickness = t or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, p) end
local function pad(p, a) mk("UIPadding", { PaddingTop = UDim.new(0, a), PaddingBottom = UDim.new(0, a), PaddingLeft = UDim.new(0, a), PaddingRight = UDim.new(0, a) }, p) end

local function tw(inst, props, time, style, dir)
	local t = TS:Create(inst, TweenInfo.new(time or 0.22, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

--==============================================================
-- RAÍZ
--==============================================================
local gui = mk("ScreenGui", { Name = "DiogoDrag", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 9999 })
pcall(function() if gethui then gui.Parent = gethui() else gui.Parent = game:GetService("CoreGui") end end)
if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

--==============================================================
-- GATE ANIMADO
--==============================================================
local gate = mk("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = T.bg, BackgroundTransparency = 0.06, ZIndex = 80 }, gui)
mk("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(14, 9, 10), Color3.fromRGB(5, 3, 4)), Rotation = 90 }, gate)

local gateDragon = mk("ImageLabel", { Size = UDim2.fromScale(1.2, 1.2), Position = UDim2.fromScale(-0.1, -0.1), BackgroundTransparency = 1, Image = DRAGON_LANDSCAPE, ImageColor3 = Color3.fromRGB(140, 18, 18), ImageTransparency = 0.55, ScaleType = Enum.ScaleType.Crop, ZIndex = 81 }, gate)
mk("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) }), Rotation = 90 }, gateDragon)

local titleG = mk("TextLabel", { Text = "DIOGO DRAG v1", Font = Enum.Font.GothamBlack, TextSize = 30, TextColor3 = T.text, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.2, 0), Size = UDim2.new(1, -40, 0, 38), TextTransparency = 1, ZIndex = 82 }, gate)
local subG = mk("TextLabel", { Text = "SELECCIONA TU DISPOSITIVO", Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = T.accent, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.2, 40), Size = UDim2.new(1, -40, 0, 16), TextTransparency = 1, ZIndex = 82 }, gate)
local detG = mk("TextLabel", { Text = "DETECTADO: " .. (LAYOUT == "MOBILE" and "TELÉFONO" or "PC"), Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = T.ok, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.2, 60), Size = UDim2.new(1, -40, 0, 14), TextTransparency = 1, ZIndex = 82 }, gate)

local wide = vp().X >= 800
local wrap = mk("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.58), Size = wide and UDim2.fromOffset(470, 160) or UDim2.new(0.86, 0, 0, 286), ZIndex = 82 }, gate)
mk("UIListLayout", { FillDirection = wide and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 14), SortOrder = Enum.SortOrder.LayoutOrder }, wrap)

local function card(order, kind, label, hint)
	local isPc = kind == "PC"
	local b = mk("TextButton", { Text = "", AutoButtonColor = false, BackgroundColor3 = T.surface, BackgroundTransparency = 0.08, BorderSizePixel = 0, LayoutOrder = order, Size = wide and UDim2.new(0.5, -7, 1, 0) or UDim2.new(1, 0, 0, 124), ZIndex = 83 }, wrap)
	corner(b, 13)
	stroke(b, kind == LAYOUT and T.hot or T.border, kind == LAYOUT and 2 or 1)

	local ic = mk("Frame", { BackgroundColor3 = T.border, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, -16), Size = isPc and UDim2.fromOffset(54, 34) or UDim2.fromOffset(25, 42), ZIndex = 84 }, b)
	corner(ic, isPc and 4 or 6)
	stroke(ic, T.accent, 1)
	if isPc then
		mk("Frame", { Size = UDim2.fromOffset(20, 3), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 1, 4), BackgroundColor3 = T.border, BorderSizePixel = 0, ZIndex = 84 }, ic)
	else
		mk("Frame", { Size = UDim2.fromOffset(9, 2), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0, 5), BackgroundColor3 = T.accent, BorderSizePixel = 0, ZIndex = 85 }, ic)
	end
	mk("TextLabel", { Text = label, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = T.text, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 72), Size = UDim2.new(1, 0, 0, 18), ZIndex = 84 }, b)
	mk("TextLabel", { Text = hint, Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = T.dim, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 92), Size = UDim2.new(1, 0, 0, 14), ZIndex = 84 }, b)

	b.MouseEnter:Connect(function() tw(b, { BackgroundTransparency = 0 }, 0.15) tw(ic, { Size = isPc and UDim2.fromOffset(60, 38) or UDim2.fromOffset(28, 46) }, 0.2, Enum.EasingStyle.Back) end)
	b.MouseLeave:Connect(function() tw(b, { BackgroundTransparency = 0.08 }, 0.15) tw(ic, { Size = isPc and UDim2.fromOffset(54, 34) or UDim2.fromOffset(25, 42) }, 0.2) end)
	return b
end

local cardPc, cardPh = card(1, "PC", "PC", "Ratón y teclado"), card(2, "MOBILE", "TELÉFONO", "Táctil")

for _, el in ipairs({ titleG, subG, detG }) do
	el.Position = UDim2.new(el.Position.X.Scale, 0, el.Position.Y.Scale, 14)
	tw(el, { Position = UDim2.new(el.Position.X.Scale, 0, el.Position.Y.Scale, 0), TextTransparency = 0 }, 0.4, Enum.EasingStyle.Quint)
end
for _, b in ipairs({ cardPc, cardPh }) do
	local target = b.Position
	b.Position = UDim2.new(target.X.Scale, target.X.Offset, target.Y.Scale, 24)
	b.BackgroundTransparency = 1
	task.delay(0.12, function() tw(b, { Position = target, BackgroundTransparency = 0.08 }, 0.4, Enum.EasingStyle.Back) end)
end

--==============================================================
-- PANEL
--==============================================================
local panel, fab, embers = nil, nil, {}
local OPEN = false

local function buildPanel()
	panel = mk("Frame", { Name = "Panel", BackgroundColor3 = T.surface, BorderSizePixel = 0, ZIndex = 10 }, gui)
	corner(panel, 15)
	stroke(panel, T.border, 1)
	mk("UIGradient", { Color = ColorSequence.new(T.surface, Color3.fromRGB(13, 9, 10)), Rotation = 90 }, panel)

	local sc = mk("UIScale", { Scale = 0.94 }, panel)

	if LAYOUT == "MOBILE" then
		panel.AnchorPoint = Vector2.new(0.5, 0.5)
		panel.Position = UDim2.fromScale(0.5, 0.5)
		panel.Size = UDim2.new(0.95, 0, 1, -140)
	else
		panel.AnchorPoint = Vector2.new(1, 0.5)
		panel.Position = UDim2.new(1, -28, 0.5, 0)
		panel.Size = UDim2.fromOffset(440, 604)
	end
	pad(panel, D.pad)

	-- dragón
	local dg = mk("ImageLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = LAYOUT == "MOBILE" and DRAGON_PORTRAIT or DRAGON_LANDSCAPE, ImageColor3 = Color3.fromRGB(146, 18, 18), ImageTransparency = 0.6, ScaleType = Enum.ScaleType.Crop, ZIndex = 11 }, panel)
	corner(dg, 15)
	mk("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.25), NumberSequenceKeypoint.new(0.6, 0.9), NumberSequenceKeypoint.new(1, 1) }), Rotation = 90 }, dg)

	local wing = mk("Frame", { Size = UDim2.fromScale(1.1, 0.75), Position = UDim2.fromScale(-0.05, 0.12), BackgroundTransparency = 1, Rotation = -12, ZIndex = 11 }, panel)
	for i = 1, 3 do
		local f = mk("Frame", { Size = UDim2.new(0.9, 0, 0, 2), Position = UDim2.new(0.05, 0, i * 0.18, 0), BackgroundColor3 = T.accent, BackgroundTransparency = 0.86 - i * 0.02, BorderSizePixel = 0, Rotation = i * 4, ZIndex = 11 }, wing)
		corner(f, 2)
	end

	-- cabecera
	local head = mk("Frame", { Size = UDim2.new(1, 0, 0, D.head), BackgroundColor3 = T.surface2, BackgroundTransparency = 0.22, BorderSizePixel = 0, ZIndex = 14 }, panel)
	corner(head, 11)
	mk("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.fromScale(0, 1), BackgroundColor3 = T.accent, BorderSizePixel = 0, ZIndex = 15 }, head)
	local pulse = mk("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.fromScale(0, 1), BackgroundColor3 = T.hot, BorderSizePixel = 0, BackgroundTransparency = 0.5, ZIndex = 15 }, head)

	mk("TextLabel", { Text = "DIOGO DRAG v1", Font = Enum.Font.GothamBlack, TextSize = LAYOUT == "MOBILE" and 17 or 14, TextColor3 = T.text, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -124, 1, 0), ZIndex = 15 }, head)
	mk("TextLabel", { Text = LAYOUT, Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = T.dim, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -46, 0.5, 0), Size = UDim2.fromOffset(44, 14), TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 15 }, head)

	local closeBtn = mk("TextButton", { Text = "✕", Font = Enum.Font.GothamBold, TextSize = LAYOUT == "MOBILE" and 19 or 15, TextColor3 = T.dim, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(32, 32), ZIndex = 15 }, head)
	closeBtn.MouseEnter:Connect(function() tw(closeBtn, { TextColor3 = T.hot }, 0.12) end)
	closeBtn.MouseLeave:Connect(function() tw(closeBtn, { TextColor3 = T.dim }, 0.12) end)

	local bodyTop = D.head + 9
	local bodyCut = D.head + 9 + D.foot + 9
	local body = mk("Frame", { Position = UDim2.fromOffset(0, bodyTop), Size = UDim2.new(1, 0, 1, -bodyCut), BackgroundTransparency = 1, ZIndex = 14 }, panel)

	local rail = mk("Frame", { Size = UDim2.new(0, D.rail, 1, 0), BackgroundColor3 = T.rail, BackgroundTransparency = 0.18, BorderSizePixel = 0, ZIndex = 14 }, body)
	corner(rail, 11)
	mk("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 7), HorizontalAlignment = Enum.HorizontalAlignment.Center }, rail)
	pad(rail, 7)

	local content = mk("ScrollingFrame", { Position = UDim2.fromOffset(D.rail + 9, 0), Size = UDim2.new(1, -(D.rail + 9), 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = T.border, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 14 }, body)
	mk("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 7) }, content)
	pad(content, 2)

	--==========================================================
	-- WIDGETS
	--==========================================================
	local function section(txt)
		return mk("TextLabel", { Text = string.upper(txt), Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = T.accent, TextTransparency = 0.1, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20) }, content)
	end

	local function row(h)
		local r = mk("Frame", { Size = UDim2.new(1, 0, 0, h or D.row), BackgroundColor3 = T.surface2, BackgroundTransparency = 0.28, BorderSizePixel = 0 }, content)
		corner(r, 9)
		pad(r, 11)
		return r
	end

	local function toggle(label, on, cb)
		local r = row()
		mk("TextLabel", { Text = label, Font = D.font, TextSize = D.fs, TextColor3 = T.text, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Size = UDim2.new(1, -50, 1, 0) }, r)
		local track = mk("Frame", { Size = UDim2.fromOffset(38, 21), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), BackgroundColor3 = on and T.accent or Color3.fromRGB(50, 39, 40), BorderSizePixel = 0 }, r)
		corner(track, 11)
		local knob = mk("Frame", { Size = UDim2.fromOffset(15, 15), Position = UDim2.fromOffset(on and 20 or 3, 3), BackgroundColor3 = T.text, BorderSizePixel = 0 }, track)
		corner(knob, 8)
		local btn = mk("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) }, r)
		local state = on or false
		btn.MouseButton1Click:Connect(function()
			state = not state
			tw(track, { BackgroundColor3 = state and T.accent or Color3.fromRGB(50, 39, 40) }, 0.16)
			tw(knob, { Position = UDim2.fromOffset(state and 20 or 3, 3) }, 0.22, Enum.EasingStyle.Back)
			tw(r, { BackgroundTransparency = 0.1 }, 0.1)
			task.delay(0.1, function() tw(r, { BackgroundTransparency = 0.28 }, 0.25) end)
			if cb then cb(state) end
		end)
		return r
	end

	local function slider(label, value, min, max, cb)
		local r = row(LAYOUT == "MOBILE" and 62 or 47)
		mk("TextLabel", { Text = label, Font = D.font, TextSize = D.fs, TextColor3 = T.text, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Size = UDim2.new(1, -46, 0, 17) }, r)
		local val = mk("TextLabel", { Text = tostring(value), Font = Enum.Font.GothamBold, TextSize = D.fs, TextColor3 = T.hot, TextXAlignment = Enum.TextXAlignment.Right, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(42, 17) }, r)
		local track = mk("Frame", { Size = UDim2.new(1, 0, 0, 7), Position = UDim2.new(0, 0, 1, -12), BackgroundColor3 = Color3.fromRGB(46, 35, 36), BorderSizePixel = 0 }, r)
		corner(track, 4)
		local fill = mk("Frame", { Size = UDim2.fromScale((value - min) / (max - min), 1), BackgroundColor3 = T.accent, BorderSizePixel = 0 }, track)
		corner(fill, 4)
		local knob = mk("Frame", { Size = UDim2.fromOffset(11, 11), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0), BackgroundColor3 = T.text, BorderSizePixel = 0, ZIndex = 2 }, track)
		corner(knob, 6)
		local hit = mk("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, LAYOUT == "MOBILE" and 28 or 20), Position = UDim2.new(0, 0, 1, LAYOUT == "MOBILE" and -22 or -16) }, r)
		local function set(px)
			local a = math.clamp(px / math.max(track.AbsoluteSize.X, 1), 0, 1)
			local v = math.floor(min + (max - min) * a + 0.5)
			fill.Size = UDim2.fromScale(a, 1)
			knob.Position = UDim2.new(a, 0, 0.5, 0)
			val.Text = tostring(v)
			if cb then cb(v) end
		end
		hit.MouseButton1Down:Connect(function() set(UIS:GetMouseLocation().X - track.AbsolutePosition.X) end)
		hit.MouseMoved:Connect(function()
			if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or #UIS:GetTouches() > 0 then
				set(UIS:GetMouseLocation().X - track.AbsolutePosition.X)
			end
		end)
		return r
	end

	local function cycle(label, options, index, cb)
		local r = row()
		mk("TextLabel", { Text = label, Font = D.font, TextSize = D.fs, TextColor3 = T.text, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Size = UDim2.new(1, -92, 1, 0) }, r)
		local btn = mk("TextButton", { Text = options[index], Font = Enum.Font.GothamBold, TextSize = LAYOUT == "MOBILE" and 11 or 10, TextColor3 = T.hot, BackgroundColor3 = Color3.fromRGB(48, 30, 31), BorderSizePixel = 0, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(84, LAYOUT == "MOBILE" and 30 or 23) }, r)
		corner(btn, 6)
		stroke(btn, T.border, 1)
		local i = index
		btn.MouseButton1Click:Connect(function()
			i = i % #options + 1
			tw(btn, { BackgroundTransparency = 0.4 }, 0.08)
			task.delay(0.08, function() tw(btn, { BackgroundTransparency = 0 }, 0.2) end)
			btn.Text = options[i]
			if cb then cb(options[i], i) end
		end)
		return r
	end

	local function keybind(label, key, cb)
		local r = row()
		mk("TextLabel", { Text = label, Font = D.font, TextSize = D.fs, TextColor3 = T.text, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Size = UDim2.new(1, -76, 1, 0) }, r)
		local box = mk("TextButton", { Text = key, Font = Enum.Font.GothamBold, TextSize = LAYOUT == "MOBILE" and 12 or 10, TextColor3 = T.hot, BackgroundColor3 = Color3.fromRGB(48, 30, 31), BorderSizePixel = 0, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(62, LAYOUT == "MOBILE" and 30 or 23) }, r)
		corner(box, 6)
		stroke(box, T.border, 1)
		local waiting = false
		box.MouseButton1Click:Connect(function()
			waiting = true
			box.Text = "..."
			tw(box, { TextColor3 = T.text }, 0.1)
		end)
		UIS.InputBegan:Connect(function(input, processed)
			if not waiting or processed then return end
			waiting = false
			box.Text = input.KeyCode.Name
			tw(box, { TextColor3 = T.hot }, 0.1)
			if cb then cb(input.KeyCode) end
		end)
		return r
	end

	local function button(label, cb, tone)
		local r = mk("TextButton", { Text = label, Font = Enum.Font.GothamBold, TextSize = D.fs, TextColor3 = T.text, BackgroundColor3 = tone or T.surface2, BackgroundTransparency = 0.28, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, D.row) }, content)
		corner(r, 9)
		r.MouseEnter:Connect(function() tw(r, { BackgroundTransparency = 0.05 }, 0.14) end)
		r.MouseLeave:Connect(function() tw(r, { BackgroundTransparency = 0.28 }, 0.14) end)
		r.MouseButton1Click:Connect(function()
			tw(r, { BackgroundTransparency = 0.5 }, 0.07)
			task.delay(0.07, function() tw(r, { BackgroundTransparency = 0.28 }, 0.2) end)
			if cb then cb() end
		end)
		return r
	end

	--==========================================================
	-- RAIL
	--==========================================================
	local PAGES = {}
	local function icon(kind)
		local f = mk("Frame", { Size = UDim2.fromOffset(19, 19), BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
		if kind == "aim" then
			local ring = mk("Frame", { Size = UDim2.fromOffset(12, 12), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 1 }, f)
			corner(ring, 6); stroke(ring, T.dim, 1.5)
			for _, p in ipairs({ { 0.5, 0, 1, 4 }, { 0.5, 1, 1, 4 }, { 0, 0.5, 4, 1 }, { 1, 0.5, 4, 1 } }) do
				mk("Frame", { AnchorPoint = Vector2.new(p[1], p[2]), Position = UDim2.fromScale(p[1], p[2]), Size = UDim2.fromOffset(p[3], p[4]), BackgroundColor3 = T.dim, BorderSizePixel = 0 }, f)
			end
		elseif kind == "eye" then
			local e = mk("Frame", { Size = UDim2.fromOffset(16, 10), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 1 }, f)
			corner(e, 5); stroke(e, T.dim, 1.5)
			local pu = mk("Frame", { Size = UDim2.fromOffset(4, 4), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), BackgroundColor3 = T.dim, BorderSizePixel = 0 }, e)
			corner(pu, 2)
		elseif kind == "person" then
			local h = mk("Frame", { Size = UDim2.fromOffset(7, 7), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 1), BackgroundColor3 = T.dim, BorderSizePixel = 0 }, f)
			corner(h, 4)
			local b = mk("Frame", { Size = UDim2.fromOffset(13, 8), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 10), BackgroundColor3 = T.dim, BorderSizePixel = 0 }, f)
			corner(b, 4)
		elseif kind == "bolt" then
			mk("Frame", { Size = UDim2.fromOffset(5, 12), Position = UDim2.fromOffset(8, 1), BackgroundColor3 = T.dim, BorderSizePixel = 0, Rotation = 14 }, f)
			mk("Frame", { Size = UDim2.fromOffset(5, 12), Position = UDim2.fromOffset(5, 6), BackgroundColor3 = T.dim, BorderSizePixel = 0, Rotation = 14 }, f)
		else
			local c = mk("Frame", { Size = UDim2.fromOffset(12, 12), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 1 }, f)
			corner(c, 6); stroke(c, T.dim, 1.5)
			local d = mk("Frame", { Size = UDim2.fromOffset(4, 4), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), BackgroundColor3 = T.dim, BorderSizePixel = 0 }, c)
			corner(d, 2)
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
		local btn = mk("TextButton", { Text = "", BackgroundColor3 = T.surface2, BackgroundTransparency = 0.5, BorderSizePixel = 0, LayoutOrder = #PAGES, Size = UDim2.new(1, 0, 0, LAYOUT == "MOBILE" and 46 or 40) }, rail)
		corner(btn, 10)
		local ic = icon(kind)
		local frame = mk("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = #PAGES, Visible = false }, content)
		mk("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 7) }, frame)
		table.insert(PAGES, { btn = btn, frame = frame, ic = ic })
	end

	local function select(i)
		for n, p in ipairs(PAGES) do
			local on = n == i
			p.frame.Visible = on
			paint(p.ic, on and Color3.new(1, 1, 1) or T.dim)
			tw(p.btn, { BackgroundColor3 = on and T.accent or T.surface2, BackgroundTransparency = on and 0 or 0.5 }, 0.15)
			if on then
				p.frame.Position = UDim2.fromOffset(10, 0)
				p.frame.BackgroundTransparency = 1
				tw(p.frame, { Position = UDim2.fromOffset(0, 0) }, 0.22, Enum.EasingStyle.Quint)
			end
		end
		content.CanvasPosition = Vector2.new()
	end

	page("aim"); page("eye"); page("person"); page("bolt"); page("gear")

	--==========================================================
	-- PÁGINAS
	--==========================================================
	local A, V, P, G, C = PAGES[1].frame, PAGES[2].frame, PAGES[3].frame, PAGES[4].frame, PAGES[5].frame

	local function on(frame, fn) local old = content; content = frame; fn(); content = old end

	on(A, function()
		section("Aimbot")
		toggle("Activar", false, function(s) M.set("Aim", s) end)
		cycle("Modo", { "Crosshair", "Cercano", "Menos vida" }, 1, function(_, i) M.cfg.AimMode = ({ "Crosshair", "Closest", "LowestHP" })[i] end)
		cycle("Parte", { "Cabeza", "Cuerpo" }, 1, function(_, i) M.cfg.AimPart = ({ "Head", "Body" })[i] end)
		slider("Suavizado", 18, 1, 100, function(v) M.cfg.Smooth = v / 100 end)
		slider("Predicción", 2, 0, 50, function(v) M.cfg.Pred = v / 100 end)
		slider("Radio FOV", 120, 20, 400, function(v) M.cfg.Fov = v end)
		toggle("Sticky", true, function(s) M.cfg.Sticky = s end)
		toggle("Verificar pared", true, function(s) M.cfg.Wall = s end)
		toggle("Ignorar aliados", true, function(s) M.cfg.Team = s end)
		section("Disparo")
		toggle("Silent aim", false, function(s) M.set("Silent", s) end)
		slider("FOV silent", 200, 20, 600, function(v) M.cfg.SilentFov = v end)
		toggle("Triggerbot", false, function(s) M.set("Trigger", s) end)
		slider("Retardo trigger", 6, 1, 40, function(v) M.cfg.TrigDelay = v / 100 end)
		section("Arma")
		toggle("Sin retroceso", false, function(s) M.set("NoRecoil", s) end)
		toggle("Sin dispersión", false, function(s) M.set("NoSpread", s) end)
		toggle("Cadencia rápida", false, function(s) M.set("RapidFire", s) end)
		toggle("Sin balanceo", false, function(s) M.set("NoSway", s) end)
	end)

	on(V, function()
		section("ESP")
		toggle("Activar", false, function(s) M.set("ESP", s) end)
		toggle("Cajas", true, function(s) M.cfg.Box = s end)
		toggle("Nombres", true, function(s) M.cfg.Name = s end)
		toggle("Distancia", true, function(s) M.cfg.Dist = s end)
		toggle("Barra de vida", true, function(s) M.cfg.Health = s end)
		toggle("Trazadoras", true, function(s) M.cfg.Tracer = s end)
		toggle("Esqueleto", false, function(s) M.cfg.Skeleton = s end)
		toggle("Chams", false, function(s) M.set("Chams", s) end)
		slider("Distancia máx", 900, 100, 2000, function(v) M.cfg.MaxDist = v end)
		slider("Grosor", 1, 1, 5, function(v) M.cfg.Thick = v end)
		section("Vista previa")
		local pv = mk("Frame", { Size = UDim2.new(1, 0, 0, 132), BackgroundColor3 = Color3.fromRGB(13, 9, 10), BackgroundTransparency = 0.15, BorderSizePixel = 0, ClipsDescendants = true }, content)
		corner(pv, 9); stroke(pv, T.border, 1)
		local nm = mk("TextLabel", { Text = "Enemigo_01", Font = Enum.Font.GothamMedium, TextSize = 10, TextColor3 = T.text, BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 6), Size = UDim2.new(1, -16, 0, 14), TextXAlignment = Enum.TextXAlignment.Left }, pv)
		local ds = mk("TextLabel", { Text = "84 studs", Font = Enum.Font.Gotham, TextSize = 9, TextColor3 = T.hot, BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 20), Size = UDim2.new(1, -16, 0, 12), TextXAlignment = Enum.TextXAlignment.Left }, pv)
		local tg = mk("Frame", { Size = UDim2.fromOffset(48, 70), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.58), BackgroundTransparency = 1 }, pv)
		stroke(tg, T.accent, 1.5)
		for _, c in ipairs({ { 0, 0 }, { 1, 0 }, { 0, 1 }, { 1, 1 } }) do
			local br = mk("Frame", { AnchorPoint = Vector2.new(c[1], c[2]), Position = UDim2.fromScale(c[1], c[2]), Size = UDim2.fromOffset(9, 9), BackgroundTransparency = 1 }, tg)
			stroke(br, T.hot, 2)
		end
		mk("Frame", { Size = UDim2.fromOffset(13, 13), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 8), BackgroundColor3 = T.dim, BorderSizePixel = 0 }, tg).Parent = tg
		local torso = mk("Frame", { Size = UDim2.fromOffset(22, 36), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 24), BackgroundColor3 = T.dim, BorderSizePixel = 0 }, tg)
		corner(torso, 5)
		local tr = mk("Frame", { Size = UDim2.fromOffset(2, 68), AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0.5, -62, 1, -12), BackgroundColor3 = T.accent, BackgroundTransparency = 0.35, BorderSizePixel = 0, Rotation = 28 }, pv)
		task.spawn(function()
			while pv.Parent do
				tr.BackgroundTransparency = 0.55
				tw(tr, { BackgroundTransparency = 0.2 }, 0.9)
				task.wait(1.2)
			end
		end)
		local function sync() tg.Visible = M.cfg.Box; nm.Visible = M.cfg.Name; ds.Visible = M.cfg.Dist; tr.Visible = M.cfg.Tracer end
		for _, k in ipairs({ "Box", "Name", "Dist", "Tracer" }) do
			local prev = M.cfg[k]
			M.hook[k] = sync
			sync()
		end
	end)

	on(P, function()
		section("Jugadores")
		local list = mk("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 }, content)
		mk("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5) }, list)
		local refresh
		refresh = function()
			for _, ch in ipairs(list:GetChildren()) do
				if ch:IsA("TextButton") then ch:Destroy() end
			end
			for _, t in ipairs(M.targets()) do
				local r = mk("TextButton", { Text = "", BackgroundColor3 = T.surface2, BackgroundTransparency = 0.28, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, D.row), AutoButtonColor = false }, list)
				corner(r, 9); pad(r, 11)
				mk("TextLabel", { Text = t.model.Name, Font = D.font, TextSize = D.fs, TextColor3 = T.text, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Size = UDim2.new(0.6, 0, 1, 0) }, r)
				mk("TextLabel", { Text = math.floor(t.dist) .. " studs", Font = Enum.Font.Gotham, TextSize = D.fs - 1, TextColor3 = T.dim, BackgroundTransparency = 1, Size = UDim2.new(0.2, 0, 1, 0) }, r)
				mk("TextLabel", { Text = t.isBot and "BOT" or "JUGADOR", Font = Enum.Font.GothamBold, TextSize = D.fs - 2, TextColor3 = t.isBot and T.dim or T.hot, TextXAlignment = Enum.TextXAlignment.Right, BackgroundTransparency = 1, Size = UDim2.new(0.2, 0, 1, 0) }, r)
				r.MouseButton1Click:Connect(function() M.cfg.Lock = t.model; M.set("Aim", true) end)
			end
			if #M.targets() == 0 then
				mk("TextLabel", { Text = "Sin objetivos", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = T.dim, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24) }, list)
			end
		end
		button("Refrescar", refresh)
		task.delay(0.1, refresh)
	end)

	on(G, function()
		section("Movimiento")
		toggle("Speed", false, function(s) M.set("Speed", s) end)
		slider("Velocidad", 32, 16, 120, function(v) M.cfg.SpeedVal = v end)
		toggle("Salto alto", false, function(s) M.set("Jump", s) end)
		section("Mundo")
		toggle("Fullbright", false, function(s) M.set("Bright", s) end)
		slider("FOV de cámara", 70, 40, 120, function(v) M.cfg.CamFov = v end)
		toggle("Auto respawn", false, function(s) M.set("Respawn", s) end)
		toggle("Anti AFK", true, function(s) M.set("AntiAfk", s) end)
	end)

	on(C, function()
		section("Interfaz")
		toggle("Marca de agua", true, function(s) foot.Visible = s end)
		toggle("Brasas", true, function(s) M.set("Embers", s) end)
		slider("Opacidad", 100, 30, 100, function(v) panel.BackgroundTransparency = 1 - v / 100 end)
		section("Sesión")
		button("Resetear ajustes", function() M.reset() end)
		button("Recargar menú", function() M.unload(); task.wait(0.2); script_gui() end)
		button("Desactivar todo", function() M.unload() end, Color3.fromRGB(70, 22, 22))
	end)

	for i, p in ipairs(PAGES) do p.btn.MouseButton1Click:Connect(function() select(i) end) end
	select(1)

	--==========================================================
	-- PIE
	--==========================================================
	local foot = mk("Frame", { Position = UDim2.new(0, 0, 1, -D.foot), Size = UDim2.new(1, 0, 0, D.foot), BackgroundTransparency = 1, ZIndex = 15 }, panel)
	mk("TextLabel", { Text = "DIOGO DRAG v1", Font = Enum.Font.GothamBlack, TextSize = 9, TextColor3 = T.accent, TextTransparency = 0.55, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Size = UDim2.new(1, -50, 1, 0) }, foot)
	mk("TextLabel", { Text = "v2.0.0", Font = Enum.Font.Gotham, TextSize = 9, TextColor3 = T.dim, TextXAlignment = Enum.TextXAlignment.Right, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0) }, foot)

	--==========================================================
	-- ANIMACIONES DE ESTADO
	--==========================================================
	task.spawn(function()
		while panel.Parent do
			pulse.BackgroundTransparency = 0.8
			tw(pulse, { BackgroundTransparency = 0.35 }, 1.6)
			task.wait(1.9)
		end
	end)

	local function open()
		if OPEN then return end
		OPEN = true
		panel.Visible = true
		sc.Scale = 0.93
		panel.BackgroundTransparency = 1
		local target = panel.Position
		panel.Position = LAYOUT == "MOBILE" and UDim2.new(target.X.Scale, target.X.Offset, target.Y.Scale, 34) or UDim2.new(target.X.Scale, target.X.Offset + 34, target.Y.Scale, target.Y.Offset)
		tw(panel, { Position = target, BackgroundTransparency = 0 }, 0.34, Enum.EasingStyle.Back)
		tw(sc, { Scale = 1 }, 0.34, Enum.EasingStyle.Back)
		fab.Visible = false
	end

	local function close()
		if not OPEN then return end
		OPEN = false
		local target = panel.Position
		local dest = LAYOUT == "MOBILE" and UDim2.new(target.X.Scale, target.X.Offset, target.Y.Scale, target.Y.Offset + 34) or UDim2.new(target.X.Scale, target.X.Offset + 34, target.Y.Scale, target.Y.Offset)
		tw(panel, { Position = dest, BackgroundTransparency = 1 }, 0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		tw(sc, { Scale = 0.93 }, 0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		task.delay(0.24, function()
			panel.Visible = false
			panel.Position = target
			fab.Visible = true
			fab.Size = UDim2.fromOffset(34, 34)
			tw(fab, { Size = UDim2.fromOffset(58, 58) }, 0.3, Enum.EasingStyle.Back)
		end)
	end

	closeBtn.MouseButton1Click:Connect(close)

	-- arrastre
	local dragging, offset = false, nil
	head.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			offset = i.Position - panel.AbsolutePosition
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			panel.Position = UDim2.fromOffset(i.Position.X - offset.X, i.Position.Y - offset.Y)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
	end)

	return open, close
end

--==============================================================
-- FAB
--==============================================================
fab = mk("TextButton", { Text = "DRAG", Font = Enum.Font.GothamBlack, TextSize = 11, TextColor3 = T.text, BackgroundColor3 = T.accent, BorderSizePixel = 0, Size = UDim2.fromOffset(58, 58), AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -18, 1, -18), ZIndex = 30, Visible = false }, gui)
corner(fab, 29); stroke(fab, T.hot, 1)
fab.MouseEnter:Connect(function() tw(fab, { Size = UDim2.fromOffset(64, 64) }, 0.2, Enum.EasingStyle.Back) end)
fab.MouseLeave:Connect(function() tw(fab, { Size = UDim2.fromOffset(58, 58) }, 0.2) end)

--==============================================================
-- MÓDULOS
--==============================================================
local M = { cfg = {
	Aim = false, AimMode = "Crosshair", AimPart = "Head", Smooth = 0.18, Pred = 0.02, Fov = 120,
	Sticky = true, Wall = true, Team = true, MaxDist = 900, Thick = 1,
	Silent = false, SilentFov = 200, Trigger = false, TrigDelay = 0.06,
	ESP = false, Box = true, Name = true, Dist = true, Health = true, Tracer = true, Skeleton = false, Chams = false,
	Speed = false, SpeedVal = 32, Jump = false, Bright = false, CamFov = 70, Respawn = false, AntiAfk = true,
	Embers = true, Lock = nil,
}, hook = {}, conns = {}, draw = {}, sticky = nil, lastShot = 0 }

local function bind(sig, fn) local c = sig:Connect(fn); table.insert(M.conns, c); return c end

local function char() return LP.Character end
local function root() local c = char() return c and c:FindFirstChild("HumanoidRootPart") end

local function teamOf(inst)
	local a = inst:GetAttribute("Team")
	if a ~= nil then return a end
	local mdl = inst:IsA("Model") and inst or inst:FindFirstAncestorOfClass("Model")
	if mdl then
		local b = mdl:GetAttribute("Team")
		if b ~= nil then return b end
		local pl = Players:GetPlayerFromCharacter(mdl)
		if pl then local c = pl:GetAttribute("Team"); if c ~= nil then return c end end
	end
	return nil
end

local function myTeam() local c = char() if not c then return nil end local t = teamOf(c) if t == nil then t = LP:GetAttribute("Team") end return t end

local function partOf(model, mode)
	if not model then return nil end
	local h = model:FindFirstChildOfClass("Humanoid")
	if not h or h.Health <= 0 then return nil end
	if mode == "Head" then local hd = model:FindFirstChild("Head") if hd then return hd end end
	return model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
end

function M.targets()
	local out = {}
	local c = cam()
	if not c then return out end
	local pos = c.CFrame.Position
	local mine = myTeam()
	local function add(model, bot)
		local h = model:FindFirstChildOfClass("Humanoid")
		if not h or h.Health <= 0 then return end
		local r = model:FindFirstChild("HumanoidRootPart")
		if not r then return end
		if M.cfg.Team and mine ~= nil then
			local t = teamOf(model)
			if t ~= nil and t == mine and t ~= -1 then return end
		end
		local d = (r.Position - pos).Magnitude
		if d > M.cfg.MaxDist then return end
		table.insert(out, { model = model, root = r, humanoid = h, dist = d, isBot = bot })
	end
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP and p.Character then add(p.Character, false) end
	end
	local mobs = workspace:FindFirstChild("Mobs")
	if mobs then for _, m in ipairs(mobs:GetChildren()) do if m:IsA("Model") then add(m, true) end end end
	return out
end

local function vis(part, model)
	if not M.cfg.Wall then return true end
	local c = char()
	if not c then return true end
	local p = RaycastParams.new()
	p.FilterType = Enum.RaycastFilterType.Exclude
	p.FilterDescendantsInstances = { c, model }
	return workspace:Raycast(cam().CFrame.Position, part.Position - cam().CFrame.Position, p) == nil
end

local function w2s(pos)
	local sp, on = cam():WorldToViewportPoint(pos)
	if not on then return nil end
	return Vector2.new(sp.X, sp.Y)
end

local function center() local v = vp() return Vector2.new(v.X / 2, v.Y / 2) end

function M.pick()
	local list = M.targets()
	local c = center()
	local best, bestScore = nil, math.huge
	for _, t in ipairs(list) do
		local part = partOf(t.model, M.cfg.AimPart)
		if part and vis(part, t.model) then
			local sp = w2s(part.Position)
			if sp then
				local sc
				if M.cfg.AimMode == "LowestHP" then sc = t.humanoid.Health
				elseif M.cfg.AimMode == "Closest" then sc = t.dist
				else sc = (sp - c).Magnitude end
				local cap = M.cfg.AimMode == "Crosshair" and M.cfg.Fov or math.huge
				if sc < bestScore and sc <= cap then best, bestScore = t, sc end
			end
		end
	end
	if not best and M.cfg.Sticky and M.sticky then
		for _, t in ipairs(list) do if t.model == M.sticky then best = t break end end
	end
	M.sticky = best and best.model or nil
	return best
end

-- ESP
local function dnew(cls, props)
	local ok, d = pcall(Drawing.new, cls)
	if not ok or not d then return nil end
	for k, v in pairs(props) do pcall(function() d[k] = v end) end
	pcall(function() d.Visible = true end)
	return d
end

local function eset(model)
	if M.draw[model] then return M.draw[model] end
	local e = {
		box = dnew("Square", { Thickness = 1, Color = T.accent, Filled = false }),
		nm = dnew("Text", { Size = 13, Center = true, Outline = true, Color = Color3.new(1, 1, 1) }),
		ds = dnew("Text", { Size = 12, Center = true, Outline = true, Color = T.hot }),
		hb = dnew("Square", { Thickness = 0, Filled = true, Color = Color3.fromRGB(18, 12, 13) }),
		hf = dnew("Square", { Thickness = 0, Filled = true, Color = T.ok }),
		tr = dnew("Line", { Thickness = 1, Color = T.accent, Transparency = 0.4 }),
		sk = { dnew("Line", { Thickness = 1, Color = Color3.new(1, 1, 1), Transparency = 0.3 }), dnew("Line", { Thickness = 1, Color = Color3.new(1, 1, 1), Transparency = 0.3 }), dnew("Line", { Thickness = 1, Color = Color3.new(1, 1, 1), Transparency = 0.3 }), dnew("Line", { Thickness = 1, Color = Color3.new(1, 1, 1), Transparency = 0.3 }) },
		hl = nil,
	}
	M.draw[model] = e
	return e
end

local function efree(model)
	local e = M.draw[model]
	if not e then return end
	for k, d in pairs(e) do
		if k == "sk" then for _, l in ipairs(d) do pcall(function() l:Remove() end) end
		elseif k ~= "hl" and d then pcall(function() d:Remove() end) end
	end
	if e.hl then pcall(function() e.hl:Destroy() end) end
	M.draw[model] = nil
end

local function ehide(e)
	for k, d in pairs(e) do
		if k == "sk" then for _, l in ipairs(d) do pcall(function() l.Visible = false end) end
		elseif k ~= "hl" and d then pcall(function() d.Visible = false end) end
	end
end

local function edraw(model)
	local e = eset(model)
	local ok, cf, size = pcall(function() return model:GetBoundingBox() end)
	if not ok then ehide(e) return end
	local v = vp()
	local mnX, mnY, mxX, mxY = math.huge, math.huge, -1, -1
	for _, sx in ipairs({ -0.5, 0.5 }) do for _, sy in ipairs({ -0.5, 0.5 }) do for _, sz in ipairs({ -0.5, 0.5 }) do
		local sp = w2s(cf * Vector3.new(size.X * sx, size.Y * sy, size.Z * sz))
		if sp then mnX = math.min(mnX, sp.X) mxX = math.max(mxX, sp.X) mnY = math.min(mnY, sp.Y) mxY = math.max(mxY, sp.Y) end
	end end end
	if mnX == math.huge or mxX < 0 or mnX > v.X then ehide(e) return end
	local w, h = mxX - mnX, mxY - mnY
	if w < 1 or h < 1 then ehide(e) return end

	e.box.Visible = M.cfg.Box
	e.box.Thickness = M.cfg.Thick
	e.box.Size = Vector2.new(w, h)
	e.box.Position = Vector2.new(mnX, mnY)

	e.nm.Visible = M.cfg.Name
	e.nm.Position = Vector2.new(mnX + w / 2, mnY - 15)
	e.nm.Text = model.Name

	e.ds.Visible = M.cfg.Dist
	e.ds.Position = Vector2.new(mnX + w / 2, mxY + 2)
	e.ds.Text = string.format("%d studs", math.floor((model:GetPivot().Position - cam().CFrame.Position).Magnitude))

	e.tr.Visible = M.cfg.Tracer
	e.tr.From = Vector2.new(v.X / 2, v.Y)
	e.tr.To = Vector2.new(mnX + w / 2, mxY)

	local hum = model:FindFirstChildOfClass("Humanoid")
	if hum then
		local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
		e.hb.Visible = M.cfg.Health
		e.hf.Visible = M.cfg.Health
		e.hb.Size = Vector2.new(3, h)
		e.hb.Position = Vector2.new(mnX - 6, mnY)
		e.hf.Size = Vector2.new(3, h * pct)
		e.hf.Position = Vector2.new(mnX - 6, mnY + h * (1 - pct))
		e.hf.Color = Color3.fromRGB(80 + 150 * (1 - pct), 60 + 130 * pct, 90)
	else
		e.hb.Visible = false
		e.hf.Visible = false
	end

	local sk = { "Head", "Torso", "UpperTorso" }
	local tor = nil
	for _, n in ipairs(sk) do local p = model:FindFirstChild(n) if p then tor = p break end end
	if tor then
		local pairs_ = { { "LeftUpperArm", "RightUpperArm" }, { "LeftUpperLeg", "RightUpperLeg" } }
		local idx = 1
		for _, pair in ipairs(pairs_) do
			for _, n in ipairs(pair) do
				local p = model:FindFirstChild(n)
				local a, b = w2s(tor.Position), p and w2s(p.Position)
				local l = e.sk[idx]
				if a and b and l and M.cfg.Skeleton then l.Visible = true l.From = a l.To = b else if l then l.Visible = false end end
				idx += 1
				if idx > 4 then idx = 4 end
			end
		end
	else
		for _, l in ipairs(e.sk) do pcall(function() l.Visible = false end) end
	end
end

-- chams
local function chams(on)
	for _, t in ipairs(M.targets()) do
		local e = M.draw[t.model]
		if on then
			if not e then e = eset(t.model) end
			if not e.hl then
				local h = Instance.new("Highlight")
				h.FillColor = T.accent
				h.FillTransparency = 0.65
				h.OutlineColor = T.hot
				h.Parent = t.model
				e.hl = h
			end
		elseif e and e.hl then
			pcall(function() e.hl:Destroy() end)
			e.hl = nil
		end
	end
end

-- silent aim
local Silent = {}
function Silent.on()
	if Silent.orig then return end
	local mod = getgenv and getgenv().GameUIMod
	if not mod or not mod.GetMousePos then return end
	Silent.mod, Silent.orig = mod, mod.GetMousePos
	mod.GetMousePos = function(...)
		local t = M.pick()
		if not t then return Silent.orig(...) end
		local part = partOf(t.model, M.cfg.AimPart)
		if not part then return Silent.orig(...) end
		local sp = w2s(part.Position)
		if not sp then return Silent.orig(...) end
		if (sp - center()).Magnitude > M.cfg.SilentFov then return Silent.orig(...) end
		return sp
	end
end
function Silent.off()
	if Silent.mod and Silent.orig then pcall(function() Silent.mod.GetMousePos = Silent.orig end) end
	Silent.mod, Silent.orig = nil, nil
end

-- disparo
local function shoot()
	if not pcall(function() getgenv().Controller:LeftClick() end) then pcall(function() mouse1click() end) end
end

-- embers
function M.embers(on)
	for _, f in ipairs(embers) do f:Destroy() end
	embers = {}
	if not on or not panel then return end
	for i = 1, (LAYOUT == "MOBILE" and 10 or 16) do
		task.spawn(function()
			while panel and panel.Parent do
				local f = mk("Frame", { Size = UDim2.fromOffset(math.random(1, 3), math.random(1, 3)), BackgroundColor3 = T.hot, BackgroundTransparency = 1, Position = UDim2.fromScale(math.random(), 1), BorderSizePixel = 0, ZIndex = 12 }, panel)
				corner(f, 2)
				table.insert(embers, f)
				tw(f, { Position = UDim2.fromScale(math.random(), math.random(0.1, 0.4)), BackgroundTransparency = math.random(30, 60) / 100 }, math.random(30, 60) / 10, Enum.EasingStyle.Linear)
				task.wait(math.random(20, 60) / 10)
				task.wait(1.5)
				pcall(function() f:Destroy() end)
			end
		end)
	end
end

-- loop
bind(RS.RenderStepped, function()
	pcall(function()
		local c = cam()
		if not c then return end

		if M.cfg.ESP then
			local seen = {}
			for _, t in ipairs(M.targets()) do
				seen[t.model] = true
				edraw(t.model)
			end
			for m in pairs(M.draw) do if not seen[m] then efree(m) end end
			if M.cfg.Chams then chams(true) end
		end

		if M.cfg.Aim then
			local t = M.pick()
			if t then
				local part = partOf(t.model, M.cfg.AimPart)
				if part then
					local pos = part.Position
					if M.cfg.Pred > 0 then pos = pos + (part.AssemblyLinearVelocity or Vector3.zero) * M.cfg.Pred end
					c.CFrame = c.CFrame:Lerp(CFrame.lookAt(c.CFrame.Position, pos), M.cfg.Smooth)
				end
			end
		end

		if M.cfg.Trigger and os.clock() - M.lastShot > M.cfg.TrigDelay then
			local cc = center()
			for _, t in ipairs(M.targets()) do
				local part = partOf(t.model, "Head")
				local sp = part and w2s(part.Position)
				if sp and (sp - cc).Magnitude <= M.cfg.Fov then
					M.lastShot = os.clock()
					shoot()
					break
				end
			end
		end

		local c2 = cam()
		if c2 and c2.FieldOfView ~= M.cfg.CamFov then c2.FieldOfView = M.cfg.CamFov end
	end)
end)

-- humanoide
task.spawn(function()
	while gui.Parent do
		local c = char()
		local h = c and c:FindFirstChildOfClass("Humanoid")
		if h then
			if M.cfg.Speed then h.WalkSpeed = M.cfg.SpeedVal end
			if M.cfg.Jump then h.JumpPower = 90 h.UseJumpPower = true end
			if M.cfg.Respawn and h.Health <= 0 then task.wait(2) pcall(function() LP:LoadCharacter() end) end
		end
		task.wait(0.4)
	end
end)

-- fullbright
local Lighting = game:GetService("Lighting")
local brightConn
function M.bright(on)
	if on then
		brightConn = RS.RenderStepped:Connect(function()
			Lighting.Ambient = Color3.new(1, 1, 1)
			Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
			Lighting.Brightness = 2
		end)
	elseif brightConn then
		brightConn:Disconnect()
		brightConn = nil
	end
end

--==============================================================
-- API
--==============================================================
function M.set(key, v)
	M.cfg[key] = v
	if key == "Silent" then if v then Silent.on() else Silent.off() end end
	if key == "Chams" and not v then for m, e in pairs(M.draw) do if e.hl then pcall(function() e.hl:Destroy() end) e.hl = nil end end end
	if key == "ESP" and not v then for m in pairs(M.draw) do efree(m) end end
	if key == "Bright" then M.bright(v) end
	if key == "Embers" then M.embers(v) end
	if M.hook[key] then M.hook[key]() end
end

function M.reset()
	for k, v in pairs({ Aim = false, ESP = false, Silent = false, Trigger = false, Speed = false, Jump = false, Bright = false, Respawn = false, Chams = false }) do
		M.set(k, v)
	end
end

function M.unload()
	for _, c in ipairs(M.conns) do pcall(function() c:Disconnect() end) end
	Silent.off()
	M.bright(false)
	for m in pairs(M.draw) do efree(m) end
	for _, f in ipairs(embers) do f:Destroy() end
	pcall(function() gui:Destroy() end)
end

--==============================================================
-- ARRANQUE
--==============================================================
local open, close

local function start(layout)
	LAYOUT = layout
	D = DIM[layout]
	local o, c = buildPanel()
	open, close = o, c
	M.embers(true)
	tw(gate, { BackgroundTransparency = 1 }, 0.3)
	tw(gateDragon, { ImageTransparency = 1 }, 0.3)
	task.delay(0.3, function()
		gate:Destroy()
		open()
	end)
end

cardPc.MouseButton1Click:Connect(function() start("PC") end)
cardPh.MouseButton1Click:Connect(function() start("MOBILE") end)
fab.MouseButton1Click:Connect(function() open() end)
