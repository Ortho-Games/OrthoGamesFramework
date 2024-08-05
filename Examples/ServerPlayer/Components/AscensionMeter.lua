local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Global = require(ReplicatedStorage.Shared.Global)

local AscensionMeter = {}

function AscensionMeter:add(entity, cur, max)
	-- insert constructor for component here
	return {
		cur = cur or 0,
		max = max or 100,
		isAscended = false,
	} :: {
		cur: number,
		max: number,
		isAscended: boolean,
	}
end

return Global.World.factory(Global.InjectLifecycleSignals(AscensionMeter))
