-- Zone 1: The Blighted Reaches (GDD 4.5)
-- Dungeons 1-3 + Capstone (id=4)
local DungeonData = {}

DungeonData.Dungeons = {
	[1] = {
		name       = "The Ashen Mine",
		zone       = 1,
		theme      = "Mines",
		minLevel   = 1,
		enemyType  = "BasicCube",
		enemyCount = 6,
		goldMin    = 12,
		goldMax    = 28,
		expReward  = 60,
		isBoss     = false,
	},
	[2] = {
		name       = "Rotwood Crypt",
		zone       = 1,
		theme      = "Crypt",
		minLevel   = 4,
		enemyType  = "BasicCube",
		enemyCount = 10,
		goldMin    = 25,
		goldMax    = 65,
		expReward  = 140,
		isBoss     = false,
	},
	[3] = {
		name       = "Brigand's Hideout",
		zone       = 1,
		theme      = "Forest Hideout",
		minLevel   = 8,
		enemyType  = "BasicCube",
		enemyCount = 14,
		goldMin    = 55,
		goldMax    = 120,
		expReward  = 280,
		isBoss     = false,
	},
	-- Capstone: unlocks Zone 2 (Phase 2)
	[4] = {
		name       = "Blight Keep — Capstone",
		zone       = 1,
		theme      = "Capstone",
		minLevel   = 12,
		enemyType  = "BasicCube",
		enemyCount = 18,
		goldMin    = 90,
		goldMax    = 200,
		expReward  = 500,
		isBoss     = true,
	},
}

return DungeonData
