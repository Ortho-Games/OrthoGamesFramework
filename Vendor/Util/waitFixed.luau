local waitLimit = 0.1

return function(duration: number, startTime: number)
	local waitTime = startTime + duration - os.clock()
	if waitTime > waitLimit then task.wait(waitTime) end
end
