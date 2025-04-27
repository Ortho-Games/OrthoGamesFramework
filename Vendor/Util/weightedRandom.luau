local RNG = Random.new()

return function(values, weights)
	local total = 0

	for _, weight in weights do
		total += weight
	end

	local random = RNG:NextNumber() * total

	local cursor = 0
	for i = 1, #weights do
		cursor += weights[i]
		if cursor >= random then return values[i] end
	end

	return values[1]
end
