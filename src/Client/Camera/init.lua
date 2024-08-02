local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local camera: Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

local Global = require(ReplicatedStorage.Shared.Global)
local cameraComponent = require(ReplicatedStorage.Client.Camera.CameraComponent)

return Global.Schedules.Boot.job(function()
	local character = player.Character or player.CharacterAdded:Wait()
	camera.CameraType = Enum.CameraType.Scriptable

	camera:GetPropertyChangedSignal("CameraType"):Once(function()
		camera.CameraType = Enum.CameraType.Scriptable
	end)

	local cameraEntity = Global.World.entity()
	cameraComponent.add(cameraEntity, character, camera)
end)
