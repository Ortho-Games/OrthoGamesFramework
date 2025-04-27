return function<T>(arr: { T }, map: (number, T) -> any)
	local dict: { [T]: T } = {}

	for i: number, v: T in ipairs(arr) do
		dict[v] = map(i, v)
	end

	return dict
end
