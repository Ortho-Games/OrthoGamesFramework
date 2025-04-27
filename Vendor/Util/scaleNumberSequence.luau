return function(numberSequence: NumberSequence, scaleFactor: number): NumberSequence
	local newKeyPoints = {}

	for _, keyPoint in numberSequence.Keypoints do
		table.insert(
			newKeyPoints,
			NumberSequenceKeypoint.new(
				keyPoint.Time,
				keyPoint.Value * scaleFactor,
				keyPoint.Envelope * scaleFactor
			)
		)
	end

	return NumberSequence.new(newKeyPoints)
end
