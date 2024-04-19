local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Utils = require(ReplicatedStorage.Shared.Modules.Util)
local modes = Utils.arrayToDict { "NONE", "VERBOSE", "DEBUG" }
local contexts = Utils.arrayToDict { "BOTH", "CLIENT", "SERVER" }

----------------------------------------------------------------
-- change these for settings
local mode = modes.VERBOSE
local context = contexts.BOTH
----------------------------------------------------------------

local IsStudio = RunService:IsStudio()
local IsClient = RunService:IsClient()
local IsServer = RunService:IsServer()

return function(...)
	if not IsStudio then return end
	if context == contexts.CLIENT and not IsClient then return end
	if context == contexts.SERVER and not IsServer then return end

	if mode == modes.VERBOSE then
		warn("[DEBUG]", ...)
	elseif mode == modes.DEBUG then
		local tb = debug.traceback("", 2)
		warn("[DEBUG]", ..., tb)
	end
end
