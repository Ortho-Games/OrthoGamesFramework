local PlayerEntityTracker = {}

local cache = {}

function PlayerEntityTracker.add(entity: number, player: Player)
	cache[player] = entity
end

function PlayerEntityTracker.get(player: Player): number
	return cache[player]
end

return PlayerEntityTracker
