local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Global = require(ReplicatedStorage.Shared.Global)
local Net = require(ReplicatedStorage.Packages.Net)

local Character = require(ReplicatedStorage.Shared.Player.Components.Character)
local InAir = require(ServerStorage.Server.Player.Components.InAir)

local InAirChanged = Net:RemoteEvent("InAirChanged")

local PlayerEntityTracker =
	require(ReplicatedStorage.Shared.Player.Modules.PlayerEntityTracker)

return Global.Schedules.Boot.job(function(...: any)
	for entity, comps in Global.World.query { Character } do
		InAir.add(entity)
		comps[Character].janitor:Add(function()
			InAir.remove(entity)
		end)
	end
	Character.onAdded:Connect(function(entity, comp)
		InAir.add(entity)
		comp.janitor:Add(function()
			InAir.remove(entity)
		end)
	end)
	InAirChanged.OnServerEvent:Connect(function(player, bool: boolean)
		local invokerEntity = PlayerEntityTracker.get(player)
		local jumpHeld = InAir.get(invokerEntity)
		if not jumpHeld then return end

		jumpHeld.inAir = bool
	end)
end, require(ReplicatedStorage.Shared.Player.Jobs.BootPlayers))
