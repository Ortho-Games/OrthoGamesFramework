local isArray = require(script.Parent.isArray)
return function(...)
	local options = {
		-- Set default merge mode:
		-- "shallow", "deep", or "reactive" (for Fusion state objects)
		mode = "deep",

		-- For array handling:
		-- "overwrite" = replace arrays completely
		-- "concat" = concatenate arrays
		arrayBehavior = "overwrite",

		-- Maximum recursion depth for deep merges
		maxDepth = 10,
	}

	local function recurse(target, source, depth)
		if depth > options.maxDepth then return target end

		for k, v in pairs(source) do
			if options.mode == "deep" then
				if type(v) == "table" and type(target[k]) == "table" then
					-- Handle array merging
					if options.arrayBehavior == "concat" and isArray(v) and isArray(target[k]) then
						for _, item in ipairs(v) do
							table.insert(target[k], item)
						end
					else
						target[k] = recurse(target[k], v, depth + 1)
					end
				else
					target[k] = v
				end
			else
				target[k] = v
			end
		end

		return target
	end

	local merged = {}
	for i = 1, select("#", ...) do
		local t = select(i, ...)
		if t then recurse(merged, t, 1) end
	end
	return merged
end
