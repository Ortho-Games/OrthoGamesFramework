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
		_items: { [string]: MoonItem },
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

			local start = current.Prev or default
			local goal
			local value = if modifier then modifier(current.Values[i]) else current.Values[i]
			if typeof(value) == "ColorSequence" then
				setup = function()
					start = start.Keypoints[1].Value
					goal = value.Keypoints[1].Value
				end

				handler = function(t: number)
					local value = lerp(start, goal, t)
					return ColorSequence.new(value)
				end
			elseif typeof(value) == "NumberSequence" then
				setup = function()
					start = start.Keypoints[1].Value
					goal = goal.Keypoints[1].Value
				end

				handler = function(t: number)
					local value = lerp(start, goal, t)
					return NumberSequence.new(value)
				end
			elseif typeof(value) == "NumberRange" then
				setup = function()
					start = start.Min
					goal = value.Min
				end

				handler = function(t: number)
					local value = lerp(start, goal, t)
					return NumberRange.new(value)
				end
			elseif CONSTANT_INTERPS[typeof(value)] then
				handler = function(t: number)
					if t >= 1 then
						return value
					else
						return start
					end
				end
			end

			table.insert(sequence, {
				Time = baseIndex + i,
				Value = if modifier then modifier(value) else value,
				Ease = EaseFuncs.Get(ease),
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

local function MakeItem(moonItem: MoonAnimItem, itemData: Folder, root: Instance?): MoonItem
	local target = resolveAnimPath(moonItem.Path, root)

	local item: MoonItem
	if moonItem.Path.ItemType == "Rig" then
		-- @TODO: handle rigs differently
	else
		local props = {}
		for i, prop in itemData:GetChildren() do
			local default: any = prop:FindFirstChild("default")
			props[prop.Name] = {
				Default = default and readValue(default),
				Sequence = unpackKeyframes(prop),
			}
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

local function UpdateItem(track: MoonTrack, item: MoonItem)
	if not item.Target then return end

	for propName, prop in item.Props do
	end
end

function MoonTrack.new(save: StringValue, root: Instance?): MoonTrack
	local data: MoonAnimSave = HttpService:JSONDecode(save.Value)
	local janitor = Janitor.new()
	janitor:Add(Janitor.new(), "Destroy", "PlayingJanitor")

	data.Information.FPS = data.Information.FPS or 60

	local items: { [string]: MoonItem }, targets: { [Instance]: MoonItem } = {}, {}
	for i, moonItem in data.Items do
		local id = HttpService:JSONEncode(moonItem.Path)
		local item = MakeItem(moonItem, data[i], root)
		items[id] = item

		if item.Target then targets[item.Target] = item end
	end

	local completed = janitor:Add(Signal.new(), "Destroy")

	return setmetatable({
		Completed = completed,
		Looped = data.Information.Looped,
		_janitor = janitor,
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
	local _playingJanitor = self.Janitor:Get("PlayingJanitor")
	_playingJanitor:Cleanup()

	_playingJanitor:Add(
		RunService.RenderStepped:Connect(function(dt)
			self._time += dt

			local frame = self._time * self._data.Information.FPS // 1
			if frame > self._data.Information.Length then
				if self._data.Information.Looped then
					frame %= self._data.Information.Length
					self._time %= self._data.Information.Length / self._data.Information.FPS
				else
					self:Stop()
				end
			end

			for _, item in self._items do
				if next(item.Locks) then continue end

				for propName, prop in item.Props do
					local currentFrame = prop.Sequence[prop._currentFrame]
					local nextFrame = prop.Sequence[prop._currentFrame + 1]

					if currentFrame.Time == frame then
						local t = currentFrame.Ease(self._time - currentFrame.Time)
						local value = if not handler then lerp(start, goal, t) else handler(t)
					end
				end
			end
		end),
		"Disconnect"
	)
end

function MoonTrack.Stop(self: MoonTrack)
	self.Janitor:Get("PlayingJanitor"):Cleanup()
end

function MoonTrack.Reset(self: MoonTrack)
	if self:IsPlaying() then return false end
	self:Stop()
	self._time = 0

	for _, item in self._items do
		if not item.Target then continue end

		for propName: string, prop in item.Props do
			setPropValue(self, item.Target, propName, prop.Default, true)
		end
	end

	return true
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

function MoonTrack.ReplaceItemByPath(
	self: MoonTrack,
	targetPath: MoonAnimPath,
	replacement: Instance
): boolean
	local id = HttpService:JSONEncode(targetPath)
	local item: MoonItem = self._items[id]

	if not item then
		return false
	elseif item.Path.ItemType == "Rig" then
	elseif replacement:IsA(item.Path.ItemType) then
		item.Target = replacement
		self._targets[replacement] = item
		return true
	end

	return false
end

return MoonTrack
