local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Net = require(Globals.Packages.Net)
local Schedules = require(Globals.Shared.Modules.Schedules)

local ClickerSystem = {}

ClickerSystem.onClick = function(name, state, type)
	if state ~= Enum.UserInputState.Begin then
		return
	end

	print("Clicked!")
	Net:RemoteEvent("Clicked"):FireServer()
end

local function onBoot()
	ContextActionService:BindAction("Click", ClickerSystem.onClick, false, Enum.UserInputType.MouseButton1)
end

ClickerSystem.boot = Schedules.boot.job(onBoot)

return ClickerSystem
