local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Global = require(ReplicatedStorage.Shared.Global)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Moonlite = require(ReplicatedStorage.Packages.Moonlite)
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

	local moonTrack = Moonlite.CreatePlayer(CreditSequenceAnimation, sequenceModel)
	moonTrack:ReplaceElementByPath("game.Workspace.CurrentCamera", workspace.CurrentCamera)

	janitor:Add(function()
		moonTrack:Stop()
		moonTrack:Reset()
	end, true)

	task.wait()

	moonTrack:Play()

	return Promise.fromEvent(moonTrack.Completed):finallyCall(janitor)
end

return CreditSequences
