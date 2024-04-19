--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Globals = require(ReplicatedStorage.Shared.Globals)

Globals.Util.requireDescendants(Globals.Local)
Globals.Util.requireDescendants(Globals.Shared)

if not game:IsLoaded() then game.Loaded:Wait() end

Globals.Schedules.boot.start()

local function tryConnectSchedule(scheduleName, schedule)
	RunService[scheduleName]:Connect(schedule.start)
end

for scheduleName, schedule in Globals.Schedules do
	pcall(tryConnectSchedule, scheduleName, schedule)
end
