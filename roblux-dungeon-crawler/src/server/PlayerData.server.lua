-- Tracks per-player stats: level, exp, gear score
local Players = game:GetService("Players")

local playerData = {}

local function onPlayerAdded(player)
	playerData[player.UserId] = {
		level   = 1,
		exp     = 0,
		expToNext = 100,
	}
	print("[PlayerData] Initialized data for", player.Name)
end

local function onPlayerRemoving(player)
	playerData[player.UserId] = nil
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

print("[PlayerData] Loaded")
