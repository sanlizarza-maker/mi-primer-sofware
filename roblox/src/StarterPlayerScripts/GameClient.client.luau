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
toastHolder.Size = UDim2.new(0, 340, 1, -260)
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
	toastHolder.Size = small and UDim2.new(0, 240, 1, -220) or UDim2.new(0, 340, 1, -260)
end
camera:GetPropertyChangedSignal("ViewportSize"):Connect(adaptToScreen)
adaptToScreen()

local toastCount = 0
local function toast(text, color)
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
	if eventBanner.Visible then
		local left = math.max(0, math.ceil(eventEndsAt - t))
		local base = eventLabel.Text:gsub("%s%(%d+s%)$", "")
		eventLabel.Text = base .. " (" .. left .. "s)"
	end
end)
