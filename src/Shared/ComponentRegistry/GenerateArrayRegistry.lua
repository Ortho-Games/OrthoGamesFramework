return function()
	local cache = {}

	return {
		registry = cache,
		register = function(key, value)
			table.insert(cache, value)
			return value
		end,
	}
end
