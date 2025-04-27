return function(model: Instance, enabled: boolean)
	if model:IsA("BasePart") then model.CanCollide = enabled end
	for _, desc in model:GetDescendants() do
		if desc:IsA("BasePart") then desc.CanCollide = enabled end
	end
end
