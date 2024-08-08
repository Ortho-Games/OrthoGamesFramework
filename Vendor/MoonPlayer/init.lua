local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)

local EaseFuncs = require(script.EaseFuncs)
local Specials = require(script.Specials)
local Types = require(script.Types)

if RunService:IsServer() then
	warn("Moonlite should NOT be used on the server! Rig transforms will not be replicated.")
end

type Signal = typeof(Signal.new())
type Janitor = typeof(Janitor.new())
type Scratchpad = Types.Scratchpad
type MoonItem = Types.MoonItem
type MoonAnimInfo = Types.MoonAnimInfo
type MoonAnimItem = Types.MoonAnimItem
type MoonAnimPath = Types.MoonAnimPath
type MoonAnimSave = Types.MoonAnimSave
type MoonEaseInfo = Types.MoonEaseInfo
type MoonKeyframe = Types.MoonKeyframe
type MoonProperty = Types.MoonProperty
type MoonJointInfo = Types.MoonJointInfo
type MoonKeyframePack = Types.MoonKeyframePack
type GetSet<Inst, Value> = Types.GetSet<Inst, Value>

local MoonTrack = {}
MoonTrack.__index = MoonTrack

export type MoonTrack = typeof(setmetatable(
	{} :: {
		Completed: Signal,
		Looped: boolean,
		_janitor: Janitor,
		_items: { MoonItem },
		_targets: { [Instance]: MoonItem },
		_save: StringValue,
		_data: MoonAnimSave,
		_time: number,
	},
	MoonTrack
))

local CONSTANT_INTERPS = {
	["Instance"] = true,
	["boolean"] = true,
	["nil"] = true,
}

local function readValue(value: Instance)
	if value:IsA("ValueBase") then
		-- stylua: ignore
		local bin = if tonumber(value.Name)
			then assert(value.Parent)
			else value

		local read = (value :: any).Value
		local enumType = bin:FindFirstChild("EnumType")

		if enumType and enumType:IsA("StringValue") then
			read = (Enum :: any)[enumType.Value][read]
		elseif bin:FindFirstChild("Vector2") then
			read = Vector2.new(read.X, read.Y)
		elseif bin:FindFirstChild("ColorSequence") then
			read = ColorSequence.new(read)
		elseif bin:FindFirstChild("NumberSequence") then
			read = NumberSequence.new(read)
		elseif bin:FindFirstChild("NumberRange") then
			read = NumberRange.new(read)
		end

		return read
	else
		return value:GetAttribute("Value")
	end
end

local function setPropValue(
	scratch: Scratchpad,
	inst: Instance?,
	propName: string,
	value: any,
	isDefault: boolean?
): boolean
	if inst then
		local binding = Specials.Get(scratch, inst, propName)

		if binding then
			if binding.Get == nil and isDefault and value == true then
				-- Ugh, This is an action(?), but for some reason six
				-- sets the default value to true here, which
				-- would behave as an immediate dispatch.
				-- Not the behavior we need.
				warn("idk what this is, but if anyone sees this let @RoboGojo know")
				value = false
			end

			return pcall(binding.Set, value)
		end
	end

	return pcall(function()
		(inst :: any)[propName] = value
	end)
end

local function lerp<T>(a: T, b: T, t: number): any
	if type(a) == "number" then
		return a + ((b - a) * t)
	else
		return (a :: any):Lerp(b, t)
	end
end

local function toPath(path: MoonAnimPath): string
	return table.concat(path.InstanceNames, ".")
end

local function parseEase(easeInst: Instance): MoonEaseInfo
	local typeInst = easeInst:FindFirstChild("Type")
	local paramInst = easeInst:FindFirstChild("Params")

	local ease = {
		-- stylua: ignore
		Type = assert(if typeInst and typeInst:IsA("StringValue")
			then typeInst.Value :: any
			else nil),

		Params = {},
	}

	if paramInst then
		for i, param in paramInst:GetChildren() do
			if param:IsA("ValueBase") then
				local value = (param :: any).Value
				ease.Params[param.Name] = value
			end
		end
	end

	return ease
end

local function parseEaseOld(easeInst: Instance): MoonEaseInfo
	local style = easeInst:FindFirstChild("Style")
	assert(style and style:IsA("StringValue"), "No style in legacy ease!")

	local dir = easeInst:FindFirstChild("Direction")
	assert(dir and dir:IsA("StringValue"), "No direction in legacy ease!")

	return {
		Type = style.Value :: any,

		Params = {
			Direction = dir.Value :: any,
		},
	}
