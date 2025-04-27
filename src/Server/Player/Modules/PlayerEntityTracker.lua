local PlayerEntityTracker = {}
PlayerEntityTracker.cache = {}

function PlayerEntityTracker.track(player, entity)
	PlayerEntityTracker.cache[player] = entity
end

function PlayerEntityTracker.get(player)
	return PlayerEntityTracker.cache[player]
end

function PlayerEntityTracker.remove(player)
	PlayerEntityTracker.cache[player] = nil
end

return PlayerEntityTracker
