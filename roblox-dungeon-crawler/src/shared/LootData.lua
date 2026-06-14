-- Raidbound loot system definitions (GDD 6.1, 6.2)
local LootData = {}

-- 4 rarities at MVP launch (GDD 2.2 — simplified from 6)
LootData.Rarities = {
	{ name = "Common", color = Color3.fromRGB(180, 180, 180), weight = 50 },
	{ name = "Rare",   color = Color3.fromRGB(60,  120, 255), weight = 30 },
	{ name = "Epic",   color = Color3.fromRGB(160,  40, 255), weight = 15 },
	{ name = "Mythic", color = Color3.fromRGB(255, 140,  20), weight = 5  },
}

-- Item mutations — primary trading economy driver (GDD 6.2)
-- chance = relative weight among mutations (after the no-mutation roll)
LootData.Mutations = {
	{ name = "Flaming",  statKey = "fireDmg",   statVal = 8,  chance = 20 },
	{ name = "Frozen",   statKey = "critChance", statVal = 8,  chance = 20 },
	{ name = "Corrupted",statKey = "dmg",        statVal = 12, chance = 12 },
	{ name = "Golden",   statKey = "goldFind",   statVal = 15, chance = 18 },
	{ name = "Ancient",  statKey = "allStats",   statVal = 5,  chance = 15 },
	{ name = "Spectral", statKey = "atkSpeed",   statVal = 10, chance = 15 },
}

-- 55% chance of no mutation on a dropped item
LootData.NO_MUTATION_CHANCE = 55

-- Item types per zone theme
LootData.ItemTypes = {
	Zone1 = {
		"Iron Sword", "Hide Armor", "Bone Dagger",
		"Leather Hood", "Mining Pick", "Crypt Staff",
		"Rusted Axe", "Stone Shield",
	},
	-- Dungeon 1 drops crude weapons to funnel players to the Blacksmith for upgrades
	Dungeon1 = {
		"Crude Iron Axe", "Crude Iron Sword",
	},
}

-- Per-enemy drop chance (%) — bosses always drop
LootData.BASE_DROP_CHANCE = 25

return LootData
