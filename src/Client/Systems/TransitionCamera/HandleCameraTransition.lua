local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Promise = require(Globals.Packages.Promise)
local Tags = require(Globals.Game.Tags)

local Camera = require(Globals.Game.Components.Camera)
local CameraFollow = require(Globals.Game.Components.CameraFollow)

local transitionPromise

local Transitions = {
	None = {
		FollowCharacter = function()
			CameraFollow.add(workspace.CurrentCamera)
			Tags.Controlling.add(workspace.CurrentCamera)
		end,
	},
}

return Globals.Schedules.TransitionCamera.job(function(toState)
	local camera = Camera.get(workspace.CurrentCamera)
	if not camera then
		return
	end

	local fromState = camera.state or "None"
	if toState == fromState then
		return
	end

	local transition = Transitions[fromState] and Transitions[fromState][toState]
	if not transition then
		error(`No transition exists between states "{fromState}" and "{toState}"`)
	end

	transitionPromise = Promise.try(transition, transitionPromise):andThen(function()
		camera.state = toState
	end)
end)
