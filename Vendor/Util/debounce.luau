return function(func)
	local db = false
	return function(...)
		if db then return end
		db = true

		task.spawn(function(...)
			func(...)
			db = false
		end, ...)
	end
end
