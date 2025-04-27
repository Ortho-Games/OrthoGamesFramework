local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local InjectLifecycleSignals = require(ReplicatedStorage.Shared.Modules.InjectLifecycleSignals)
local PlayerEntityTracker = require(ServerStorage.Server.Player.Modules.PlayerEntityTracker)
local World = require(ServerStorage.Server.World)

local Player = {}

function Player:add(entity, player): Player
	PlayerEntityTracker.track(player, entity)
	return player
	-- insert constructor for component here
end

function Player:removed(entity, comp: Player)
	PlayerEntityTracker.remove(comp)
end

return World.factory(InjectLifecycleSignals(Player))
