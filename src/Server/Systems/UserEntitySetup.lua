local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Net = require(Globals.Packages.Net)

local World = require(Globals.Shared.Modules.World)

local Schedules = require(Globals.Shared.Modules.Schedules)
local Profiles = require(Globals.Server.Modules.Profiles)

local ClicksComponent = require(Globals.Components.ClicksComponent)
local ProfileComponent = require(Globals.Components.ProfileComponent)

local PlayerProfileStore

local function newUser(player)
	assert(PlayerProfileStore, "Player Profile Didn't Load")
	local profile = ProfileComponent.add(player, PlayerProfileStore)
	local componentData = ClicksComponent.add(player, profile)
end

return Schedules.boot.job(function()
	PlayerProfileStore = Profiles.createProfileTemplate()

	Players.PlayerAdded:Connect(Schedules.userAdded.start)
	for _, player in Players:GetPlayers() do
		newUser(player)
	end
end)
