local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)

local Tags = require(Globals.Game.Tags)
local CharacterConfig = require(Globals.Shared.Config.Character)

local CharacterInput = require(Globals.Game.Components.CharacterInput)

local ControlledCharacters = Globals.World.query({ CharacterInput, Tags.Controlling })

local function controlCharacterInput(characterInput: CharacterInput.CharacterInput, dt)
	local t = os.clock()
	local moveVector = characterInput.controls:GetMoveVector()
	local jumpPressing = -moveVector.Z > 0.01

	if characterInput.jumpBuffered and t - characterInput.jumpBuffered > CharacterConfig.JumpBuffer then
		characterInput.jumpBuffered = false
	elseif
		t > characterInput.jumpCooldown
		and not characterInput.jumpBuffered
		and jumpPressing
		and not characterInput.jumpPressing
	then
		characterInput.jumpBuffered = t
	end

	characterInput.jumpPressing = jumpPressing
	characterInput.movingDirection = moveVector.X
end

return Globals.Schedules.UpdateCharacter.job(function(dt)
	for _, components in ControlledCharacters do
		controlCharacterInput(components[CharacterInput], dt)
	end
end)
