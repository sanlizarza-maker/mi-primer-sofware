-- GameClient (LocalScript dentro de StarterPlayer > StarterPlayerScripts)
-- Interfaz: monedas, ingresos, botón de renacer, avisos y banner de eventos.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local remote = ReplicatedStorage:WaitForChild("GameRemote")
local player = Players.LocalPlayer

---------------------------------------------------------------------
-- Interfaz
---------------------------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "CriaturasHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 12)
	c.Parent = parent
end

local function stroke(parent, color)
	local s = Instance.new("UIStroke")
	s.Thickness = 3
	s.Color = color or Color3.fromRGB(20, 20, 30)
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
end

local function label(parent, text, size, position, color)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Size = size
	l.Position = position or UDim2.new()
	l.Font = Enum.Font.FredokaOne
	l.TextScaled = true
	l.TextColor3 = color or Color3.new(1, 1, 1)
	l.TextStrokeTransparency = 0.3
	l.Text = text
	l.Parent = parent
	return l
end

-- Panel de monedas (arriba al centro)
local coinPanel = Instance.new("Frame")
coinPanel.AnchorPoint = Vector2.new(0.5, 0)
coinPanel.Position = UDim2.new(0.5, 0, 0, 8)
coinPanel.Size = UDim2.fromOffset(260, 78)
coinPanel.BackgroundColor3 = Color3.fromRGB(255, 200, 40)
coinPanel.Parent = gui
corner(coinPanel, 16)
stroke(coinPanel)

local coinLabel = label(coinPanel, "💰 0", UDim2.new(1, -16, 0.6, 0), UDim2.fromOffset(8, 4))
local incomeLabel = label(coinPanel, "+0/s", UDim2.new(1, -16, 0.35, 0), UDim2.new(0, 8, 0.6, 0), Color3.fromRGB(255, 255, 230))

-- Botón de renacer (abajo a la derecha)
local rebirthButton = Instance.new("TextButton")
rebirthButton.AnchorPoint = Vector2.new(1, 1)
rebirthButton.Position = UDim2.new(1, -16, 1, -16)
rebirthButton.Size = UDim2.fromOffset(200, 64)
rebirthButton.BackgroundColor3 = Color3.fromRGB(170, 90, 255)
rebirthButton.Font = Enum.Font.FredokaOne
rebirthButton.TextScaled = true
rebirthButton.TextColor3 = Color3.new(1, 1, 1)
rebirthButton.Text = "🔁 Renacer"
rebirthButton.Parent = gui
corner(rebirthButton, 16)
stroke(rebirthButton)

rebirthButton.Activated:Connect(function()
	remote:FireServer("Rebirth")
end)

---------------------------------------------------------------------
-- Botones de la izquierda: Tienda, Códigos, Diario
---------------------------------------------------------------------

local MarketplaceService = game:GetService("MarketplaceService")
local toast -- se define más abajo

local sideBar = Instance.new("Frame")
sideBar.BackgroundTransparency = 1
sideBar.AnchorPoint = Vector2.new(0, 1)
sideBar.Position = UDim2.new(0, 16, 1, -16)
sideBar.Size = UDim2.fromOffset(170, 3 * 54 + 2 * 8)
sideBar.Parent = gui
local sideLayout = Instance.new("UIListLayout")
sideLayout.Padding = UDim.new(0, 8)
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
sideLayout.Parent = sideBar

local function sideButton(text, color, order)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 54)
	b.BackgroundColor3 = color
	b.Font = Enum.Font.FredokaOne
	b.TextScaled = true
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Text = text
	b.LayoutOrder = order
	b.Parent = sideBar
	corner(b, 14)
	stroke(b)
	return b
end

local shopButton = sideButton("🛒 Tienda", Color3.fromRGB(40, 170, 255), 1)
local codesButton = sideButton("🎁 Códigos", Color3.fromRGB(255, 110, 150), 2)
local dailyButton = sideButton("📅 Diario", Color3.fromRGB(60, 200, 110), 3)

