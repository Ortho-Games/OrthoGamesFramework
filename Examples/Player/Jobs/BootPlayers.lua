local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Shared.Global)

local PlayerEntityTracker =
	require(ReplicatedStorage.Shared.Player.Modules.PlayerEntityTracker)

local Character = require(ReplicatedStorage.Shared.Player.Components.Character)
local Player = require(ReplicatedStorage.Shared.Player.Components.Player)

local function ListenCharacterAdded(entity, playerInstance)
	local addedPartial = function(character)
		Character.add(entity, character)
	end

	playerInstance.CharacterAdded:Connect(addedPartial)
	if playerInstance.Character then addedPartial(playerInstance.Character) end
	playerInstance.CharacterRemoving:Connect(function()
		Character.remove(entity)
	end)
end

local function InitPlayer(playerInstance)
	local playerEntity = Global.World.entity()
	Player.add(playerEntity, playerInstance)
	ListenCharacterAdded(playerEntity, playerInstance)
end

local function ListenPlayerAdded()
	-- Global.DEBUG("SetupPlayers Booted!")

	Players.PlayerAdded:Connect(InitPlayer)
	Players.PlayerRemoving:Connect(function(playerInstance)
		local playerEntity = PlayerEntityTracker.get(playerInstance)
		if playerEntity then Player.remove(playerEntity) end
	end)

	for _, playerInstance in Players:GetPlayers() do
		InitPlayer(playerInstance)
	end
end

return Global.Schedules.Boot.job(ListenPlayerAdded)
