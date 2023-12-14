--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Globals: {} = require(ReplicatedStorage.Shared.Globals)
local Net = require(Globals.Packages.Net)
local TableValue: {} = require(Globals.Packages.TableValue)
local Janitor = require(Globals.Packages.Janitor)

local ClicksDisplay = require(Globals.Client.UI.ClicksDisplay)

local World: {} = require(Globals.Shared.Modules.World)

local Factory = World.factory({
	add = function(factory, entity, data)
		-- print(`Added clicks component to entity type "{typeof(entity)}"`)

		local self = TableValue.new(data, function(index, value)
			if entity ~= Players.LocalPlayer then
				return
			end
		end)

		self.jan = Janitor.new()
		self.ui = self.jan:Add(ClicksDisplay.make(self.Value))

		function self.Changed(index, value)
			ClicksDisplay.update(data.ui, self.Value)
		end

		-- data.clicks = data.clicks or 0

		return self
	end,

	remove = function(factory, entity, component)
		component.jan:Destroy()
	end,

	data = {
		name = script.Name,
		id = "clicks",
	},
})

Net:Connect("ReplicateAll", function(name, entities, entitiesData)
	if name ~= Factory.data.name then
		return
	end

	for i = 1, #entities do
		Factory.add(entities[i], entitiesData[i])
	end
end)

Net:Connect("ReplicateAdded", function(name, entity, data)
	print("Replicate Added")
	if name ~= Factory.data.name then
		return
	end

	Factory.add(entity, data)
end)

Net:Connect("ReplicateChanged", function(name, entity, index, value)
	if name ~= Factory.data.name then
		return
	end

	local data = Factory.get(entity)
	if not data then
		data = Factory.add(entity, { [index] = value })
		return
	end

	data[index] = value
end)

Net:Connect("ReplicateRemoved", function(name, entity)
	if name ~= Factory.data.name then
		return
	end

	Factory.remove(entity)
end)

return Factory
