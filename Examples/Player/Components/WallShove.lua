local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Shared.Global)

local Component = {}

function Component:add(entity, acceleration: number, radius: number)
	local comp = {}
	comp.acceleration = acceleration or 30
	comp.radius = radius or 16

	return comp
end

return Global.World.factory(Global.InjectLifecycleSignals(Component))
