local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Global = require(ReplicatedStorage.Shared.Global)
local Net = require(ReplicatedStorage.Packages.Net)

local BaseSpeed = require(ReplicatedStorage.Shared.Player.Components.BaseSpeed)
local Player = require(ReplicatedStorage.Shared.Player.Components.Player)
local Slowed = require(ServerStorage.Server.StatusEffects.Slowed.Component)
local SpeedMulti =
	require(ReplicatedStorage.Shared.Player.Components.SpeedMulti)
local WallShove = require(ReplicatedStorage.Shared.Player.Components.WallShove)

local ReplSpeedMultiRE = Net:RemoteEvent("ReplSpeedMulti")
local ReplBaseSpeedRE = Net:RemoteEvent("ReplBaseSpeed")
local ReplSlowedRE = Net:RemoteEvent("ReplSlowed")
local ReplWallShove = Net:RemoteEvent("ReplWallShove")

local function HandleReplication(factory, onAdded, onRemoved)
	factory.onAdded:Connect(function(entity, ...)
		local player = Player.get(entity)
		if not player then return end
		onAdded(player.instance, ...)
	end)

	factory.onRemoved:Connect(function(entity, ...)
		local player = Player.get(entity)
		if not player then return end
		onRemoved(player.instance, ...)
	end)
end

return Global.Schedules.Init.job(function(...: any)
	HandleReplication(SpeedMulti, function(playerInstance, speedMulti)
		ReplSpeedMultiRE:FireClient(playerInstance, speedMulti.multi)
	end, function(playerInstance)
		ReplSpeedMultiRE:FireClient(playerInstance)
	end)

	HandleReplication(BaseSpeed, function(playerInstance, baseSpeed)
		ReplBaseSpeedRE:FireClient(
			playerInstance,
			baseSpeed.speed,
			baseSpeed.sprint
		)
	end, function(playerInstance)
		ReplBaseSpeedRE:FireClient(playerInstance)
	end)

	HandleReplication(Slowed, function(playerInstance, slowed)
		ReplSlowedRE:FireClient(playerInstance, slowed.speed)
	end, function(playerInstance)
		ReplSlowedRE:FireClient(playerInstance)
	end)

	HandleReplication(WallShove, function(playerInstance, wallShove)
		ReplWallShove:FireClient(
			playerInstance,
			wallShove.acceleration,
			wallShove.radius
		)
	end, function(playerInstance)
		ReplWallShove:FireClient(playerInstance)
	end)
end)
