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

local EntityReplication = {}
EntityReplication.removed = Net:RemoteEvent("EntityRemoved")

function EntityReplication.worldAdded(entity)
	-- insert ser here
	replicateEntityComponents(entity)
end

function EntityReplication.worldRemoved(entity)
	EntityReplication.removed:FireAllClients(-entity)
end

EntityReplication.init = Schedules.init.job(function()
	World.addedSignal:Connect(EntityReplication.worldAdded)
	World.removedSignal:Connect(EntityReplication.worldRemoved)
end)

return
