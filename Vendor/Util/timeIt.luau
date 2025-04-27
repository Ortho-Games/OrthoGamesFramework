return function(name: string, func, useWarn: boolean?, thresh: number?)
	local s = os.clock()
	func()
	local t = os.clock() - s
	if thresh and t < thresh then return end

	local f = if useWarn then warn else print
	f(string.format("%.05f", t), "-", name)
end
