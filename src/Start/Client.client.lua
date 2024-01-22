--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)

function Globals.World.spawned(entity)
	if typeof(entity) == "Instance" then
		entity.Destroying:Once(function()
			Globals.World.kill(entity)
		end)
	end
end

for _, descendant in Globals.Game:GetDescendants() do
	if descendant:IsA("ModuleScript") then
		pcall(require, descendant)
	end
end

if not game:IsLoaded() then
	game.Loaded:Wait()
end

Globals.Schedules.Boot.start()
