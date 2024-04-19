local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)

local Player = require(Globals.Local.Core.Player.Components.Player)

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
		-- print(profile.Data)
		profile = nil
		player:Kick()
	end)

	if not player:IsDescendantOf(Players) then
		profile:Release()
		return
	end

	return profile
end

local Component = {}

function Component:add(entity, player, profileStore)
	local profile = LoadData(player, profileStore)
	return profile
end

function Component:removed(entity, component)
	local player = Player.get(entity)

	component:Release()
	player:Kick()
end

return Globals.World.factory(Component)
