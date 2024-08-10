local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sandwich = require(ReplicatedStorage.Packages.Sandwich)

local Util = require(ReplicatedStorage.Packages.OrthoUtil)

export type Schedule = typeof(Sandwich.schedule())

local jobToPathName = {}

local Schedules = {}

local function CreateScheduleProxy(settings: { [string]: any }?)
	local schedule

	local alreadyStarted = false
	schedule = Sandwich.schedule(settings)

	local self = setmetatable({}, { __index = schedule })

	self.job = function(func, ...)
		local pathName = debug.traceback(nil, 2)
		local job = schedule.job(func, ...)
		jobToPathName[job] = pathName:gsub("%s+", "")
		return job
	end

	self.start = function(...)
		if alreadyStarted then return schedule.start(...) end
		alreadyStarted = true
		return schedule.start(...)
	end

	function self.getGraphPaths()
		local graph = {}

		for job, jobs in schedule.graph do
			if not jobToPathName[job] then continue end

			graph[jobToPathName[job]] = Util.filter_map(jobs, function(_, childJob)
				return jobToPathName[childJob] or childJob
			end)
		end

		return graph
	end

	return self
end

function Schedules:Create(name: any, settings: { [string]: any }?)
	local schedule = CreateScheduleProxy(settings)
	rawset(self, name, schedule)
	return self[name]
end

setmetatable(Schedules, {
	__index = function(self, k)
		return Schedules:Create(k)
	end,
})

return Schedules
