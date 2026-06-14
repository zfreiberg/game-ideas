-- Raidbound player data (Phase 1 MVP: in-memory; Phase 2 moves to ProfileService)
local PlayerDataModule = {}

local data = {}

local EXP_BASE     = 100
local EXP_SCALE    = 1.5

function PlayerDataModule.init(player)
	data[player.UserId] = {
		level     = 1,
		exp       = 0,
		expToNext = EXP_BASE,
		gold      = 0,
		class     = "Warrior",  -- default; class selection Phase 1 stub
		inventory = {},         -- { name, rarity, mutation, statKey, statVal, tier }
	}
end

function PlayerDataModule.cleanup(player)
	data[player.UserId] = nil
end

function PlayerDataModule.get(player)
	return data[player.UserId]
end

-- Returns updated data (handles multi-level-ups)
function PlayerDataModule.grantEXP(player, amount)
	local d = data[player.UserId]
	if not d then return nil end
	d.exp += amount
	while d.exp >= d.expToNext do
		d.exp      -= d.expToNext
		d.level    += 1
		d.expToNext = math.floor(d.expToNext * EXP_SCALE)
		print(("[PlayerData] %s leveled up → Level %d"):format(player.Name, d.level))
	end
	return d
end

function PlayerDataModule.grantGold(player, amount)
	local d = data[player.UserId]
	if not d then return nil end
	d.gold += amount
	return d
end

function PlayerDataModule.addItem(player, item)
	local d = data[player.UserId]
	if not d then return nil end
	table.insert(d.inventory, item)
	return d
end

function PlayerDataModule.setClass(player, className)
	local d = data[player.UserId]
	if not d then return nil end
	d.class = className
	return d
end

return PlayerDataModule
