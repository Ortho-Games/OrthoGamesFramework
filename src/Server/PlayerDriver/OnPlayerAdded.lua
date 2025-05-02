local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local DataComponentRegistry =
	require(ServerScriptService.Server.PlayerDriver.Interface.DataComponentRegistry)
local Player = require(ServerScriptService.Server.PlayerDriver.Components.Player)
local PlayerComponentRegistry =
	require(ServerScriptService.Server.PlayerDriver.Interface.PlayerComponentRegistry)
local ProfileComponent =
	require(ServerScriptService.Server.PlayerDriver.Components.ProfileComponent)
local World = require(ReplicatedStorage.Shared.Modules.World)

-- local PlayerEntityTracker = require(ServerStorage.Server.Player.Modules.)

local function PlayerAdd(player)
	local entity = World.entity()

	print("player added", player)
	local profile = ProfileComponent.add(entity, player)

	print("profile added", player)
	for _, factory in DataComponentRegistry.registry do
		factory.add(entity, profile)
	end

	for _, factory in PlayerComponentRegistry.registry do
		factory.add(entity, player)
	end

	Player.add(entity, player)
	print("player component added", player)

	return entity
end

return function()
	Players.PlayerAdded:Connect(PlayerAdd)
	for _, player: Player in Players:GetPlayers() do
		PlayerAdd(player)
	end

	Players.PlayerRemoving:Connect(function(player)
		local entity = Player.getEntity(player)
		if not entity then return end

		ProfileComponent.remove(entity)
		task.defer(function()
			World.kill(entity)
		end)
	end)
end
