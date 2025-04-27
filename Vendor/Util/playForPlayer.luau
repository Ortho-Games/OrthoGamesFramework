local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local isClient = RunService:IsClient()

return function(player, func, ...)
	if isClient and Players.LocalPlayer == player then return task.spawn(func, ...) end
	return nil
end
