return function(ns: NumberSequence, t: number): number
	if t <= 0 then return ns.Keypoints[1].Value end
	if t >= 1 then return ns.Keypoints[#ns.Keypoints].Value end
	for i = 1, #ns.Keypoints - 1 do
		local this = ns.Keypoints[i]
		local next = ns.Keypoints[i + 1]
		if t >= this.Time and t < next.Time then
			local alpha = (t - this.Time) / (next.Time - this.Time)
			return (next.Value - this.Value) * alpha + this.Value
		end
	end

	return 1
end
