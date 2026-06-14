-- Raidbound dungeon lifecycle: entry → mutation banner → combat → extraction → result
-- Core tension: "Do I extract now, or push deeper?" (GDD §3, §7)
local Players             = game:GetService("Players")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local Workspace           = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataModule = require(ServerScriptService.PlayerDataModule)
local LootManager      = require(ServerScriptService.LootManager)
local DungeonData      = require(ReplicatedStorage.DungeonData)
local EnemyData        = require(ReplicatedStorage.EnemyData)
local Config           = require(ReplicatedStorage.Config)

local remotes               = ReplicatedStorage:WaitForChild("RemoteEvents")
local evDungeonEntered      = remotes:WaitForChild("DungeonEntered")
local evGoldGained          = remotes:WaitForChild("GoldGained")
local evLootDropped         = remotes:WaitForChild("LootDropped")
local evExtractionAvailable = remotes:WaitForChild("ExtractionAvailable")
local evExtractionCountdown = remotes:WaitForChild("ExtractionCountdown")
local evExtractionResult    = remotes:WaitForChild("ExtractionResult")
local evEXPGained           = remotes:WaitForChild("EXPGained")
local evReturnToHub         = remotes:WaitForChild("ReturnToHub")

-- All dungeons share the same room (Phase 1: single room at Z=1000)
-- Phase 2: each dungeon gets its own themed room position
local DUNGEON_ENTRY_CF = CFrame.new(0, 5, 975)
local HUB_SPAWN_CF     = CFrame.new(0, 5, 40)

-- [userId] = { dungeonId, mutation, pendingGold, pendingLoot[], enemiesRemaining, phase, portal }
-- phase: "fighting" | "extracting" | "countdown" | "done"
local activeRuns = {}

-- ── Mutation rolling (GDD 4.4) ────────────────────────────────────────────────

local function rollMutation()
	local r = math.random(1, 100)
	if     r <= 65 then return "Normal"
	elseif r <= 80 then return "Golden"
	elseif r <= 92 then return "Corrupted"
	else                return "Treasure"
	end
end

-- ── Extraction portal ─────────────────────────────────────────────────────────

local function startExtractionCountdown(player)
	local run = activeRuns[player.UserId]
	if not run or run.phase ~= "countdown" then return end

	local totalSeconds = Config.EXTRACTION_COUNTDOWN

	task.spawn(function()
		for t = totalSeconds, 1, -1 do
			local r = activeRuns[player.UserId]
			if not r or r.phase ~= "countdown" then return end
			evExtractionCountdown:FireClient(player, t)
			task.wait(1)
		end
		-- Commit after countdown
		local r = activeRuns[player.UserId]
		if r and r.phase == "countdown" then
			commitExtraction(player, true)
		end
	end)
end

local function spawnExtractionPortal(player)
	-- North wall of the dungeon room (Z=1000, portal at Z=948)
	local pos = Vector3.new(0, 7, 948)

	local portal = Instance.new("Part")
	portal.Name      = "ExtractionPortal_" .. player.UserId
	portal.Size      = Vector3.new(10, 14, 2)
	portal.Position  = pos
	portal.Anchored  = true
	portal.CanCollide = false
	portal.Material  = Enum.Material.Neon
	portal.Color     = Color3.fromRGB(60, 255, 160)
	portal.Transparency = 0.35
	portal.Parent    = Workspace

	-- Billboard label
	local bg = Instance.new("BillboardGui")
	bg.Size         = UDim2.new(0, 260, 0, 56)
	bg.StudsOffset  = Vector3.new(0, 10, 0)
	bg.AlwaysOnTop  = true
	bg.Parent       = portal

	local lbl = Instance.new("TextLabel")
	lbl.Size               = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text               = "EXTRACTION PORTAL"
	lbl.TextColor3         = Color3.fromRGB(60, 255, 160)
	lbl.TextScaled         = true
	lbl.Font               = Enum.Font.GothamBold
	lbl.Parent             = bg

	-- ProximityPrompt triggers 10-second countdown (GDD 7.1)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText            = "Extract"
	prompt.ObjectText            = "Extraction Portal"
	prompt.HoldDuration          = 0
	prompt.MaxActivationDistance = 18
	prompt.Parent = portal

	prompt.Triggered:Connect(function(triggerPlayer)
		if triggerPlayer ~= player then return end
		local run = activeRuns[player.UserId]
		if not run or run.phase ~= "extracting" then return end
		run.phase = "countdown"
		prompt:Destroy()  -- prevent double-trigger
		startExtractionCountdown(player)
	end)

	return portal
end

-- ── Commit extraction (GDD 7.2) ───────────────────────────────────────────────

