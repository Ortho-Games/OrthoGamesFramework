local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Stew = require(Globals.Packages.Stew)

local world = Stew.world()

local connections = {}

function world.spawned(entity)
	if typeof(entity) == "Instance" then
		connections[entity] = entity.Destroyed:Once(function()
			world.kill(entity)
		end)
	end
end

function world.killed(entity)
	if typeof(entity) == "Instance" then
		connections[entity]:Disconnect()
		connections[entity] = nil
	end
end

return Stew.world()
