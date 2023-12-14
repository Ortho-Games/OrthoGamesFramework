local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Net = require(Globals.Packages.Net)

local World = require(Globals.Shared.Modules.World)

local Schedules = require(Globals.Shared.Modules.Schedules)

local UserEntitySetup = require(Globals.Systems.UserEntitySetup)

-- local query = World.query({ PlayerComponent, ClicksComponent })

Net:RemoteEvent("ReplicateWorld")
Net:RemoteEvent("ReplicateAdd")
Net:RemoteEvent("ReplicateChange")
Net:RemoteEvent("ReplicateRemove")

local factoryToName = {}
for _, factoryModule in Globals.Components:GetChildren() do
	local success, factoryOrError = pcall(require, factoryModule)
	if success then
		factoryToName[factoryOrError] = factoryModule.Name
	end
end

local query = World.query({})
function replicateWorld(player)
	local replicationPacket = {}
	for entity, components in query do
		for factory, componentData in components do
			local factoryName = factoryToName[factory]
			if not factoryName or typeof(factory.getReplicateData) ~= "function" then
				continue
			end

			local factoryPacket = replicationPacket[factoryName]
			if not factoryPacket then
				factoryPacket = { entities = {}, entityPackets = {} }
				replicationPacket[factoryName] = factoryPacket
			end

			local entityPacket = factory.getReplicatePacket(entity, componentData)
			table.insert(factoryPacket.entities, entity)
			table.insert(factoryPacket.entityPackets, entityPacket)
		end
	end

	Net:RemoteEvent("ReplicateWorld"):FireClient(player, replicationPacket)
end

Net:Connect("ReplicateWorld", replicateWorld)
return Schedules.userAdded.job(replicateWorld, UserEntitySetup)
