local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Shared.Global)

local Component = {}

function Component:add(entity, multi: number)
	-- insert constructor for component here
	local comp = {}
	comp.multi = multi or 2

	return comp
end

return Global.World.factory(Global.InjectLifecycleSignals(Component))
