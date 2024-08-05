local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Shared.Global)

local Component = {}

function Component:add(entity, speed: number, sprint: number)
	-- insert constructor for component here
	local comp = {}
	comp.speed = speed or 16
	comp.sprint = sprint or 24

	return comp
end

return Global.World.factory(Global.InjectLifecycleSignals(Component))