function commitExtraction(player, success)
	local run = activeRuns[player.UserId]
	if not run then return end
	run.phase = "done"

	if run.portal then run.portal:Destroy() end

	if success then
		-- Grant gold, loot, EXP — all server-side
		PlayerDataModule.grantGold(player, run.pendingGold)
		for _, item in ipairs(run.pendingLoot) do
			PlayerDataModule.addItem(player, item)
		end

		local dungeon = DungeonData.Dungeons[run.dungeonId]
		local expData = dungeon and PlayerDataModule.grantEXP(player, dungeon.expReward)
		if expData then
			evEXPGained:FireClient(player, dungeon.expReward, expData.level)
		end

		evExtractionResult:FireClient(player, {
			success  = true,
			goldKept = run.pendingGold,
			lootKept = run.pendingLoot,
			goldLost = 0,
		})
	else
		-- Dungeons: only unbanked gold lost, gear always kept (GDD 7.2)
		evExtractionResult:FireClient(player, {
			success  = false,
			goldKept = 0,
			goldLost = run.pendingGold,
			lootKept = {},
		})
	end

	activeRuns[player.UserId] = nil
end

-- ── Enemy spawning ────────────────────────────────────────────────────────────

local function spawnEnemies(player, dungeonId, mutation)
	local dungeon  = DungeonData.Dungeons[dungeonId]
	local typeData = EnemyData.Types[dungeon.enemyType] or EnemyData.Types.BasicCube

	local count   = dungeon.enemyCount
	local hpMult  = Config.ENEMY_HP_MULT[mutation]  or 1.0
	local goldMult = Config.GOLD_MULTIPLIERS[mutation] or 1.0

	-- Treasure: fewer enemies, no boss (GDD 4.4)
	if mutation == "Treasure" then
		count = math.max(2, math.floor(count * 0.4))
	end

	-- Corrupted: enemies purple (GDD 4.4)
	local enemyColor = (mutation == "Corrupted")
		and Color3.fromRGB(120, 30, 160)
		or typeData.color

	local run = activeRuns[player.UserId]
	if not run then return end
	run.enemiesRemaining = count

	-- Player damage from class
	local pd     = PlayerDataModule.get(player)
	local damage = Config.DAMAGE[pd and pd.class or "Default"] or Config.DAMAGE.Default

	local center = Vector3.new(0, typeData.size.Y / 2 + 2, 1000)
	local goldPerEnemy = math.floor((dungeon.goldMin + dungeon.goldMax) / 2 * goldMult / count)

	for i = 1, count do
		local maxHP = math.floor(typeData.health * hpMult)

		local cube = Instance.new("Part")
		cube.Name        = "Enemy_" .. player.UserId .. "_" .. i
		cube.Size        = typeData.size
		cube.Color       = enemyColor
		cube.Material    = Enum.Material.SmoothPlastic
		cube.Anchored    = true
		cube.CanCollide  = true

		local angle = ((i - 1) / count) * math.pi * 2
		cube.Position = center + Vector3.new(math.cos(angle) * 22, 0, math.sin(angle) * 22)
		cube:SetAttribute("Health", maxHP)
		cube:SetAttribute("MaxHP",  maxHP)
		cube.Parent = Workspace

		-- HP bar billboard
		local bg = Instance.new("BillboardGui")
		bg.Size        = UDim2.new(0, 140, 0, 28)
		bg.StudsOffset = Vector3.new(0, typeData.size.Y / 2 + 1.5, 0)
		bg.AlwaysOnTop = false
		bg.Parent      = cube

		local hpLbl = Instance.new("TextLabel")
		hpLbl.Name                 = "HPLabel"
		hpLbl.Size                 = UDim2.new(1, 0, 1, 0)
		hpLbl.BackgroundColor3     = Color3.fromRGB(150, 0, 0)
		hpLbl.BackgroundTransparency = 0.15
		hpLbl.Text                 = maxHP .. " HP"
		hpLbl.TextColor3           = Color3.new(1, 1, 1)
		hpLbl.TextScaled           = true
		hpLbl.Font                 = Enum.Font.GothamBold
		hpLbl.BorderSizePixel      = 0
		hpLbl.Parent               = bg

		local cd = Instance.new("ClickDetector")
		cd.MaxActivationDistance = 45
		cd.Parent = cube

		local isBossEnemy = (dungeon.isBoss and i == count)

		cd.MouseClick:Connect(function(clicker)
			if clicker ~= player then return end
			local hp = cube:GetAttribute("Health")
			if not hp or hp <= 0 then return end

			hp = math.max(0, hp - damage)
			cube:SetAttribute("Health", hp)
			hpLbl.Text = hp .. " HP"

			if hp <= 0 then
				cube:Destroy()

				local r = activeRuns[player.UserId]
				if not r or r.phase ~= "fighting" then return end

				-- Gold drop — spread dungeon gold budget across enemies
				local goldDrop = math.random(
					math.max(1, math.floor(goldPerEnemy * 0.7)),
					math.ceil(goldPerEnemy * 1.3)
				)
				r.pendingGold += goldDrop
				evGoldGained:FireClient(player, goldDrop, r.pendingGold)

				-- Loot drop (server-side roll only)
				local item = LootManager.rollForEnemy(dungeonId, mutation, isBossEnemy)
				if item then
					table.insert(r.pendingLoot, item)
					evLootDropped:FireClient(player, item)
				end

				-- Room clear check
				r.enemiesRemaining -= 1
				if r.enemiesRemaining <= 0 then
					r.phase = "extracting"
					task.wait(0.6)
					local portal = spawnExtractionPortal(player)
					r.portal = portal
					evExtractionAvailable:FireClient(player)
					print(("[DungeonManager] %s cleared %s → extraction portal spawned"):format(player.Name, dungeon.name))
				end
			end
		end)
	end

	print(("[DungeonManager] %s entered %s (%s) — %d enemies"):format(player.Name, dungeon.name, mutation, count))
