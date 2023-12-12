local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Stew = require(Globals.Packages.Stew)
local TableValue = require(Globals.Packages.TableValue)

local World = require(Globals.Shared.Modules.World)

local ClicksComponent = {}

ClicksComponent.factory = World.factory({
	add = function(factory, entity)
		local self = TableValue.new({})

		self.clicks = 0

		function self.Changed(index, value)
			print(index, value)
		end

		return self
	end,

	remove = function(factory, entity, component) end,
})

return ClicksComponent.factory
