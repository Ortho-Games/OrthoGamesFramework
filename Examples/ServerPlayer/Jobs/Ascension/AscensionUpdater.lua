local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Global = require(ReplicatedStorage.Shared.Global)

local AscensionMeter =
	require(ServerStorage.Server.Player.Components.AscensionMeter)
local Player = require(ReplicatedStorage.Shared.Player.Components.Player)
local PlayingAction =
	require(ReplicatedStorage.Shared.Player.Components.PlayingAction)

local query = Global.World.query { AscensionMeter, Player }

local DECAY_RATE = 1

return Global.Schedules.PreSimulation.job(function(dt)
	for entity, components in query do
		local ascensionComp = components[AscensionMeter]
		local player = components[Player]

		if not ascensionComp.isAscended then continue end

		local new = ascensionComp.cur - dt * DECAY_RATE

		if new < 0 and not PlayingAction.get(entity) then
			ascensionComp.isAscended = false
			player.instance:SetAttribute("isAscended", false)
			player.instance:SetAttribute("CurrentActionSet", "Default")
		end

		ascensionComp.cur = new
		player.instance:SetAttribute("ascension", ascensionComp.cur)
	end
end)
