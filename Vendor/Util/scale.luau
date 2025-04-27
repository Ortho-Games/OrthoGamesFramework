return function(v: number, inMin: number, inMax: number, outMin: number, outMax: number)
	return outMin + (v - inMin) * (outMax - outMin) / (inMax - inMin)
end
