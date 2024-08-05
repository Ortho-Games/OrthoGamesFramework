--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Shared.Global)
local Janitor = require(ReplicatedStorage.Packages.Janitor)

local PlayingAction = {}

local Player = require(ReplicatedStorage.Shared.Player.Components.Player)

local i = 0

export type PlayingActionComponent = {
	action: ModuleScript,
	janitor: Janitor.Janitor,
	_i: number,
} & { [string]: any } -- for extra properties that are injected like for the "branch" prop in the dash action

function PlayingAction:add(
	entity: number,
	action: ModuleScript,
	janitor: Janitor.Janitor?
): PlayingActionComponent
	i += 1
	-- print(i, "added action", action.Parent, action)

	local player: Player.PlayerComponent = Player.get(entity)
	if player then
		player.instance:SetAttribute("PlayingAction", action:GetFullName())
	end

	-- note: useful for debugging
	-- print("Adding", action, debug.traceback("Adding", 2))

	return {
		action = action,
		janitor = janitor or Janitor.new(),
		_i = i,
	}
end

function PlayingAction:remove(entity: number, comp: PlayingActionComponent): ()
	-- print(comp._i, "removed action", comp.action.Parent, comp.action)

	local player: Player.PlayerComponent = Player.get(entity)
	if player then player.instance:SetAttribute("PlayingAction", nil) end

	comp.janitor:RemoveNoClean("RemovePlayingActionOnCleanup")
	comp.janitor:Destroy()

	-- note: useful for debugging
	--print("Removing", comp.action, debug.traceback("Removing", 2))
end

return Global.World.factory(Global.InjectLifecycleSignals(PlayingAction))
