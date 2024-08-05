local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Global = require(ReplicatedStorage.Shared.Global)

local Finisher = {}

-- this is hardcode should be changed later.
local Electrocute = require(ServerStorage.Server.Executions.Modules.Electrocute)

function Finisher:add(entity)
	-- @TODO: Maybe load this in from profile.

	return Electrocute
end

return Global.World.factory(Finisher)
