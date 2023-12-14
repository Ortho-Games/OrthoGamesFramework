--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals: {} = require(ReplicatedStorage.Shared.Globals)
local Net = require(Globals.Packages.Net)
local TableValue: {} = require(Globals.Packages.TableValue)

local World: {} = require(Globals.Shared.Modules.World)

local Factory = World.factory({
	add = function(factory, entity, profile)
		local self = TableValue.new(profile.Data[factory.data.id], function(index, value)
			Net:RemoteEvent("ReplicateChanged"):FireAllClients(factory.data.name, entity, index, value)
			-- print(index, value)
		end)

		Net:RemoteEvent("ReplicateAdded"):FireAllClients(factory.data.name, entity, profile.Data[factory.data.id])

		return self
	end,

	remove = function(factory, entity, component)
		Net:RemoteEvent("ReplicateRemoved"):FireAllClients(factory.data.name, entity)
	end,

	data = {
		name = script.Name,
		id = "clicks",
		replicateAll = function(player, factory)
			local entities = {}
			local entitiesData = {}
			for entity in World.query({ factory }) do
				-- print(entity, typeof(entity))
				table.insert(entities, entity)
				table.insert(entitiesData, factory.get(entity).Value)
			end

			Net:RemoteEvent("ReplicateAll"):FireClient(player, factory.data.name, entities, entitiesData)
		end,
	},
})

Net:Connect("ReplicateAll", function(player, name)
	if name ~= Factory.data.name then
		return
	end
	Factory.data.replicateAll(player, Factory)
end)

return Factory
