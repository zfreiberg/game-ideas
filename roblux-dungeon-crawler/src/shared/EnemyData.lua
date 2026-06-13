-- Enemy type definitions
local EnemyData = {}

EnemyData.Types = {
	BasicCube = {
		name       = "Basic Cube",
		health     = 50,
		speed      = 10,
		expDrop    = 10,
		color      = Color3.fromRGB(255, 0, 0), -- red placeholder
		size       = Vector3.new(3, 3, 3),
	},
}

return EnemyData
