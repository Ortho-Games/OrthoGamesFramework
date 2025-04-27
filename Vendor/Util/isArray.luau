return function(t)
	if type(t) ~= "table" then return false end
	local count = 0
	for k in pairs(t) do
		if type(k) ~= "number" then return false end
		count = count + 1
	end
	return count == #t
end
