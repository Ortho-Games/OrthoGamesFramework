local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local CameraComponent = require(ReplicatedStorage.Client.Camera.CameraComponent)
local Global = require(ReplicatedStorage.Shared.Global)
local CameraEntities = Global.World.query { CameraComponent }

local function processCamera(cameraComponent)
	local characterPosition = cameraComponent.Character:GetPivot().Position
	local cameraPosition = characterPosition + Vector3.new(0, 12, 0)

	cameraComponent.Camera.CFrame =
		CFrame.lookAt(cameraPosition, characterPosition)
end

return Global.Schedules.PreRender.job(function()
	for _, components in CameraEntities do
		local cameraComponent = components[CameraComponent]

		processCamera(cameraComponent)
	end
end)
