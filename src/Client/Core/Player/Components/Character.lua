local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)

local Character = {}

function Character:add(entity, character)
	-- insert constructor for component here
	print("character component added")

	local humanoid = character.Humanoid
	humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)

	return character
end

return Globals.World.factory(Character)