end

local function parseKeyframePack(kf: Instance): MoonKeyframePack
	local frame = tonumber(kf.Name)
	assert(frame, "Bad frame number")

	local valueBin = kf:FindFirstChild("Values")
	assert(valueBin, "No value folder!")

	local zero = valueBin:FindFirstChild("0")
	assert(zero, "No starting value!")

	local values = {}
	local maxIndex = 0

	for i, value in valueBin:GetChildren() do
		local index = tonumber(value.Name)

		if index then
			local success, read = pcall(readValue, value)

			if success then
				values[index] = read
				maxIndex = math.max(index, maxIndex)
			end
		end
	end

	local easesBin = kf:FindFirstChild("Eases")
	local easeOld = kf:FindFirstChild("Ease")
	local eases = {}

	if easesBin then
		for _, easeBin in easesBin:GetChildren() do
			local index = tonumber(easeBin.Name)
			assert(index, `Bad index on ease @{easeBin:GetFullName()}`)

			local ease = parseEase(easeBin)
			eases[index] = ease
		end
	elseif easeOld then
		eases[maxIndex] = parseEaseOld(easeOld)
	end

	return {
		FrameIndex = frame,
		FrameCount = maxIndex,

		Values = values,
		Eases = eases,
	}
end

local function unpackKeyframes(container: Folder, modifier: ((any) -> any)?, default: any)
	local packs = {}

	local indices = {}
	for _, frameFolder in container:GetChildren() do
		local frame = tonumber(frameFolder.Name)
		if frame then
			packs[frame] = parseKeyframePack(frameFolder)
			table.insert(indices, frame)
		end
	end
	table.sort(indices)

	for i = 2, #indices do
		local prev = packs[indices[i - 1]]
		local curr = packs[indices[i]]
		prev.Next = curr
		curr.Prev = prev
	end

	local sequence = {}
	local current: MoonKeyframePack? = packs[indices[1]]
	while current do
		local baseIndex, lastEase = current.FrameIndex, nil
		for i = 0, current.FrameCount do
			local ease = current.Eases[i] or lastEase
			if current.Values[i] == nil then continue end
			if ease then lastEase = ease end

			local prev = sequence[#sequence]
			local start = if prev then prev.Value else default
			local value = if modifier then modifier(current.Values[i]) else current.Values[i]
			local goal = value

			local handler: (number) -> any
			if typeof(goal) == "ColorSequence" then
				start = start.Keypoints[1].Value
				goal = goal.Keypoints[1].Value
				handler = function(t: number)
					return ColorSequence.new(lerp(start, goal, t))
				end
			elseif typeof(goal) == "NumberSequence" then
				start = start.Keypoints[1].Value
				goal = goal.Keypoints[1].Value
				handler = function(t: number)
					return NumberSequence.new(lerp(start, goal, t))
				end
			elseif typeof(goal) == "NumberRange" then
				start = start.Min
				goal = goal.Min
				handler = function(t: number)
					return NumberRange.new(lerp(start, goal, t))
				end
			elseif CONSTANT_INTERPS[typeof(goal)] then
				handler = function(t: number)
					return if t >= 1 then goal else start
				end
			else
				handler = function(t: number)
					return lerp(start, goal, t)
				end
			end

			local currentTime = baseIndex + i
			local lastTime = sequence[#sequence] and sequence[#sequence].Time
			table.insert(sequence, {
				Time = currentTime,
				Duration = if lastTime then currentTime - lastTime else currentTime,
				Value = value,
				Ease = EaseFuncs.Get(ease),
				Handler = handler,
			})
		end

		current = current.Next
	end

	return sequence
end

local function resolveAnimPath(path: MoonAnimPath?, root: Instance?): Instance?
	if not path then return nil end

	local numSteps = #path.InstanceNames
	local current: Instance = root or game

	local success = pcall(function()
		for i = 2, numSteps do
			local name = path.InstanceNames[i]
			local class = path.InstanceTypes[i]

			local nextInst = (current :: any)[name]
			assert(typeof(nextInst) == "Instance")
			assert(nextInst.ClassName == class)

			current = nextInst
		end
	end)

	if success then return current end

	warn("!! PATH RESOLVE FAILED:", table.concat(path.InstanceNames, "."))
	return nil
end

local function MakeItem(moonItem: MoonAnimItem, itemSave: Instance, root: Instance?): MoonItem
	local target = resolveAnimPath(moonItem.Path, root)

	local item: MoonItem
	if moonItem.Path.ItemType == "Rig" then
		-- @TODO: handle rigs differently
	else
		local props = {}
		for i, prop in itemSave:GetChildren() do
			local default: any = prop:FindFirstChild("default")
			props[prop.Name] = {
				Default = default and readValue(default),
				Sequence = unpackKeyframes(prop),
			}

			if moonItem.Path.ItemType == "Camera" and prop.Name == "CFrame" then
				print(props[prop.Name].Sequence)
			end
		end

		item = {
			Locks = {},
			Props = props,
			Target = target,
			Path = moonItem.Path,
		}
	end

	return item
end

function MoonTrack.new(save: StringValue, root: Instance?): MoonTrack
	local data: MoonAnimSave = HttpService:JSONDecode(save.Value)
	local janitor = Janitor.new()

	data.Information.FPS = data.Information.FPS or 60

	local items: { MoonItem }, targets: { [Instance]: MoonItem } = {}, {}
	for i, moonItem in data.Items do
		local itemSave = assert(save:FindFirstChild(i))
		local item = MakeItem(moonItem, itemSave, root)
		if not item then
			warn("FIX THIS, HANDLE RIGS DIFFERENTLY")
			continue
		end

		table.insert(items, item)

		if item.Target then targets[item.Target] = item end
	end

	local completed = janitor:Add(Signal.new(), "Destroy")

	return setmetatable({
		Completed = completed,
		Looped = data.Information.Looped,
		_janitor = janitor,
		_playingJanitor = janitor:Add(Janitor.new(), "Destroy"),
		_items = items,
		_save = save,
		_data = data,
		_time = 0,
		_scratch = {},
		_targets = targets,
	}, MoonTrack)
end

function MoonTrack.Destroy(self: MoonTrack)
	if not self._janitor.Destroy then return end
	self._janitor:Destroy()
end

function MoonTrack.Play(self: MoonTrack)
	self:Reset()

	local startTime = os.clock()
	local conn = RunService.RenderStepped:Connect(function(dt)
		local frameTime = (os.clock() - startTime) * self._data.Information.FPS
		local frame = frameTime // 1
		if frame > self._data.Information.Length then
			self.Completed:Fire()
			if not self._data.Information.Looped then
				self:Stop()
				return
			end
			frame %= self._data.Information.Length
			frameTime %= self._data.Information.Length
		end

		for _, item in self._items do
			if next(item.Locks) then continue end

			for propName, prop in item.Props do
				if not prop._nextFrame then continue end

				local kf = prop.Sequence[prop._nextFrame]
				if kf and kf.Time <= frame then
					repeat
						prop._nextFrame += 1
						kf = prop.Sequence[prop._nextFrame]
					until not (kf and kf.Time <= frame)
				end

				if kf then
					local t = math.clamp((frameTime - kf.Time + kf.Duration) / kf.Duration, 0, 1)
					local te = kf.Ease(t)
					local v = kf.Handler(te)

					setPropValue(self._scratch, item.Target, propName, v)
					if item.Path.ItemType == "Camera" and propName == "CFrame" then
						print(kf.Time, frameTime, t)
					end
				end
			end
		end
	end)

	self._playingJanitor:Add(conn, "Disconnect")
end

function MoonTrack.Stop(self: MoonTrack)
	self._playingJanitor:Cleanup()
end

function MoonTrack.Reset(self: MoonTrack)
	self:Stop()

	for _, item in self._items do
		if not item.Target then continue end

		for propName: string, prop in item.Props do
			setPropValue(self._scratch, item.Target, propName, prop.Default, true)
			prop._nextFrame = prop.Sequence[1] and (prop.Sequence[1].Time + 1)
		end
	end
end

function MoonTrack.LockElement(self: MoonTrack, target: Instance?, lock: any?)
	local item = target and self._targets[target]
	if item then
		item.Locks[lock or "Default"] = true
		return true
	end

	return false
end

function MoonTrack.UnlockElement(self: MoonTrack, target: Instance?, lock: any?)
	local item = target and self._targets[target]
	if item then
		item.Locks[lock or "Default"] = nil
		return true
	end

	return false
end

function MoonTrack.ReplaceItemByPath(self: MoonTrack, targetPath: string, replacement: Instance)
	for _, item in self._items do
		if toPath(item.Path):lower() == targetPath:lower() then
			local itemType = item.Path.ItemType

			if itemType == "Rig" then
				return false
			elseif replacement:IsA(item.Path.ItemType) then
				item.Target = replacement
				self._targets[replacement] = item
				return true
			end
		end
	end

	return false
end

return MoonTrack
