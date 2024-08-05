local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Shared.Global)

local Janitor = require(ReplicatedStorage.Packages.Janitor)

local CharacterEntityTracker =
	require(ReplicatedStorage.Shared.Player.Modules.CharacterEntityTracker)

local Character = {}

type CharacterModel = Model & {
	HumanoidRootPart: BasePart,
	Humanoid: Humanoid,
}

export type CharacterComponent = {
	janitor: Janitor.Janitor,
	instance: CharacterModel,
}

function Character:add(
	entity: number,
	characterInstance: CharacterModel
): CharacterComponent
	CharacterEntityTracker.add(entity, characterInstance)

	return {
		janitor = Janitor.new(),
		instance = characterInstance,
	}
end

function Character:remove(_, comp: CharacterComponent)
	comp.janitor:Destroy()
end

return Global.World.factory(Global.InjectLifecycleSignals(Character))
