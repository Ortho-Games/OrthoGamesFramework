return function(t: {}, func: (...any?) -> ())
	local threads: { thread } = {}

	for _, v in t do
		table.insert(
			threads,
			task.spawn(function()
				func(v)
			end)
		)
	end

	repeat
		local finished = true
		for _, thread in threads do
			if coroutine.status(thread) ~= "dead" then finished = false end
		end
		task.wait()
	until finished
end
