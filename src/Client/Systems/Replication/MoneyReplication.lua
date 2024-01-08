local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Net = require(Globals.Packages.Net)
local Schedules = require(ReplicatedStorage.Shared.Modules.Schedules)
local MoneyComponent = require(Globals.Local.Components.MoneyComponent)

return Schedules.init.job(function()
	Net:Connect("MoneyReplicationAdded", function(entity, component)
		-- insert ser here

		MoneyComponent.add(entity, component)
	end)

	Net:Connect("MoneyReplicationChanged", function(entity, componentDelta)
		-- insert ser here

		local localComponent = MoneyComponent.get(entity)
		if not localComponent then
			return
		end

		for k, v in componentDelta do
			localComponent[k] = v
		end
	end)

	Net:Connect("MoneyReplicationRemoved", function(entity)
		MoneyComponent.remove(entity)
	end)
	-- in this case we have no removed signal because you can detect when a model is destroyed on the client anyways.
end)
