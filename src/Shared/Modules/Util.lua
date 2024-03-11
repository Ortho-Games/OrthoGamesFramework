local RNG = Random.new()

local Util = {}

function Util.slerp(angle1, angle2, t)
	local theta = angle2 - angle1
	angle1 += if theta > math.pi then 2 * math.pi elseif theta < -math.pi then -2 * math.pi else 0
	return angle1 + (angle2 - angle1) * t
end

function Util.partial(func: (...any) -> (), ...: any...)
	local args = { ... }
	return function(...)
		func(table.unpack(args), ...)
	end
end

function Util.debounce(func)
	local db = false
	return function(...)
		if db then
			return
		end
		db = true

		task.spawn(function(...)
			func(...)
			db = false
		end, ...)
	end
end

function Util.pickRandom<T>(tbl: { T }, except: T)
	if #tbl <= 0 then
		return nil
	end

	if #tbl < 2 then
		return tbl[1]
	end

	local pick
	repeat
		pick = tbl[RNG:NextInteger(1, #tbl)]
	until pick ~= except

	return pick
end

function Util.weldBetween(a: Instance, b: Instance, inPlace: boolean): Weld
	local weld = Instance.new("Weld")
	weld.Part0 = a
	weld.Part1 = b
	weld.C0 = if inPlace then CFrame.new() else a.CFrame:ToObjectSpace(b.CFrame)
	weld.Parent = a
	return weld
end

--- Maps number v, within range inMin inMax to range outMin outMax
function Util.scale(v: number, inMin: number, inMax: number, outMin: number, outMax: number): number
	return outMin + (v - inMin) * (outMax - outMin) / (inMax - inMin)
end

--- Like Util.scale, except clamps the output
function Util.scaleClamp(v: number, inMin: number, inMax: number, outMin: number, outMax: number): number
	return math.clamp(outMin + (v - inMin) * (outMax - outMin) / (inMax - inMin), outMin, outMax)
end

--- Gives you next value given (current value, how much you want to add to it, and the wrapped maximum, with a "1" offset for roblox)
--- (5, 2, 5) = 2
function Util.next(value: number, increment: number, wrap: number): number
	return (value + increment - 1) % wrap + 1
end

--- Gives you next value given (current value, how much you want to add to it, and the wrapped maximum, with a "1" offset for roblox)
--- (5, 2, 5) = 2
function Util.next(value: number, increment: number, min: number, max: number): number
	return (value + increment - min) % max + min
end

--- Gives you prev value given (current value, how much you want to sub  and the wrapped maximum, with a "1" offset for roblox)
--- (1, 2, 5) = 4
function Util.prev(value: number, decrement: number, wrap: number): number
	return (value - decrement + wrap - 1) % wrap + 1
end

--- Returns a squared magnitude value for a vector meant for comparisons with squared values (saves performance by avoiding square root)
function Util.squareMag(vector: Vector3): number
	return vector:Dot(vector)
end

--- Returns an array with each index as the value with the given array entry as the key.
function Util.arrToOrderLUT(arr: { any }): { [any]: number }
	local lut = {}

	for i, v in ipairs(arr) do
		lut[v] = i
	end

	return lut
end

function Util.isBetweenVectors(origin, a, b, target)
	local StartOriginVector = a - origin
	local PositionOriginVector = target - origin
	local EndOriginVector = b - origin

	local Dot1 = StartOriginVector:Cross(PositionOriginVector).Y * StartOriginVector:Cross(EndOriginVector).Y
	local Dot2 = EndOriginVector:Cross(PositionOriginVector).Y * EndOriginVector:Cross(StartOriginVector).Y

	return Dot1 >= 0 and Dot2 >= 0
end

return Util
