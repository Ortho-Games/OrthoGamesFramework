local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Shared.Global)

local Janitor = require(ReplicatedStorage.Packages.Janitor)

local Ascended = {}

function Ascended:add(entity)
	return {
		janitor = Janitor.new(),
	}
end

function Ascended:remove(entity, comp)
	comp.janitor:Destroy()
end

return Global.World.factory(Ascended)
