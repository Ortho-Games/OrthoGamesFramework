local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Camera = require(Globals.Game.Components.Camera)

local function setCameraType()
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
end

return Globals.Schedules.Boot.job(function()
	setCameraType()
	workspace.CurrentCamera:GetPropertyChangedSignal("CameraType"):Connect(setCameraType)
	Camera.add(workspace.CurrentCamera)

	RunService.PreRender:Connect(function(dt)
		Globals.Schedules.UpdateCamera.start(dt)
	end)
end)
