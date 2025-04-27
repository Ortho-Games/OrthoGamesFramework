local weldBetween = require(script.Parent.weldBetween)
return function(model: Model)
	if not model.PrimaryPart then return end

	for _, desc in model:GetDescendants() do
		if desc:IsA("BasePart") and desc ~= model.PrimaryPart then
			weldBetween(desc, model.PrimaryPart)
		end
	end
end
