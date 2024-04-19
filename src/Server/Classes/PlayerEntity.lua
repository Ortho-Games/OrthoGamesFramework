local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)

local UserComponents = Globals.Local.Components.UserComponents
local Player = require(UserComponents.Player)
local Profile = require(UserComponents.Profile)
local Money = require(UserComponents.Money)
local Exp = require(UserComponents.EXP)
local CharacterOwned = require(UserComponents.CharacterOwned)
local CharacterAppearance = require(UserComponents.CharacterAppearance)
local Challenges = require(UserComponents.Challenges)
local Settings = require(UserComponents.Settings)

local PlayerEntityTracker = require(Globals.Local.Modules.PlayerEntityTracker)

return function(ProfileStore, player)
	print("New User", player)

	local entity = Globals.World.entity()
	local profile = Profile.add(entity, player, ProfileStore)

	-- ValueNet.GetTracker("PlayerData", player)

	Player.add(entity, player)
	Money.add(entity, profile)
	Exp.add(entity, profile)
	CharacterOwned.add(entity, profile)
	Challenges.add(entity, profile)
	CharacterAppearance.add(entity, profile)
	Settings.add(entity, Settings)

	PlayerEntityTracker.add(entity, player)

	-- ValueNet.SetPlayer(player, "PlayerData", profile.Data)

	return entity
end
