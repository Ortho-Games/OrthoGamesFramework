local TweenService = game:GetService("TweenService")
return function(character: Model)
	for _, desc in character:GetDescendants() do
		if
			(desc:IsA("BasePart") or desc:IsA("Decal"))
			and desc:GetAttribute("OriginalTransparency")
		then
			TweenService:Create(
				desc,
				TweenInfo.new(0.5),
				{ Transparency = desc:GetAttribute("OriginalTransparency") }
			):Play()
			desc:SetAttribute("OriginalTransparency", nil)
		end
	end
end
