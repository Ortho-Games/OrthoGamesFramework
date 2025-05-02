local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local InjectLifecycleSignals = require(ReplicatedStorage.Shared.Modules.InjectLifecycleSignals)
local World = require(ReplicatedStorage.Shared.Modules.World)

local entityCache: { [Player]: number } = {}
local Player = {}

--[[
.getEntity(player: Player): number?
Function will return entity id from Player Instance
]]
function Player.getEntity(player: Player): number?
	return entityCache[player]
end

function Player:add(entity, player): Player
	entityCache[player] = entity
	return player
end

function Player:removed(entity, comp: Player)
	entityCache[comp] = nil
end

return World.factory(InjectLifecycleSignals(Player))
