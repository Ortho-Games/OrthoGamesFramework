local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local InjectLifecycleSignals = require(ReplicatedStorage.Shared.Modules.InjectLifecycleSignals)
local PlayerComponentRegistry =
	require(ServerStorage.Server.Player.Interface.PlayerComponentRegistry)
local PlayerEntityTracker = require(ServerStorage.Server.Player.Modules.PlayerEntityTracker)
local World = require(ServerStorage.Server.World)

local TeleportDataComponent = {}
type PlayerJoinData = {
	SourceGameId: number,
	SourcePlaceId: number,
	ReferredByPlayerId: number,
	Members: { number },
	TeleportData: any,
	LaunchData: string,
	GameJoinContext: {
		JoinSource: Enum.JoinSource,
		ItemType: Enum.AvatarItemType?,
		AssetId: string?,
		OutfitId: string?,
		AssetType: Enum.AssetType?,
	},
}

function TeleportDataComponent:add(entity, player: Player): PlayerJoinData
	return player:GetJoinData() :: PlayerJoinData
end

return PlayerComponentRegistry.register(World.factory(TeleportDataComponent))
