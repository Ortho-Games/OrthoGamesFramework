--!strict

local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Net = require(Globals.Packages.Net)

local Schedules = require(Globals.Shared.Modules.Schedules)
local World = require(ReplicatedStorage.Shared.Modules.World)

local PlayerComponent = require(Globals.Server.Components.PlayerComponent)
local ClicksComponent = require(Globals.Server.Components.ClicksComponent)

-- local query = World.query({ PlayerComponent, ClicksComponent })

return Schedules.boot.job(function()
	Net:Connect("Clicked", function(player)
		ClicksComponent.get(player).clicks += 1
	end)
end)
