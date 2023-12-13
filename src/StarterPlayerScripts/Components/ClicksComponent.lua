--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals: {} = require(ReplicatedStorage.Shared.Globals)
local Net = require(Globals.Packages.Net)
local TableValue: {} = require(Globals.Packages.TableValue)

local World: {} = require(Globals.Shared.Modules.World)

local Factory = World.factory({
	add = function(factory, entity, data)
		local self = TableValue.new(data, function(index, value)
			-- Net:RemoteEvent("ReplicateChanged"):FireAllClients(entity, script.Name, index, value)
			print(index, value)
		end)

		return self
	end,

	remove = function(factory, entity, component) end,

	data = {
		name = script.Name,
		id = "clicks",
	},
})

Net:Connect("ReplicateAll", function(name, entityToData)
	if name ~= Factory.data.name then
		return
	end

	for entity, data in entityToData do
		Factory.add(entity, data)
	end
end)
Net:Connect("ReplicateAdded", function(name, entity, data)
	print("Replicate Added")
	if name ~= Factory.data.name then
		return
	end

	print(name, entity, data)
end)
Net:Connect("ReplicateChanged", function(name, entity, index, value)
	if name ~= Factory.data.name then
		return
	end

	print(name, entity, index, value)
end)
Net:Connect("ReplicateRemoved", function(name)
	if name ~= Factory.data.name then
		return
	end

	print(name)
end)

return Factory
