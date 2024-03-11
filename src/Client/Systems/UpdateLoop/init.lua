local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Globals = require(ReplicatedStorage.Shared.Globals)

local function startUpdateLoop()
	local function tryConnectSchedule(scheduleName, schedule)
		RunService[scheduleName]:Connect(schedule.start)
	end

	for scheduleName, schedule in Globals.Schedules do
		pcall(tryConnectSchedule, scheduleName, schedule)
	end
end

return Globals.Schedules.boot.job(startUpdateLoop)
