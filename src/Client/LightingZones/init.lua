local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Global = require(ReplicatedStorage.Shared.Global)

local LightMachine = require(ReplicatedStorage.Vendor.LightMachine)

local DefaultLightingPreset = Global.Assets.LightingPresets.RobloxDefault

local LightingTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)

return Global.Schedules.Boot.job(function()
	LightMachine = LightMachine.new(DefaultLightingPreset)

	local QueryParams = OverlapParams.new()
	QueryParams.FilterType = Enum.RaycastFilterType.Include
	QueryParams.RespectCanCollide = false

	local lightingZones = CollectionService:GetTagged("LightingZone")
	CollectionService:GetInstanceAddedSignal("LightingZone"):Connect(function(zone)
		table.insert(lightingZones, zone)
		QueryParams.FilterDescendantsInstances = lightingZones
	end)

	CollectionService:GetInstanceRemovedSignal("LightingZone"):Connect(function(zone)
		table.remove(lightingZones, table.find(lightingZones, zone))
		QueryParams.FilterDescendantsInstances = lightingZones
	end)

	local setZone
	Global.Schedules.PreSimulation.job(function()
		local zones =
			workspace:GetPartBoundsInRadius(workspace.CurrentCamera.CFrame.Position, 1, QueryParams)

		local currentZone, currentPriority
		for _, zone in ipairs(zones) do
			local priority = zone:GetAttribute("LightingPriority") or 0
			if currentPriority and priority < currentPriority then continue end
			currentZone, currentPriority = zone, priority
		end

		print(setZone, currentZone == setZone)
		if currentZone == setZone then return end
		setZone = currentZone
		LightMachine:SetLighting(setZone and setZone.LightingPreset.Value, LightingTweenInfo)
	end)
end)
