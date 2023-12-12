local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Stew = require(Globals.Packages.Stew)

local World = require(Globals.Shared.Modules.World)

local ClicksComponent = require(Globals.Server.Components.ClicksComponent)
local PlayerComponent = require(Globals.Server.Components.PlayerComponent)

local function newUser(player)
	local entity = World.entity()
	PlayerComponent.add(entity, player)
	ClicksComponent.add(entity)
	return entity
end

Players.PlayerAdded:Connect(newUser)
for _, player in Players:GetPlayers() do
	newUser(player)
end

return 1
