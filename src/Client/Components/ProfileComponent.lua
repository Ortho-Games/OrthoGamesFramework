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

return World.factory({
	add = function(factory, entity, profileStore)
		if not (typeof(entity) == "Instance" and entity:IsA("Player")) then
			warn("Added ProfileComponent to non-player entity...")
			return
		end

		local profile = factory.data.LoadData(entity, profileStore)

		return profile
	end,

	remove = function(factory, entity, component)
		component:Release()
		entity:Kick()
	end,

	data = {
		LoadData = LoadData,
	},
})
