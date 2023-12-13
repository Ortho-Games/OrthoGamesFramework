local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Stew = require(Globals.Packages.Stew)

local world = Stew.world()

function world.spawned(entity)
	if typeof(entity) == "Instance" then
		entity.Destroying:Once(function()
			world.kill(entity)
		end)
	end
end

return Stew.world()
