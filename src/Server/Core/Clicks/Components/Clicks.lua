local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)

local InjectLifecycleSignals =
	require(Globals.Shared.Modules.InjectLifecycleSignals)

local Profiles = require(Globals.Local.Core.Profiles.Modules.Profiles)

local ClicksComponent = {}
ClicksComponent.profileID = "clicks"

Profiles.addDefaultData(ClicksComponent.profileID, {
	clicks = 0,
})

function ClicksComponent:add(entity, profile)
	-- insert constructor for component here
	local comp = profile.Data[self.profileID]

	return comp
end

return Globals.World.factory(InjectLifecycleSignals(ClicksComponent))
