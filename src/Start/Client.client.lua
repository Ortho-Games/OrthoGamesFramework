--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Global = require(ReplicatedStorage.Shared.Global)

-- insert wait for Fighters?
ReplicatedStorage.Client:WaitForChild("Fighters")

warn(
	Global.Util.filter_map(
		ReplicatedStorage.Client:GetDescendants(),
		function(_, v)
			if v:IsA("ModuleScript") then return v:GetFullName() end
			return nil
		end
	)
)

Global.Util.requireDescendants(ReplicatedStorage.Client)
Global.Util.requireDescendants(ReplicatedStorage.Shared)

Global.Schedules.Init.start()
Global.Schedules.Boot.start()

for scheduleName, schedule in Global.Schedules :: any do
	pcall(function()
		RunService[scheduleName]:Connect(schedule.start)
	end)
end
