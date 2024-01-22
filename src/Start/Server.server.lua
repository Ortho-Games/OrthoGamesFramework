--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)

local function assertPersistent(entity: any)
	if not workspace.StreamingEnabled then
		return
	end

	local modelAncestor = entity:FindFirstAncestorOfType("Model")
	if modelAncestor and modelAncestor.ModelStreamingMode == Enum.ModelStreamingMode.Persistent then
		return
	end

	error("FOOL! YOU DARE SET AN ENTITY TO A NONPERSISTENT INSTANCE!? REPLICATION WILL DIE! CHANGE IT TO A COMPONENT!")
end

function Globals.World.spawned(entity)
	if typeof(entity) == "Instance" then
		entity.Destroying:Once(function()
			assertPersistent(entity)
			Globals.World.kill(entity)
		end)
	end
end

for _, descendant in Globals.Game:GetDescendants() do
	if descendant:IsA("ModuleScript") then
		pcall(require, descendant)
	end
end

Globals.Schedules.Boot.start()
