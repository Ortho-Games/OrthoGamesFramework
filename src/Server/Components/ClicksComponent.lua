local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Net = require(Globals.Packages.Net)
local TableValue = require(Globals.Packages.TableValue)

local Profiles = require(Globals.Local.Modules.Profiles)

local World = require(Globals.Shared.Modules.World)
local Schedules = require(Globals.Shared.Modules.Schedules)

local ClicksComponent = {}
ClicksComponent.profileId = "clicks"

Schedules.init.job(function()
	Profiles.setDefaultData(ClicksComponent.profileId, {
		clicks = 0,
	})
end)

function ClicksComponent:add(entity, profile)
	-- insert constructor for component here
	local self = TableValue.new(profile.Data[self.profileId])

	function self.Changed(index, value)
		Net:RemoteEvent("ReplicateChange"):FireAllClients(script.Name, entity, { { index, value } })
	end

	return self
end

function ClicksComponent.added(entity, componentData)
	Net:RemoteEvent("ReplicateAdd"):FireAllClients(script.Name, entity, componentData.Value)
end

function ClicksComponent.removed(entity, componentData)
	Net:RemoteEvent("ReplicateRemove"):FireAllClients(script.Name, entity, componentData.Value)
end

function ClicksComponent.getReplicatePacket(_, componentData)
	return componentData.Value
end

return World.factory(ClicksComponent)
