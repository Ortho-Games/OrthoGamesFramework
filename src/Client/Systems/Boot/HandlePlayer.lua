local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Promise = require(Globals.Packages.Promise)

local Tags = require(Globals.Game.Tags)

local Player = require(Globals.Game.Components.Player)
local Character = require(Globals.Game.Components.Character)
local CharacterControls = require(Globals.Game.Components.CharacterControls)
local CharacterInput = require(Globals.Game.Components.CharacterInput)

local LocalPlayer = Players.LocalPlayer

local GlobalPlaneAttachment = workspace.Terrain:WaitForChild("GlobalPlane")

local function onCharacterRemoving(character)
	CharacterControls.remove(character)
	Character.remove(character)
end

local function onCharacterAdded(character)
	local humanoid = character:WaitForChild("Humanoid")
	local root = character:WaitForChild("HumanoidRootPart")
	local rootAttachment = root:WaitForChild("RootAttachment")
	Character.add(character, humanoid, root, rootAttachment)

	if character == LocalPlayer.Character then
		humanoid.EvaluateStateMachine = false
		CharacterControls.add(character, root, rootAttachment, GlobalPlaneAttachment)
		CharacterInput.add(character)
		Tags.Controlling.add(character)
		Globals.Schedules.TransitionCamera.start("FollowCharacter")
	end
end

local function onPlayerRemoving(player)
	if player.Character then
		onCharacterRemoving(player.Character)
	end
	Player.remove(player)
end

local function onPlayerAdded(player)
	local playerComponent = Player.add(player)

	playerComponent.janitor:Add(player.CharacterAdded:Connect(function(character)
		playerComponent.characterAddedPromise = Promise.try(onCharacterAdded, character)
		playerComponent.janitor:AddPromise(playerComponent.characterAddedPromise)
	end, "Disconnect"))

	playerComponent.janitor:Add(player.CharacterRemoving:Connect(function(character)
		if playerComponent.characterAddedPromise and playerComponent.characterAddedPromise.Status == "Started" then
			playerComponent.characterAddedPromise:cancel()
		end
		onCharacterRemoving(character)
	end, "Disconnect"))

	if player.Character and player.Character.Parent then
		onCharacterAdded(player.Character)
	end
end

return Globals.Schedules.Boot.job(function()
	Players.PlayerRemoving:Connect(onPlayerRemoving)
	Players.PlayerAdded:Connect(onPlayerAdded)

	for _, player in Players:GetPlayers() do
		onPlayerAdded(player)
	end

	RunService.PreSimulation:Connect(function(dt)
		Globals.Schedules.UpdateCharacter.start(dt)
	end)
end)
