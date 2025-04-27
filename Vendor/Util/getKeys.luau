return function(dict)
	local keys = {}
	for k, _ in dict do
		table.insert(keys, k)
	end
	return keys
end
