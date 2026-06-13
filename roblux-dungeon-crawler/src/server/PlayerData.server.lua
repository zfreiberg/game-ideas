-- Thin wrapper: wires PlayerAdded/Removing to the shared PlayerDataModule singleton
local Players = game:GetService("Players")
local PlayerDataModule = require(script.Parent.PlayerDataModule)

Players.PlayerAdded:Connect(function(player)
	PlayerDataModule.init(player)
	print("[PlayerData] Initialized data for", player.Name)
end)

Players.PlayerRemoving:Connect(function(player)
	PlayerDataModule.cleanup(player)
end)

-- Handle players who joined before this script loaded (Studio play-solo edge case)
for _, player in ipairs(Players:GetPlayers()) do
	PlayerDataModule.init(player)
end

print("[PlayerData] Loaded")
