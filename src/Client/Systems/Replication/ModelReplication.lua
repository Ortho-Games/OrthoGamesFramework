local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Net = require(Globals.Packages.Net)
local Schedules = require(ReplicatedStorage.Shared.Modules.Schedules)
local ModelComponent = require(Globals.Local.Components.ModelComponent)

local ModelReplication = {}

ModelReplication.replicationAdded = function(entity, model)
	ModelComponent:add(entity, model)
end

ModelReplication.init = Schedules.init.job(function()
	Net:Connect("ModelReplicationAdded", ModelReplication.replicationAdded)
end)

return ModelReplication
