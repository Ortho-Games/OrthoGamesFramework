local TweenService = game:GetService("TweenService")
return function(model: Model, tweenInfo: TweenInfo, goal)
	local cf = Instance.new("CFrameValue")
	cf.Value = model:GetPivot()
	cf.Changed:Connect(function()
		model:PivotTo(cf.Value)
	end)

	goal.Value = goal.CFrame
	goal.CFrame = nil
	return TweenService:Create(cf, tweenInfo, goal)
end
