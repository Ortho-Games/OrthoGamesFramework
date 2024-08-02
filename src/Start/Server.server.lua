--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local Global = require(ReplicatedStorage.Shared.Global)

local s

-- for _, descendant in ServerStorage.Server:GetDescendants() do
-- 	if
-- 		descendant:IsA("ModuleScript")
-- 		and not descendant:FindFirstAncestor("Client")
-- 		and descendant.Name ~= "Client"
-- 	then
-- 		s = os.clock()
-- 		local succ, err = pcall(require, descendant)
-- 		local t = os.clock() - s
-- 		if t > 0.2 then
-- 			warn(
-- 				"[Server] time to require",
-- 				descendant:GetFullName(),
-- 				os.clock() - s
-- 			)
-- 		end

-- 		if not succ then warn(descendant, err) end
-- 	end
-- end

s = os.clock()
warn("[Server] starting server requires...")
Global.Util.requireDescendants(ServerStorage.Server)
warn("[Server] time to require server:", os.clock() - s)

s = os.clock()
warn("[Server] starting shared requires...")
Global.Util.requireDescendants(ReplicatedStorage.Shared)
warn("[Server] time to require shared:", os.clock() - s)

s = os.clock()
warn("[Server] starting run start...")
Global.Schedules.Init.start()
warn("[Server] time to run init:", os.clock() - s)

s = os.clock()
warn("[Server] starting boot start...")
Global.Schedules.Boot.start()
warn("[Server] time to boot:", os.clock() - s)

for scheduleName, schedule in Global.Schedules :: any do
	pcall(function()
		RunService[scheduleName]:Connect(schedule.start)
	end)
end
