-- Raidbound WorldBuilder: hub + Zone 1 dungeon room (code-driven, no Studio Parts)
local Workspace   = game:GetService("Workspace")
local DungeonData = require(game:GetService("ReplicatedStorage").DungeonData)

-- ── Utility ───────────────────────────────────────────────────────────────────

local function makePart(name, size, pos, color, material, anchored)
	local p = Instance.new("Part")
	p.Name       = name
	p.Size       = size
	p.Position   = pos
	p.BrickColor = color and BrickColor.new(color) or BrickColor.new("Medium stone grey")
	p.Material   = material or Enum.Material.SmoothPlastic
	p.Anchored   = anchored ~= false
	p.CanCollide = true
	p.Parent     = Workspace
	return p
end

local function makeLabel(parent, text, textColor, size, pos, font)
	local bg = Instance.new("BillboardGui")
	bg.Size        = size or UDim2.new(0, 240, 0, 60)
	bg.StudsOffset = pos  or Vector3.new(0, 8, 0)
	bg.AlwaysOnTop = false
	bg.Parent      = parent

	local lbl = Instance.new("TextLabel")
	lbl.Size               = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text               = text
	lbl.TextColor3         = textColor or Color3.new(1, 1, 1)
	lbl.TextScaled         = true
	lbl.Font               = font or Enum.Font.GothamBold
	lbl.Parent             = bg
	return lbl
end

-- ── Forest helpers ───────────────────────────────────────────────────────────

local function makeTree(x, z, trunkH, canopyR)
	trunkH  = trunkH  or (math.random(10, 18))
	canopyR = canopyR or (math.random(7,  12))

	local trunk = Instance.new("Part")
	trunk.Name      = "TreeTrunk"
	trunk.Size      = Vector3.new(2.5, trunkH, 2.5)
	trunk.Position  = Vector3.new(x, trunkH / 2, z)
	trunk.Anchored  = true
	trunk.Material  = Enum.Material.Wood
	trunk.BrickColor = BrickColor.new("Reddish brown")
	trunk.CanCollide = true
	trunk.Parent    = Workspace

	local canopy = Instance.new("Part")
	canopy.Name      = "TreeCanopy"
	canopy.Shape     = Enum.PartType.Ball
	canopy.Size      = Vector3.new(canopyR * 2, canopyR * 2, canopyR * 2)
	canopy.Position  = Vector3.new(x, trunkH + canopyR * 0.6, z)
	canopy.Anchored  = true
	canopy.Material  = Enum.Material.Grass
	canopy.BrickColor = BrickColor.new(math.random() < 0.3 and "Dark green" or "Bright green")
	canopy.CanCollide = false
	canopy.CastShadow = true
	canopy.Parent    = Workspace
end

-- Place a dense tree line along one edge (axis = "x" or "z", sign = 1 or -1)
local function forestEdge(axis, edgeVal, minA, maxA, spacing)
	spacing = spacing or 14
	local a = minA
	while a <= maxA do
		local jitter = math.random(-4, 4)
		local depth  = math.random(0, 16)  -- how far inward the tree is pushed
		local x, z
		if axis == "z" then
			x = a + jitter
			z = edgeVal + (edgeVal > 0 and -depth or depth)
		else
			x = edgeVal + (edgeVal > 0 and -depth or depth)
			z = a + jitter
		end
		makeTree(x, z)
		a = a + spacing + math.random(-3, 3)
	end
end

-- ── Hub baseplate ─────────────────────────────────────────────────────────────

-- Grass baseplate
local baseplate = makePart("HubBaseplate", Vector3.new(240, 4, 240), Vector3.new(0, -2, 0), "Bright green")
baseplate.Material = Enum.Material.Grass

-- Dirt path from spawn to dungeon doors
makePart("HubPath", Vector3.new(20, 1, 100), Vector3.new(0, 0.5, -5), "Reddish brown").Material = Enum.Material.Ground

-- Grass detail patches (visual variety)
local patches = {
	{ Vector3.new(-90, 0.5, -20), Vector3.new(40, 1, 30) },
	{ Vector3.new(90,  0.5, -20), Vector3.new(40, 1, 30) },
	{ Vector3.new(-90, 0.5,  60), Vector3.new(40, 1, 40) },
	{ Vector3.new(90,  0.5,  60), Vector3.new(40, 1, 40) },
}
for i, p in ipairs(patches) do
	local patch = makePart("GrassPatch_" .. i, p[2], p[1], "Medium green")
	patch.Material = Enum.Material.Grass
end

