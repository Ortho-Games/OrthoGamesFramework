local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stew = require(ReplicatedStorage.Packages.Stew)

local World = Stew.world {}

function World:spawned(entity)
	if typeof(entity) == "Instance" then
		error(`Attempted to establish an entity as an instance {entity}`)
	end
end

return World
