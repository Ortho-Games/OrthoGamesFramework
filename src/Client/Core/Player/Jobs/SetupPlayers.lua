local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Janitor = require(Globals.Packages.Janitor)

local Character = require(Globals.Local.Components.Character)

local PlayerComponentFactory = require(Globals.Local.Components.Player)
local PlayerEntity = require(Globals.Local.Classes.PlayerEntity)

local REQUIRED_CHARACTER_DESCENDANTS = {
	"Humanoid",
	"HumanoidRootPart",
	"Head",
}

local function isLoaded(model, REQUIRED_DESCENDANTS)
	for _, bodyPart in REQUIRED_DESCENDANTS do
		if not model:FindFirstChild(bodyPart, true) then return false end
	end

	return true
end

local function onCharacterAdded(characterModel, playerEntity, playerInstance)
	local janitor = Janitor.new()

	janitor:Add(
		characterModel.DescendantAdded:Connect(function()
			if not isLoaded(characterModel, REQUIRED_CHARACTER_DESCENDANTS) then
				return
			end

			Character.add(playerEntity, characterModel)
			janitor:Destroy()
		end),
		"Disconnect"
	)

	janitor:Add(playerInstance.CharacterRemoving:Once(function()
		janitor:Destroy()
	end))
end

local function ListenForPlayerLifecycle()
	PlayerComponentFactory.onAdded:Connect(function(entity, player)
		print("Player factory added")
		local function addedPartial(characterModel)
			onCharacterAdded(characterModel, entity, player)
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
end

local function ListenForPlayerAdded()
	for _, player in Players:GetPlayers() do
		PlayerEntity(player)
	end

	Players.PlayerAdded:Connect(PlayerEntity)
end

local function SetupPlayers()
	Globals.DEBUG("SetupPlayers Booted!")
	ListenForPlayerLifecycle()
	ListenForPlayerAdded()
end

return Globals.Schedules.boot.job(
	SetupPlayers,
	require(Globals.Local.Core.Actions.Jobs.UpdateActionSet)
)
