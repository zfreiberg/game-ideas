-- Wires PlayerAdded/Removing to PlayerDataModule; syncs initial data to client
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataModule = require(ServerScriptService.PlayerDataModule)
local evSync = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("PlayerDataSync")

local function onPlayerAdded(player)
	PlayerDataModule.init(player)
	print("[PlayerData] Initialized:", player.Name)

	-- Wait for character then sync initial data to client HUD
	player.CharacterAdded:Connect(function()
		task.wait(1)  -- let client scripts load
		local d = PlayerDataModule.get(player)
		if d then
			evSync:FireClient(player, { level = d.level, gold = d.gold, class = d.class })
		end
	end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(function(player)
	PlayerDataModule.cleanup(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

print("[PlayerData] Loaded")
