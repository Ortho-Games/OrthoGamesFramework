local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Net = require(Globals.Packages.Net)
local Schedules = require(ReplicatedStorage.Shared.Modules.Schedules)
local MoneyComponent = require(Globals.Local.Components.MoneyComponent)

return Schedules.init.job(function()
	local added = Net:RemoteEvent("MoneyReplicationAdded")
	local changed = Net:RemoteEvent("MoneyReplicationChanged")
	local removed = Net:RemoteEvent("MoneyReplicationRemoved")

	MoneyComponent.addedSignal:Connect(function(entity: number, component, player: Player | nil)
		-- insert ser here

		if player then
			added:FireClient(player, -entity, component)
			return
		end
		added:FireAllClients(-entity, component)
	end)

	MoneyComponent.changedSignal:Connect(function(entity: number, component, player: Player | nil)
		-- insert ser here

		if player then
			changed:FireClient(player, -entity, component)
			return
		end
		changed:FireAllClients(-entity, component)
	end)

	MoneyComponent.removedSignal:Connect(function(entity: number, player: Player | nil)
		if player then
			changed:FireClient(player, -entity)
			return
		end
		removed:FireAllClients(-entity)
	end)

	-- in this case we have no removed signal because you can detect when a model is destroyed on the client anyways.
end)
