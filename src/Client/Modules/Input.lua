local ReplicatedStorage = game:GetService 'ReplicatedStorage'

local Globals = require(ReplicatedStorage.Shared.Globals)
local Signal = require(Globals.Packages.Signal)
local TableValue = require(Globals.Packages.TableValue)

local EnabledActionMaps, ActionMaps, EnabledActions, Actions
local DeviceTypes, InputTypeToDeviceType

export type DeviceType = 'KeyboardMouse' | 'Gamepad' | 'Touch'
export type MappedBinds = {
	KeyCodes: { Enum.KeyCode }?,
	UserInputTypes: { Enum.UserInputState }?,
	UiTags: { string }?,
}
export type DeviceBinds = {
	All: MappedBinds?,
	KeyboardMouse: MappedBinds?,
	Gamepad: MappedBinds?,
	Touch: MappedBinds?,
}

export type ActionMaps = {
	[string]: { string },
}

export type InputState = 'Began' | 'Changed' | 'Ended'
export type UiData = {
	Tag: string,
	Ui: GuiObject,
}

local LastInputType = Enum.UserInputType.None
local ActiveInputObjectToUiData = {}
local Focus = {
	Window = true,
	TextBox = false,
	Game = true,
}

local Input = {
	DeviceType = 'None' :: DeviceType | 'None',
	IsDeviceTypeForced = false,
	AllUiTags = TableValue.new {},

	Focus = TableValue.new(Focus),

	DeviceSwitched = Signal.new(),
	DeviceTypeForced = Signal.new(),

	Began = Signal.new(),
	Changed = Signal.new(),
	Ended = Signal.new(),
	Toggled = Signal.new(),
}

local function ValidateDeviceType(deviceType)
	assert(
		table.find(DeviceTypes, deviceType),
		`Invalid device type "{deviceType}." Supported device types include: {DeviceTypes} `
	)
end

local StateToActionHandler = {}
do -- Handling actions
	function StateToActionHandler.Began(action, inputObject: InputObject, uiData: UiData?)
		local activeInputObjects = action.ActiveInputObjects
		table.insert(activeInputObjects, inputObject)
		ActiveInputObjectToUiData[inputObject] = uiData

		local state = if #activeInputObjects == 1 then 'Began' else 'Changed'
		action[state]:Fire(action.Name, inputObject, uiData)
		Input[state]:Fire(action.Name, inputObject, uiData)
	end

	function StateToActionHandler.Changed(action, inputObject: InputObject, uiData: UiData?)
		action.Changed:Fire(action.Name, inputObject, uiData)
	end

	function StateToActionHandler.Ended(action, inputObject: InputObject, uiData: UiData?)
		local activeInputObjects = action.ActiveInputObjects
		table.remove(activeInputObjects, table.find(activeInputObjects, inputObject))
		ActiveInputObjectToUiData[inputObject] = nil

		local state = if #activeInputObjects == 0 then 'Ended' else 'Changed'
		action[state]:Fire(action.Name, inputObject, uiData)
		Input[state]:Fire(action.Name, inputObject, uiData)
	end
end

local function CreateAction(actionName: string, deviceBinds: DeviceBinds)
	assert(not Actions[actionName], 'Action already already exists with name "{actionName}"')

	local action = {}
	action.ActiveInputObjects = {}
	action.Name = actionName
	action.Began = Signal.new()
	action.Changed = Signal.new()
	action.Ended = Signal.new()
	action.Toggled = Signal.new()
	action.NumEnabledMaps = 0

	function action.Release()
		for _, inputObject in action.ActiveInputObjects do
			local uiData = ActiveInputObjectToUiData[inputObject]
			StateToActionHandler['Ended'](action, inputObject, uiData)
		end
	end

	for _, deviceType: DeviceType in DeviceTypes do
		action[deviceType] = {
			UiTags = {},
			KeyCodes = {},
			UserInputTypes = {},
		}

		if not deviceBinds[deviceType] then
			continue
		end

		for bindType, binds in deviceBinds[deviceType] do
			for _, bind in binds do
				action[deviceType][bindType][bind] = true
				if bindType == 'UiTags' and not Input.AllUiTags[bind] then
					Input.AllUiTags[bind] = true
				end
			end
		end

		if deviceBinds.All then
			for bindType, bind in deviceBinds.All do
				action[deviceType][bindType][bind] = true
			end
		end
	end

	Actions[actionName] = action
end

local function SetDeviceType(deviceType)
	if Input.DeviceType == deviceType then
		return
	end

	for _, action in Actions do
		action.Release()
	end

	Input.DeviceSwitched:Fire(deviceType, Input.DeviceType)
	Input.DeviceType = deviceType
end

local function GetAction(actionName: string)
	return assert(Actions[actionName], `No action exists with name "{actionName}"`)
end

local function GetFromAction(index: any)
	return function(actionName: string)
		return GetAction(actionName)[index]
	end
end

