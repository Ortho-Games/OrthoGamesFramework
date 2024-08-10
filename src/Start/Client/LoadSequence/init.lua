local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Global = require(ReplicatedStorage.Shared.Global)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local LightMachine = require(ReplicatedStorage.Vendor.LightMachine)
local Net = require(ReplicatedStorage.Packages.Net)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Signal = require(ReplicatedStorage.Packages.Signal)

local CreditSequences = require(script.CreditSequences)

local LoadScreen = require(ReplicatedFirst.First.LoadScreen)

local InitAsyncFinished = Signal.new()

local IntroLightingPreset = Global.Assets.LightingPresets.Intro

local lightMachine = LightMachine.new(Global.Assets.LightingPresets.Intro)

local function WaitForInputPromise(holdTime)
	local janitor = Janitor.new()
	local signal = janitor:AddObject(Signal, "Destroy")

	local n: number = 0
	janitor:Add(
		UserInputService.InputBegan:Connect(function(input, gpe)
			if
				gpe
				or not (
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
					or input.UserInputType == Enum.UserInputType.Keyboard
				)
			then
				return
			end

			if n == 0 then LoadScreen.startHoldAnim(holdTime) end

			n += 1
			janitor:Add(
				task.delay(1.5, function()
					signal:Fire()
				end),
				true,
				input
			)
		end),
		"Disconnect"
	)

	janitor:Add(
		UserInputService.InputEnded:Connect(function(input)
			if not janitor:Get(input) then return end
			n -= 1
			janitor:Remove(input)
			if n == 0 then LoadScreen.endHoldAnim() end
		end),
		"Disconnect"
	)

	return Promise.fromEvent(signal):catch(warn):finally(function()
		janitor:Destroy()
		LoadScreen.endHoldAnim()
	end)
end

local FadeScreen = Instance.new("ScreenGui", Players.LocalPlayer.PlayerGui)
FadeScreen.IgnoreGuiInset = true

local FadeFrame = Instance.new("Frame", FadeScreen)
FadeFrame.Size = UDim2.new(1, 0, 1, 0)
FadeFrame.BackgroundColor3 = Color3.new()
FadeFrame.BackgroundTransparency = 1
FadeFrame.ZIndex = math.huge

local FadeInTween = TweenService:Create(
	FadeFrame,
	TweenInfo.new(1.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
	{
		BackgroundTransparency = 1,
	}
)

local FadeOutTween = TweenService:Create(
	FadeFrame,
	TweenInfo.new(1.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	{
		BackgroundTransparency = 0,
	}
)

return function()
	-- required loading
	LoadScreen.setDescription("Initializing...", 0)
	Global.Schedules.Init.start()

	-- cosmetic loading
	LoadScreen.setDescription("Loading world...", 0.75)
	local preloadCredits = CreditSequences.preloadPromise()
	local initAsync = Promise.fromEvent(InitAsyncFinished)
	task.defer(function()
		Global.Schedules.InitAsync.start()
		ContentProvider:PreloadAsync { workspace, ReplicatedStorage }
		InitAsyncFinished:Fire()
	end)

	Promise.all({
		Promise.race {
			Promise.delay(2):andThen(function()
				LoadScreen.enableSkipButton(true)
				return WaitForInputPromise(2)
			end),
			initAsync:andThen(function()
				LoadScreen.setDescription("Bazinga...", 0.9)
				LoadScreen.enableSkipButton(false)
			end),
		},
		preloadCredits,
	})
		:andThen(function()
			LoadScreen.enableSkipButton(false)
			LoadScreen.setDescription("Starting...", 1)
			FadeOutTween:Play()
			FadeOutTween.Completed:Wait()
			task.wait(1)
			LoadScreen.endLoadScreen()

			return Promise.race {
				preloadCredits:andThen(function(preloadedAssets)
					task.defer(FadeInTween.Play, FadeInTween)
					return CreditSequences.startPromise(preloadedAssets):catch(warn)
				end),
				Promise.fromEvent(UserInputService.InputBegan, function(input, gpe)
					return not gpe
						and (
							input.UserInputType == Enum.UserInputType.MouseButton1
							or input.UserInputType == Enum.UserInputType.Touch
							or input.UserInputType == Enum.UserInputType.Keyboard
						)
				end),
			}
		end)
		:finally(function()
			FadeOutTween:Play()
			FadeOutTween.Completed:Wait()
			preloadCredits:andThen(function(preloadedAssets)
				preloadedAssets.janitor:Destroy()
			end)
		end)
		:await()

	while not Net:Invoke("RequestStart") do
		print("sad")
		task.wait(3)
	end

	Global.Schedules.Boot.start()
	FadeInTween:Play()
end
