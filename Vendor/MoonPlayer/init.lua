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
		_save: StringValue,
		_data: MoonAnimSave,
		_time: number,
	},
	MoonTrack
))

function MoonTrack.new(save: StringValue, root: Instance): MoonTrack
	local data: MoonAnimSave = HttpService:JSONDecode(save.Value)
	local janitor = Janitor.new()
	janitor:Add(Janitor.new(), "Destroy", "PlayingJanitor")

	local self = setmetatable({
		Looped = data.Information.Looped,
		Completed = janitor:Add(Signal.new(), "Destroy"),
		_janitor = janitor,
		_items = {},
		_save = save,
		_data = data,
		_time = 0,
	}, MoonTrack)

	for i, moonItem in data.Items do
		local itemData = data[i]
		local id = HttpService:JSONEncode()

		if moonItem.Path.ItemType == "Rig" then
		else
		end
	end

	return self
end

function MoonTrack:Destroy()
	if not self._janitor.Destroy then return end
	self._janitor:Destroy()
end

function MoonTrack:Play()
	local _playingJanitor = self.Janitor:Get("PlayingJanitor")
	_playingJanitor:Cleanup()
	_playingJanitor:Add(
		RunService.RenderStepped:Connect(function(dt)
			self._time += dt
			local frame = self._time * (self._data.Information.FPS or 60) // 1

			for itemPath, item in self._items do
				item:UpdateValue()
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
