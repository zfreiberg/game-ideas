-- Singleton module: all server scripts share the same data table when they require this
local PlayerDataModule = {}

local data = {}

function PlayerDataModule.init(player)
	data[player.UserId] = {
		level     = 1,
		exp       = 0,
		expToNext = 100,
	}
end

function PlayerDataModule.cleanup(player)
	data[player.UserId] = nil
end

function PlayerDataModule.get(player)
	return data[player.UserId]
end

-- Returns updated data table after granting EXP (handles level-ups)
function PlayerDataModule.grantEXP(player, amount)
	local d = data[player.UserId]
	if not d then return nil end

	d.exp += amount

	while d.exp >= d.expToNext do
		d.exp -= d.expToNext
		d.level += 1
		d.expToNext = math.floor(d.expToNext * 1.5)
		print(("[PlayerData] %s leveled up → Level %d"):format(player.Name, d.level))
	end

	return d
end

return PlayerDataModule
