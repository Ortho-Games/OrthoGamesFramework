return function(a: Vector3, b: Vector3)
	local vector = (a - b)

	local part = Instance.new("Part")
	part.Anchored = true
	part.Size = Vector3.new(1, 1, vector.Magnitude)
	part.CFrame = CFrame.new(b + vector / 2, a) * CFrame.new(-part.Size.X / 2, 0, 0)
	return part
end
