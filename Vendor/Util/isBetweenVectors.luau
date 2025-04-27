return function(origin, a, b, target)
	local StartOriginVector = a - origin
	local PositionOriginVector = target - origin
	local EndOriginVector = b - origin

	local Dot1 = StartOriginVector:Cross(PositionOriginVector).Y
		* StartOriginVector:Cross(EndOriginVector).Y
	local Dot2 = EndOriginVector:Cross(PositionOriginVector).Y
		* EndOriginVector:Cross(StartOriginVector).Y

	return Dot1 >= 0 and Dot2 >= 0
end
