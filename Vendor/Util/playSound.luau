return function(sound: Sound, parent: Instance)
	local newSound = sound:Clone()
	newSound.Ended:Once(function(_a0: string)
		if newSound then newSound:Destroy() end
	end)
	newSound.Stopped:connect(function()
		if newSound then newSound:Destroy() end
	end)
	newSound.Parent = parent

	newSound:Play()
	return newSound
end
