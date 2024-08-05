local Janitor = require(script.Packages.Janitor)
local Signal = require(script.Packages.Signal)

local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

ReplicatedFirst:RemoveDefaultLoadingScreen()

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local loadingGui = ReplicatedFirst:WaitForChild("LoadingScreen"):Clone()
loadingGui.Parent = playerGui
loadingGui.Enabled = false

local logo = loadingGui.Logo
local path2D = logo.Path2D

local progressTi = TweenInfo.new(0.25, Enum.EasingStyle.Quad)
local fadeTi = TweenInfo.new(1)

local LoadScreen = {}
LoadScreen.onSkipped = Signal.new()

local _janitor = Janitor.new()

local function getPreviousIndex(t, index)
	local newIndex = index - 1

	if newIndex < 1 then return #t end

	return newIndex
end

local path2DAnimation = {
	{
		UDim2.fromScale(0.5, 1.1),
		UDim2.fromScale(-0.1, 0.5),
		UDim2.fromScale(0.5, -0.1),
		UDim2.fromScale(1.1, 0.5),
	},

	{
		UDim2.fromScale(0.5, 1.1),
		UDim2.fromScale(-0.1, 0.5),
		UDim2.fromScale(0.5, -0.1),
		UDim2.fromScale(1.1, 0.5),
	},

	{
		UDim2.fromScale(-0.1, 0.5),
		UDim2.fromScale(0.5, -0.1),
		UDim2.fromScale(1.1, 0.5),
		UDim2.fromScale(0.5, 1.1),
	},
}

local function startLoadingAnimation()
	path2D:SetControlPoints {
		Path2DControlPoint.new(UDim2.fromScale(1.1, 0.5)),
		Path2DControlPoint.new(UDim2.fromScale(1.1, 0.5)),
		Path2DControlPoint.new(UDim2.fromScale(0.5, 1.1)),
	}

	local startTime = os.clock()

	local period = 1.5
	local sides = 4
	local timePerSide = period / sides

	_janitor:Add(
		task.defer(function()
			_janitor:Add(
				RunService.RenderStepped:Connect(function()
					local t = os.clock() - startTime
					local animIndex = (t // timePerSide) % 4 + 1
					local i = (t % timePerSide) / timePerSide

					for index, controlPoint: Path2DControlPoint in ipairs(path2D:GetControlPoints()) do
						local pathAnim = path2DAnimation[index]
						local goal = pathAnim[getPreviousIndex(pathAnim, animIndex)]:Lerp(
							pathAnim[animIndex],
							i
						)

						if index == 2 then goal = path2DAnimation[index][animIndex] end

						pcall(function()
							path2D:UpdateControlPoint(index, Path2DControlPoint.new(goal))
						end)
					end
				end),
				"Disconnect"
			)
		end),
		true
	)
end

function LoadScreen.startLoadScreen()
	_janitor:Cleanup()

	logo.Visible = true

	local skip = logo.SkipPrompt_0
	local skip_1 = logo.SkipPrompt_1

	skip.Visible = false
	skip_1.Visible = false

	loadingGui.LoadingAsset.Text = "Loading..."
	TweenService:Create(logo.Image.UIGradient, TweenInfo.new(0), { Offset = Vector2.new(0, 1) })
		:Play()

	loadingGui.Enabled = true

	startLoadingAnimation()
end

function LoadScreen.endLoadScreen()
	-- _janitor:Add(
	-- 	task.delay(0.25, function()
	-- 		_janitor:Cleanup()
	-- 	end),
	-- 	true
	-- )

	logo.Visible = false

	local fadeTween =
		TweenService:Create(loadingGui.Background, fadeTi, { BackgroundTransparency = 1 })

	fadeTween:Play()

	fadeTween.Completed:Connect(function()
		loadingGui.Enabled = false
	end)

	_janitor:Cleanup()
end

function LoadScreen.setDescription(msg: string, progress: number?)
	loadingGui.LoadingAsset.Text = msg

	if not progress then
		TweenService:Create(logo.Image.UIGradient, TweenInfo.new(0), { Offset = Vector2.new(0, 1) })
			:Play()
		return
	end

	local invertedProgress = math.abs(progress - 1)

	TweenService
		:Create(logo.Image.UIGradient, progressTi, { Offset = Vector2.new(0, invertedProgress) })
		:Play()
end

function LoadScreen.startHoldAnim(holdTime)
	local skipButtonTi = TweenInfo.new(holdTime)

	local skip = logo.SkipPrompt_0
	local skip_1 = logo.SkipPrompt_1

	TweenService:Create(skip.UIGradient, skipButtonTi, { Offset = Vector2.new(0, -1) }):Play()
	TweenService:Create(skip_1.UIGradient, skipButtonTi, { Offset = Vector2.zero }):Play()
end

function LoadScreen.endHoldAnim()
	local skipButtonTi = TweenInfo.new(0.2)

	local skip = logo.SkipPrompt_0
	local skip_1 = logo.SkipPrompt_1

	TweenService:Create(skip.UIGradient, skipButtonTi, { Offset = Vector2.zero }):Play()
	TweenService:Create(skip_1.UIGradient, skipButtonTi, { Offset = Vector2.new(0, 1) }):Play()
end

function LoadScreen.enableSkipButton(enable: boolean?)
	local skipButtonTi = TweenInfo.new(0.5)

	enable = enable == nil or enable == true

	local skip = logo.SkipPrompt_0
	local skip_1 = logo.SkipPrompt_1

	if enable then
		local skipJanitor = _janitor:AddObject(Janitor, "Destroy", "SkipButton")

		skip.Visible = true
		skip_1.Visible = true

		skip.TextTransparency = 1
		skip_1.TextTransparency = 1

		skip.UIGradient.Offset = Vector2.zero
		skip_1.UIGradient.Offset = Vector2.new(0, 1)

		TweenService:Create(skip, skipButtonTi, { TextTransparency = 0 }):Play()
		TweenService:Create(skip_1, skipButtonTi, { TextTransparency = 0 }):Play()
	else
		local hideTween = TweenService:Create(skip, skipButtonTi, { TextTransparency = 1 })
		TweenService:Create(skip_1, skipButtonTi, { TextTransparency = 1 }):Play()

		TweenService:Create(skip.UIGradient, skipButtonTi, { Offset = Vector2.zero }):Play()
		TweenService:Create(skip_1.UIGradient, skipButtonTi, { Offset = Vector2.new(0, 1) }):Play()

		hideTween.Completed:Connect(function(state)
			if state ~= Enum.PlaybackState.Completed then return end

			skip.Visible = false
			skip_1.Visible = false
		end)

		hideTween:Play()

		_janitor:Remove("SkipButton")
	end
end

return LoadScreen
