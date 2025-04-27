return function(arr: { any })
	local lut = {}

	for i, v in ipairs(arr) do
		lut[v] = i
	end

	return lut
end
