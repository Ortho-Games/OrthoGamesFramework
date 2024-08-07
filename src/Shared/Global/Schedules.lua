local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sandwich = require(ReplicatedStorage.Packages.Sandwich)

local Util = require(ReplicatedStorage.Packages.OrthoUtil)

export type Schedule = typeof(Sandwich.schedule())
export type Schedules = { [any]: Schedule }

local jobToPathName = {}

local Schedules: Schedules = {}

local function CreateScheduleProxy(scheduleName)
	local schedule

	local alreadyStarted = false
	local jobRan = {}
	schedule = Sandwich.schedule {
		-- before = function(job, ...)
		-- 	-- if jobRan[job] then return end
		-- 	-- jobRan[job] = true
		-- 	-- print(`- {scheduleName}:`, jobToPathName[job])
		-- end,
	}

	local self = setmetatable({}, { __index = schedule })

	self.job = function(func, ...)
		local pathName = debug.traceback(nil, 2)
		local job = schedule.job(func, ...)
		jobToPathName[job] = pathName:gsub("%s+", "")
		--warn("Job added:", pathName)
		return job
	end

	self.start = function(...)
		if alreadyStarted then return schedule.start(...) end
		alreadyStarted = true
		-- print(scheduleName, self.getGraphPaths())
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

setmetatable(Schedules, {
	__index = function(self, k)
		local schedule = CreateScheduleProxy(k)
		rawset(self, k, schedule)
		return self[k]
	end,
})

return Schedules
