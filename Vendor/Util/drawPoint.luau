return function(position: Vector3, size: number, color: Color3)
	local part = Instance.new("Part")
	part.Anchored = true
	part.Size = Vector3.new(size, size, size)
	part.Position = position
	part.Shape = Enum.PartType.Ball
	part.Color = color
	part.Parent = workspace
end
