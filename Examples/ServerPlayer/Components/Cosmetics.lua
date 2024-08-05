local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Global = require(ReplicatedStorage.Shared.Global)

local Cosmetics = {}

function Cosmetics:add(entity)
	-- insert constructor for component here
	return 1
end

return Global.World.factory(Cosmetics)
