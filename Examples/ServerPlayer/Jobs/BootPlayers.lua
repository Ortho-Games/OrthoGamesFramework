local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Global = require(ReplicatedStorage.Shared.Global)

local Cooldowns = require(ReplicatedStorage.Shared.Player.Components.Cooldowns)
local Finisher = require(ServerStorage.Server.Player.Components.Finisher)
local Profile = require(ServerStorage.Server.Player.Components.Profile)

local Profiles = require(ServerStorage.Server.Player.Modules.Profiles)

local Player = require(ReplicatedStorage.Shared.Player.Components.Player)

local profileStore

local function SetupPlayer(entity, player)
	Finisher.add(entity)
	Cooldowns.add(entity, player.instance)

	player.instance:SetAttribute("CurrentFighter", "Kashimo")
	player.instance:SetAttribute("CurrentActionSet", "Default")

	Profile.add(entity, player.instance, profileStore)
end

return Global.Schedules.Init.job(function(...: any)
	profileStore = Profiles.getProfileStore(Profiles.defaultPlayerStore)

	Player.onAdded:Connect(SetupPlayer)
end)
