-- Dungeon definitions (mirrors Config.DUNGEONS but with richer data)
local DungeonData = {}

DungeonData.Dungeons = {
	[1] = { name = "Dungeon 1 — Beginner", minLevel = 1,  enemyType = "BasicCube", enemyCount = 5,  expReward = 50  },
	[2] = { name = "Dungeon 2 — Easy",     minLevel = 3,  enemyType = "BasicCube", enemyCount = 10, expReward = 120 },
	[3] = { name = "Dungeon 3 — Medium",   minLevel = 6,  enemyType = "BasicCube", enemyCount = 15, expReward = 250 },
}

return DungeonData
