local CollectionService = game:GetService("CollectionService")
return function(tag: string, position: Vector3, radius: number): { PVInstance }
	local taggedInstances = {}

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.CollisionGroup = ""
	overlapParams.FilterDescendantsInstances = CollectionService:GetTagged(tag)

	local partsInRadius = workspace:GetPartBoundsInRadius(position, radius, overlapParams)

	for _, part in partsInRadius do
		local taggedInstance = part
		while taggedInstance and not CollectionService:HasTag(taggedInstance, tag) do
			taggedInstance = taggedInstance.Parent
		end

		if taggedInstance and not table.find(taggedInstances, taggedInstance) then
			table.insert(taggedInstances, taggedInstance)
		end
	end

	return taggedInstances
end
