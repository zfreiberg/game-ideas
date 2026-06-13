-- Global game constants
local Config = {}

Config.HUB_SPAWN = Vector3.new(0, 5, 0)

Config.DUNGEONS = {
	{ id = 1, name = "Dungeon 1 — Beginner", minLevel = 1,  enemyCount = 5,  expReward = 50  },
	{ id = 2, name = "Dungeon 2 — Easy",     minLevel = 3,  enemyCount = 10, expReward = 120 },
	{ id = 3, name = "Dungeon 3 — Medium",   minLevel = 6,  enemyCount = 15, expReward = 250 },
}

return Config
