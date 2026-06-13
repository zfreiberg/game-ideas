-- Handles dungeon entry, enemy tracking, and completion
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DungeonData = require(ReplicatedStorage.DungeonData)

-- RemoteEvents (create these in Studio or via Rojo later)
-- DungeonEnter  : client → server (dungeonId)
-- DungeonComplete : server → client ()

print("[DungeonManager] Loaded")
