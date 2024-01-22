local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)

local Controls = require(game.Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()

local CharacterInput = {}

function CharacterInput:add()
	return {
		controls = Controls,
		movingDirection = 0,
		jumpBuffered = false,
		jumpCooldown = os.clock(),
	}
end

export type CharacterInput = typeof(CharacterInput:add(...))

return Globals.World.factory(CharacterInput)
