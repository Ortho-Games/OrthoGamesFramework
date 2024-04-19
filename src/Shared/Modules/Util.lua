local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local isClient = RunService:IsClient()

local RNG = Random.new()

local Util = {}

function Util.slerp(angle1, angle2, t)
	local theta = angle2 - angle1
	angle1 += if theta > math.pi
		then 2 * math.pi
		elseif theta < -math.pi then -2 * math.pi
		else 0
	return angle1 + (angle2 - angle1) * t
end

function Util.partial(func: (...any) -> (), ...: any...)
	local args = table.pack(...)
	return function(...)
		local newArgs = table.clone(args)
		local internalArgs = table.pack(...)
		table.move(internalArgs, 1, #internalArgs, #newArgs + 1, newArgs)
		func(table.unpack(newArgs))
	end
end

function Util.debounce(func)
	local db = false
	return function(...)
		if db then return end
		db = true

		task.spawn(function(...)
			func(...)
			db = false
		end, ...)
	end
end

function Util.pickRandom<T>(tbl: { T }, except: T | nil): T
	if #tbl <= 0 then return nil end

	if #tbl < 2 then return tbl[1] end

	local pick
	repeat
		pick = tbl[RNG:NextInteger(1, #tbl)]
	until pick ~= except

	return pick
end

function Util.weldBetween(a: BasePart, b: BasePart, inPlace: boolean?): Weld
	local weld = Instance.new("Weld")
	weld.Part0 = a
	weld.Part1 = b
	weld.C0 = if inPlace then CFrame.new() else a.CFrame:ToObjectSpace(b.CFrame)
	weld.Parent = a
	return weld
end

--- Maps number v, within range inMin inMax to range outMin outMax
function Util.scale(
	v: number,
	inMin: number,
	inMax: number,
	outMin: number,
	outMax: number
): number
	return outMin + (v - inMin) * (outMax - outMin) / (inMax - inMin)
end

--- Like Util.scale, except clamps the output
function Util.scaleClamp(
	v: number,
	inMin: number,
	inMax: number,
	outMin: number,
	outMax: number
): number
	return math.clamp(
		outMin + (v - inMin) * (outMax - outMin) / (inMax - inMin),
		outMin,
		outMax
	)
end

--- Gives you next value given (current value, how much you want to add to it, and the wrapped maximum, with a "1" offset for roblox)
--- (5, 2, 5) = 2
function Util.next(value: number, increment: number, wrap: number): number
	return (value + increment - 1) % wrap + 1
end

-- --- Gives you next value given (current value, how much you want to add to it, and the wrapped maximum, with a "1" offset for roblox)
-- --- (5, 2, 5) = 2
-- function Util.next(value: number, increment: number, min: number, max: number): number
-- 	return (value + increment - min) % max + min
-- end

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

	local Dot1 = StartOriginVector:Cross(PositionOriginVector).Y
		* StartOriginVector:Cross(EndOriginVector).Y
	local Dot2 = EndOriginVector:Cross(PositionOriginVector).Y
		* EndOriginVector:Cross(StartOriginVector).Y

	return Dot1 >= 0 and Dot2 >= 0
end

function Util.arrayToDict<T>(arr: { T }): { [T]: T }
	local dict: { [T]: T } = {}

	for _, v: T in ipairs(arr) do
		dict[v] = v
	end

	return dict
end

function Util.arrayToCustomDict<T, C>(arr: { T }, map: (number, T) -> C): { [T]: C }
	local dict: { [T]: T } = {}

	for i: number, v: T in ipairs(arr) do
		dict[v] = map(i, v)
	end

	return dict
end

function Util.requireDescendants(parent)
	for _, descendant in parent:GetDescendants() do
		if descendant:IsA("ModuleScript") then pcall(require, descendant) end
	end
end

function Util.playServer(func, ...)
	if not isClient then return task.spawn(func, ...) end
end

function Util.playClient(func, ...)
	if isClient then return task.spawn(func, ...) end
end

function Util.playForPlayer(player, func, ...)
	if isClient and Players.LocalPlayer == player then
		return task.spawn(func, ...)
	end
end

function Util.getAnimationTrack(animator, animationId)
	for _, track in animator:GetPlayingAnimationTracks() do
		if track.Animation.AnimationId == animationId then return track end
	end
end

function Util.getValues(dict)
	local values = {}
	for _, v in dict do
		table.insert(values, v)
	end
	return values
end

function Util.filter<T, U>(t: { T }, predicate: (key: U, value: T) -> boolean): { T }
	local newTable = {}

	for key, value in t do
		if predicate(key, value) then newTable[key] = value end
	end

	return newTable
end

function Util.map<T, U>(t: { T }, mapper: (value: T) -> U): { any }
	local newTable = {}

	for key, value in t do
		newTable[key] = mapper(value)
	end

	return newTable
end

function Util.filter_map<T, U>(
	t: { [T]: U },
	filter_mapper: (T, U) -> any
): { [T]: U }
	local newTable = {}
	for key, value in t do
		local mapped = filter_mapper(key, value)
		if mapped then newTable[key] = mapped end
	end

	return newTable
end

function Util.reduce<T, U>(
	t: { T },
	reducer: (accumulator: U, value: T, key: any) -> U,
	initialValue: U
)
	local accumulator = initialValue

	for k, value in t do
		accumulator = reducer(accumulator, value, k)
	end

	return accumulator
end

function Util.find<T>(t: { T }, predicate: (value: T) -> boolean)
	for _, value in t do
		if predicate(value) then return value end
	end

	return nil
end

function Util.findIndex<T>(t: { T }, predicate: (value: T) -> boolean)
	for key, value in t do
		if predicate(value) then return key end
	end

	return nil
end

function Util.filter_map_no_duplicates<T, U>(
	t: { [T]: U },
	filter_mapper: (T, U) -> any
): { [T]: U }
	local newTable = {}
	local tempDict = {}
	for key, value in t do
		local mapped = filter_mapper(key, value)
		if not mapped then continue end
		if tempDict[mapped] then continue end
		tempDict[mapped] = true

		newTable[key] = mapped
	end

	return newTable
end

return Util
