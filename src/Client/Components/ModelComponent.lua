local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Net = require(Globals.Packages.Net)
local World = require(Globals.Shared.Modules.World)

local ModelComponent = {}
ModelComponent.re = Net:RemoteEvent("ModelComponentReplication")

function ModelComponent:add(entity, model)
	-- insert constructor for component here
	if typeof(entity) == "Instance" and workspace.ModelStreamingBehavior == Enum.ModelStreamingBehavior.Improved then
		warn(
			"You created a Model Component with a instance entity and a model behavior set to improved, there will be problems with replication!"
		)
	end

	model.Destroying:Once(function()
		self.remove(entity)
	end)

	return model
end

function ModelComponent:remove(entity, model)
	model:Destroy()
end

Net:Connect("ModelComponentReplication", function() end)

return World.factory(ModelComponent)
