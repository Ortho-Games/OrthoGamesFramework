local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TableValue = require(ReplicatedStorage.Packages.TableValue)

local Globals = require(ReplicatedStorage.Shared.Globals)
local World = require(Globals.Modules.World)
local Schedules = Globals.Modules.Schedules

local profileId = "Money"
Schedules.profileSetup.job(function(profileTemplate)
	profileTemplate[profileId] = {
		amount = 0,
	}
end)

local Money = {}

function Money.add(factory, player, profile)
	local component = TableValue.new(table.clone(profile.Data[profileId]))

	function component.Changed(index, value)
		if index == "amount" then
			factory.sendChangePacket(player, value)
		end

		if profile.Data[profileId][index] then
			profile.Data[profileId][index] = value
		end
	end

	return component
end

export type Type = typeof(Money.add(...))

function Money.getRemovePacket() end

function Money.getAddPacket() end

Money.Id = "Money"

return World.factory(Money)
