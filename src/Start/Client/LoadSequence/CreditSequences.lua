local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global = require(ReplicatedStorage.Shared.Global)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local MoonPlayer = require(ReplicatedStorage.Vendor.MoonPlayer)
local Promise = require(ReplicatedStorage.Packages.Promise)

local CreditSequenceAnimation = Global.Assets.MoonAnimations.CreditSequence.Animation
local CreditSequenceModel = Global.Assets.MoonAnimations.CreditSequence.Model

local CreditSequences = {}

function CreditSequences.preloadPromise()
	print("preloading credits")

	local preloadedAssets = {}

	return Promise.try(function()
		ContentProvider:PreloadAsync { CreditSequenceModel }
	end)
		:andThenCall(print, "preloaded credits")
		:andThenReturn(preloadedAssets)
end

function CreditSequences.startPromise(preloadedAssets)
	print("starting credits")

	local janitor = Janitor.new()

	local sequenceModel = janitor:Add(CreditSequenceModel:Clone(), "Destroy")
	sequenceModel.Parent = workspace

	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	janitor:Add(
		workspace.CurrentCamera:GetPropertyChangedSignal("CameraType"):Once(function()
			workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
		end),
		"Disconnect"
	)

	local moonTrack = janitor:Add(MoonPlayer.new(CreditSequenceAnimation, sequenceModel), "Destroy")
	moonTrack:SetSetting("KeepCameraType", true)
	moonTrack:ReplaceItemByPath("game.Workspace.CurrentCamera", workspace.CurrentCamera)
	moonTrack:Play()

	janitor:Add(function()
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	end, true)

	return Promise.fromEvent(moonTrack.Completed):finallyCall(janitor)
end

return CreditSequences
