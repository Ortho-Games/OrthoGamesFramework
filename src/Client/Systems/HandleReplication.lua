local CollectionService = game:GetService 'CollectionService'
local ReplicatedStorage = game:GetService 'ReplicatedStorage'

local Net = require(ReplicatedStorage.Packages.Net)
local Promise = require(ReplicatedStorage.Packages.Promise)

local Globals = require(ReplicatedStorage.Shared.Globals)
local World = Globals.Modules.World
local Schedules = Globals.Modules.Schedules
local ReplicatedComponents = Globals.Modules.ReplicatedComponents

local replicatedFactoryToName = {}
local tagAddedPromises = {}

local function handleReplicate(handleFactoryPacket)
	return function(entityPackets)
		for id, packet in entityPackets.packets do
			local entity = entityPackets.entities[id]
			if not entity then
				continue
			end

			for factoryName, factoryPacket in packet do
				local factory = Globals.Components[factoryName]
				if factory then
					handleFactoryPacket(factory, entity, factoryPacket)
				end
			end
		end
	end
end

local function onTagAdded(entityInstance)
	local promise = Promise.try(function()
		warn('Tag Request', entityInstance)
		return Net:Invoke('ReplicateEntity', entityInstance)
	end):andThen(function(entityPacket)
		print('Tag Recieve', entityInstance)
		for factory in World.get(entityInstance) do
			local factoryName = replicatedFactoryToName[factory]
			if factoryName and not entityPacket[factoryName] then
				print('Tag Remove', entityInstance, factoryName)
				factory.remove(entityInstance)
			end
		end

		for factoryName, packet in entityPacket do
			local factory = Globals.Components[factoryName]
			if factory then
				print('Tag Add', entityInstance, factoryName)
				factory.add(entityInstance, table.unpack(packet))
			end
		end
	end)

	tagAddedPromises[entityInstance] = promise
end

local function onTagRemoved(entityInstance)
	local addedPromise = tagAddedPromises[entityInstance]

	if addedPromise then
		warn('Tag Request Cancel', entityInstance)
		addedPromise:cancel()
		tagAddedPromises[entityInstance] = nil
	end

	for factory in World.get(entityInstance) do
		if replicatedFactoryToName[factory] then
			print('Tag Remove', entityInstance)
			factory.remove(entityInstance)
		end
	end
end

local function onInit()
	Net:RemoteFunction 'ReplicateEntity'

	for _, factoryName in ReplicatedComponents do
		local factory = Globals.Components[factoryName]
		if factory then
			replicatedFactoryToName[factory] = factoryName
		end
	end
end

local function onBoot()
	for _, entityInstance in CollectionService:GetTagged 'Replicated' do
		onTagAdded(entityInstance)
	end

	CollectionService:GetInstanceAddedSignal('Replicated'):Connect(onTagAdded)
	CollectionService:GetInstanceRemovedSignal('Replicated'):Connect(onTagRemoved)

	Net:Connect(
		'ReplicateAdd',
		handleReplicate(function(factory, entity, factoryPacket)
			print('Replicate Add', entity, replicatedFactoryToName[factory])
			factory.add(entity, table.unpack(factoryPacket))
		end)
	)

	Net:Connect(
		'ReplicateChange',
		handleReplicate(function(factory, entity, factoryPacket)
			if not typeof(factory.change) == 'function' then
				return
			end

			local component = factory.get(entity)
			for _, changePacket in factoryPacket do
				print('Replicate Change', entity, replicatedFactoryToName[factory])
				factory.change(entity, component, table.unpack(changePacket))
			end
		end)
	)

	Net:Connect(
		'ReplicateRemove',
		handleReplicate(function(factory, entity, factoryPacket)
			print('Replicate Remove', entity, replicatedFactoryToName[factory])
			factory.remove(entity, table.unpack(factoryPacket))
		end)
	)
end

return {
	init = Schedules.init.job(onInit),
	boot = Schedules.boot.job(onBoot),
}
