local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)

local ClicksDisplay = {}

function ClicksDisplay.make(props)
	local ui = Instance.new("ScreenGui")
	ui.Parent = Players.LocalPlayer.PlayerGui

	local frame = Instance.new("Frame")
	frame.Name = "Container"
	frame.Size = UDim2.fromScale(0.1, 0.1)
	frame.Position = UDim2.fromScale(0.3, 0.5)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Parent = ui

	local clicksDisplay = Instance.new("TextLabel")
	clicksDisplay.Name = "ClicksDisplay"
	clicksDisplay.Text = props.clicks
	clicksDisplay.Size = UDim2.fromScale(1, 1)
	clicksDisplay.Parent = frame

	return ui
end

function ClicksDisplay.update(ui, props)
	-- if no ui, no ui to update
	print(ui, props)
	ui.Container.ClicksDisplay.Text = props.clicks
end

return ClicksDisplay
