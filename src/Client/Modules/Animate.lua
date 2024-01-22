local Tracks = {}

local Animate = {}

local function withTrack(func)
	return function(animator, animationName, ...)
		local track = assert(
			Animate.getAnimationTrack(animator, animationName),
			`Animator {animator:GetFullName()} has no animation loaded with name "{animationName}"`
		)
		return func(track, ...)
	end
end

local function deregisterAnimator(animator)
	Tracks[animator] = nil
end

local function registerAnimator(animator)
	animator.Destroying:Once(function()
		deregisterAnimator(animator)
	end)

	Tracks[animator] = {}
	return Tracks[animator]
end

function Animate.stopAnimations(animator, animationNames, weightFadeTime)
	for _, animationName in ipairs(animationNames) do
		Animate.stopAnimation(animator, animationName, weightFadeTime)
	end
end

function Animate.stopAllAnimations(animator, weightFadeTime)
	for _, track in animator:GetPlayingAnimationTracks() do
		track:Stop(weightFadeTime)
	end
end

function Animate.getAnimationTrack(animator, animationName)
	return Tracks[animator] and Tracks[animator][animationName]
end

Animate.playAnimation = withTrack(function(track, weightFadeTime, weight, speed, priority)
	track:Play(weightFadeTime, weight, speed)
	if priority then
		track.Priority = priority
	end
	return track
end)

Animate.stopAnimation = withTrack(function(track, weightFadeTime)
	track:Stop(weightFadeTime)
end)

Animate.adjustAnimationWeight = withTrack(function(track, weight, weightFadeTime)
	track:AdjustWeight(weight, weightFadeTime)
end)

Animate.adjustAnimationSpeed = withTrack(function(track, speed)
	track:AdjustSpeed(speed)
end)

Animate.setAnimationPriority = withTrack(function(track, priority)
	track.Priority = priority
end)

function Animate.loadAnimation(animator, animation, animationName)
	animationName = animationName or animation.Name

	local tracks = Animate.getAnimationTracks(animator) or registerAnimator(animator)
	assert(
		tracks[animationName] == nil,
		'Animator {animator:GetFullName()} already has an animation loaded with name "{animationName}"'
	)

	local track = animator:LoadAnimation(animation)
	tracks[animationName] = track
	return track
end

function Animate.loadAnimations(animator, animations)
	for animationNameOrIndex, animation in animations do
		Animate.loadAnimation(
			animator,
			animation,
			if type(animationNameOrIndex) == "string" then animationNameOrIndex else nil
		)
	end
	return Tracks[animator]
end

return Animate
