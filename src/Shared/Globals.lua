--!strict

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local localFolder = if RunService:IsServer() then ServerStorage.Server else ReplicatedStorage.Client

local world = require(localFolder.World)

return {
	Packages = ReplicatedStorage.Packages,
	Vendor = ReplicatedStorage.Vendor,
	Assets = ReplicatedStorage.Assets,
	Shared = ReplicatedStorage.Shared,
	Local = localFolder,
	World = world,
	Schedules = require(ReplicatedStorage.Shared.Modules.Schedules),
	Util = require(ReplicatedStorage.Shared.Modules.Util),
}
