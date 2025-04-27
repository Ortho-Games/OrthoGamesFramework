return function<T, U>(t: { U }, filter_mapper: (T, U) -> any)
	local newTable = {}
	local tempDict = {}
	for key, value in t do
		local mapped = filter_mapper(key, value)
		if not mapped then continue end
		if tempDict[mapped] then continue end
		tempDict[mapped] = true

		table.insert(newTable, mapped)
	end

	return newTable
end
