local components = {}

return {
	components = components,
	register = function(factory)
		table.insert(components, factory)
		return factory
	end,
}
