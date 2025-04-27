return function(size, center)
	local parts = {}

	for i = 1, 6 do
		local vectorTable = { 1, 0, 0, 0 }

		for _ = 1, i - 1 do
			local vectorTable2 = { 0, 0, 0 }

			for i2 = 1, 3 do
				vectorTable2[i2] = math.max(vectorTable2[i2] * 2 - 1, -vectorTable[i2])

				vectorTable2[i2 + 1] = math.max(0, -vectorTable[i2])
			end

			vectorTable = vectorTable2
		end

		for i2 = 1, 3 do
			vectorTable[i2] = math.abs(vectorTable[i2] - vectorTable[i2 + 1]) * vectorTable[i2]
		end

		local sizeVectorTable = {}

		for i2 = 1, 3 do
			sizeVectorTable[i2] = 1 - math.abs(vectorTable[i2])
		end

		local part = Instance.new("Part")
		part.Name = "Part" .. i
		part.Anchored = true
		part.CFrame = center + Vector3.new(unpack(vectorTable)) * size / 2
		part.Size = size * Vector3.new(unpack(sizeVectorTable))
		part.Parent = workspace
		table.insert(parts, part)
	end

	return parts
end
