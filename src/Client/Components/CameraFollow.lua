local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Janitor = require(Globals.Packages.Janitor)

local CameraFollow = {}

local BoundaryRaycastParams = RaycastParams.new()
BoundaryRaycastParams.CollisionGroup = "Default"
BoundaryRaycastParams.FilterType = Enum.RaycastFilterType.Include
BoundaryRaycastParams.FilterDescendantsInstances = {}
CameraFollow.BoundaryRaycastParams = BoundaryRaycastParams

function CameraFollow:add()
	local component = {
		janitor = Janitor.new(),
		horizontalOffset = 0,
		normal = -Vector3.zAxis,
		lastX = 0,
	}

	export type CameraFollow = typeof(component)
	return component
end

return Globals.World.factory(CameraFollow)
