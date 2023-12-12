--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Stew = require(Globals.Packages.Stew)

local World = require(Globals.Shared.Modules.World)

local ProfileComponent = {}

ProfileComponent.factory = World.factory({
	add = function(factory, entity, player)
		return player
	end,

	remove = function(factory, entity, component) end,
})

return ProfileComponent.factory
