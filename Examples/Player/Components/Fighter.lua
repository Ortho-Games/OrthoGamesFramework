--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Shared.Global)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Player = require(ReplicatedStorage.Shared.Player.Components.Player)
local Signal = require(ReplicatedStorage.Packages.Signal)

local Fighter = {}

export type FighterComponent = {
	fighterChanged: Signal.Signal<string>,
	fighterJanitor: Janitor.Janitor,
}

function Fighter:add(entityId: number)
	local plrComponent: Player.PlayerComponent = Player.get(entityId)
	local plr = plrComponent.instance

	local janitor = Janitor.new()
	local changedSignal = Signal.new()

	janitor:Add(
		plr:GetAttributeChangedSignal("CurrentFighter"):Connect(function()
			local fighter = plr:GetAttribute("CurrentFighter")
			if fighter then changedSignal:Fire(fighter) end
		end),
		"Disconnect"
	)

	local fighterData = {
		fighterChanged = changedSignal,
		fighterJanitor = janitor,
	}

	return fighterData
end

function Fighter:remove(_entityId: number, fighter: FighterComponent)
	fighter.fighterJanitor:Cleanup()
end

return Global.World.factory(Fighter)
