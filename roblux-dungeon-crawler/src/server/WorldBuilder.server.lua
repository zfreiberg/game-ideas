-- Procedurally builds the hub world and dungeon rooms so everything is code-driven (no Studio Parts needed)
local Workspace = game:GetService("Workspace")
local DungeonData = require(game:GetService("ReplicatedStorage").DungeonData)

-- Hub baseplate
local hubPlate = Instance.new("Part")
hubPlate.Name = "HubBaseplate"
hubPlate.Size = Vector3.new(200, 4, 200)
hubPlate.Position = Vector3.new(0, -2, 0)
hubPlate.Anchored = true
hubPlate.Material = Enum.Material.SmoothPlastic
hubPlate.BrickColor = BrickColor.new("Medium stone grey")
hubPlate.Parent = Workspace

-- Spawn location (yellow pad near center)
local spawnLoc = Instance.new("SpawnLocation")
spawnLoc.Name = "HubSpawn"
spawnLoc.Size = Vector3.new(8, 1, 8)
spawnLoc.Position = Vector3.new(0, 1, 40)
spawnLoc.Anchored = true
spawnLoc.BrickColor = BrickColor.new("Bright yellow")
spawnLoc.Duration = 0
spawnLoc.Parent = Workspace

-- Dungeon doors
local doorColors = {
	BrickColor.new("Bright green"),   -- Dungeon 1 (unlocked)
	BrickColor.new("Dark grey"),      -- Dungeon 2 (locked)
	BrickColor.new("Dark grey"),      -- Dungeon 3 (locked)
}
local doorXPositions = { -40, 0, 40 }

for i = 1, 3 do
	local dungeon = DungeonData.Dungeons[i]
	local isOpen = (i == 1)

	local door = Instance.new("Part")
	door.Name = "DungeonDoor_" .. i
	door.Size = Vector3.new(10, 12, 2)
	door.Position = Vector3.new(doorXPositions[i], 6, -20)
	door.Anchored = true
	door.Material = Enum.Material.SmoothPlastic
	door.BrickColor = doorColors[i]
	door.Parent = Workspace

	-- Name label above door
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 220, 0, 60)
	billboard.StudsOffset = Vector3.new(0, 8, 0)
	billboard.AlwaysOnTop = false
	billboard.Parent = door

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = dungeon and dungeon.name or ("Dungeon " .. i)
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Parent = billboard

	local subLabel = Instance.new("TextLabel")
	subLabel.Size = UDim2.new(1, 0, 0.4, 0)
	subLabel.Position = UDim2.new(0, 0, 0.6, 0)
	subLabel.BackgroundTransparency = 1
	subLabel.Text = isOpen and "Click to Enter" or ("Req. Level " .. (dungeon and dungeon.minLevel or "?"))
	subLabel.TextColor3 = isOpen and Color3.fromRGB(180, 255, 180) or Color3.fromRGB(180, 180, 180)
	subLabel.TextScaled = true
	subLabel.Font = Enum.Font.Gotham
	subLabel.Parent = billboard

	-- ProximityPrompt (only on door 1 for now)
	if isOpen then
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Enter Dungeon"
		prompt.ObjectText = dungeon and dungeon.name or ("Dungeon " .. i)
		prompt.HoldDuration = 0
		prompt.MaxActivationDistance = 12
		prompt.Parent = door
	end
end

-- Dungeon 1 room (1000 studs away so it's isolated from hub)
local d1Center = Vector3.new(0, 0, 1000)

local d1Floor = Instance.new("Part")
d1Floor.Name = "Dungeon1Floor"
d1Floor.Size = Vector3.new(100, 4, 100)
d1Floor.Position = d1Center + Vector3.new(0, -2, 0)
d1Floor.Anchored = true
d1Floor.Material = Enum.Material.SmoothPlastic
d1Floor.BrickColor = BrickColor.new("Dark grey")
d1Floor.Parent = Workspace

-- Walls (N/S/E/W)
local wallDefs = {
	{ pos = Vector3.new(0, 10, -52),  size = Vector3.new(104, 28, 4) },
	{ pos = Vector3.new(0, 10, 52),   size = Vector3.new(104, 28, 4) },
	{ pos = Vector3.new(-52, 10, 0),  size = Vector3.new(4, 28, 100) },
	{ pos = Vector3.new(52, 10, 0),   size = Vector3.new(4, 28, 100) },
}
for _, w in ipairs(wallDefs) do
	local wall = Instance.new("Part")
	wall.Size = w.size
	wall.Position = d1Center + w.pos
	wall.Anchored = true
	wall.Material = Enum.Material.SmoothPlastic
	wall.BrickColor = BrickColor.new("Dark stone grey")
	wall.Parent = Workspace
end

-- Dungeon 1 label on ceiling/sign area
local d1Sign = Instance.new("Part")
d1Sign.Name = "Dungeon1Sign"
d1Sign.Size = Vector3.new(30, 6, 1)
d1Sign.Position = d1Center + Vector3.new(0, 20, -51)
d1Sign.Anchored = true
d1Sign.BrickColor = BrickColor.new("Bright green")
d1Sign.Parent = Workspace

local signGui = Instance.new("SurfaceGui")
signGui.Face = Enum.NormalId.Front
signGui.Parent = d1Sign

local signLabel = Instance.new("TextLabel")
signLabel.Size = UDim2.new(1, 0, 1, 0)
signLabel.BackgroundTransparency = 1
signLabel.Text = "DUNGEON 1 — BEGINNER"
signLabel.TextColor3 = Color3.new(1, 1, 1)
signLabel.TextScaled = true
signLabel.Font = Enum.Font.GothamBold
signLabel.Parent = signGui

print("[WorldBuilder] Hub and Dungeon 1 room built")
