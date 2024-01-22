local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)

local Tags = require(Globals.Game.Tags)

local Camera = require(Globals.Game.Components.Camera)
local CameraFollow = require(Globals.Game.Components.CameraFollow)
local Character = require(Globals.Game.Components.Character)
local CharacterInput = require(Globals.Game.Components.CharacterInput)
local CharacterControls = require(Globals.Game.Components.CharacterControls)

local ControlledCharacters = Globals.World.query({ Character, CharacterControls, CharacterInput, Tags.Controlling })

local BoundaryRaycastParams = CameraFollow.BoundaryRaycastParams

local CAMERA_DAMPING = 5

local SPACING_SCALE = 0.25
local MIN_CAMERA_FOCAL_SIZE = 30

local function getBoundaryClampedPosition(cameraPosition)
	local planePosition = cameraPosition * Vector3.new(1, 1)
	local aspectRatio = math.min(workspace.CurrentCamera.ViewportSize.X / workspace.CurrentCamera.ViewportSize.Y, 1.75)
	local halfFocalHeight = math.tan(math.rad(workspace.CurrentCamera.FieldOfView / 2)) * cameraPosition.Z / 2
	local halfFocalWidth = halfFocalHeight * 1.25 * aspectRatio

	local upResult = workspace:Raycast(planePosition, Vector3.yAxis * halfFocalHeight, BoundaryRaycastParams)
	if upResult then
		cameraPosition -= Vector3.yAxis * (halfFocalHeight - upResult.Distance)
	end

	local downResult = workspace:Raycast(planePosition, -Vector3.yAxis * halfFocalHeight, BoundaryRaycastParams)
	if downResult then
		cameraPosition += Vector3.yAxis * (halfFocalHeight - downResult.Distance)
	end

	local rightResult = workspace:Raycast(planePosition, Vector3.xAxis * halfFocalWidth, BoundaryRaycastParams)
	if rightResult then
		cameraPosition -= Vector3.xAxis * (halfFocalWidth - rightResult.Distance)
	end

	local leftResult = workspace:Raycast(planePosition, -Vector3.xAxis * halfFocalWidth, BoundaryRaycastParams)
	if leftResult then
		cameraPosition += Vector3.xAxis * (halfFocalWidth - leftResult.Distance)
	end

	return cameraPosition
end

local function getDistanceToKeepRegionInView(furthestUp, furthestDown, furthestLeft, furthestRight)
	local aspectRatio = math.min(workspace.CurrentCamera.ViewportSize.X / workspace.CurrentCamera.ViewportSize.Y, 1.75)

	local focalHeight = (1 + SPACING_SCALE) * math.max(MIN_CAMERA_FOCAL_SIZE, math.abs(furthestUp - furthestDown))
	local verticalFOV = math.rad(workspace.CurrentCamera.FieldOfView)
	local verDistance = focalHeight / (2 * math.tan(verticalFOV / 2))

	local focalWidth = (1 + SPACING_SCALE)
		* math.max(MIN_CAMERA_FOCAL_SIZE * aspectRatio, math.abs(furthestRight - furthestLeft))
	local horizontalFOV = math.atan(math.tan(verticalFOV / 2) * aspectRatio) * 2
	local horDistance = focalWidth / (2 * math.tan(horizontalFOV / 2))

	return math.max(verDistance, horDistance)
end

local function getDesiredCameraPosition()
	local totalCharacters = 0
	local furthestUp, furthestDown, furthestRight, furthestLeft

	for _, characterComponents in ControlledCharacters do
		local characterRoot = characterComponents[Character].root
		totalCharacters += 1

		if not furthestUp then
			furthestUp = characterRoot.Position.Y
			furthestDown = characterRoot.Position.Y
		else
			furthestUp = math.min(characterRoot.Position.Y, furthestUp)
			furthestDown = math.min(characterRoot.Position.Y, furthestDown)
		end

		if not furthestRight then
			furthestRight = characterRoot.Position.X
			furthestLeft = characterRoot.Position.X
		else
			furthestRight = math.min(characterRoot.Position.X, furthestRight)
			furthestLeft = math.min(characterRoot.Position.X, furthestLeft)
		end
	end

	local planePosition = Vector3.new((furthestLeft + furthestRight) / 2, (furthestUp + furthestDown) / 2)

	if totalCharacters == 0 then
		return workspace.CurrentCamera.Position
	elseif totalCharacters == 1 then
		local cameraDistance = (1 + SPACING_SCALE)
			* MIN_CAMERA_FOCAL_SIZE
			/ (2 * math.tan(workspace.CurrentCamera.FieldOfView / 2))
		local cameraPosition = planePosition + Vector3.zAxis * cameraDistance
		cameraPosition = getBoundaryClampedPosition(cameraPosition)

		return cameraPosition
	else
		local cameraDistance = getDistanceToKeepRegionInView(furthestUp, furthestDown, furthestLeft, furthestRight)
		local cameraPosition = planePosition + Vector3.zAxis * cameraDistance
		return cameraPosition
	end
end

return Globals.Schedules.UpdateCamera.job(function(dt)
	local camera = Camera.get(workspace.CurrentCamera)
	local cameraFollow = CameraFollow.get(workspace.CurrentCamera)
	if not (camera and cameraFollow and Tags.Controlling.get(workspace.CurrentCamera)) then
		return
	end

	local rate = 1 - math.pow(2, -CAMERA_DAMPING * dt)
	local desiredCFrame = CFrame.fromMatrix(getDesiredCameraPosition(), Vector3.xAxis, Vector3.yAxis)
	workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(desiredCFrame, rate)
end)
