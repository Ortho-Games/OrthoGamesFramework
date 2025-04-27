return function<T, U>(t: { T }, predicate: (key: U, value: T) -> ())
	local newTable = {}

	for key, value in t do
		if predicate(key, value) then table.insert(newTable, value) end
	end

	return newTable
end
