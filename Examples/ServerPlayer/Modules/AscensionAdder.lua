local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Global = require(ReplicatedStorage.Shared.Global)

local Ascended = require(ReplicatedStorage.Shared.Player.Components.Ascended)
local AscensionMeter =
	require(ServerStorage.Server.Player.Components.AscensionMeter)
local Player = require(ReplicatedStorage.Shared.Player.Components.Player)

local ActionSetChanger =
	require(ServerStorage.Server.Player.Modules.ActionSetChanger)

local AscensionAdder = {}

function AscensionAdder.set(entity, number: number)
	local playerInstance = Player.get(entity)
	if not playerInstance then return end
	playerInstance = playerInstance.instance

	local comp = AscensionMeter.get(entity)
	if not comp then
		warn(`entity {entity} has no AscensionMeter, failed to set {number}`)
		return
	end

	comp.cur = math.min(comp.max, number)
	playerInstance:SetAttribute("ascension", comp.cur)

	-- Global.DEBUG("Updated ascension attribute for", entity, "to", comp.cur)
end

function AscensionAdder.ascend(entity)
	local playerInstance = Player.get(entity).instance

	local comp = AscensionMeter.get(entity)
	if not comp then
		warn(`entity {entity} has no AscensionMeter, failed to set ascend`)
		return
	end

	if comp.isAscended then return end

	if comp.cur >= comp.max then
		comp.isAscended = true
		playerInstance:SetAttribute("isAscended", true)
		playerInstance:SetAttribute("CurrentActionSet", "Ascended")
		-- ActionSetChanger.setActionSet(entity, "Ascended")
	end

	local ascended = Ascended.add(entity)
	ascended.janitor:Add(
		playerInstance
			:GetAttributeChangedSignal("CurrentActionSet")
			:Once(function()
				Ascended.remove(entity)
			end),
		"Disconnect"
	)
end

function AscensionAdder.add(entity, amount: number)
	local comp = AscensionMeter.get(entity)
	if not comp then
		warn(`entity {entity} has no AscensionMeter, failed to add {amount}`)
		return
	end

	if comp.isAscended then return end

	AscensionAdder.set(entity, comp.cur + amount)
end

return AscensionAdder
