return function<T>(t: { T }, mapper: (value: T) -> ())
	local newTable = {}

	for key, value in t do
		newTable[key] = mapper(value)
	end

	return newTable
end
