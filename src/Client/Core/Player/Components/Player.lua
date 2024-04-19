local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)

local InjectLifecycleSignals =
	require(Globals.Shared.Modules.InjectLifecycleSignals)

local Player = {}

function Player:add(entity, player)
	return player
end

return Globals.World.factory(InjectLifecycleSignals(Player))
