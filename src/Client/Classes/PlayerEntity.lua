local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)

local ActionInput = require(Globals.Local.Components.ActionInput)
local ActionSet = require(Globals.Local.Components.ActionSet)
local Player = require(Globals.Local.Components.Player)
local PlayerEntityTracker = require(Globals.Shared.Modules.PlayerEntityTracker)

return function(player)
	local entity = Globals.World.entity()

	print("player was created yay")
	Player.add(entity, player)

	PlayerEntityTracker.add(entity, player)
	return entity
end
