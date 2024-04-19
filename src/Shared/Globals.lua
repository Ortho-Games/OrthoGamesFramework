--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local localFolder = if RunService:IsServer()
	then ServerStorage.Server
	else ReplicatedStorage.Client

local Sandwich = require(ReplicatedStorage.Packages.Sandwich)

local schedules = {}
schedules.boot = Sandwich.schedule()

local world = require(localFolder.World)

local runServiceEvents =
	{ "PostSimulation", "PreSimulation", "PreRender", "PreAnimation" }
for _, event in runServiceEvents do
	-- print(event)
	schedules[event] = Sandwich.schedule()
end

return {
	Packages = ReplicatedStorage.Packages,
	Vendor = ReplicatedStorage.Vendor,
	Assets = ReplicatedStorage.Assets,
	Shared = ReplicatedStorage.Shared,
	Local = localFolder,
	World = world,
	Schedules = schedules,
	Util = require(ReplicatedStorage.Shared.Modules.Util),
	DEBUG = require(ReplicatedStorage.Shared.Modules.DebugUtil),
}
