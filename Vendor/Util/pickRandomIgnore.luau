local RNG = Random.new()

return function<T>(tbl: { T }, ignore: { T })
	if #tbl <= 0 then return nil end
	if #tbl < 2 then return tbl[1] end

	local pick
	repeat
		pick = tbl[RNG:NextInteger(1, #tbl)]
	until not table.find(ignore, pick)

	return pick
end
