return function<T>(t: { T }, predicate: (value: T) -> ())
	for key, value in t do
		if predicate(value) then return key end
	end

	return nil
end
