return function(func: (...any) -> (), ...)
	local args = table.pack(...)
	return function(...)
		local newArgs = table.clone(args)
		local internalArgs = table.pack(...)
		table.move(internalArgs, 1, #internalArgs, #newArgs + 1, newArgs)
		func(table.unpack(newArgs))
	end
end
