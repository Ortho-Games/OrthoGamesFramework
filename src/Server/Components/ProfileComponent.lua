local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local World = require(Globals.Shared.Modules.World)

local function LoadData(player, profileStore)
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

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local World = require(Globals.Shared.Modules.World)

local ProfileComponent = {}
ProfileComponent.LoadData = LoadData

function ProfileComponent:add(entity, player, profileStore)
	return self.LoadData(player, profileStore)
end

function ProfileComponent:remove(entity, component)
	component:Release()
end

return World.factory(ProfileComponent)
