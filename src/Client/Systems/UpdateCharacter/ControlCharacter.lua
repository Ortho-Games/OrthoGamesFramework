local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)

local CharacterConfig = require(Globals.Shared.Config.Character)

local Tags = require(Globals.Game.Tags)

local Character = require(Globals.Game.Components.Character)
local CharacterInput = require(Globals.Game.Components.CharacterInput)
local CharacterControls = require(Globals.Game.Components.CharacterControls)

local ControlledCharacters = Globals.World.query({ Character, CharacterControls, CharacterInput, Tags.Controlling })

local function jump(character, characterInput)
	characterInput.jumpCooldown = os.clock() + CharacterConfig.JumpCooldown
	characterInput.jumpBuffered = false

	local jumpSpeed = math.sqrt(2 * workspace.Gravity * CharacterConfig.JumpHeight)
	local velocity = character.root.AssemblyLinearVelocity
	character.root.AssemblyLinearVelocity = Vector3.new(velocity.X, jumpSpeed, velocity.Z)
end

local function controlCharacterMovement(components, dt)
	local character: Character.Character = components[Character]
	local characterInput: CharacterInput.CharacterInput = components[CharacterInput]
	local characterControls: CharacterControls.CharacterControls = components[CharacterControls]

	local wasGrounded = characterControls.controllerManager.ActiveController == characterControls.groundController
	local isGrounded = characterControls.groundSensor.SensedPart ~= nil

	if not wasGrounded and isGrounded then
		characterControls.controllerManager.ActiveController = characterControls.groundController
	elseif wasGrounded and not isGrounded then
		characterControls.controllerManager.ActiveController = characterControls.airController
	end
	characterControls.controllerManager.MovingDirection = Vector3.xAxis * characterInput.movingDirection
	characterControls.controllerManager.FacingDirection = characterControls.controllerManager.MovingDirection

	if isGrounded and characterInput.jumpBuffered then
		jump(character, characterInput)
	end
end

return Globals.Schedules.UpdateCharacter.job(function(dt)
	for _, components in ControlledCharacters do
		controlCharacterMovement(components, dt)
	end
end)
