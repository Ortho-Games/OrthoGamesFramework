local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Janitor = require(Globals.Packages.Janitor)

local Player = {}

function Player:add()
	return {
		janitor = Janitor.new(),
	}
end

return Globals.World.factory(Player)
