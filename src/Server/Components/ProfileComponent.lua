--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Globals = require(ReplicatedStorage.Shared.Globals)
local World = require(Globals.Shared.Modules.World)

local function LoadData(player: Player, profileStore: {}): {}
	assert(player, "No player given.")
	assert(profileStore, "No profilestore given.")

	if RunService:IsStudio() and player.Name == "Player1" then
		profileStore = profileStore.Mock
	end

	if not profileStore then
		warn("Tried to load data before ProfileTemplate was finished loading.")
		return
	end
	local profile = profileStore:LoadProfileAsync(`Player_{player.UserId}`)

	if not profile then
		player:Kick()
		return
	end

	profile:AddUserId(player.UserId)
	profile:Reconcile()
	profile:ListenToRelease(function()
		print(profile.Data)
		profile = nil
		player:Kick()
	end)

	if not player:IsDescendantOf(Players) then
		profile:Release()
		return
	end

	return profile
end

local ProfileComponent = {}
ProfileComponent.LoadData = LoadData

function ProfileComponent:add(entity: any, player: Player, profileStore: {}): {}
	return self.LoadData(player, profileStore)
end
export type Type = typeof(ProfileComponent.add(...))

function ProfileComponent:removed(entity: any, component: Type)
	component:Release()
end

return World.factory(ProfileComponent)