-- Ventana genérica
local function makeWindow(titleText, height)
	local w = Instance.new("Frame")
	w.AnchorPoint = Vector2.new(0.5, 0.5)
	w.Position = UDim2.fromScale(0.5, 0.5)
	w.Size = UDim2.new(0, 380, 0, height)
	w.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	w.Visible = false
	w.ZIndex = 5
	w.Parent = gui
	corner(w, 18)
	stroke(w)
	local t = label(w, titleText, UDim2.new(1, -70, 0, 40), UDim2.fromOffset(16, 10))
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.ZIndex = 6
	local close = Instance.new("TextButton")
	close.Size = UDim2.fromOffset(40, 40)
	close.Position = UDim2.new(1, -50, 0, 10)
	close.BackgroundColor3 = Color3.fromRGB(230, 70, 70)
	close.Font = Enum.Font.FredokaOne
	close.TextScaled = true
	close.TextColor3 = Color3.new(1, 1, 1)
	close.Text = "X"
	close.ZIndex = 6
	close.Parent = w
	corner(close, 10)
	close.Activated:Connect(function()
		w.Visible = false
	end)
	return w
end

local windows = {}
local function toggle(w)
	local show = not w.Visible
	for _, other in ipairs(windows) do
		other.Visible = false
	end
	w.Visible = show
end

