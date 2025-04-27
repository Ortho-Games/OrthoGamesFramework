return function(animator, animationId)
	for _, track in animator:GetPlayingAnimationTracks() do
		if track.Animation.AnimationId == animationId then return track end
	end
	return nil
end
