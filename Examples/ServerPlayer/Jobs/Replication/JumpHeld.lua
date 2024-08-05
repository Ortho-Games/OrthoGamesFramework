local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Global = require(ReplicatedStorage.Shared.Global)
local Net = require(ReplicatedStorage.Packages.Net)

local Character = require(ReplicatedStorage.Shared.Player.Components.Character)
local JumpHeld = require(ServerStorage.Server.Player.Components.JumpHeld)

local JumpHeldChanged = Net:RemoteEvent("JumpHeldChanged")

local PlayerEntityTracker =
	require(ReplicatedStorage.Shared.Player.Modules.PlayerEntityTracker)

return Global.Schedules.Boot.job(function(...: any)
	for entity, comps in Global.World.query { Character } do
		JumpHeld.add(entity)
		comps[Character].janitor:Add(function()
			JumpHeld.remove(entity)
		end)
	end
	Character.onAdded:Connect(function(entity, comp)
		JumpHeld.add(entity)
		comp.janitor:Add(function()
			JumpHeld.remove(entity)
		end)
	end)
	JumpHeldChanged.OnServerEvent:Connect(function(player, bool: boolean)
		local invokerEntity = PlayerEntityTracker.get(player)
		local jumpHeld = JumpHeld.get(invokerEntity)

		if not jumpHeld then return end
		jumpHeld.held = bool
	end)
end, require(ReplicatedStorage.Shared.Player.Jobs.BootPlayers))
