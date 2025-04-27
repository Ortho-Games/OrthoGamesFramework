local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local PlayerEntityTracker = require(ServerStorage.Server.Player.Modules.PlayerEntityTracker)
local PlayerStore = require(ServerStorage.Server.DataManager.Modules.PlayerStore)
local World = require(ServerStorage.Server.World)

local Profile = {}

local function GetProfile(entity, player, profileStore)
	-- Start a profile session for this player's data:

	local profile = profileStore:StartSessionAsync(`{player.UserId}`, {
		Cancel = function()
			return not player:IsDescendantOf(Players)
		end,
	})

	-- Handling new profile session or failure to start it:

	if not profile then
		player:Kick(`Profile load fail - Please rejoin`)
		return
	end

	profile:AddUserId(player.UserId) -- GDPR compliance
	profile:Reconcile() -- Fill in missing variables from PROFILE_TEMPLATE (optional)

	profile.OnSessionEnd:Connect(function(): ()
		print(
			`Profile session has ended ({profile.Key}) - Profile.Data will no longer be saved to the DataStore`
		)
	end)

	if not player:IsDescendantOf(Players) then
		profile:EndSession()
		return
	end

	-- print(`Profile loaded for {player.DisplayName}!`)
	-- -- EXAMPLE: Grant the player 100 coins for joining:
	-- profile.Data.Cash += 100
	-- -- You should set "Cash" in PROFILE_TEMPLATE and use "Profile:Reconcile()",
	-- -- otherwise you'll have to check whether "Data.Cash" is not nil

	return profile
end

function Profile:add(entity, player)
	local profileStore = PlayerStore.playerStore
	if not profileStore then
		warn("no playerstore found")
		return
	end

	return GetProfile(entity, player, profileStore)
end

function Profile:removed(entity, profile)
	-- print(profile.Data)
	if profile then profile:EndSession() end
end

return World.factory(Profile)
