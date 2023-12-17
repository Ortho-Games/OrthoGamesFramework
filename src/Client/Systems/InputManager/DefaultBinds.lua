local Actions = {}
Actions.Movement = {
	KeyboardMouse = {
		KeyCodes = { Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D },
		UiTags = {},
		UserInputTypes = {},
	},

	Gamepad = {
		KeyCodes = {
			Enum.KeyCode.Thumbstick1,
		},
	},

	Touch = nil,
	All = nil,
}

local ActionMaps = {
	Character = { 'Movement' },
}

return {
	Actions = Actions,
	ActionMaps = ActionMaps,

	DeviceTypes = { 'KeyboardMouse', 'Gamepad', 'Touch' },
	InputTypeToDeviceType = {
		[Enum.UserInputType.Keyboard] = 'KeyboardMouse',
		[Enum.UserInputType.MouseButton1] = 'KeyboardMouse',
		[Enum.UserInputType.MouseButton2] = 'KeyboardMouse',
		[Enum.UserInputType.MouseButton3] = 'KeyboardMouse',
		[Enum.UserInputType.MouseMovement] = 'KeyboardMouse',
		[Enum.UserInputType.MouseWheel] = 'KeyboardMouse',

		[Enum.UserInputType.Gamepad1] = 'Gamepad',
		[Enum.UserInputType.Gamepad2] = 'Gamepad',
		[Enum.UserInputType.Gamepad3] = 'Gamepad',
		[Enum.UserInputType.Gamepad4] = 'Gamepad',
		[Enum.UserInputType.Gamepad5] = 'Gamepad',
		[Enum.UserInputType.Gamepad6] = 'Gamepad',
		[Enum.UserInputType.Gamepad7] = 'Gamepad',
		[Enum.UserInputType.Gamepad8] = 'Gamepad',

		[Enum.UserInputType.Touch] = 'Touch',
		[Enum.UserInputType.Accelerometer] = 'Touch',
		[Enum.UserInputType.Gyro] = 'Touch',
	},
}
