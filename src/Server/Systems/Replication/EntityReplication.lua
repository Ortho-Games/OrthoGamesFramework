local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Net = require(Globals.Packages.Net)
local Schedules = require(ReplicatedStorage.Shared.Modules.Schedules)
local ModelComponent = require(Globals.Local.Components.ModelComponent)
local World = require(ReplicatedStorage.Shared.Modules.World)

local function replicateEntityComponents(entity)
	for factory, component in World.get(entity) do
		factory.addedSignal:Fire(entity, component)
	end
end

return Schedules.init.job(function()
	local removed = Net:RemoteEvent("EntityRemoved")

	World.addedSignal:Connect(function(entity)
		-- insert ser here
		replicateEntityComponents(entity)
	end)

	World.removedSignal:Connect(function(entity)
		removed:FireAllClients(-entity)
	end)

	-- in this case we have no removed signal because you can detect when a model is destroyed on the client anyways.
end)
