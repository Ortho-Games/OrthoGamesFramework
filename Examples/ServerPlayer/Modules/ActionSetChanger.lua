local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Player = require(ReplicatedStorage.Shared.Player.Components.Player)

local Characters = ServerStorage.Server:WaitForChild("Fighters")

local ActionSetChanger = {}

function ActionSetChanger.setActionSet(entity, actionSet)
	local playerInstance = Player.get(entity).instance

	local character = playerInstance:GetAttribute("CurrentFighter")

	local characterFolder = Characters:FindFirstChild(character)
	if not characterFolder then return end

	local actionSetFolder = characterFolder:FindFirstChild(actionSet)
	if not actionSetFolder then return end

	playerInstance:SetAttribute("CurrentActionSet", actionSet)
end

return ActionSetChanger
