-- GameServer (Script dentro de ServerScriptService)
-- Construye el mapa, maneja la cinta de criaturas, bases, robos, ingresos,
-- renacimientos, eventos y guardado de datos.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local Config = require(ReplicatedStorage:WaitForChild("Config"))

local remote = Instance.new("RemoteEvent")
remote.Name = "GameRemote"
remote.Parent = ReplicatedStorage

local rng = Random.new()

local store = nil
do
	local ok, result = pcall(function()
		return DataStoreService:GetDataStore(Config.DataStoreName)
	end)
	if ok then
		store = result
	else
		warn("[CriaturasCaoticas] DataStore no disponible (¿activaste 'Enable Studio Access to API Services'?):", result)
	end
end

---------------------------------------------------------------------
-- Utilidades
---------------------------------------------------------------------

local function makePart(props)
	local parent = props.Parent
	props.Parent = nil
	local p = Instance.new("Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in pairs(props) do
		p[k] = v
	end
	p.Parent = parent
	return p
end

local function makeLabel(parent, text, size, color, position)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = size
	label.Position = position or UDim2.new()
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.TextColor3 = color or Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.2
	label.Text = text
	label.Parent = parent
	return label
end

local function notify(player, text, color)
	remote:FireClient(player, "Notify", text, color)
end

local function notifyAll(text, color)
	remote:FireAllClients("Notify", text, color)
end

local function displayName(def, mutName)
	if mutName then
		return mutName .. " " .. def.name
	end
	return def.name
end

---------------------------------------------------------------------
-- Mapa
---------------------------------------------------------------------

local map = Instance.new("Folder")
map.Name = "CriaturasCaoticasMapa"
map.Parent = workspace

local oldBaseplate = workspace:FindFirstChild("Baseplate")
if oldBaseplate then
	oldBaseplate:Destroy()
end

makePart({
	Name = "Suelo",
	Size = Vector3.new(420, 2, 320),
	Position = Vector3.new(0, -1, 0),
	Color = Color3.fromRGB(110, 190, 90),
	Material = Enum.Material.Grass,
	Parent = map,
})

local spawnPoint = Instance.new("SpawnLocation")
spawnPoint.Anchored = true
spawnPoint.Size = Vector3.new(10, 1, 10)
spawnPoint.Position = Vector3.new(-150, 0.5, 0)
spawnPoint.Neutral = true
spawnPoint.Duration = 0
spawnPoint.Parent = map

-- Cinta transportadora en el centro (eje X)
local CONVEYOR_START_X = -118
local CONVEYOR_END_X = 118
makePart({
	Name = "Cinta",
	Size = Vector3.new(CONVEYOR_END_X - CONVEYOR_START_X + 10, 1, 12),
	Position = Vector3.new(0, 0.5, 0),
	Color = Color3.fromRGB(45, 45, 55),
	Material = Enum.Material.DiamondPlate,
	Parent = map,
})
for _, z in ipairs({ -6.5, 6.5 }) do
	makePart({
		Name = "Borde",
		Size = Vector3.new(CONVEYOR_END_X - CONVEYOR_START_X + 10, 1.5, 1),
		Position = Vector3.new(0, 0.75, z),
		Color = Color3.fromRGB(255, 210, 0),
		Material = Enum.Material.Neon,
		Parent = map,
	})
end

local conveyorFolder = Instance.new("Folder")
conveyorFolder.Name = "CriaturasEnCinta"
conveyorFolder.Parent = workspace

-- Bases (6 jugadores por servidor: pon "Max Players" en 6)
local PLOT_W, PLOT_D = 60, 44
local plotCenters = {
	Vector3.new(-80, 0, -55), Vector3.new(0, 0, -55), Vector3.new(80, 0, -55),
	Vector3.new(-80, 0, 55), Vector3.new(0, 0, 55), Vector3.new(80, 0, 55),
}
local plotColors = {
	Color3.fromRGB(255, 120, 120), Color3.fromRGB(120, 180, 255), Color3.fromRGB(255, 220, 110),
	Color3.fromRGB(170, 120, 255), Color3.fromRGB(120, 230, 170), Color3.fromRGB(255, 160, 220),
}

local plots = {}

for index, center in ipairs(plotCenters) do
	local dir = center.Z < 0 and 1 or -1 -- dirección hacia la cinta
	local folder = Instance.new("Folder")
	folder.Name = "Base" .. index
	folder.Parent = map

	makePart({
		Name = "Piso",
		Size = Vector3.new(PLOT_W, 1, PLOT_D),
		Position = center + Vector3.new(0, 0.5, 0),
		Color = plotColors[index],
		Material = Enum.Material.SmoothPlastic,
		Parent = folder,
	})

	local pedestals = {}
	local columns = { -24, -12, 0, 12, 24 }
	local rows = { 8, -6 }
	for _, rowOffset in ipairs(rows) do
		for _, x in ipairs(columns) do
			local ped = makePart({
				Name = "Pedestal",
				Size = Vector3.new(6, 2, 6),
				Position = center + Vector3.new(x, 2, dir * rowOffset),
				Color = Color3.fromRGB(240, 240, 240),
				Material = Enum.Material.Marble,
				Parent = folder,
			})
			table.insert(pedestals, ped)
		end
	end

	local signPos = center + Vector3.new(0, 6, -dir * 19)
	local sign = makePart({
		Name = "Cartel",
		Size = Vector3.new(24, 7, 1),
		CFrame = CFrame.lookAt(signPos, signPos + Vector3.new(0, 0, dir)),
		Color = Color3.fromRGB(40, 30, 30),
		Parent = folder,
	})
	local surface = Instance.new("SurfaceGui")
	surface.Face = Enum.NormalId.Front
	surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surface.PixelsPerStud = 25
	surface.Parent = sign
	local signLabel = makeLabel(surface, "Base libre", UDim2.fromScale(1, 1), plotColors[index])

	local lockButton = makePart({
		Name = "BotonEscudo",
		Size = Vector3.new(4, 1, 4),
		Position = center + Vector3.new(25, 1.5, dir * 17),
		Color = Color3.fromRGB(255, 60, 60),
		Material = Enum.Material.Neon,
		Parent = folder,
	})
	local lockGui = Instance.new("BillboardGui")
	lockGui.Size = UDim2.fromOffset(160, 40)
	lockGui.StudsOffset = Vector3.new(0, 3, 0)
	lockGui.MaxDistance = 80
	lockGui.Parent = lockButton
	local lockLabel = makeLabel(lockGui, "🛡️ ESCUDO", UDim2.fromScale(1, 1))

	local shield = makePart({
		Name = "Escudo",
		Size = Vector3.new(PLOT_W, 30, PLOT_D),
		Position = center + Vector3.new(0, 15, 0),
		Color = Color3.fromRGB(255, 80, 80),
		Material = Enum.Material.ForceField,
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
		CastShadow = false,
		Parent = folder,
	})

	table.insert(plots, {
		index = index,
		center = center,
		dir = dir,
		folder = folder,
		pedestals = pedestals,
		signLabel = signLabel,
		lockButton = lockButton,
		lockLabel = lockLabel,
		shield = shield,
		owner = nil,
	})
end

local function isInPlot(position, plot)
	local c = plot.center
	return math.abs(position.X - c.X) <= PLOT_W / 2
		and math.abs(position.Z - c.Z) <= PLOT_D / 2
		and position.Y < c.Y + 40
end

---------------------------------------------------------------------
-- Criaturas (modelo visual)
---------------------------------------------------------------------

local function weld(a, b)
	local w = Instance.new("WeldConstraint")
	w.Part0 = a
	w.Part1 = b
	w.Parent = a
end

local function buildCreature(def, mutName, priceText)
	local rarity = Config.GetRarity(def.rarity)
	local mut = Config.GetMutation(mutName)
	local s = rarity.size

	local model = Instance.new("Model")
	model.Name = def.name

	local body = Instance.new("Part")
	body.Name = "Body"
	body.Shape = def.shape == "Block" and Enum.PartType.Block or Enum.PartType.Ball
	body.Size = Vector3.new(s, s, s)
	body.Color = mut and mut.color or def.color
	body.Material = mut and mut.material or Enum.Material.SmoothPlastic
	body.Anchored = true
	body.CanCollide = false
	body.TopSurface = Enum.SurfaceType.Smooth
	body.BottomSurface = Enum.SurfaceType.Smooth
	body.CFrame = CFrame.new()
	body.Parent = model
	model.PrimaryPart = body
	if mut and mut.rainbow then
		CollectionService:AddTag(body, "Rainbow")
	end

	local function addBall(size, color, offset)
		local p = Instance.new("Part")
		p.Shape = Enum.PartType.Ball
		p.Size = Vector3.new(size, size, size)
		p.Color = color
		p.Material = Enum.Material.SmoothPlastic
		p.CanCollide = false
		p.CanQuery = false
		p.Massless = true
		p.Anchored = false
		p.CFrame = offset
		p.Parent = model
		weld(body, p)
		return p
	end

	for _, side in ipairs({ -1, 1 }) do
		addBall(s * 0.32, Color3.new(1, 1, 1), CFrame.new(side * s * 0.22, s * 0.15, -s * 0.42))
		addBall(s * 0.15, Color3.new(0, 0, 0), CFrame.new(side * s * 0.22, s * 0.15, -s * 0.56))
	end

	-- Corona para Legendario o más raro
	if Config.GetRarityIndex(def.rarity) >= 5 then
		local crown = Instance.new("Part")
		crown.Size = Vector3.new(s * 0.5, s * 0.3, s * 0.5)
		crown.Color = Color3.fromRGB(255, 215, 0)
		crown.Material = Enum.Material.Neon
		crown.CanCollide = false
		crown.CanQuery = false
		crown.Massless = true
		crown.Anchored = false
		crown.CFrame = CFrame.new(0, s * 0.62, 0)
		crown.Parent = model
		weld(body, crown)
	end

	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(220, 78)
	gui.StudsOffset = Vector3.new(0, s / 2 + 2.2, 0)
	gui.MaxDistance = 70
	gui.Parent = body
	local title = displayName(def, mutName)
	makeLabel(gui, title, UDim2.fromScale(1, 0.4), mut and mut.color or Color3.new(1, 1, 1))
	makeLabel(gui, def.rarity, UDim2.fromScale(1, 0.28), rarity.color, UDim2.fromScale(0, 0.4))
	local income = def.income * (mut and mut.mult or 1)
	local info = "+" .. Config.FormatNumber(income) .. "/s"
	if priceText then
		info = priceText .. "  ·  " .. info
	end
	makeLabel(gui, info, UDim2.fromScale(1, 0.32), Color3.fromRGB(255, 240, 120), UDim2.fromScale(0, 0.68))

	return model, body
end

local function addPrompt(body, actionText, objectText, hold, kind, ownerId, key)
	local pp = Instance.new("ProximityPrompt")
	pp.ActionText = actionText
	pp.ObjectText = objectText
	pp.HoldDuration = hold
	pp.MaxActivationDistance = 10
	pp.RequiresLineOfSight = false
	pp:SetAttribute("Kind", kind)
	if ownerId then
		pp:SetAttribute("OwnerId", ownerId)
	end
	if key then
		pp.KeyboardKeyCode = key
	end
	pp.Parent = body
	return pp
end

---------------------------------------------------------------------
-- Estado de jugadores
---------------------------------------------------------------------

local states = {} -- [Player] = estado

local function freeSlot(st)
	for i = 1, Config.SlotsPerPlot do
		if not st.slots[i] then
			return i
		end
	end
	return nil
end

local function multiplier(st)
	return 1 + st.rebirths.Value * Config.RebirthBonus
end

local function incomeOf(st)
	local total = 0
	for i = 1, Config.SlotsPerPlot do
		local s = st.slots[i]
		if s then
			local def = Config.GetCreature(s.id)
			local mut = Config.GetMutation(s.mut)
			total += def.income * (mut and mut.mult or 1)
		end
	end
	return math.floor(total * multiplier(st))
end

local function setSpeed(player, speed)
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = speed
	end
end

local placeInSlot -- declarada abajo

local function returnToOwner(thiefState, reason)
	local c = thiefState.carrying
	if not c then
		return
	end
	thiefState.carrying = nil
	if c.model then
		c.model:Destroy()
	end
	setSpeed(thiefState.player, Config.NormalSpeed)

	local ownerState = states[c.owner]
	if ownerState and ownerState.loaded then
		local slot = (not ownerState.slots[c.ownerSlot]) and c.ownerSlot or freeSlot(ownerState)
		if slot then
			placeInSlot(ownerState, slot, c.id, c.mut)
		else
			local def = Config.GetCreature(c.id)
			local mut = Config.GetMutation(c.mut)
			ownerState.coins.Value += math.floor(def.price * (mut and mut.mult or 1) * Config.SellRefund)
		end
		notify(c.owner, "✅ Recuperaste tu criatura. " .. (reason or ""), Color3.fromRGB(120, 255, 120))
	end
	notify(thiefState.player, "❌ Perdiste la criatura robada. " .. (reason or ""), Color3.fromRGB(255, 120, 120))
end

local function startSteal(thief, owner, slotIndex, slotData)
	local ts, ownerState = states[thief], states[owner]
	if not ts or not ownerState or thief == owner then
		return
	end
	if ownerState.slots[slotIndex] ~= slotData then
		return
	end
	if ts.carrying then
		notify(thief, "Ya llevas una criatura. ¡Llévala a tu base!")
		return
	end
	if ownerState.lockedUntil > os.clock() then
		notify(thief, "🛡️ Esa base tiene el escudo activo.")
		return
	end
	if not freeSlot(ts) then
		notify(thief, "Tu base está llena. Vende una criatura primero.")
		return
	end
	local char = thief.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local head = char and char:FindFirstChild("Head")
	if not hrp or not head then
		return
	end

	ownerState.slots[slotIndex] = nil
	local model = slotData.model
	local body = model.PrimaryPart
	model:PivotTo(head.CFrame * CFrame.new(0, body.Size.Y / 2 + 1.5, 0))
	model.Parent = char
	weld(hrp, body)
	for _, d in ipairs(model:GetDescendants()) do
		if d:IsA("ProximityPrompt") then
			d:Destroy()
		elseif d:IsA("BasePart") then
			d.Massless = true
			d.CanCollide = false
			d.Anchored = false
		end
	end

	ts.carrying = { id = slotData.id, mut = slotData.mut, model = model, owner = owner, ownerSlot = slotIndex }
	setSpeed(thief, Config.CarrySpeed)

	local def = Config.GetCreature(slotData.id)
	local name = displayName(def, slotData.mut)
	notify(owner, "🚨 ¡" .. thief.DisplayName .. " te está robando " .. name .. "! ¡Tócalo para recuperarla!", Color3.fromRGB(255, 90, 90))
	notify(thief, "😈 ¡Llévala a tu base! Si su dueño te toca, la pierdes.", Color3.fromRGB(255, 200, 80))
end

placeInSlot = function(st, slotIndex, id, mutName)
	local def = Config.GetCreature(id)
	if not def then
		return
	end
	local model, body = buildCreature(def, mutName)
	local ped = st.plot.pedestals[slotIndex]
	local top = ped.Position + Vector3.new(0, ped.Size.Y / 2 + body.Size.Y / 2, 0)
	model:PivotTo(CFrame.lookAt(top, top + Vector3.new(0, 0, st.plot.dir)))
	model.Parent = st.plot.folder

	local slotData = { id = id, mut = mutName, model = model }
	st.slots[slotIndex] = slotData

	local owner = st.player
	local mut = Config.GetMutation(mutName)
	local sellValue = math.floor(def.price * (mut and mut.mult or 1) * Config.SellRefund)

	local sell = addPrompt(body, "Vender ($" .. Config.FormatNumber(sellValue) .. ")", def.name, 0.5, "Sell", owner.UserId, Enum.KeyCode.F)
	sell.Triggered:Connect(function(player)
		if player ~= owner or st.slots[slotIndex] ~= slotData then
			return
		end
		st.slots[slotIndex] = nil
		model:Destroy()
		st.coins.Value += sellValue
		notify(player, "💸 Vendiste " .. displayName(def, mutName) .. " por $" .. Config.FormatNumber(sellValue))
	end)

	local steal = addPrompt(body, "Robar", displayName(def, mutName), Config.StealHoldTime, "Steal", owner.UserId)
	steal.Triggered:Connect(function(thief)
		startSteal(thief, owner, slotIndex, slotData)
	end)
end

---------------------------------------------------------------------
-- Cinta transportadora
---------------------------------------------------------------------

local luckActive = false
local creaturesByRarity = {}
for _, def in ipairs(Config.Creatures) do
	creaturesByRarity[def.rarity] = creaturesByRarity[def.rarity] or {}
	table.insert(creaturesByRarity[def.rarity], def)
end

local function rollCreature()
	local weights, total = {}, 0
	for i, r in ipairs(Config.Rarities) do
		local w = r.weight
		if luckActive and i >= 4 then
			w *= Config.EventLuckMultiplier
		end
		weights[i] = w
		total += w
	end
	local roll = rng:NextNumber() * total
	local chosen = Config.Rarities[1]
	for i, r in ipairs(Config.Rarities) do
		roll -= weights[i]
		if roll <= 0 then
			chosen = r
			break
		end
	end
	local list = creaturesByRarity[chosen.name] or creaturesByRarity[Config.Rarities[1].name]
	return list[rng:NextInteger(1, #list)]
end

local function rollMutation()
	for _, m in ipairs(Config.Mutations) do
		local chance = m.chance * (luckActive and Config.EventLuckMultiplier or 1)
		if rng:NextNumber() < chance then
			return m.name
		end
	end
	return nil
end

local conveyorItems = {}

local function spawnOnConveyor()
	local def = rollCreature()
	local mutName = rollMutation()
	local model, body = buildCreature(def, mutName, "$" .. Config.FormatNumber(def.price))
	local y = 1 + body.Size.Y / 2
	local item = {
		model = model,
		def = def,
		mut = mutName,
		start = os.clock(),
		y = y,
		sold = false,
	}
	model:PivotTo(CFrame.lookAt(Vector3.new(CONVEYOR_START_X, y, 0), Vector3.new(CONVEYOR_END_X, y, 0)))
	model.Parent = conveyorFolder

	local buy = addPrompt(body, "Comprar ($" .. Config.FormatNumber(def.price) .. ")", displayName(def, mutName), 0, "Buy")
	buy.Triggered:Connect(function(player)
		local st = states[player]
		if item.sold or not st or not st.loaded then
			return
		end
		if st.coins.Value < def.price then
			notify(player, "No tienes suficientes monedas 😢")
			return
		end
		local slot = freeSlot(st)
		if not slot then
			notify(player, "Tu base está llena. Vende una criatura (tecla F).")
			return
		end
		item.sold = true
		st.coins.Value -= def.price
		model:Destroy()
		placeInSlot(st, slot, def.id, mutName)
		notify(player, "🎉 ¡Compraste " .. displayName(def, mutName) .. "!", Color3.fromRGB(120, 255, 120))
		if Config.GetRarityIndex(def.rarity) >= 5 or mutName == "Arcoíris" then
			notifyAll("🌟 " .. player.DisplayName .. " consiguió " .. displayName(def, mutName) .. " (" .. def.rarity .. ")!", Config.GetRarity(def.rarity).color)
		end
	end)

	table.insert(conveyorItems, item)

	if Config.GetRarityIndex(def.rarity) >= 6 then
		notifyAll("⚠️ ¡Apareció " .. displayName(def, mutName) .. " (" .. def.rarity .. ") en la cinta!", Config.GetRarity(def.rarity).color)
	end
end

RunService.Heartbeat:Connect(function()
	local now = os.clock()
	for i = #conveyorItems, 1, -1 do
		local item = conveyorItems[i]
		local alpha = (now - item.start) / Config.ConveyorTravelTime
		if item.sold or alpha >= 1 or not item.model.Parent then
			if item.model.Parent then
				item.model:Destroy()
			end
			table.remove(conveyorItems, i)
		else
			local x = CONVEYOR_START_X + (CONVEYOR_END_X - CONVEYOR_START_X) * alpha
			local bob = math.sin(now * 6 + i) * 0.25
			local pos = Vector3.new(x, item.y + bob, 0)
			item.model:PivotTo(CFrame.lookAt(pos, pos + Vector3.xAxis))
		end
	end
end)

task.spawn(function()
	while true do
		spawnOnConveyor()
		task.wait(Config.SpawnInterval)
	end
end)

---------------------------------------------------------------------
-- Guardado
---------------------------------------------------------------------

local function inTransitFrom(player)
	local list = {}
	for _, st in pairs(states) do
		if st.carrying and st.carrying.owner == player then
			table.insert(list, { id = st.carrying.id, mut = st.carrying.mut })
		end
	end
	return list
end

local function save(player, st)
	if not store or st.loadFailed or not st.loaded then
		return
	end
	local creatures = {}
	for i = 1, Config.SlotsPerPlot do
		local s = st.slots[i]
		if s then
			table.insert(creatures, { id = s.id, mut = s.mut })
		end
	end
	for _, c in ipairs(inTransitFrom(player)) do
		table.insert(creatures, c)
	end
	local data = {
		coins = st.coins.Value,
		rebirths = st.rebirths.Value,
		creatures = creatures,
	}
	for attempt = 1, 3 do
		local ok, err = pcall(function()
			store:SetAsync("p_" .. player.UserId, data)
		end)
		if ok then
			return
		end
		warn("[CriaturasCaoticas] Error guardando (intento " .. attempt .. "):", err)
		task.wait(1)
	end
end

---------------------------------------------------------------------
-- Entrada / salida de jugadores
---------------------------------------------------------------------

local function onCharacter(player, char)
	local st = states[player]
	if not st then
		return
	end
	local hrp = char:WaitForChild("HumanoidRootPart", 10)
	if hrp and st.plot then
		task.defer(function()
			char:PivotTo(CFrame.new(st.plot.center + Vector3.new(0, 5, 0)))
		end)
	end
end

Players.PlayerAdded:Connect(function(player)
	local plot = nil
	for _, p in ipairs(plots) do
		if not p.owner then
			plot = p
			break
		end
	end
	if not plot then
		player:Kick("Servidor lleno, ¡prueba otro servidor!")
		return
	end
	plot.owner = player
	plot.signLabel.Text = "Base de " .. player.DisplayName
	plot.lockButton:FindFirstChildOfClass("ProximityPrompt"):SetAttribute("OwnerId", player.UserId)

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	local coins = Instance.new("NumberValue")
	coins.Name = "Monedas"
	coins.Value = Config.StartingCoins
	coins.Parent = leaderstats
	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Renacimientos"
	rebirths.Parent = leaderstats
	leaderstats.Parent = player

	local st = {
		player = player,
		plot = plot,
		coins = coins,
		rebirths = rebirths,
		slots = {},
		carrying = nil,
		lockedUntil = 0,
		lockCooldownUntil = 0,
		loaded = false,
		loadFailed = false,
		lastRebirth = 0,
	}
	states[player] = st

	player.CharacterAdded:Connect(function(char)
		onCharacter(player, char)
	end)
	if player.Character then
		onCharacter(player, player.Character)
	end

	local data = nil
	if store then
		local ok, result = pcall(function()
			return store:GetAsync("p_" .. player.UserId)
		end)
		if ok then
			data = result
		else
			st.loadFailed = true -- no guardamos para no borrar sus datos reales
			warn("[CriaturasCaoticas] No se pudieron cargar los datos:", result)
			notify(player, "⚠️ No se pudieron cargar tus datos. Tu progreso de esta partida no se guardará.")
		end
	end
	if player.Parent == nil then
		return
	end

	if type(data) == "table" then
		coins.Value = tonumber(data.coins) or Config.StartingCoins
		rebirths.Value = tonumber(data.rebirths) or 0
		if type(data.creatures) == "table" then
			for _, c in ipairs(data.creatures) do
				local slot = freeSlot(st)
				if not slot then
					break
				end
				if Config.GetCreature(c.id) then
					placeInSlot(st, slot, c.id, c.mut)
				end
			end
		end
	end
	st.loaded = true

	notify(player, "👋 ¡Bienvenido! Compra criaturas en la cinta amarilla. Ganan monedas solas.")
	notify(player, "😈 Puedes robar criaturas de otras bases. Usa el botón 🛡️ para proteger la tuya.")
	if luckActive then
		remote:FireClient(player, "Event", true, "🍀 ¡LLUVIA DE SUERTE! Más criaturas raras y mutaciones", Config.EventDuration)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	local st = states[player]
	if not st then
		return
	end
	if st.carrying then
		returnToOwner(st, "El ladrón se fue.")
	end
	save(player, st)

	-- Cancelar robos en curso de criaturas de este jugador (ya quedaron guardadas arriba)
	for _, other in pairs(states) do
		if other.carrying and other.carrying.owner == player then
			if other.carrying.model then
				other.carrying.model:Destroy()
			end
			other.carrying = nil
			setSpeed(other.player, Config.NormalSpeed)
			notify(other.player, "El dueño se fue y su criatura desapareció.")
		end
	end

	for i = 1, Config.SlotsPerPlot do
		local s = st.slots[i]
		if s and s.model then
			s.model:Destroy()
		end
	end
	if st.plot then
		st.plot.owner = nil
		st.plot.signLabel.Text = "Base libre"
		st.plot.shield.Transparency = 1
	end
	states[player] = nil
end)

game:BindToClose(function()
	for player, st in pairs(states) do
		task.spawn(save, player, st)
	end
	task.wait(3)
end)

task.spawn(function()
	while true do
		task.wait(Config.AutosaveInterval)
		for player, st in pairs(states) do
			task.spawn(save, player, st)
		end
	end
end)

---------------------------------------------------------------------
-- Escudo de base
---------------------------------------------------------------------

for _, plot in ipairs(plots) do
	local pp = Instance.new("ProximityPrompt")
	pp.ActionText = "Activar escudo"
	pp.ObjectText = "Protege tu base " .. Config.LockDuration .. "s"
	pp.HoldDuration = 0
	pp.MaxActivationDistance = 10
	pp.RequiresLineOfSight = false
	pp:SetAttribute("Kind", "Lock")
	pp.Parent = plot.lockButton
	pp.Triggered:Connect(function(player)
		local st = states[player]
		if not st or st.plot ~= plot then
			return
		end
		local now = os.clock()
		if now < st.lockCooldownUntil then
			notify(player, "El escudo se está recargando: " .. math.ceil(st.lockCooldownUntil - now) .. "s")
			return
		end
		st.lockedUntil = now + Config.LockDuration
		st.lockCooldownUntil = now + Config.LockDuration + Config.LockCooldown
		plot.shield.Transparency = 0.2
		notify(player, "🛡️ ¡Escudo activado por " .. Config.LockDuration .. " segundos!", Color3.fromRGB(120, 200, 255))
	end)
end

---------------------------------------------------------------------
-- Bucles: ingresos, robos, carteles
---------------------------------------------------------------------

-- Ingresos cada segundo + actualización de carteles del escudo
task.spawn(function()
	while true do
		task.wait(1)
		local now = os.clock()
		for player, st in pairs(states) do
			if st.loaded then
				local income = incomeOf(st)
				st.coins.Value += income
				remote:FireClient(player, "Stats", income, multiplier(st), Config.RebirthCost(st.rebirths.Value))
			end
			local plot = st.plot
			if plot then
				if now < st.lockedUntil then
					plot.lockLabel.Text = "🛡️ ACTIVO " .. math.ceil(st.lockedUntil - now) .. "s"
				else
					plot.shield.Transparency = 1
					if now < st.lockCooldownUntil then
						plot.lockLabel.Text = "⏳ " .. math.ceil(st.lockCooldownUntil - now) .. "s"
					else
						plot.lockLabel.Text = "🛡️ ESCUDO"
					end
				end
			end
		end
	end
end)

-- Revisar a los ladrones: entrega en su base, muerte o atrapados por el dueño
task.spawn(function()
	while true do
		task.wait(0.2)
		for player, st in pairs(states) do
			local c = st.carrying
			if c then
				local char = player.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if not hrp or not hum or hum.Health <= 0 or not c.model.Parent then
					returnToOwner(st, "El ladrón cayó.")
				elseif isInPlot(hrp.Position, st.plot) then
					st.carrying = nil
					c.model:Destroy()
					setSpeed(player, Config.NormalSpeed)
					local slot = freeSlot(st)
					local def = Config.GetCreature(c.id)
					if slot then
						placeInSlot(st, slot, c.id, c.mut)
						notify(player, "🏆 ¡Robo exitoso! " .. displayName(def, c.mut) .. " ahora es tuya.", Color3.fromRGB(120, 255, 120))
						if c.owner.Parent then
							notify(c.owner, "💀 " .. player.DisplayName .. " te robó " .. displayName(def, c.mut) .. ".", Color3.fromRGB(255, 120, 120))
						end
					else
						st.carrying = c
						returnToOwner(st, "La base del ladrón estaba llena.")
					end
				else
					local ownerChar = c.owner.Character
					local ownerHrp = ownerChar and ownerChar:FindFirstChild("HumanoidRootPart")
					if ownerHrp and (ownerHrp.Position - hrp.Position).Magnitude <= Config.CatchDistance then
						returnToOwner(st, "¡El dueño atrapó al ladrón!")
					end
				end
			end
		end
	end
end)

---------------------------------------------------------------------
-- Renacimiento
---------------------------------------------------------------------

remote.OnServerEvent:Connect(function(player, action)
	if action ~= "Rebirth" then
		return
	end
	local st = states[player]
	if not st or not st.loaded then
		return
	end
	local now = os.clock()
	if now - st.lastRebirth < 2 then
		return
	end
	st.lastRebirth = now
	local cost = Config.RebirthCost(st.rebirths.Value)
	if st.coins.Value < cost then
		notify(player, "Necesitas $" .. Config.FormatNumber(cost) .. " para renacer.")
		return
	end
	if st.carrying then
		returnToOwner(st, "Renaciste.")
	end
	for i = 1, Config.SlotsPerPlot do
		local s = st.slots[i]
		if s then
			s.model:Destroy()
			st.slots[i] = nil
		end
	end
	st.rebirths.Value += 1
	st.coins.Value = Config.StartingCoins
	notifyAll("🔁 " .. player.DisplayName .. " renació (nivel " .. st.rebirths.Value .. ")! Ahora gana x" .. multiplier(st), Color3.fromRGB(200, 150, 255))
	task.spawn(save, player, st)
end)

---------------------------------------------------------------------
-- Evento: Lluvia de suerte
---------------------------------------------------------------------

task.spawn(function()
	while true do
		task.wait(Config.EventInterval)
		luckActive = true
		remote:FireAllClients("Event", true, "🍀 ¡LLUVIA DE SUERTE! Más criaturas raras y mutaciones", Config.EventDuration)
		task.wait(Config.EventDuration)
		luckActive = false
		remote:FireAllClients("Event", false)
	end
end)
