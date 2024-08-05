local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)

local EaseFuncs = require(script.EaseFuncs)
local Specials = require(script.Specials)
local Types = require(script.Types)

if RunService:IsServer() then
	warn("Moonlite should NOT be used on the server! Rig transforms will not be replicated.")
end

type Event = Types.Event
type Scratchpad = Types.Scratchpad
type MoonElement = Types.MoonElement
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
		Completed: typeof(Signal.new()),
		Looped: boolean,
		Janitor: typeof(Janitor.new()),

		_elements: { MoonElement },
		_targets: {
			[Instance]: MoonElement,
		},

		_time: number,
		_playing: {
			[MoonProperty]: {},
		},

		_root: Instance?,
		_save: StringValue,
		_data: MoonAnimSave,

		_scratch: Scratchpad,
		_compiled: boolean,
	},
	MoonTrack
))

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

local function getPropValue(self: MoonTrack, inst: Instance?, prop: string): (boolean, any?)
	if inst then
		local binding = Specials.Get(self._scratch, inst, prop)

		if binding then
			local get = binding.Get

			if get then
				return pcall(get, inst)
			else
				return true, binding.Default
			end
		end
	end

	return pcall(function()
		return (inst :: any)[prop]
	end)
end

local function setPropValue(
	self: MoonTrack,
	inst: Instance?,
	prop: string,
	value: any,
	isDefault: boolean?
): boolean
	if inst then
		local binding = Specials.Get(self._scratch, inst, prop)

		if binding then
			if binding.Get == nil and isDefault and value == true then
				-- Ugh, This is an action(?), but for some reason six
				-- sets the default value to true here, which
				-- would behave as an immediate dispatch.
				-- Not the behavior we need.
				value = false
			end

			return pcall(binding.Set, value)
		end
	end

	return pcall(function()
		(inst :: any)[prop] = value
	end)
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

local function unpackKeyframes(container: Instance, modifier: ((any) -> any)?)
	local packs = {}
	local indices = {}
	local sequence = {}

	for i, child in container:GetChildren() do
		local index = tonumber(child.Name)

		if index then
			packs[index] = parseKeyframePack(child)
			table.insert(indices, index)
		end
	end

	table.sort(indices)

	for i = 2, #indices do
		local prev = packs[indices[i - 1]]
		local curr = packs[indices[i]]

		prev.Next = curr
		curr.Prev = prev
	end

	local first = indices[1]
	local current: MoonKeyframePack? = packs[first]

	while current do
		local baseIndex = current.FrameIndex
		local lastEase

		for i = 0, current.FrameCount do
			local ease = current.Eases[i] or lastEase
			local value = current.Values[i]

			if value ~= nil then
				if modifier then value = modifier(value) end

				table.insert(sequence, {
					Time = baseIndex + i,
					Value = value,
					Ease = ease,
				})

				if ease then lastEase = ease end
			end
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

local function resolveJoints(target: Instance)
	local joints = {} :: {
		[string]: MoonJointInfo,
	}

	for i, desc: Instance in target:GetDescendants() do
		if desc:IsA("Motor6D") and desc.Active then
			local part1 = desc.Part1
			local name = part1 and part1.Name

			if name then
				joints[name] = {
					Name = name,
					Joint = desc,
					Children = {},
				}
			end
		end
	end

	for name1, data1 in joints do
		local joint = data1.Joint
		local part0 = joint.Part0

		if part0 then
			local name0 = part0.Name
			local data0 = joints[name0]

			if data0 then
				data0.Children[name1] = data1
				data1.Parent = data0
			end
		end
	end

	return joints
end

