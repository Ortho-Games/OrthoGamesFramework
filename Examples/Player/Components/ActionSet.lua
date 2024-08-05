local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Shared.Global)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)

local InputEnum = require(ReplicatedStorage.Shared.Enums.Input)

local ActionSet = {}
ActionSet.onActionAdded =
	Signal.new() :: Signal.Signal<(number, ModuleScript, Janitor.Janitor)>

export type ActionSetComponent = {
	janitor: Janitor.Janitor,
	actions: { [InputEnum.InputEnum]: ModuleScript },
	lut: { [ModuleScript]: InputEnum.InputEnum },
	set: (
		self: ActionSetComponent,
		actionSet: { [InputEnum.InputEnum]: ModuleScript }
	) -> (),
}

function ActionSet:add(entity: number): ActionSetComponent
	local comp = {}
	comp.janitor = Janitor.new()
	comp.actions = {}
	comp.lut = {}

	for inputEnum in InputEnum do
		comp.janitor:Add(Janitor.new(), "Destroy", inputEnum)
	end

	function comp:set(actionSet: { [InputEnum.InputEnum]: ModuleScript })
		table.clear(comp.actions)
		table.clear(comp.lut)
		if not actionSet then
			for inputEnum in InputEnum do
				comp.janitor:Get(inputEnum):Cleanup()
			end

			return
		end

		for inputEnum in InputEnum do
			local action = actionSet[inputEnum]
			if not action or action == comp.actions[inputEnum] then continue end

			local actionJanitor: Janitor.Janitor = comp.janitor:Get(inputEnum)
			actionJanitor:Cleanup()

			comp.actions[inputEnum] = action
			comp.lut[action] = inputEnum

			if action then
				ActionSet.onActionAdded:Fire(entity, action, actionJanitor)
			end
		end
	end

	return comp
end

function ActionSet:remove(_, comp: ActionSetComponent)
	comp.janitor:Destroy()
end

return Global.World.factory(ActionSet)
