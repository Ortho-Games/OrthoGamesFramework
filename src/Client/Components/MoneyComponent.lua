local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TableValue = require(ReplicatedStorage.Packages.TableValue)

local Globals = require(ReplicatedStorage.Shared.Globals)
local LemonSignal = require(Globals.Packages.LemonSignal)
local World = require(Globals.Modules.World)

local profileId = "Money"

local MoneyComponent = {}
MoneyComponent.addedSignal = LemonSignal.new()
MoneyComponent.changedSignal = LemonSignal.new()
MoneyComponent.removedSignal = LemonSignal.new()

function MoneyComponent:add(entity: number, data: {})
	local component = TableValue.new(data)

	function component.Changed(index, value)
		self.changedSignal:Fire(entity, component)
	end

	self.addedSignal:Fire(entity, component)

	return component
end

function MoneyComponent:remove(entity: number)
	self.removedSignal:Fire(entity)
end

export type Type = typeof(MoneyComponent.add(...))
MoneyComponent.Id = "Money"

return World.factory(MoneyComponent)