local function compileItem(self: MoonTrack, item: MoonAnimItem)
	local id = table.find(self._data.Items, item)

	if not id then return end

	local path = item.Path
	local itemType = path.ItemType

	local target = item.Override or resolveAnimPath(path, self._root)
	local frame = self._save:FindFirstChild(tostring(id))
	local rig = frame and frame:FindFirstChild("Rig")

	if not (target and frame) then return end

	assert(target)
	assert(frame)

	if rig and itemType == "Rig" then
		local joints = resolveJoints(target)

		for i, jointData in rig:GetChildren() do
			if jointData.Name ~= "_joint" then continue end

			local hier = jointData:FindFirstChild("_hier")
			local default: any = jointData:FindFirstChild("default")
			local keyframes = jointData:FindFirstChild("_keyframes")

			if default then default = readValue(default) end

			if hier and keyframes then
				local tree = readValue(hier)
				local readName = tree:gmatch("[^%.]+")

				local name = readName()
				local data: MoonJointInfo? = joints[name]

				while data do
					local children = data.Children
					name = readName()

					if name == nil then
						break
					elseif children[name] then
						data = children[name]
					else
						warn(
							`failed to resolve joint '{tree}' (could not find child '{name}' in {data.Name}!)`
						)
						data = nil
					end
				end

				if data then
					local joint = data.Joint

					local props: any = {
						Transform = {
							Default = CFrame.identity,

							Sequence = unpackKeyframes(keyframes, function(c1: CFrame)
								return c1:Inverse() * default
							end),
						},
					}

					local element = {
						Locks = {},
						Props = props,
						Instance = joint,
					}

					self._targets[joint] = element
					table.insert(self._elements, element)
				end
			end
		end
	else
		local props = {}

		for i, prop in frame:GetChildren() do
			local default: any = prop:FindFirstChild("default")

			if default then default = readValue(default) end

			props[prop.Name] = {
				Default = default,
				Sequence = unpackKeyframes(prop),
			}
		end

		local element = {
			Locks = {},
			Props = props,
			Target = target,
		}

		self._targets[target] = element
		table.insert(self._elements, element)
	end
end

local function toPath(path: MoonAnimPath): string
	return table.concat(path.InstanceNames, ".")
end

function MoonTrack.new(save: StringValue, root: Instance): MoonTrack
	local data: MoonAnimSave = HttpService:JSONDecode(save.Value)
	local _janitor = Janitor.new()
	_janitor:Add(Janitor.new(), "Destroy", "PlayingJanitor")

	return setmetatable({
		Looped = data.Information.Looped,
		Completed = _janitor:Add(Signal.new(), "Destroy"),
		Janitor = _janitor,

		_save = save,
		_data = data,

		_completed = completed,
		_compiled = false,

		_elements = {},
		_targets = {},

		_time = 0,
		_playing = {},
		_scratch = {},
		_tweens = tweens,
		_root = root,
	}, MoonTrack)
end

function MoonTrack:Play()
	local _playingJanitor = self.Janitor:Get("PlayingJanitor")
	_playingJanitor:Cleanup()
	_playingJanitor:Add(
		RunService.RenderStepped:Connect(function(dt)
			self._time += dt
			local frame = self._time * (self._data.Information.FPS or 60) // 1

			for inst, element in self._targets do
				for name, data in element.Props do
				end
			end
		end),
		"Disconnect"
	)
end

function MoonTrack:Stop()
	self.Janitor:Get("PlayingJanitor"):Cleanup()
end

function MoonTrack:Reset()
	if self:IsPlaying() then return false end
	self:Stop()
	self._time = 0

	for inst, element in self._targets do
		for name, data in element.Props do
			setPropValue(self, inst, name, data.Default, true)
		end
	end

	return true
end

function MoonTrack:ReplaceElementByPath(targetPath: string, replacement: Instance)
	for i, item in self._data.Items do
		local path = item.Path
		local id = toPath(path)

		if targetPath:lower() == id:lower() then
			local itemType = path.ItemType

			if itemType == "Rig" or replacement:IsA(path.ItemType) then
				item.Override = replacement

				if self._compiled then compileItem(self, item) end

				return true
			end
		end
	end

	return false
end

return MoonTrack