end

-- ── Dungeon entry ─────────────────────────────────────────────────────────────

local function enterDungeon(player, dungeonId)
	if activeRuns[player.UserId] then return end

	local dungeon = DungeonData.Dungeons[dungeonId]
	if not dungeon then return end

	-- Level gate
	local pd = PlayerDataModule.get(player)
	if pd and pd.level < dungeon.minLevel then
		warn(("[DungeonManager] %s needs Level %d for %s"):format(player.Name, dungeon.minLevel, dungeon.name))
		return
	end

	local char = player.Character
	local hrp  = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local mutation = rollMutation()

	activeRuns[player.UserId] = {
		dungeonId        = dungeonId,
		mutation         = mutation,
		pendingGold      = 0,
		pendingLoot      = {},
		enemiesRemaining = 0,
		phase            = "fighting",
		portal           = nil,
	}

	hrp.CFrame = DUNGEON_ENTRY_CF
	evDungeonEntered:FireClient(player, dungeon.name, mutation)

	task.wait(0.5)
	spawnEnemies(player, dungeonId, mutation)
end

-- ── Hub return ────────────────────────────────────────────────────────────────

evReturnToHub.OnServerEvent:Connect(function(player)
	local run = activeRuns[player.UserId]

	-- Player bailed mid-run — treat as failed extraction (gold lost, GDD 7.2)
	if run and (run.phase == "fighting" or run.phase == "extracting") then
		evExtractionResult:FireClient(player, {
			success  = false,
			goldKept = 0,
			goldLost = run.pendingGold,
			lootKept = {},
		})
	end

	-- Clean up world objects
	for _, obj in ipairs(Workspace:GetChildren()) do
		if obj.Name:find("Enemy_" .. player.UserId, 1, true)
		or obj.Name == "ExtractionPortal_" .. player.UserId then
			obj:Destroy()
		end
	end

	if run and run.portal then run.portal:Destroy() end
	activeRuns[player.UserId] = nil

	local char = player.Character
	local hrp  = char and char:FindFirstChild("HumanoidRootPart")
	if hrp then hrp.CFrame = HUB_SPAWN_CF end
end)

-- ── Cleanup on disconnect ─────────────────────────────────────────────────────

Players.PlayerRemoving:Connect(function(player)
	activeRuns[player.UserId] = nil
	for _, obj in ipairs(Workspace:GetChildren()) do
		if obj.Name:find("Enemy_" .. player.UserId, 1, true)
		or obj.Name == "ExtractionPortal_" .. player.UserId then
			obj:Destroy()
		end
	end
end)

-- ── Connect dungeon doors (waits for WorldBuilder) ────────────────────────────

task.spawn(function()
	for i = 1, 4 do
		local door = Workspace:WaitForChild("DungeonDoor_" .. i, 20)
		if door then
			local prompt = door:FindFirstChildOfClass("ProximityPrompt")
			if prompt then
				local id = i
				prompt.Triggered:Connect(function(p) enterDungeon(p, id) end)
				print(("[DungeonManager] Connected door %d"):format(i))
			end
		else
			warn("[DungeonManager] Timed out waiting for DungeonDoor_" .. i)
		end
	end
	print("[DungeonManager] All doors connected")
end)

print("[DungeonManager] Loaded")
