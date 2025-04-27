return function(v: number, inMin: number, inMax: number, outMin: number, outMax: number): number
	return math.clamp(outMin + (v - inMin) * (outMax - outMin) / (inMax - inMin), outMin, outMax)
end
