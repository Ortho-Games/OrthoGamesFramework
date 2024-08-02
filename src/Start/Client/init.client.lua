--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Global = require(ReplicatedStorage.Shared.Global)
local Net = require(ReplicatedStorage.Packages.Net)

Global.Util.requireDescendants(ReplicatedStorage.Client)
Global.Util.requireDescendants(ReplicatedStorage.Shared)

Global.Schedules.Init.start()
Global.Schedules.Boot.start()

for scheduleName, schedule in Global.Schedules :: any do
	pcall(function()
		RunService[scheduleName]:Connect(schedule.start)
	end)
end
