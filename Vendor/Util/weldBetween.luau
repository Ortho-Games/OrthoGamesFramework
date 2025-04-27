return function(a: BasePart, b: BasePart, inPlace: boolean?)
	local weld = Instance.new("Weld")
	weld.Part0 = a
	weld.Part1 = b
	weld.C0 = if inPlace then CFrame.new() else a.CFrame:ToObjectSpace(b.CFrame)
	weld.Parent = a
	return weld
end
