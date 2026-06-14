-- Enemy type definitions
local EnemyData = {}

EnemyData.Types = {
	BasicCube = {
		name     = "Basic Cube",
		health   = 75,
		expDrop  = 10,
		goldDrop = 0,   -- gold rolls handled by DungeonManager from dungeon gold range
		color    = Color3.fromRGB(200, 50, 50),
		size     = Vector3.new(4, 4, 4),
	},
}

return EnemyData
