local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)

local Janitor = require(Globals.Packages.Janitor)

local InjectLifecycleSignals =
	require(Globals.Shared.Modules.InjectLifecycleSignals)

local Component = {}

function Component:add(entity, player: Player)
	return player
end

return Globals.World.factory(InjectLifecycleSignals(Component))
