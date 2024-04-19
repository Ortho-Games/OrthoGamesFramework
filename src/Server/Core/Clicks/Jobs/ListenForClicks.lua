local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Net = require(Globals.Packages.Net)

local ClicksComponent = require(Globals.Local.Core.Clicks.Components.Clicks)

local function onPlayerClicked(player)
	local component = ClicksComponent.get(player)

	if not component then return end

	component.clicks += 1
	if component.clicks > 40 then ClicksComponent.remove(player) end
end

local function onBoot()
	Net:Connect("Clicked", onPlayerClicked)
end

return Globals.Schedules.boot.job(onBoot)
