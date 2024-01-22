local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)

local CharacterAnimations = {}

function CharacterAnimations:add()
	local component = {}

	export type CharacterAnimations = typeof(component)

	return component
end

return Globals.World.factory(CharacterAnimations)
