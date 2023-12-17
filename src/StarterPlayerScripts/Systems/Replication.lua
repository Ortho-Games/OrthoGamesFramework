local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Net = require(Globals.Packages.Net)

local World = require(Globals.Shared.Modules.World)

local Schedules = require(Globals.Shared.Modules.Schedules)

-- local query = World.query({ PlayerComponent, ClicksComponent })

local factories = {}
for _, factoryModule in Globals.Components:GetChildren() do
	local success, factoryOrError = pcall(require, factoryModule)
	if success then
		factories[factoryModule.Name] = factoryOrError
	end
end

local function replicateWorld()
	Net:Connect("ReplicateWorld", function(replicationPacket)
		for factoryName, factoryPacket in replicationPacket do
			local factory = factories[factoryName]
			if not factory then
				continue
			end

			for i = 1, #factoryPacket.entities do
				local entity = factoryPacket.entities[i]
				local entityPacket = factoryPacket.entityPackets[i]
				factory.addFromPacket(entity, entityPacket)
			end
		end
	end)

	Net:Connect("ReplicateAdd", function(factoryName, entity, addPacket)
		local factory = factories[factoryName]
		if factory then
			factory.addFromPacket(entity, addPacket)
		end
	end)

	Net:Connect("ReplicateChange", function(factoryName, entity, changePacket)
		local factory = factories[factoryName]
		if factory then
			factory.changeFromPacket(entity, changePacket)
		end
	end)

	Net:Connect("ReplicateRemove", function(factoryName, entity, removePacket)
		local factory = factories[factoryName]
		if factory then
			factory.removeFromPacket(entity, removePacket)
		end
	end)
end

return Schedules.boot.job(replicateWorld)
