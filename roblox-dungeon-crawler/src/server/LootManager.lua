-- Server-side loot generation — never called from client (GDD 12.3)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LootData = require(ReplicatedStorage.LootData)
local Config   = require(ReplicatedStorage.Config)

local LootManager = {}

local function weightedPick(tbl, weightKey)
	local total = 0
	for _, v in ipairs(tbl) do total += v[weightKey] end
	local roll = math.random(1, total)
	local cum  = 0
	for _, v in ipairs(tbl) do
		cum += v[weightKey]
		if roll <= cum then return v end
	end
	return tbl[#tbl]
end

local function rollRarity(tierBonus)
	local picked = weightedPick(LootData.Rarities, "weight")
	if tierBonus and tierBonus > 0 then
		for i, r in ipairs(LootData.Rarities) do
			if r.name == picked.name then
				return LootData.Rarities[math.min(i + tierBonus, #LootData.Rarities)]
			end
		end
	end
	return picked
end

local function rollMutation()
	if math.random(1, 100) <= LootData.NO_MUTATION_CHANCE then return nil end
	return weightedPick(LootData.Mutations, "chance")
end

local function rollItemType()
	local types = LootData.ItemTypes.Zone1
	return types[math.random(1, #types)]
end

-- Returns an item table, or nil if no drop
function LootManager.rollForEnemy(dungeonId, dungeonMutation, isBoss)
	local dropChance = isBoss and 100 or LootData.BASE_DROP_CHANCE
	if math.random(1, 100) > dropChance then return nil end

	local tierBonus = Config.LOOT_TIER_BONUS[dungeonMutation] or 0
	local rarity    = rollRarity(tierBonus)
	local mutation  = rollMutation()
	local itemType  = rollItemType()

	return {
		name     = itemType,
		rarity   = rarity.name,
		color    = rarity.color,
		mutation = mutation and mutation.name  or nil,
		statKey  = mutation and mutation.statKey or nil,
		statVal  = mutation and mutation.statVal or nil,
		tier     = 1,
	}
end

return LootManager
