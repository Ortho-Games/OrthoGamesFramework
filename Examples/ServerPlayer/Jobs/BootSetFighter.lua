local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Global = require(ReplicatedStorage.Shared.Global)
local Net = require(ReplicatedStorage.Packages.Net)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Global = require(ReplicatedStorage.Shared.Global)

local AscensionMeter =
	require(ServerStorage.Server.Player.Components.AscensionMeter)
local Fighter = require(ReplicatedStorage.Shared.Player.Components.Fighter)

local Player = require(ReplicatedStorage.Shared.Player.Components.Player)

local PlayerEntityTracker =
	require(ReplicatedStorage.Shared.Player.Modules.PlayerEntityTracker)

local DEFAULT_FIGHTER = "Kashimo"

local function setFighter(entity, fighterName)
	local playerInstance = Player.get(entity).instance
	playerInstance:SetAttribute("CurrentFighter", fighterName)
	playerInstance:SetAttribute("CurrentActionSet", "Default")

	if AscensionMeter.get(entity) then AscensionMeter.remove(entity) end
	AscensionMeter.add(entity)

	playerInstance:LoadCharacter()
end

local function BootSetFighter()
	for entity, components in Global.World.query { Player } do
		Fighter.add(entity)
		setFighter(entity, DEFAULT_FIGHTER)
	end

	Player.onAdded:Connect(function(entity, player)
		Fighter.add(entity)
		setFighter(entity, DEFAULT_FIGHTER)
	end)

	Net:Connect("RequestCharacterChange", function(playerInstance, fighterName)
		local playerEntity = PlayerEntityTracker.get(playerInstance)
		if not playerEntity then return end
		-- @TODO: enumerate fighterName for validation and serialization
		setFighter(playerEntity, fighterName)
	end)
end

return Global.Schedules.Boot.job(BootSetFighter)
