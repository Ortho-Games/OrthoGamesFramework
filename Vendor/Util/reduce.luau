return function<T, U>(t: { T }, reducer: (accumulator: U, value: T, key: any) -> (), initialValue: U)
	local accumulator = initialValue

	for k, value in t do
		accumulator = reducer(accumulator, value, k)
	end

	return accumulator
end
