local Players = game:GetService("Players")
local ClicksComponent = {}

function ClicksComponent.setClicks(entity, value)
	local comp = ClicksComponent.get(entity)

	comp.clicks = value
end

function ClicksComponent.incClicks(entity, value)
	local comp = ClicksComponent.get(entity)

	comp.clicks += value

	-- example complexity
	-- Net:RemoteEvent("UpdateClicks"):FireClient(Players.get(entity), comp)
	-- ValueTracker:Get(entity, ClicksComponent.id).Value = comp.clicks
end

return ClicksComponent
