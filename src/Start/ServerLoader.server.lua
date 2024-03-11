--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Globals = require(ReplicatedStorage.Shared.Globals)

local Schedules = Globals.Modules.Schedules

-- boot
for _, module in Globals.Server:GetDescendants() do
	if not module:IsA("ModuleScript") then
		continue
	end

	local success, e = pcall(require, module)
	if not success then
		warn(`{module.Name} ERROR: {e}\n {debug.traceback()}`)
	end
end

-- tick
Schedules.init.start()
Schedules.boot.start()

RunService.Heartbeat:Connect(function(dt)
	Schedules.heartbeat.start(dt)
end)

Schedules.gameTick(RunService.Heartbeat, 3, Schedules.gameTick.start)
