--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Stew = require(Globals.Packages.Stew)
local LemonSignal = require(Globals.Packages.LemonSignal)

local world = Stew.world({})
world.addedSignal = LemonSignal.new()

local function assertPersistent(entity: any)
	if
		not (
			RunService:IsServer()
			and workspace.StreamingEnabled
			and (workspace.ModelStreamingBehavior == Enum.ModelStreamingBehavior.Improved and entity:IsA("Model"))
		)
		or (
			entity:FindFirstAncestorOfType("Model")
			and entity:FindFirstAncestorOfType("Model").ModelStreamingMode == Enum.ModelStreamingMode.Persistent
		)
	then
		return
	end

	error("FOOL! YOU DARE SET AN ENTITY TO A NONPERSISTENT INSTANCE!? REPLICATION WILL DIE! CHANGE IT TO A COMPONENT!")
end

function world:spawned(entity: any)
	if typeof(entity) == "Instance" then
		assertPersistent(entity)
		entity.Destroying:Once(function()
			world.kill(entity)
		end)
	end
end

function world:killed(entity: any) end

return world
