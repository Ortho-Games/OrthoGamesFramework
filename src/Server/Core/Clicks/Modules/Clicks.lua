local Players = game:GetService("Players")
local ClicksComponent = {}

function ClicksComponent.setClicks(entity, value)
	local comp = ClicksComponent.get(entity)

	comp.clicks = value
end

function ClicksComponent.incClicks(entity, value)
	local comp = ClicksComponent.get(entity)

	comp.clicks += value
end

return ClicksComponent
