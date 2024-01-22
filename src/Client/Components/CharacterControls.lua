local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Janitor = require(Globals.Packages.Janitor)

local CharacterConfig = require(Globals.Shared.Config.Character)

local WALK_SPEED = CharacterConfig.WalkSpeed
local AIR_ACCEL_TIME = CharacterConfig.AirAccelTime

local CharacterControls = {}

function CharacterControls:add(
	entity: Model,
	root: BasePart,
	rootAttachment: Attachment,
	planeAttachment: Attachment
): CharacterControls
	local component = {
		janitor = Janitor.new(),
	}

	local groundSensor = Instance.new("ControllerPartSensor")
	groundSensor.SensorMode = Enum.SensorMode.Floor
	groundSensor.SearchDistance = 3.5
	groundSensor.Parent = root
	component.janitor:Add(groundSensor, "Destroy")
	component.groundSensor = groundSensor

	local controllerManager = Instance.new("ControllerManager")
	controllerManager.RootPart = root
	controllerManager.Parent = entity
	controllerManager.GroundSensor = groundSensor
	controllerManager.BaseMoveSpeed = WALK_SPEED
	controllerManager.BaseTurnSpeed = 10
	component.janitor:Add(controllerManager, "Destroy")
	component.controllerManager = controllerManager

	local groundController = Instance.new("GroundController")
	groundController.GroundOffset = 2
	groundController.AccelerationTime = 0.2
	groundController.DecelerationTime = 0.2
	groundController.FrictionWeight = 100
	groundController.BalanceRigidityEnabled = true
	groundController.Parent = controllerManager
	component.janitor:Add(groundController, "Destroy")
	component.groundController = groundController
	controllerManager.ActiveController = groundController

	local airController = Instance.new("AirController")
	airController.MoveMaxForce = root.AssemblyMass * WALK_SPEED / AIR_ACCEL_TIME
	airController.MaintainLinearMomentum = false
	airController.MaintainAngularMomentum = false
	airController.BalanceRigidityEnabled = true
	airController.Parent = controllerManager
	component.janitor:Add(airController, "Destroy")
	component.airController = airController

	local planeConstraint = Instance.new("PlaneConstraint")
	planeConstraint.Parent = root
	planeConstraint.Attachment0 = planeAttachment
	planeConstraint.Attachment1 = rootAttachment
	component.janitor:Add(planeConstraint, "Destroy")
	component.planeConstraint = planeConstraint

	export type CharacterControls = typeof(component)

	return component
end

function CharacterControls:remove(_, component)
	component.janitor:Destroy()
end

return Globals.World.factory(CharacterControls)
