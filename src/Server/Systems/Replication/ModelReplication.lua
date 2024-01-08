local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Net = require(Globals.Packages.Net)
local Schedules = require(ReplicatedStorage.Shared.Modules.Schedules)
local ModelComponent = require(Globals.Local.Components.ModelComponent)

local added = Net:RemoteEvent("ModelReplicationAdded")

local ModelReplication = {}

ModelReplication.addedSignal = function(entity, model, player: Player | nil)
	-- insert ser here
	if player then
		added:FireClient(player, -entity, model)
	end
	added:FireAllClients(-entity, model)
end

ModelReplication.init = Schedules.init.job(function()
	ModelComponent.addedSignal:Connect(ModelReplication.addedSignal)
end)

return ModelReplication
