local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Net = require(Globals.Packages.Net)
local Schedules = require(ReplicatedStorage.Shared.Modules.Schedules)
local MoneyComponent = require(Globals.Local.Components.MoneyComponent)

local MoneyReplication = {}

local added = Net:RemoteEvent("MoneyReplicationAdded")
local changed = Net:RemoteEvent("MoneyReplicationChanged")
local removed = Net:RemoteEvent("MoneyReplicationRemoved")

MoneyReplication.addedSignal = function(entity: number, component, player: Player | nil)
	-- insert ser here

	if player then
		added:FireClient(player, -entity, component)
		return
	end
	added:FireAllClients(-entity, component)
end

MoneyReplication.changedSignal = function(entity: number, component, player: Player | nil)
	-- insert ser here

	if player then
		changed:FireClient(player, -entity, component)
		return
	end
	changed:FireAllClients(-entity, component)
end

MoneyReplication.removedSignal = function(entity: number, player: Player | nil)
	if player then
		changed:FireClient(player, -entity)
		return
	end
	removed:FireAllClients(-entity)
end

MoneyReplication.MoneyReplication.init = Schedules.init.job(function()
	MoneyComponent.addedSignal:Connect(MoneyReplication.addedSignal)
	MoneyComponent.changedSignal:Connect(MoneyReplication.changedSignal)
	MoneyComponent.removedSignal:Connect(MoneyReplication.removedSignal)
end)

return MoneyReplication
