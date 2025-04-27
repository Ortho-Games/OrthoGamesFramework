return function<T, U>(t: { T }, predicate: (key: U, value: T) -> any?)
	local newTable = {}

	for key, value in t do
		if predicate(key, value) then newTable[key] = value end
	end

	return newTable
end
