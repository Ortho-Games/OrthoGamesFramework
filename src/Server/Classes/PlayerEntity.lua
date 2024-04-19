local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)

local Clicks = require(Globals.Local.Core.Clicks.Components.Clicks)
local Player = require(Globals.Local.Core.Player.Components.Player)
local Profile = require(Globals.Local.Core.Player.Components.Profile)

local PlayerEntityTracker = require(Globals.Local.Modules.PlayerEntityTracker)

return function(ProfileStore, player)
	print("New User", player)

	local entity = Globals.World.entity()
	local profile = Profile.add(entity, player, ProfileStore)

	Player.add(entity, player)
	Clicks.add(entity, profile)

	PlayerEntityTracker.add(entity, player)

	return entity
end
