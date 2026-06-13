-- Main server orchestrator: dungeon entry, enemy spawning, kill tracking, completion
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataModule = require(ServerScriptService.PlayerDataModule)
local DungeonData      = require(ReplicatedStorage.DungeonData)
local EnemyData        = require(ReplicatedStorage.EnemyData)

local remotes           = ReplicatedStorage:WaitForChild("RemoteEvents")
local evDungeonComplete = remotes:WaitForChild("DungeonComplete")
local evEXPGained       = remotes:WaitForChild("EXPGained")
local evReturnToHub     = remotes:WaitForChild("ReturnToHub")

-- Where to drop the player when entering each dungeon (just Dungeon 1 for now)
local DUNGEON_ENTRY_CF = {
	[1] = CFrame.new(0, 5, 975), -- south end of Dungeon 1 room
}
local HUB_SPAWN_CF = CFrame.new(0, 5, 40)

local DAMAGE_PER_CLICK = 25

-- [userId] = { dungeonId: number, enemiesRemaining: number }
local activeRuns = {}

-- ── Enemy spawning ──────────────────────────────────────────────────────────

local function spawnEnemies(player, dungeonId)
	local dungeon  = DungeonData.Dungeons[dungeonId]
	if not dungeon then return end

	local typeData = EnemyData.Types[dungeon.enemyType] or EnemyData.Types.BasicCube
	local count    = dungeon.enemyCount

	-- Room center for Dungeon 1
	local center = Vector3.new(0, typeData.size.Y / 2 + 2, 1000)

	activeRuns[player.UserId] = { dungeonId = dungeonId, enemiesRemaining = count }

	for i = 1, count do
		local cube = Instance.new("Part")
		cube.Name = "Enemy_" .. player.UserId .. "_" .. i
		cube.Size = typeData.size
		cube.Color = typeData.color
		cube.Material = Enum.Material.SmoothPlastic
		cube.Anchored = true
		cube.CanCollide = true

		-- Scatter enemies in a ring around the room center
		local angle = ((i - 1) / count) * math.pi * 2
		cube.Position = center + Vector3.new(math.cos(angle) * 25, 0, math.sin(angle) * 25)

		cube:SetAttribute("Health", typeData.health)
		cube:SetAttribute("OwnerId", player.UserId)
		cube:SetAttribute("ExpDrop", typeData.expDrop)
		cube.Parent = Workspace

		-- HP billboard
		local bg = Instance.new("BillboardGui")
		bg.Size = UDim2.new(0, 130, 0, 26)
		bg.StudsOffset = Vector3.new(0, typeData.size.Y / 2 + 1, 0)
		bg.AlwaysOnTop = false
		bg.Parent = cube

		local hpLabel = Instance.new("TextLabel")
		hpLabel.Name = "HPLabel"
		hpLabel.Size = UDim2.new(1, 0, 1, 0)
		hpLabel.BackgroundColor3 = Color3.fromRGB(160, 0, 0)
		hpLabel.BackgroundTransparency = 0.2
		hpLabel.Text = typeData.health .. " / " .. typeData.health .. " HP"
		hpLabel.TextColor3 = Color3.new(1, 1, 1)
		hpLabel.TextScaled = true
		hpLabel.Font = Enum.Font.GothamBold
		hpLabel.Parent = bg

		-- ClickDetector — 25 damage per click, only the owning player can damage their enemies
		local cd = Instance.new("ClickDetector")
		cd.MaxActivationDistance = 35
		cd.Parent = cube

		cd.MouseClick:Connect(function(clicker)
			if clicker ~= player then return end

			local hp = cube:GetAttribute("Health")
			if not hp or hp <= 0 then return end

			hp = math.max(0, hp - DAMAGE_PER_CLICK)
			cube:SetAttribute("Health", hp)
			hpLabel.Text = hp .. " / " .. typeData.health .. " HP"

			if hp <= 0 then
				local expDrop = cube:GetAttribute("ExpDrop") or 0
				cube:Destroy()

				-- Grant per-kill EXP
				local updatedData = PlayerDataModule.grantEXP(player, expDrop)
				if updatedData then
					evEXPGained:FireClient(player, expDrop, updatedData.level)
				end

				-- Check for dungeon completion
				local run = activeRuns[player.UserId]
				if run and run.dungeonId == dungeonId then
					run.enemiesRemaining -= 1
					if run.enemiesRemaining <= 0 then
						activeRuns[player.UserId] = nil

						-- Grant completion bonus EXP
						local bonus = dungeon.expReward or 0
						if bonus > 0 then
							local d2 = PlayerDataModule.grantEXP(player, bonus)
							if d2 then
								evEXPGained:FireClient(player, bonus, d2.level)
							end
						end

						task.wait(0.3) -- brief pause before popup
						evDungeonComplete:FireClient(player)
						print(("[DungeonManager] %s completed Dungeon %d"):format(player.Name, dungeonId))
					end
				end
			end
		end)
	end

	print(("[DungeonManager] Spawned %d enemies for %s in Dungeon %d"):format(count, player.Name, dungeonId))
end

-- ── Dungeon entry ───────────────────────────────────────────────────────────

local function enterDungeon(player, dungeonId)
	if activeRuns[player.UserId] then
		print(("[DungeonManager] %s already in a run, ignoring entry"):format(player.Name))
		return
	end

	local entryCF = DUNGEON_ENTRY_CF[dungeonId]
	if not entryCF then
		print(("[DungeonManager] Dungeon %d not implemented yet"):format(dungeonId))
		return
	end

	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	hrp.CFrame = entryCF
	task.wait(0.3) -- let physics settle before spawning enemies
	spawnEnemies(player, dungeonId)
end

-- ── Hub return ──────────────────────────────────────────────────────────────

evReturnToHub.OnServerEvent:Connect(function(player)
	-- Clean up any leftover enemies for this player (shouldn't happen after completion, but safety)
	for _, obj in ipairs(Workspace:GetChildren()) do
		if obj.Name:sub(1, #("Enemy_" .. player.UserId)) == "Enemy_" .. player.UserId then
			obj:Destroy()
		end
	end
	activeRuns[player.UserId] = nil

	local char = player.Character
	if char then
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = HUB_SPAWN_CF
		end
	end
end)

-- Clean up if player leaves mid-run
Players.PlayerRemoving:Connect(function(player)
	activeRuns[player.UserId] = nil
	for _, obj in ipairs(Workspace:GetChildren()) do
		if obj.Name:find("Enemy_" .. player.UserId) then
			obj:Destroy()
		end
	end
end)

-- ── Connect to dungeon doors (wait for WorldBuilder to create them) ─────────

task.spawn(function()
	for i = 1, 3 do
		local door = Workspace:WaitForChild("DungeonDoor_" .. i, 15)
		if door then
			local prompt = door:FindFirstChildOfClass("ProximityPrompt")
			if prompt then
				local dungeonId = i
				prompt.Triggered:Connect(function(player)
					enterDungeon(player, dungeonId)
				end)
				print(("[DungeonManager] Connected door %d"):format(i))
			end
		else
			warn("[DungeonManager] Timed out waiting for DungeonDoor_" .. i)
		end
	end
	print("[DungeonManager] All doors connected")
end)

print("[DungeonManager] Loaded")
