return function<T>(arr: { T })
	local dict: { [T]: T } = {}

	for _, v: T in ipairs(arr) do
		dict[v] = v
	end

	return dict
end
