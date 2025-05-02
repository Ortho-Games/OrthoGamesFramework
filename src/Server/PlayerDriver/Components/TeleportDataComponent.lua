local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ServerStorage = game:GetService("ServerStorage")

local PlayerComponentRegistry =
	require(ServerScriptService.Server.PlayerDriver.Interface.PlayerComponentRegistry)
local World = require(ReplicatedStorage.Shared.Modules.World)

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
