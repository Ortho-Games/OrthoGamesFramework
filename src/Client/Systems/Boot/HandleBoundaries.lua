local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)

local CameraFollow = require(Globals.Game.Components.CameraFollow)

local boundaries = {}

local function onBoundaryAdded(boundary)
	table.insert(boundaries, boundary)
	CameraFollow.BoundaryRaycastParams.FilterDescendantsInstances = boundaries
end

local function onBoundaryRemoved(boundary)
	table.remove(boundaries, table.find(boundaries, boundary))
end

return Globals.Schedules.Boot.job(function()
	CollectionService:GetInstanceAddedSignal("Boundary"):Connect(onBoundaryAdded)
	CollectionService:GetInstanceRemovedSignal("Boundary"):Connect(onBoundaryRemoved)

	for _, floor in CollectionService:GetTagged("Boundary") do
		onBoundaryAdded(floor)
	end
end)
