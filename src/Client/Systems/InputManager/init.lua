local CollectionService = game:GetService 'CollectionService'
local ReplicatedStorage = game:GetService 'ReplicatedStorage'
local UserInputService = game:GetService 'UserInputService'

local Globals = require(ReplicatedStorage.Shared.Globals)
local Janitor = require(Globals.Packages.Janitor)

local DefaultBinds = require(Globals.Shared.Modules.DefaultBinds)
local Input = require(ReplicatedStorage.Client.Modules.Input)
local Schedules = require(ReplicatedStorage.Shared.Modules.Schedules)

local UiJanitors = {}

local function handleFocus(focusName: 'Window' | 'Textbox', enabled: boolean)
	return function()
		Input.Focus[focusName] = enabled
	end
end

local function handleUserInput(state: Input.InputState)
	return function(inputObject: InputObject, gpe: boolean)
		Input.Focus.TextBox = UserInputService:GetFocusedTextBox() ~= nil
		Input.HandleInput(state, inputObject, gpe)
	end
end

local function handleUiInput(state: Input.InputState, uiData: Input.UiData)
	return function(inputObject: InputObject)
		Input.HandleInput(state, inputObject, uiData)
	end
end

local function handleTaggedUi(state: 'Added' | 'Removed', tag: string)
	return function(ui)
		local uiData = {
			Tag = tag,
			Ui = ui,
		}

		if not ui:IsA 'GuiObject' then
			return
		end

		if state == 'Added' then
			local janitor = Janitor.new()
			janitor:Add(ui.InputBegan:Connect(handleUiInput('Began', uiData)))
			janitor:Add(ui.InputChanged:Connect(handleUiInput('Changed', uiData)))
			janitor:Add(ui.InputEnded:Connect(handleUiInput('Ended', uiData)))
		else
			UiJanitors[ui]:Destroy()
			UiJanitors[ui] = nil
		end
	end
end

local tagJanitors = {}
local function HandleTag(tag)
	local onUiAdded, onUiRemoved = handleTaggedUi('Added', tag), handleTaggedUi('Removed', tag)
	for _, ui in CollectionService:GetTagged(tag) do
		onUiAdded(ui)
	end

	tagJanitors[tag] = Janitor.new()
	tagJanitors[tag]:Add(CollectionService:GetInstanceAddedSignal(tag):Connect(onUiAdded))
	tagJanitors[tag]:Add(CollectionService:GetInstanceRemovedSignal(tag):Connect(onUiRemoved))
end

local function CleanUpTag(tag)
	tagJanitors[tag]:Destroy()
	tagJanitors[tag] = nil
end

local function initInput()
	Input.Load(
		DefaultBinds.Actions,
		DefaultBinds.ActionMaps,
		{ 'Character' },
		DefaultBinds.DeviceTypes,
		DefaultBinds.InputTypeToDeviceType
	)

	UserInputService.InputBegan:Connect(handleUserInput 'Began')
	UserInputService.InputChanged:Connect(handleUserInput 'Changed')
	UserInputService.InputEnded:Connect(handleUserInput 'Ended')

	UserInputService.TextBoxFocused:Connect(handleFocus('Textbox', true))
	UserInputService.TextBoxFocusReleased:Connect(handleFocus('Textbox', false))
	UserInputService.WindowFocused:Connect(handleFocus('Window', true))
	UserInputService.WindowFocusReleased:Connect(handleFocus('Window', false))

	Input.HandleLastInputTypeChanged(UserInputService:GetLastInputType())
	UserInputService.LastInputTypeChanged:Connect(Input.HandleLastInputTypeChanged)

	for tag in Input.AllUiTags do
		HandleTag(tag)
	end

	function Input.AllUiTags.Changed(tag, new, old)
		if new == old then
			return
		elseif not new then
			CleanUpTag(tag)
		elseif not old then
			HandleTag(tag)
		end
	end

	-- test start
	Input.Began:Connect(function(...)
		warn('Began', ...)
	end)
	Input.Changed:Connect(function(...)
		warn('Changed', ...)
	end)
	Input.Ended:Connect(function(...)
		warn('Ended', ...)
	end)
	Input.Toggled:Connect(function(...)
		warn('Toggled', ...)
	end)
	-- test end
end

return {
	Schedules.boot.job(initInput),
}
