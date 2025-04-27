local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local InjectLifecycleSignals = require(ReplicatedStorage.Shared.Modules.InjectLifecycleSignals)
local PlayerComponentRegistry =
	require(ServerStorage.Server.Player.Interface.PlayerComponentRegistry)
local PlayerEntityTracker = require(ServerStorage.Server.Player.Modules.PlayerEntityTracker)
local World = require(ServerStorage.Server.World)

local TeleportDataComponent = {}

function TeleportDataComponent:add(entity, player): Player
	return player:GetJoinData()
	-- insert constructor for component here
end

return PlayerComponentRegistry.register(World.factory(TeleportDataComponent))
