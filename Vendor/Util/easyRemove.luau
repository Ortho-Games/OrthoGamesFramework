local partial = require(script.Parent.partial)
return function(factory, entity: number, ...)
	factory.add(entity, ...)
	return partial(factory.remove, entity)
end
