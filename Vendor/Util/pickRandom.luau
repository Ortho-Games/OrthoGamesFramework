local RNG = Random.new()

return function<T>(tbl: { T }, except: T | nil)
	if #tbl <= 0 then return nil end

	if #tbl < 2 then return tbl[1] end

	local pick
	repeat
		pick = tbl[RNG:NextInteger(1, #tbl)]
	until pick ~= except

	return pick
end
