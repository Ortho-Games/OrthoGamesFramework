local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local TableValue = require(Globals.Packages.TableValue)
local Janitor = require(Globals.Packages.Janitor)

local ClicksDisplay = require(Globals.Modules.ClicksDisplay)

local World = require(Globals.Shared.Modules.World)

local ClicksComponent = World.factory({
	add = function(factory, entity, data)
		data = data or {}
		data.clicks = data.clicks or 0

		local self = TableValue.new(data)
		self.jan = Janitor.new()
		self.ui = self.jan:Add(ClicksDisplay.make(self.Value))

		function self.Changed(index, value)
			ClicksDisplay.update(data.ui, self.Value)
		end

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

function ClicksComponent.addFromPacket(entity, addPacket)
	ClicksComponent.add(entity, addPacket)
end

function ClicksComponent.changeFromPacket(entity, changePacket)
	local componentData = ClicksComponent.get(entity)
	if not componentData then
		componentData = ClicksComponent.add(entity, componentData)
	end

	for _, delta in changePacket do
		print(delta)
		componentData[delta[1]] = delta[2]
	end
end

function ClicksComponent.removeFromPacket(entity, removePacket)
	ClicksComponent.remove(entity, removePacket)
end

return ClicksComponent
