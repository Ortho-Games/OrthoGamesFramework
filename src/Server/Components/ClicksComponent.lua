local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Net = require(Globals.Packages.Net)
local TableValue = require(Globals.Packages.TableValue)

local World = require(Globals.Shared.Modules.World)

local ClicksComponent = World.factory({
	add = function(factory, entity, profile)
		local self = TableValue.new(profile.Data[factory.data.id])

		function self.Changed(index, value)
			Net:RemoteEvent("ReplicateChange"):FireAllClients(script.Name, entity, { { index, value } })
		end

		return self
	end,

	data = {
		id = "clicks",
	},
})

function ClicksComponent.added(entity, componentData)
	Net:RemoteEvent("ReplicateAdd"):FireAllClients(script.Name, entity, componentData.Value)
end

function ClicksComponent.removed(entity, componentData)
	Net:RemoteEvent("ReplicateRemove"):FireAllClients(script.Name, entity, componentData.Value)
end

function ClicksComponent.getReplicatePacket(_, componentData)
	return componentData.Value
end

return ClicksComponent