-- Spawn pad
local spawn = Instance.new("SpawnLocation")
spawn.Name      = "HubSpawn"
spawn.Size      = Vector3.new(10, 1, 10)
spawn.Position  = Vector3.new(0, 1, 40)
spawn.Anchored  = true
spawn.BrickColor = BrickColor.new("Bright yellow")
spawn.Duration  = 0
spawn.Parent    = Workspace

-- ── Dense perimeter forest ────────────────────────────────────────────────────
-- Hub baseplate spans ±120 on X and Z. Trees ring the outside edge.
math.randomseed(42)  -- deterministic layout so it's the same every server start

forestEdge("z",  115, -110, 110, 13)   -- North wall
forestEdge("z", -115, -110, 110, 13)   -- South wall
forestEdge("x",  115,  -90,  90, 13)   -- East wall
forestEdge("x", -115,  -90,  90, 13)   -- West wall

-- Corner clusters (fill the gaps)
for _, c in ipairs({ {110,110},{-110,110},{110,-110},{-110,-110} }) do
	for _ = 1, 6 do
		makeTree(c[1] + math.random(-10, 10), c[2] + math.random(-10, 10))
	end
end

-- ── Town Showcase Board (GDD 9.2 — must be impossible to miss) ───────────────

local showcase = makePart("TownShowcaseBoard", Vector3.new(28, 16, 2),
	Vector3.new(0, 8, 10), "Bright blue")
showcase.Material = Enum.Material.SmoothPlastic

local sfaceGui = Instance.new("SurfaceGui")
sfaceGui.Face  = Enum.NormalId.Front
sfaceGui.Parent = showcase

local function addShowcaseRow(gui, text, color, yPos)
	local lbl = Instance.new("TextLabel")
	lbl.Size           = UDim2.new(1, -10, 0, 24)
	lbl.Position       = UDim2.new(0, 5, 0, yPos)
	lbl.BackgroundTransparency = 1
	lbl.Text           = text
	lbl.TextColor3     = color or Color3.new(1, 1, 1)
	lbl.Font           = Enum.Font.GothamBold
	lbl.TextScaled     = false
	lbl.TextSize       = 16
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent         = gui
end

addShowcaseRow(sfaceGui, "TOWN SHOWCASE BOARD", Color3.fromRGB(255, 200, 40), 10)
addShowcaseRow(sfaceGui, "Recent Mythic Drops", Color3.fromRGB(255, 140, 20), 40)
addShowcaseRow(sfaceGui, "— (Waiting for first drop...)", Color3.fromRGB(180, 180, 180), 62)
addShowcaseRow(sfaceGui, "Fastest Clear This Week", Color3.fromRGB(60, 200, 255), 96)
addShowcaseRow(sfaceGui, "— (No clears yet)", Color3.fromRGB(180, 180, 180), 118)
addShowcaseRow(sfaceGui, "Top Gold Earner Today", Color3.fromRGB(255, 200, 40), 152)
addShowcaseRow(sfaceGui, "— (No data yet)", Color3.fromRGB(180, 180, 180), 174)

-- ── Hub NPCs / buildings (visual stubs — GDD 9.1) ────────────────────────────

-- Blacksmith
local smith = makePart("Blacksmith", Vector3.new(14, 16, 12), Vector3.new(-60, 8, 10), "Dark grey")
makeLabel(smith, "BLACKSMITH\nGear Upgrades", Color3.fromRGB(255, 160, 40),
	UDim2.new(0, 200, 0, 60), Vector3.new(0, 12, 0))

-- Trade Bench
local trade = makePart("TradeBench", Vector3.new(10, 6, 8), Vector3.new(-60, 3, 30), "Reddish brown")
makeLabel(trade, "TRADE BENCH", Color3.fromRGB(255, 200, 80),
	UDim2.new(0, 180, 0, 40), Vector3.new(0, 7, 0))

-- Quest Board
local quest = makePart("QuestBoard", Vector3.new(10, 14, 2), Vector3.new(60, 7, 10), "Bright orange")
makeLabel(quest, "QUEST BOARD\nDaily Bounties", Color3.fromRGB(255, 200, 80),
	UDim2.new(0, 200, 0, 60), Vector3.new(0, 10, 0))

-- Storage Vault
local vault = makePart("StorageVault", Vector3.new(10, 12, 10), Vector3.new(60, 6, 30), "Dark stone grey")
makeLabel(vault, "STORAGE VAULT", Color3.fromRGB(200, 200, 200),
	UDim2.new(0, 180, 0, 40), Vector3.new(0, 10, 0))

-- ── Dungeon doors (4 total: 3 Zone 1 + Capstone) ─────────────────────────────

