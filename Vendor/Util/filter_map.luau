return function<T, U>(t: { [T]: U }, filter_mapper: (T, U) -> any)
	local newTable = {}
	for key, value in t do
		local mapped = filter_mapper(key, value)
		if mapped then table.insert(newTable, mapped) end
	end

	return newTable
end
