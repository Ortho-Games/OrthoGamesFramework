return function(dict)
	local values = {}
	for _, v in dict do
		table.insert(values, v)
	end
	return values
end
