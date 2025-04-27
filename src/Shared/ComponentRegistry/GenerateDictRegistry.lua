return function()
	local cache = {}

	return {
		registry = cache,
		register = function(key, value)
			cache[key] = value
			return value
		end,
	}
end
