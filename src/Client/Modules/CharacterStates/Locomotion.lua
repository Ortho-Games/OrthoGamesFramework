local Transitions = {}
function Transitions.Sliding() end
function Transitions.WallRunning() end
function Transitions.Dashing() end
function Transitions.LedgeClimbing() end

function onEnter() end
function onUpdate() end
function onExit() end

return {
	Enter = onEnter,
	Update = onUpdate,
	Exit = onExit,

	Transitions = Transitions,
}
