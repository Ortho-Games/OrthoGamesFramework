local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Global = require(ReplicatedStorage.Shared.Global)

local Player = require(ReplicatedStorage.Shared.Player.Components.Player)

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
	local playerInstance = Player.get(entity).instance

	component:Release()
	playerInstance:Kick()
end

return Global.World.factory(Global.InjectLifecycleSignals(Component))
