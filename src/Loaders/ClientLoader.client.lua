local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Globals = require(ReplicatedStorage.Shared.Globals)

local Schedules = require(Globals.Shared.Modules.Schedules)

-- boot
for _, module in Globals.Client.Systems:GetDescendants() do
	if not module:IsA("ModuleScript") then
		continue
	end

	local success, e = pcall(require, module)
	if not success then
		warn(e)
	end
end

-- tick
Schedules.boot.start()

RunService.RenderStepped:Connect(function(dt)
	Schedules.heartbeat.start(dt)
end)

Schedules.tick(RunService.Heartbeat, 3, Schedules.gameTick.start)