Input.GetActionBeganSignal = GetFromAction 'Began'
Input.GetActionChangedSignal = GetFromAction 'Changed'
Input.GetActionEndedSignal = GetFromAction 'Ended'
Input.GetActionToggledSignal = GetFromAction 'Toggled'
Input.GetActionActiveInputObjects = GetFromAction 'ActiveInputObjects'

function Input.GetUiDataFromInputObject(inputObject: InputObject)
	return ActiveInputObjectToUiData[inputObject]
end

function Input.IsActionEnabled(actionName: string)
	local action = GetAction(actionName)
	return action.NumEnabledMaps > 0
end

function Input.IsActionActive(actionName: string): boolean
	local action = GetAction(actionName)
	return #action.ActiveInputObjects > 0
end

function Input.Focus.Changed()
	local gameFocused = Focus.Window and not Focus.TextBox
	if gameFocused == Focus.Game then
		return
	end
	Focus.Game = gameFocused

	if not gameFocused then
		for _, action in Actions do
			action.Release()
		end
	end
end

function Input.EnableActionMap(actionMapName: string, enable: boolean?)
	enable = enable == nil or enable
	local map = assert(ActionMaps[actionMapName], `No action map exists with name "{actionMapName}"`)
	if (EnabledActionMaps[actionMapName] ~= nil) == enable then
		return
	end

	EnabledActionMaps[actionMapName] = enable and map or nil
	for actionName, action in map do
		EnabledActions[actionName] = enable and action or nil
		action.NumEnabledMaps += enable and 1 or -1
		Input.Toggled:Fire(actionName, enable)
		if action.NumEnabledMaps == 0 and not enable then
			action.Release()
		end
	end
end

function Input.ReleaseAction(actionName: string)
	local action = GetAction(actionName)
	if action then
		action.Release()
	end
end

function Input.ReleaseAllActions()
	for _, action in Actions do
		action.Release()
	end
end

function Input.SetActionBinds(actionName: string, deviceBinds: DeviceBinds)
	local action = Actions[actionName]
	if not action then
		CreateAction(actionName, deviceBinds)
		return
	end

	action.Release()

	for _, deviceType in DeviceTypes do
		for bindType, binds in deviceBinds[deviceType] do
			local bindsDict = {}
			for _, bind in binds do
				bindsDict[bind] = true

				if bindType == 'UiTags' and not Input.AllUiTags[bind] then
					Input.AllUiTags[bind] = true
				end
			end

			action[deviceType][bindType] = bindsDict
		end

		if deviceBinds.All then
			for bindType, bind in deviceBinds.All do
				action[deviceType][bindType][bind] = true
			end
		end
	end
end

function Input.HandleInput(state: InputState, inputObject: InputObject, gpeOrUiData: boolean | UiData)
	local uiData: UiData? = if typeof(gpeOrUiData) ~= 'boolean' then gpeOrUiData else nil

	if (Input.DeviceType == 'None' or not Input.Focus.Game) or (not uiData and gpeOrUiData) then
		return
	end

	local queryData = {
		UiTags = uiData and uiData.Tag,
		UserInputTypes = inputObject.UserInputType,
		KeyCodes = inputObject.KeyCode,
	}

	for bindType, bind in queryData do
		for _, action in EnabledActions do
			if action[Input.DeviceType][bindType][bind] then
				StateToActionHandler[state](action, inputObject, uiData)
			end
		end
	end
end

function Input.HandleLastInputTypeChanged(lastInputType: Enum.UserInputType)
	local deviceType = InputTypeToDeviceType[lastInputType]
	if not deviceType then
		return
	end

	LastInputType = lastInputType
	if not (Input.IsDeviceTypeForced or Input.DeviceType == deviceType) then
		SetDeviceType(deviceType)
	end
end

function Input.ForceDeviceType(deviceType: DeviceType?)
	ValidateDeviceType(deviceType)
	Input.IsDeviceTypeForced = deviceType ~= nil
	Input.DeviceTypeForced:Fire(Input.IsDeviceTypeForced, deviceType)
	SetDeviceType(if Input.IsDeviceTypeForced then deviceType else InputTypeToDeviceType[LastInputType])
end

local hasLoaded = false
function Input.Load(
	actions: { [string]: DeviceBinds },
	actionMaps: ActionMaps,
	enabledActionMaps: { string },
	deviceTypes,
	inputTypeToDeviceType
)
	if hasLoaded then
		Input.ReleaseAllActions()
	end

	EnabledActionMaps, ActionMaps, EnabledActions, Actions = {}, {}, {}, {}
	DeviceTypes, InputTypeToDeviceType = deviceTypes, inputTypeToDeviceType

	for _, deviceType in InputTypeToDeviceType do
		ValidateDeviceType(deviceType)
	end

	for actionName, deviceBinds in actions do
		Input.SetActionBinds(actionName, deviceBinds)
	end

	for actionMapName, actionNames in actionMaps do
		local map = {}
		ActionMaps[actionMapName] = map
		for _, actionName in actionNames do
			map[actionName] = Actions[actionName]
		end
	end

	for _, actionMapName in enabledActionMaps do
		Input.EnableActionMap(actionMapName, true)
	end

	hasLoaded = true
end

return Input
