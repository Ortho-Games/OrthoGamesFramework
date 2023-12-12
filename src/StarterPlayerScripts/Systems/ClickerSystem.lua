local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Net = require(Globals.Packages.Net)
local Schedules = require(Globals.Shared.Modules.Schedules)

local function onClick(name, state, type)
	if state ~= Enum.UserInputState.Begin then
		return
	end

	print("Clicked!")
	Net:RemoteEvent("Clicked"):FireServer()
	-- get entity of localplayer err fire server to increase?
end

return Schedules.boot.job(function()
	ContextActionService:BindAction("Click", onClick, false, Enum.UserInputType.MouseButton1)
end)
