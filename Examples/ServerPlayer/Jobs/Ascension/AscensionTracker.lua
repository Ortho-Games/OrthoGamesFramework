local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Global = require(ReplicatedStorage.Shared.Global)

local AscensionAdder =
	require(ServerStorage.Server.Player.Modules.AscensionAdder)
local AscensionMeter =
	require(ServerStorage.Server.Player.Components.AscensionMeter)
local Character = require(ReplicatedStorage.Shared.Player.Components.Character)
local Player = require(ReplicatedStorage.Shared.Player.Components.Player)

local function onAscensionMeterAdded(entity, comp)
	local player = Player.get(entity)
	player.instance:SetAttribute("ascension", comp.cur)
	player.instance:SetAttribute("maxAscension", comp.max)
	player.instance:SetAttribute("isAscended", comp.isAscended)
end

return Global.Schedules.Init.job(function()
	Character.onAdded:Connect(function(playerEntity)
		AscensionAdder.set(playerEntity, 0)
	end)
	AscensionMeter.onAdded:Connect(onAscensionMeterAdded)
end)
