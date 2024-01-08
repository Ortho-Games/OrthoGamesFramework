local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TableValue = require(ReplicatedStorage.Packages.TableValue)

local Globals = require(ReplicatedStorage.Shared.Globals)
local LemonSignal = require(Globals.Packages.LemonSignal)
local World = require(ReplicatedStorage.Shared.Modules.World)
local Schedules = require(ReplicatedStorage.Shared.Modules.Schedules)

local profileId = "Test"
Schedules.init.job(function(profileTemplate)
	profileTemplate[profileId] = {
		test = 0,
	}
end)

local TestComponent = {}
TestComponent.addedSignal = LemonSignal.new()
TestComponent.changedSignal = LemonSignal.new()
TestComponent.removedSignal = LemonSignal.new()

function TestComponent:add(entity: number)
	local component = TableValue.new({})

	function component.Changed(index, value)
		self.changedSignal:Fire(entity, component)
	end

	self.addedSignal:Fire(entity, component)

	return component
end

function TestComponent:remove(entity: number)
	self.removedSignal:Fire(entity)
end

export type Type = typeof(TestComponent.add(...))
TestComponent.Id = "Test"

return World.factory(TestComponent)
