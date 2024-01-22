--!strict

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Stew = require(ReplicatedStorage.Packages.Stew)
local Sandwich = require(ReplicatedStorage.Packages.Sandwich)

local gameFolder = if RunService:IsServer() then ServerStorage.Server else ReplicatedStorage.Client

local schedules = {}
for _, child in gameFolder.Systems:GetChildren() do
	schedules[child.Name] = Sandwich.schedule()
end

return {
	Packages = ReplicatedStorage.Packages,
	Vendor = ReplicatedStorage.Vendor,
	Assets = ReplicatedStorage.Assets,
	Shared = ReplicatedStorage.Shared,
	Game = gameFolder,
	Schedules = schedules,
	World = Stew.world({}),
}
