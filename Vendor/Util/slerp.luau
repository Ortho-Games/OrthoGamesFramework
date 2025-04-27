return function(angle1, angle2, t)
	local theta = angle2 - angle1
	angle1 += if theta > math.pi then 2 * math.pi elseif theta < -math.pi then -2 * math.pi else 0
	return angle1 + (angle2 - angle1) * t
end
