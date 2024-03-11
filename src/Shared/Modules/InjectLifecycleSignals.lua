local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local LemonSignal = require(Globals.Packages.LemonSignal)

--- Adds onAdded and onRemoved to Components
return function(factoryTable)
	--- onAdded(entity, component) -> ()
	factoryTable.onAdded = LemonSignal.new()

	--- onRemove(entity, component) -> ()
	factoryTable.onRemoved = LemonSignal.new()

	local added = factoryTable.added
	local removed = factoryTable.removed

	function factoryTable:added(entity, component)
		if added then
			added(self, entity, component)
		end
		factoryTable.onAdded:Fire(entity, component)
	end

	function factoryTable:removed(entity, component)
		if removed then
			removed(self, entity, component)
		end
		factoryTable.onRemoved:Fire(entity, component)
	end

	return factoryTable
end