-- Tienda de pases
local ownedPasses = {}
local shopWindow = makeWindow("🛒 Tienda", 70 + #Config.Gamepasses * 92)
table.insert(windows, shopWindow)
local passButtons = {}

for i, pass in ipairs(Config.Gamepasses) do
	local row = Instance.new("Frame")
	row.Position = UDim2.new(0, 14, 0, 60 + (i - 1) * 92)
	row.Size = UDim2.new(1, -28, 0, 82)
	row.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
	row.ZIndex = 6
	row.Parent = shopWindow
	corner(row, 12)
	local n = label(row, pass.name, UDim2.new(0.62, 0, 0.45, 0), UDim2.fromOffset(10, 6))
	n.TextXAlignment = Enum.TextXAlignment.Left
	n.ZIndex = 7
	local d = label(row, pass.desc, UDim2.new(0.62, 0, 0.38, 0), UDim2.new(0, 10, 0.52, 0), Color3.fromRGB(210, 210, 230))
	d.TextXAlignment = Enum.TextXAlignment.Left
	d.ZIndex = 7
	local buy = Instance.new("TextButton")
	buy.AnchorPoint = Vector2.new(1, 0.5)
	buy.Position = UDim2.new(1, -10, 0.5, 0)
	buy.Size = UDim2.new(0.33, 0, 0, 50)
	buy.BackgroundColor3 = Color3.fromRGB(60, 200, 110)
	buy.Font = Enum.Font.FredokaOne
	buy.TextScaled = true
	buy.TextColor3 = Color3.new(1, 1, 1)
	buy.Text = pass.id == 0 and "Pronto" or "Comprar"
	buy.ZIndex = 7
	buy.Parent = row
	corner(buy, 10)
	passButtons[pass.key] = buy

	if pass.id ~= 0 then
		task.spawn(function()
			local ok, info = pcall(function()
				return MarketplaceService:GetProductInfo(pass.id, Enum.InfoType.GamePass)
			end)
			if ok and info and info.PriceInRobux and not ownedPasses[pass.key] then
				buy.Text = "R$ " .. info.PriceInRobux
			end
		end)
	end

	buy.Activated:Connect(function()
		if ownedPasses[pass.key] then
			return
		end
		if pass.id == 0 then
			toast("Este pase todavía no está disponible.")
			return
		end
		MarketplaceService:PromptGamePassPurchase(player, pass.id)
	end)
end

local function refreshPasses()
	for key, button in pairs(passButtons) do
		if ownedPasses[key] then
			button.Text = "✅ Tienes"
			button.BackgroundColor3 = Color3.fromRGB(90, 90, 110)
		end
	end
end

shopButton.Activated:Connect(function()
	toggle(shopWindow)
end)

-- Códigos
local codesWindow = makeWindow("🎁 Códigos", 190)
table.insert(windows, codesWindow)
local codeBox = Instance.new("TextBox")
codeBox.Position = UDim2.new(0, 14, 0, 62)
codeBox.Size = UDim2.new(1, -28, 0, 50)
codeBox.BackgroundColor3 = Color3.fromRGB(250, 250, 255)
codeBox.Font = Enum.Font.FredokaOne
codeBox.TextScaled = true
codeBox.TextColor3 = Color3.fromRGB(30, 30, 40)
codeBox.PlaceholderText = "Escribe un código..."
codeBox.Text = ""
codeBox.ClearTextOnFocus = false
codeBox.ZIndex = 6
codeBox.Parent = codesWindow
corner(codeBox, 10)
local redeem = Instance.new("TextButton")
redeem.Position = UDim2.new(0, 14, 0, 124)
redeem.Size = UDim2.new(1, -28, 0, 50)
redeem.BackgroundColor3 = Color3.fromRGB(255, 110, 150)
redeem.Font = Enum.Font.FredokaOne
redeem.TextScaled = true
redeem.TextColor3 = Color3.new(1, 1, 1)
redeem.Text = "Canjear"
redeem.ZIndex = 6
redeem.Parent = codesWindow
corner(redeem, 10)
redeem.Activated:Connect(function()
	if codeBox.Text ~= "" then
		remote:FireServer("Code", codeBox.Text)
		codeBox.Text = ""
	end
end)
codesButton.Activated:Connect(function()
	toggle(codesWindow)
end)

-- Diario
local dailyReadyAt = math.huge
local dailyNextDay = 1
dailyButton.Activated:Connect(function()
	if os.clock() >= dailyReadyAt then
		remote:FireServer("Daily")
	else
		toast("Vuelve más tarde para tu recompensa del día " .. dailyNextDay .. ".")
	end
end)

-- Banner de evento
local eventBanner = Instance.new("Frame")
eventBanner.AnchorPoint = Vector2.new(0.5, 0)
eventBanner.Position = UDim2.new(0.5, 0, 0, 94)
eventBanner.Size = UDim2.fromOffset(460, 50)
eventBanner.BackgroundColor3 = Color3.fromRGB(40, 180, 90)
eventBanner.Visible = false
eventBanner.Parent = gui
corner(eventBanner, 12)
stroke(eventBanner)
local eventLabel = label(eventBanner, "", UDim2.new(1, -16, 1, -8), UDim2.fromOffset(8, 4))

-- Contenedor de avisos (a la izquierda)
local toastHolder = Instance.new("Frame")
toastHolder.BackgroundTransparency = 1
toastHolder.Position = UDim2.new(0, 16, 0, 160)
toastHolder.Size = UDim2.new(0, 340, 1, -380)
toastHolder.Parent = gui
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = toastHolder

-- Pantallas pequeñas (móvil): reducir tamaños
local camera = workspace.CurrentCamera
local function adaptToScreen()
	local small = camera.ViewportSize.X < 700
	coinPanel.Size = small and UDim2.fromOffset(190, 60) or UDim2.fromOffset(260, 78)
	rebirthButton.Size = small and UDim2.fromOffset(150, 50) or UDim2.fromOffset(200, 64)
	eventBanner.Size = small and UDim2.fromOffset(320, 40) or UDim2.fromOffset(460, 50)
	toastHolder.Size = small and UDim2.new(0, 240, 1, -330) or UDim2.new(0, 340, 1, -380)
	sideBar.Size = small and UDim2.fromOffset(130, 3 * 54 + 2 * 8) or UDim2.fromOffset(170, 3 * 54 + 2 * 8)
end
camera:GetPropertyChangedSignal("ViewportSize"):Connect(adaptToScreen)
adaptToScreen()

local toastCount = 0
function toast(text, color)
	toastCount += 1
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 46)
	frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	frame.BackgroundTransparency = 0.15
	frame.LayoutOrder = toastCount
	frame.Parent = toastHolder
	corner(frame, 10)
	local l = label(frame, text, UDim2.new(1, -16, 1, -8), UDim2.fromOffset(8, 4), color)
	l.TextXAlignment = Enum.TextXAlignment.Left

	local children = toastHolder:GetChildren()
	local frames = {}
	for _, c in ipairs(children) do
		if c:IsA("Frame") then
			table.insert(frames, c)
		end
	end
	if #frames > 5 then
		table.sort(frames, function(a, b)
			return a.LayoutOrder < b.LayoutOrder
		end)
		frames[1]:Destroy()
	end

	task.delay(5, function()
		if frame.Parent then
			local info = TweenInfo.new(0.4)
			TweenService:Create(frame, info, { BackgroundTransparency = 1 }):Play()
			TweenService:Create(l, info, { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
			task.wait(0.45)
			frame:Destroy()
		end
	end)
end

---------------------------------------------------------------------
-- Datos
---------------------------------------------------------------------

local leaderstats = player:WaitForChild("leaderstats")
local coins = leaderstats:WaitForChild("Monedas")

local function updateCoins()
	coinLabel.Text = "💰 " .. Config.FormatNumber(coins.Value)
end
coins.Changed:Connect(updateCoins)
updateCoins()

local eventEndsAt = 0

remote.OnClientEvent:Connect(function(kind, a, b, c)
	if kind == "Notify" then
		toast(a, b)
	elseif kind == "Stats" then
		incomeLabel.Text = "+" .. Config.FormatNumber(a) .. "/s  ·  x" .. tostring(b)
		rebirthButton.Text = "🔁 Renacer ($" .. Config.FormatNumber(c) .. ")"
		rebirthButton.BackgroundColor3 = coins.Value >= c and Color3.fromRGB(170, 90, 255) or Color3.fromRGB(110, 90, 130)
	elseif kind == "Event" then
		if a then
			eventBanner.Visible = true
			eventLabel.Text = b
			eventEndsAt = os.clock() + (c or 60)
			toast(b, Color3.fromRGB(120, 255, 150))
		else
			eventBanner.Visible = false
			toast("La lluvia de suerte terminó.", Color3.fromRGB(200, 200, 200))
		end
	elseif kind == "Daily" then
		dailyReadyAt = os.clock() + a
		dailyNextDay = b
	elseif kind == "Passes" then
		ownedPasses = a or {}
		refreshPasses()
	end
end)

---------------------------------------------------------------------
-- Mostrar solo los botones que te corresponden
-- (vender/escudo: solo el dueño · robar: solo los demás)
---------------------------------------------------------------------

local function refreshPrompt(prompt)
	local kind = prompt:GetAttribute("Kind")
	local ownerId = prompt:GetAttribute("OwnerId")
	if kind == "Steal" then
		prompt.Enabled = ownerId ~= player.UserId
	elseif kind == "Sell" or kind == "Lock" then
		prompt.Enabled = ownerId == player.UserId
	end
end

local function watch(inst)
	if inst:IsA("ProximityPrompt") then
		refreshPrompt(inst)
		inst:GetAttributeChangedSignal("OwnerId"):Connect(function()
			refreshPrompt(inst)
		end)
	end
end

for _, d in ipairs(workspace:GetDescendants()) do
	watch(d)
end
workspace.DescendantAdded:Connect(watch)

---------------------------------------------------------------------
-- Efectos visuales
---------------------------------------------------------------------

RunService.RenderStepped:Connect(function()
	local t = os.clock()
	for i, part in ipairs(CollectionService:GetTagged("Rainbow")) do
		part.Color = Color3.fromHSV((t * 0.35 + i * 0.13) % 1, 1, 1)
	end
	if t >= dailyReadyAt then
		dailyButton.Text = "📅 ¡Reclamar!"
		dailyButton.BackgroundColor3 = Color3.fromRGB(60, 200, 110)
	elseif dailyReadyAt ~= math.huge then
		local left = math.ceil(dailyReadyAt - t)
		dailyButton.Text = string.format("📅 %dh %02dm", left // 3600, (left % 3600) // 60)
		dailyButton.BackgroundColor3 = Color3.fromRGB(90, 120, 100)
	end
	if eventBanner.Visible then
		local left = math.max(0, math.ceil(eventEndsAt - t))
		local base = eventLabel.Text:gsub("%s%(%d+s%)$", "")
		eventLabel.Text = base .. " (" .. left .. "s)"
	end
end)
