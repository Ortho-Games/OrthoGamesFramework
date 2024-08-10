local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global = require(ReplicatedStorage.Shared.Global)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local MoonPlayer = require(ReplicatedStorage.Vendor.MoonPlayer)
local Promise = require(ReplicatedStorage.Packages.Promise)

local CreditSequenceAnimation = Global.Assets.MoonAnimations.CreditSequence.Animation
local CreditSequenceModel = Global.Assets.MoonAnimations.CreditSequence.Model
local CreditSequenceSound = Global.Assets.MoonAnimations.CreditSequence.Sound

local CreditSequences = {}

function CreditSequences.preloadPromise()
	local janitor = Janitor.new()
	local preloadedAssets = {
		janitor = janitor,
	}

	return Promise.try(function()
		ContentProvider:PreloadAsync { CreditSequenceModel }
		preloadedAssets.sequenceModel = janitor:Add(CreditSequenceModel:Clone(), "Destroy")
		preloadedAssets.sequenceModel.Parent = workspace
		preloadedAssets.moonTrack = preloadedAssets.janitor:Add(
			MoonPlayer.new(CreditSequenceAnimation, preloadedAssets.sequenceModel),
			"Destroy"
		)
		preloadedAssets.moonTrack:SetSetting("KeepCameraType", true)
	end)
		:catch(function(e)
			warn(e)
			janitor:Destroy()
		end)
		:andThenReturn(preloadedAssets)
end

function CreditSequences.startPromise(preloadedAssets)
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	preloadedAssets.janitor:Add(
		workspace.CurrentCamera:GetPropertyChangedSignal("CameraType"):Once(function()
			workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
		end),
		"Disconnect"
	)

	preloadedAssets.moonTrack:ReplaceItemByPath(
		"game.Workspace.CurrentCamera",
		workspace.CurrentCamera
	)
	preloadedAssets.moonTrack:Play()
	preloadedAssets.janitor:Add(Global.Util.playSound(CreditSequenceSound, game), "Destroy")

	preloadedAssets.janitor:Add(function()
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	end, true)

	return Promise.fromEvent(preloadedAssets.moonTrack.Completed)
end

return CreditSequences
