-- Config (ModuleScript dentro de ReplicatedStorage)
-- Aquí cambias precios, criaturas, rarezas y reglas sin tocar el resto del código.

local Config = {}

-- Reglas generales
Config.StartingCoins = 100
Config.SlotsPerPlot = 10
Config.SpawnInterval = 2.5        -- segundos entre criaturas en la cinta
Config.ConveyorTravelTime = 28    -- segundos que tarda una criatura en cruzar la cinta
Config.StealHoldTime = 1.5        -- segundos manteniendo E para robar
Config.LockDuration = 30          -- segundos que dura el escudo de la base
Config.LockCooldown = 60          -- segundos de espera para volver a usar el escudo
Config.SellRefund = 0.5           -- al vender recuperas el 50%
Config.CarrySpeed = 12            -- velocidad mientras cargas una criatura robada
Config.NormalSpeed = 16
Config.CatchDistance = 7          -- si el dueño se acerca a esta distancia, recupera su criatura
Config.EventInterval = 300        -- cada 5 minutos hay evento
Config.EventDuration = 60
Config.EventLuckMultiplier = 4
Config.RebirthBaseCost = 5000
Config.RebirthCostGrowth = 3
Config.RebirthBonus = 0.5         -- +50% de ingresos por cada renacimiento
Config.AutosaveInterval = 120
Config.DataStoreName = "CriaturasCaoticas_v1"

-- Rarezas (de más común a más rara)
Config.Rarities = {
	{ name = "Común",      weight = 55,   color = Color3.fromRGB(200, 200, 200), size = 3 },
	{ name = "Poco común", weight = 26,   color = Color3.fromRGB(90, 220, 110),  size = 3.4 },
	{ name = "Raro",       weight = 12,   color = Color3.fromRGB(70, 150, 255),  size = 3.8 },
	{ name = "Épico",      weight = 5,    color = Color3.fromRGB(180, 90, 255),  size = 4.3 },
	{ name = "Legendario", weight = 1.6,  color = Color3.fromRGB(255, 170, 30),  size = 5 },
	{ name = "Mítico",     weight = 0.35, color = Color3.fromRGB(255, 70, 110),  size = 5.8 },
	{ name = "Secreto",    weight = 0.05, color = Color3.fromRGB(20, 20, 20),    size = 6.8 },
}

-- Criaturas originales. price = coste, income = monedas por segundo
Config.Creatures = {
	{ id = "papa",      name = "Papa Sentada",        rarity = "Común",      price = 25,      income = 1,     color = Color3.fromRGB(181, 140, 85),  shape = "Ball" },
	{ id = "tostadora", name = "Tostadora Feliz",     rarity = "Común",      price = 60,      income = 2,     color = Color3.fromRGB(170, 170, 180), shape = "Block" },
	{ id = "calcetin",  name = "Calcetín Perdido",    rarity = "Común",      price = 120,     income = 4,     color = Color3.fromRGB(230, 90, 90),   shape = "Block" },
	{ id = "pinguino",  name = "Pingüino Taxista",    rarity = "Poco común", price = 300,     income = 9,     color = Color3.fromRGB(40, 40, 60),    shape = "Ball" },
	{ id = "sandia",    name = "Sandía Bailarina",    rarity = "Poco común", price = 550,     income = 15,    color = Color3.fromRGB(60, 170, 70),   shape = "Ball" },
	{ id = "gato",      name = "Gato Burócrata",      rarity = "Poco común", price = 900,     income = 24,    color = Color3.fromRGB(240, 160, 60),  shape = "Block" },
	{ id = "tiburon",   name = "Tiburón con Bigote",  rarity = "Raro",       price = 2000,    income = 50,    color = Color3.fromRGB(110, 140, 170), shape = "Ball" },
	{ id = "aguacate",  name = "Aguacate Ninja",      rarity = "Raro",       price = 3500,    income = 80,    color = Color3.fromRGB(100, 140, 40),  shape = "Ball" },
	{ id = "llama",     name = "Llama Gamer",         rarity = "Raro",       price = 6000,    income = 130,   color = Color3.fromRGB(245, 235, 210), shape = "Block" },
	{ id = "pollo",     name = "Pollo Astronauta",    rarity = "Épico",      price = 15000,   income = 300,   color = Color3.fromRGB(255, 255, 255), shape = "Ball" },
	{ id = "taco",      name = "Taco Volador",        rarity = "Épico",      price = 28000,   income = 520,   color = Color3.fromRGB(240, 200, 80),  shape = "Block" },
	{ id = "dragon",    name = "Dragón de Gelatina",  rarity = "Legendario", price = 80000,   income = 1400,  color = Color3.fromRGB(255, 80, 160),  shape = "Ball" },
	{ id = "pepinillo", name = "Rey Pepinillo",       rarity = "Legendario", price = 150000,  income = 2500,  color = Color3.fromRGB(80, 160, 50),   shape = "Block" },
	{ id = "capibara",  name = "Cosmo Capibara",      rarity = "Mítico",     price = 600000,  income = 9000,  color = Color3.fromRGB(150, 100, 60),  shape = "Ball" },
	{ id = "bigoton",   name = "El Bigotón Supremo",  rarity = "Secreto",    price = 3000000, income = 40000, color = Color3.fromRGB(30, 30, 30),    shape = "Ball" },
}

-- Mutaciones (de la más rara a la más común). No suben el precio de compra: son pura suerte.
Config.Mutations = {
	{ name = "Arcoíris", chance = 0.005, mult = 5, color = Color3.fromRGB(255, 0, 255),   material = Enum.Material.Neon,  rainbow = true },
	{ name = "Diamante", chance = 0.02,  mult = 3, color = Color3.fromRGB(120, 230, 255), material = Enum.Material.Glass },
	{ name = "Dorado",   chance = 0.06,  mult = 2, color = Color3.fromRGB(255, 200, 40),  material = Enum.Material.Metal },
}

local creatureById = {}
for _, c in ipairs(Config.Creatures) do
	creatureById[c.id] = c
end

local rarityIndex = {}
for i, r in ipairs(Config.Rarities) do
	rarityIndex[r.name] = i
end

function Config.GetCreature(id)
	return creatureById[id]
end

function Config.GetRarity(name)
	return Config.Rarities[rarityIndex[name]]
end

function Config.GetRarityIndex(name)
	return rarityIndex[name] or 1
end

function Config.GetMutation(name)
	if not name then
		return nil
	end
	for _, m in ipairs(Config.Mutations) do
		if m.name == name then
			return m
		end
	end
	return nil
end

function Config.RebirthCost(rebirths)
	return math.floor(Config.RebirthBaseCost * Config.RebirthCostGrowth ^ rebirths)
end

local suffixes = { "", "K", "M", "B", "T", "Qa", "Qi" }
function Config.FormatNumber(n)
	n = math.floor(n or 0)
	local i = 1
	local value = n
	while math.abs(value) >= 1000 and i < #suffixes do
		value = value / 1000
		i += 1
	end
	if i == 1 then
		return tostring(n)
	end
	return string.format("%.1f%s", value, suffixes[i])
end

return Config
