--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals: {} = require(ReplicatedStorage.Shared.Globals)
local Net: {} = require(Globals.Packages.Net)

local Schedules: {} = require(Globals.Shared.Modules.Schedules)

-- local query = World.query({ PlayerComponent, ClicksComponent })

local ClicksComponent: {} = require(Globals.Server.Components.ClicksComponent)

local Profiles: {} = require(Globals.Server.Modules.Profiles)

local ClicksSystem = {
	id = "clicks",
	defaultData = {
		clicks = 0,
	},
}

Schedules.init.job(function()
	Profiles.addDefaultData(ClicksSystem.id, ClicksSystem.defaultData)
end)

return Schedules.boot.job(function()
	Net:Connect("Clicked", function(player)
		local component = ClicksComponent.get(player)

		if component then
			component.clicks += 1
		end

		-- print(component)
	end)
end)
