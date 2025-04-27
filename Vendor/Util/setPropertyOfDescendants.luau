return function(instance: Instance, propName: string, propValue: any)
	for _, descendant in instance:GetDescendants() do
		pcall(function()
			if descendant[propName] then descendant[propName] = propValue end
		end)
	end
end
