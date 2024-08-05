local CharacterEntityTracker = {}

local cache = {}

function CharacterEntityTracker.add(entity: number, model: Model)
	cache[model] = entity
end

function CharacterEntityTracker.get(model: Model): number
	return cache[model]
end

return CharacterEntityTracker
