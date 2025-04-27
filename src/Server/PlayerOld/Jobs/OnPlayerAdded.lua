local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local DataComponentRegistry =
	require(ServerStorage.Server.DataManager.Modules.DataComponentRegistry)
local PlayerComponent = require(ServerStorage.Server.Player.Components.PlayerComponent)
local PlayerComponentRegistry =
	require(ServerStorage.Server.Player.Interface.PlayerComponentRegistry)
local PlayerEntityTracker = require(ServerStorage.Server.Player.Modules.PlayerEntityTracker)
local ProfileComponent = require(ServerStorage.Server.DataManager.Components.ProfileComponent)
local RemovalQueue = require(ServerStorage.Server.EntityRemovalQueue.RemovalQueue)
local Schedules = require(ReplicatedStorage.Shared.Modules.Schedules)
local World = require(ServerStorage.Server.World)

local function PlayerAdd(player)
	local entity = World.entity()

	print("player added", player)
	local profile = ProfileComponent.add(entity, player)

	print("profile added", player)
	for _, factory in DataComponentRegistry.components do
		factory.add(entity, profile)
	end

	for _, factory in PlayerComponentRegistry.components do
		factory.add(entity, player)
	end

	PlayerComponent.add(entity, player)
	print("player component added", player)

	return entity
end

return Schedules.Boot.job(function()
	Players.PlayerAdded:Connect(PlayerAdd)
	for _, player: Player in Players:GetPlayers() do
		PlayerAdd(player)
	end

	Players.PlayerRemoving:Connect(function(player)
		local entity = PlayerEntityTracker.get(player)
		if not entity then return end

		ProfileComponent.remove(entity)
		task.defer(function()
			World.kill(entity)
		end)
	end)
end)
