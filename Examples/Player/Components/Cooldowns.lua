--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Shared.Global)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local TableValue = require(ReplicatedStorage.Packages.TableValue)

local InputEnum = require(ReplicatedStorage.Shared.Enums.Input)

local TIMES_TEMPLATE = Global.Util.filter_map(InputEnum, function()
	return 0
end)

local Cooldowns = {}
Cooldowns.Changed = Signal.new()

export type CooldownsComponent = {
	janitor: Janitor.Janitor,
	times: { [string]: number },
	ended: Signal.Signal<string>,
}

function Cooldowns:add(entity: number): CooldownsComponent
	local janitor = Janitor.new()
	local ended = janitor:Add(Signal.new(), "Destroy")
	local times = TableValue.new(
		table.clone(TIMES_TEMPLATE),
		function(_, cooldownName, newTime, oldTime)
			if newTime == oldTime then return end
			Cooldowns.Changed:Fire(entity, cooldownName, newTime, oldTime)
			janitor:Remove(cooldownName)
			janitor:Add(
				task.delay(
					newTime - workspace:GetServerTimeNow(),
					ended.Fire,
					ended,
					cooldownName
				),
				true,
				cooldownName
			)
		end
	)

	return {
		janitor = janitor,
		times = times,
		ended = ended,
	}
end

function Cooldowns:removed(_, comp: CooldownsComponent): ()
	comp.janitor:Destroy()
end

return Global.World.factory(Global.InjectLifecycleSignals(Cooldowns))
