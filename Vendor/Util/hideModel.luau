local TweenService = game:GetService("TweenService")
return function(character: Model)
	for _, desc in character:GetDescendants() do
		if (desc:IsA("BasePart") or desc:IsA("Decal")) and desc.Transparency ~= 1 then
			desc:SetAttribute("OriginalTransparency", desc.Transparency)
			TweenService:Create(desc, TweenInfo.new(0.5), { Transparency = 1 }):Play()
		end
	end
end
