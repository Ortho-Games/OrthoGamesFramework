local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)

local Schedules = require(Globals.Shared.Modules.Schedules)
local Profiles = require(Globals.Server.Modules.Profiles)

local ClicksComponent = require(Globals.Components.ClicksComponent)
local ProfileComponent = require(Globals.Components.ProfileComponent)
local MoneyComponent = require(Globals.Components.MoneyComponent)

local PlayerProfileStore

local function newUser(player)
	assert(PlayerProfileStore, "Player Profile Didn't Load")
	local profile = ProfileComponent.add(player, PlayerProfileStore)
	ClicksComponent.add(player, profile)
	MoneyComponent.add(player, profile)

	-- replicate?
end

local function onBoot()
	PlayerProfileStore = Profiles.createProfileTemplate()

	Players.PlayerAdded:Connect(Schedules.userAdded.start)
	for _, player in Players:GetPlayers() do
		newUser(player)
	end
end

return {
	boot = Schedules.boot.job(onBoot),
}
