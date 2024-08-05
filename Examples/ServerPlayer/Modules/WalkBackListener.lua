--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ActionSet = require(ReplicatedStorage.Shared.Player.Components.ActionSet)
local Character = require(ReplicatedStorage.Shared.Player.Components.Character)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Player = require(ReplicatedStorage.Shared.Player.Components.Player)
local PlayingAction =
	require(ReplicatedStorage.Shared.Player.Components.PlayingAction)

return function(
	entity: number,
	janitor: Janitor.Janitor,
	walkBackAnimation: Animation
)
	local playerComponent: Player.PlayerComponent = Player.get(entity)

	local characterComponent: Character.CharacterComponent =
		Character.get(entity)
	local character = characterComponent.instance

	local humanoid = character:FindFirstChildOfClass("Humanoid") :: Humanoid
	local animator = humanoid:FindFirstChildOfClass("Animator") :: Animator
	local humanoidRootPart =
		character:FindFirstChild("HumanoidRootPart") :: Part

	local walkingBackwardsTrack: AnimationTrack =
		janitor:Add(animator:LoadAnimation(walkBackAnimation), "Stop")

	janitor:Add(
		humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
			local newMoveDirection = humanoid.MoveDirection

			if PlayingAction.get(entity) then return end

			local dir =
				humanoidRootPart.CFrame:VectorToObjectSpace(newMoveDirection)

			if dir.Z > 0 and not walkingBackwardsTrack.IsPlaying then
				walkingBackwardsTrack:Play()
			elseif dir.Z <= 0 and walkingBackwardsTrack.IsPlaying then
				walkingBackwardsTrack:Stop()
			end
		end),
		"Disconnect"
	)

	janitor:Add(PlayingAction.onAdded:Connect(function(entityId, _comp)
		if entityId ~= entity then return end
		walkingBackwardsTrack:Stop()
	end))

	janitor:Add(
		playerComponent.instance
			:GetAttributeChangedSignal("CurrentActionSet")
			:Connect(function()
				janitor:Destroy() -- the new action set will have its own listener
			end),
		"Disconnect"
	)
end
