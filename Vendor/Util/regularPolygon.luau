local makePartBetween = require(script.Parent.makePartBetween)
return function(n: number, radius: number, height: number)
	local rotationAngle = math.rad(360 / n)
	local center = CFrame.new() * CFrame.Angles(0, rotationAngle / 2, 0)

	local model = Instance.new("Model")
	for i = 1, n do
		local a = (center * CFrame.new(0, n, radius)).Position
		center *= CFrame.Angles(0, rotationAngle, 0)
		local b = (center * CFrame.new(0, n, radius)).Position
		local part = makePartBetween(a, b)
		part.Size += Vector3.yAxis * height
		part.Parent = model
	end
	return model
end
