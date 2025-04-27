local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)

--- Adds onAdded and onRemoved to Components
return function(factoryTable)
	--- onAdded(entity, component) -> ()
	factoryTable.onAdded = Signal.new()

	--- onRemove(entity, component) -> ()
	factoryTable.onRemoved = Signal.new()

	local added = factoryTable.added
	local removed = factoryTable.removed

	local callingEntityScript = debug.info(2, "s")

	function factoryTable:added(entity, component)
		if added then added(self, entity, component) end
		-- print(
		-- 	callingEntityScript,
		-- 	"added @",
		-- 	debug.info(3, "s"),
		-- 	"Added",
		-- 	entity,
		-- 	component
		-- )
		factoryTable.onAdded:Fire(entity, component)
	end

	function factoryTable:removed(entity, component)
		if removed then removed(self, entity, component) end
		factoryTable.onRemoved:Fire(entity, component)
	end

	return factoryTable
end
