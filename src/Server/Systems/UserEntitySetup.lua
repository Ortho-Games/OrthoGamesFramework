local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)

local Schedules = require(Globals.Shared.Modules.Schedules)
local Profiles = require(Globals.Local.Modules.Profiles)
local Janitor = require(Globals.Packages.Janitor)

local PlayerComponent = require(Globals.Local.Components.PlayerComponent)
local ProfileComponent = require(Globals.Local.Components.ProfileComponent)
local MoneyComponent = require(Globals.Local.Components.MoneyComponent)

local World = require(ReplicatedStorage.Shared.Modules.World)

local UserEntitySetup = {}
UserEntitySetup.jan = Janitor.new()
UserEntitySetup.PlayerProfileStore = nil

function UserEntitySetup.replicateEntityComponents(player)
	for entity, components in World.query({}) do
		for factory, component in components do
			if factory.addedSignal then
				factory.addedSignal:Fire(entity, component, player)
			end
		end
	end
end

function UserEntitySetup.newUser(player: Player)
	-- here?
	-- before the user entity can be added we must first send ALL entities to the player.
	assert(player, "No player given.")

	UserEntitySetup.replicateEntityComponents(player)

	assert(UserEntitySetup.PlayerProfileStore, "Player Profile Didn't Load")

	local entity = World.entity()
	PlayerComponent.add(entity, player)
	local profile = ProfileComponent.add(entity, player, UserEntitySetup.PlayerProfileStore)
	MoneyComponent.add(entity, profile)

	-- replicate?
	return entity
end

function UserEntitySetup.onBoot()
	UserEntitySetup.PlayerProfileStore = Profiles.createProfileTemplate()

	UserEntitySetup.jan:Add(Players.PlayerAdded:Connect(UserEntitySetup.newUser), "Disconnect", "PlayerAdded")
	for _, player in Players:GetPlayers() do
		UserEntitySetup.newUser(player)
	end
end

UserEntitySetup.boot = Schedules.boot.job(UserEntitySetup.onBoot)

return UserEntitySetup
