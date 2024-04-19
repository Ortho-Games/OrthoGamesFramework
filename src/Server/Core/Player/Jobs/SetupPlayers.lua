local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Janitor = require(Globals.Packages.Janitor)

local ActionData = require(Globals.Local.Core.Actions.Components.ActionData)
local Character = require(Globals.Local.Core.Player.Components.Character)

local CharacterEntityTracker =
	require(Globals.Shared.Modules.CharacterEntityTracker)

local PlayerComponentFactory =
	require(Globals.Local.Core.Player.Components.Player)
local PlayerEntity = require(Globals.Local.Classes.PlayerEntity)

local function ListenForPlayerLifecycle()
	PlayerComponentFactory.onAdded:Connect(function(entity, player)
		local addedPartial = function(character)
			Character.add(entity, character)
		end

		player.CharacterAdded:Connect(addedPartial)
		if player.Character then addedPartial(player.Character) end

		player.CharacterRemoving:Connect(function()
			Character.remove(entity)
		end)
	end)

	PlayerComponentFactory.onRemoved:Connect(function(entity)
		Globals.World.kill(entity)
	end)

	Character.onAdded:Connect(function(entity, comp)
		CharacterEntityTracker.add(entity, comp)
		ActionData.add(entity)
	end)

	Character.onRemoved:Connect(function(entity)
		ActionData.remove(entity)
	end)
end

local function ListenForPlayerAdded()
	for _, player in Players:GetPlayers() do
		PlayerEntity(player)
	end
	Players.PlayerAdded:Connect(PlayerEntity)
end

local function SetupPlayers()
	ListenForPlayerLifecycle()
	ListenForPlayerAdded()
end

return Globals.Schedules.boot.job(SetupPlayers)
