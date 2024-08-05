local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Global = require(ReplicatedStorage.Shared.Global)

local Character = require(ReplicatedStorage.Shared.Player.Components.Character)

local function setCollisionGroup(descendant)
	if descendant:IsA("BasePart") then
		descendant.CollisionGroup = "Character"
	end
end

local function onCharacterAdded(_, character)
	character.instance.DescendantAdded:Connect(setCollisionGroup)
	for _, descendant in character.instance:GetDescendants() do
		setCollisionGroup(descendant)
	end

	local humanoid = character.instance.Humanoid
	humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	humanoid.BreakJointsOnDeath = false
	humanoid.RequiresNeck = false
end

local function SetupCharacters()
	for entity, comps in Global.World.query { Character } do
		onCharacterAdded(entity, comps[Character])
	end
	Character.onAdded:Connect(onCharacterAdded)
end

return Global.Schedules.Init.job(SetupCharacters)
