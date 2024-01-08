local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Net = require(Globals.Packages.Net)
local LemonSignal = require(Globals.Packages.LemonSignal)
local World = require(Globals.Shared.Modules.World)

local ModelComponent = {}
ModelComponent.addedSignal = LemonSignal.new()

function ModelComponent:add(entity, model)
	-- insert constructor for component here
	if typeof(entity) == "Instance" and workspace.ModelStreamingBehavior == Enum.ModelStreamingBehavior.Improved then
		error(
			"You created a Model Component with a instance entity and a model behavior set to improved, there will be problems with replication!"
		)
	end
	self.addedSignal:Fire(entity, model)

	return model
end

function ModelComponent:remove(entity, model)
	model:Destroy()
end

return World.factory(ModelComponent)
