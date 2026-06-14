-- Raidbound: global constants (GDD v1.0)
local Config = {}

Config.HUB_SPAWN_CF = CFrame.new(0, 5, 40)

-- Zone 1 level cap — players should reach Zone 2 within 3-4 sessions
Config.ZONE_1_LEVEL_CAP = 15

-- Combat damage by class (GDD 5.2)
Config.DAMAGE = {
	Warrior = 35,
	Mage    = 55,
	Default = 25,
}

-- Dungeon mutation rates (GDD 4.4) — non-Normal target 35%+
Config.MUTATION_RATES = {
	Normal    = 65,
	Golden    = 15,
	Corrupted = 12,
	Treasure  = 8,
}

-- Gold multiplier per mutation (GDD 4.4)
Config.GOLD_MULTIPLIERS = {
	Normal    = 1.0,
	Golden    = 1.5,  -- +50% gold
	Corrupted = 0.9,
	Treasure  = 1.2,
}

-- Loot tier bonus per mutation — shifts rarity up N steps (GDD 4.4)
Config.LOOT_TIER_BONUS = {
	Normal    = 0,
	Golden    = 0,
	Corrupted = 1,  -- loot quality +1 tier
	Treasure  = 0,
}

-- Enemy HP multiplier per mutation
Config.ENEMY_HP_MULT = {
	Normal    = 1.0,
	Golden    = 1.2,  -- enemy shields (harder to kill)
	Corrupted = 1.5,  -- enemies stronger
	Treasure  = 0.6,  -- weaker enemies, no boss
}

-- Extraction countdown seconds (GDD 7.1)
Config.EXTRACTION_COUNTDOWN = 10

return Config
