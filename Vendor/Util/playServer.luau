local RunService = game:GetService("RunService")
local isClient = RunService:IsClient()

return function(func: (...any) -> (), ...)
	if not isClient then return task.spawn(func, ...) end
	return nil
end
