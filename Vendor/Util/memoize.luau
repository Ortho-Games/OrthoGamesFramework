local filter = require(script.Parent.filter)
return function(fn)
	local cache = {}

	return function(...: any)
		local args = filter({ ... }, function(_i, v) -- support varargs with nil inbetween
			return v ~= nil
		end)
		local key = table.concat(args, ",")

		if cache[key] == nil then cache[key] = fn(...) end

		return cache[key]
	end
end