local doorData = {
	{ x = -60, dungeon = 1, open = true  },
	{ x = -20, dungeon = 2, open = false },
	{ x =  20, dungeon = 3, open = false },
	{ x =  60, dungeon = 4, open = false },  -- Capstone
}

for _, dd in ipairs(doorData) do
	local dungeon = DungeonData.Dungeons[dd.dungeon]
	local doorColor = dd.open and "Bright green" or "Dark grey"

	local door = makePart("DungeonDoor_" .. dd.dungeon,
		Vector3.new(10, 14, 2),
		Vector3.new(dd.x, 7, -50),
		doorColor)

	-- Name label
	local bg = Instance.new("BillboardGui")
	bg.Size        = UDim2.new(0, 240, 0, 72)
	bg.StudsOffset = Vector3.new(0, 11, 0)
	bg.AlwaysOnTop = false
	bg.Parent      = door

	local nameLbl = Instance.new("TextLabel")
	nameLbl.Size              = UDim2.new(1, 0, 0.56, 0)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Text              = dungeon and dungeon.name or ("Dungeon " .. dd.dungeon)
	nameLbl.TextColor3        = Color3.new(1, 1, 1)
	nameLbl.TextScaled        = true
	nameLbl.Font              = Enum.Font.GothamBold
	nameLbl.Parent            = bg

	local subLbl = Instance.new("TextLabel")
	subLbl.Size              = UDim2.new(1, 0, 0.38, 0)
	subLbl.Position          = UDim2.new(0, 0, 0.58, 0)
	subLbl.BackgroundTransparency = 1
	subLbl.Text              = dd.open
		and "ENTER (Lv " .. (dungeon and dungeon.minLevel or 1) .. "+)"
		or  "LOCKED — Req. Level " .. (dungeon and dungeon.minLevel or "?")
	subLbl.TextColor3        = dd.open
		and Color3.fromRGB(140, 255, 140)
		or  Color3.fromRGB(160, 160, 160)
	subLbl.TextScaled        = true
	subLbl.Font              = Enum.Font.Gotham
	subLbl.Parent            = bg

	-- ProximityPrompt on open doors only (locked doors use DungeonManager level check)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText            = "Enter Dungeon"
	prompt.ObjectText            = dungeon and dungeon.name or ("Dungeon " .. dd.dungeon)
	prompt.HoldDuration          = 0
	prompt.MaxActivationDistance = 14
	prompt.Parent                = door
	-- DungeonManager enforces the level gate server-side; all 4 have prompts
end

-- ── Zone 1 dungeon room (shared for Phase 1 — at Z = 1000) ───────────────────

local D1_CENTER = Vector3.new(0, 0, 1000)

-- Floor
local d1Floor = Instance.new("Part")
d1Floor.Name     = "Dungeon1Floor"
d1Floor.Size     = Vector3.new(120, 4, 120)
d1Floor.Position = D1_CENTER + Vector3.new(0, -2, 0)
d1Floor.Anchored = true
d1Floor.Material = Enum.Material.SmoothPlastic
d1Floor.BrickColor = BrickColor.new("Dark grey")
d1Floor.Parent   = Workspace

-- Walls
local walls = {
	{ Vector3.new(0, 14, -62),  Vector3.new(124, 32, 4) },   -- N
	{ Vector3.new(0, 14, 62),   Vector3.new(124, 32, 4) },   -- S
	{ Vector3.new(-62, 14, 0),  Vector3.new(4, 32, 120) },   -- W
	{ Vector3.new(62, 14, 0),   Vector3.new(4, 32, 120) },   -- E
}
for _, w in ipairs(walls) do
	local wall = Instance.new("Part")
	wall.Size      = w[2]
	wall.Position  = D1_CENTER + w[1]
	wall.Anchored  = true
	wall.Material  = Enum.Material.SmoothPlastic
	wall.BrickColor = BrickColor.new("Dark stone grey")
	wall.Parent    = Workspace
end

-- Entry sign (south wall)
local entranceSign = makePart("EntranceSign", Vector3.new(30, 6, 1),
	D1_CENTER + Vector3.new(0, 18, 61), "Bright green")
local signGui = Instance.new("SurfaceGui")
signGui.Face  = Enum.NormalId.Front
signGui.Parent = entranceSign
local signLbl = Instance.new("TextLabel")
signLbl.Size   = UDim2.new(1, 0, 1, 0)
signLbl.BackgroundTransparency = 1
signLbl.Text   = "ZONE 1 — THE BLIGHTED REACHES"
signLbl.TextColor3 = Color3.new(1, 1, 1)
signLbl.TextScaled = true
signLbl.Font   = Enum.Font.GothamBold
signLbl.Parent = signGui

print("[WorldBuilder] Hub and dungeon room built")
