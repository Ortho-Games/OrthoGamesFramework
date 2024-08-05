--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Shared.Global)

local Janitor = require(ReplicatedStorage.Packages.Janitor)

local PlayerEntityTracker =
	require(ReplicatedStorage.Shared.Player.Modules.PlayerEntityTracker)

local Component = {}

export type PlayerComponent = {
	instance: Player,
	janitor: Janitor.Janitor,
}

function Component:add(entity: number, playerInstance: Player): PlayerComponent
	PlayerEntityTracker.add(entity, playerInstance)

	return {
		instance = playerInstance,
		janitor = Janitor.new(),
	}
end

function Component:remove(_, comp: PlayerComponent): ()
	comp.janitor:Destroy()
end

return Global.World.factory(Global.InjectLifecycleSignals(Component))
