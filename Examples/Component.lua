local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Global = require(ReplicatedStorage.Shared.Global)

local Character = {}

function Character:add(entity, model: Model)
	-- insert constructor for component here

	return model
end

return Global.World.factory(Character)
