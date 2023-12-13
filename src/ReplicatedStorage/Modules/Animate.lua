local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Packages.Promise)
local Janitor = require(ReplicatedStorage.Packages.Janitor)

local Data = {}

local Animate = {}

function Animate.LoadAnimation(animator, animationName, animation)
	local data = Animate.GetData(animator)
	local tracks = data.Tracks

	if tracks[animation.Name] then
		warn('Animation is already loaded with name "' .. animationName .. '"')
		return
	end

	local promise = Promise.try(function()
		return animator:LoadAnimation(animation)
	end)
		:andThen(function(animTrack)
			repeat
				task.wait()
			until animTrack.Length > 0

			return animTrack
		end)
		:andThen(function(animTrack)
			tracks[animationName] = animTrack
			return animTrack
		end)
		:catch(warn)

	return data.Janitor:AddPromise(promise)
end

function Animate.LoadAnimations(animator, animations)
	local loadAnims = {}
	for animationName, animation in animations do
		local loadAnimationPromise = Animate.LoadAnimation(animator, animationName, animation)
		table.insert(loadAnims, loadAnimationPromise)
	end

	return Promise.all(loadAnims)
end

function Animate.PlayAnimation(animator, animationName, weightFadeTime, weight, speed, priority)
	local track = Animate.GetAnimationTrack(animator, animationName)
	if not track then
		return warn(`No animation exists with name "{animationName}"`)
	end
	if priority then
		track.Priority = priority
	end
	track:Play(weightFadeTime, weight, speed)
	return track
end

function Animate.StopAnimation(animator, animationName, weightFadeTime)
	local track = Animate.GetAnimationTrack(animator, animationName)
	if not track then
		return
	end
	track:Stop(weightFadeTime)
end

function Animate.StopAnimations(animator, animationNames, weightFadeTime)
	for _, animationName in ipairs(animationNames) do
		Animate.StopAnimation(animator, animationName, weightFadeTime)
	end
end

function Animate.StopAllAnimations(animator, weightFadeTime)
	for _, track in animator:GetPlayingAnimationTracks() do
		track:Stop(weightFadeTime)
	end
end

function Animate.AdjustAnimationWeight(animator, animationName, weight, weightFadeTime)
	local track = Animate.GetAnimationTrack(animator, animationName)
	if not track then
		return
	end
	track:AdjustWeight(weight, weightFadeTime)
end

function Animate.AdjustAnimationSpeed(animator, animationName, speed)
	local track = Animate.GetAnimationTrack(animator, animationName)
	if not track then
		return
	end
	track:AdjustSpeed(speed)
end

function Animate.SetAnimationPriority(animator, animationName, priority)
	local track = Animate.GetAnimationTrack(animator, animationName)
	if not track then
		return
	end
	track.Priority = priority
end

function Animate.GetAnimationTrack(animator, animationName)
	return Animate.GetData(animator).Tracks[animationName]
end

function Animate.GetData(animator)
	local data = Data[animator]
	return data or error(`Animator {animator} has not been registered`)
end

function Animate.Register(animator)
	Data[animator] = {
		Tracks = {},
		Janitor = Janitor.new(),
	}
end

function Animate.Deregister(animator)
	local data = Data[animator]
	if not data then
		return
	end

	data.Janitor:Destroy()
	Data[animator] = nil
end

return Animate
