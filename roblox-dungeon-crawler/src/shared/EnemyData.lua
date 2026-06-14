-- Enemy type definitions
local EnemyData = {}

EnemyData.Types = {
	BasicCube = {
		name      = "Basic Cube",
		health    = 75,
		expDrop   = 10,
		goldDrop  = 0,
		color     = Color3.fromRGB(200, 50, 50),
		size      = Vector3.new(4, 4, 4),
		partShape = Enum.PartType.Block,
	},
	Spider = {
		name      = "Ashen Spider",
		health    = 40,
		expDrop   = 8,
		goldDrop  = 0,   -- gold handled by DungeonManager (goldPerEnemy on dungeon def)
		color     = Color3.fromRGB(40, 28, 20),
		size      = Vector3.new(5, 2, 5),
		partShape = Enum.PartType.Block,
	},
}

return EnemyData
