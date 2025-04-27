local RunService = game:GetService("RunService")
local isClient = RunService:IsClient()

return function(func, ...)
	if isClient then return task.spawn(func, ...) end
	return nil
end
