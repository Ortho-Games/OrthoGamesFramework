return function<T>(t: { T }, predicate: (value: T) -> ())
	for _, value in t do
		if predicate(value) then return value end
	end

	return nil
end
