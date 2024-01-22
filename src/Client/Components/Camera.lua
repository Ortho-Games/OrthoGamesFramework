local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Janitor = require(Globals.Packages.Janitor)

local Camera = {}

function Camera:add()
	local component = {
		janitor = Janitor.new(),
		state = nil,
	}

	export type Camera = typeof(component)
	return component
end

return Globals.World.factory(Camera)
