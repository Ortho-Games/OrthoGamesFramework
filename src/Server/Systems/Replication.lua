local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Packages.Net)

local Globals = require(ReplicatedStorage.Shared.Globals)

local World = Globals.Modules.World
local Schedules = Globals.Modules.Schedules
local ReplicatedComponents = Globals.Modules.ReplicatedComponents

local UserSetup = Globals.Systems.UserSetup

local replicatedFactoryToName = {}
local instanceToNumComponents = {}

local EntityPackets = {
	added = {},
	changed = {},
	removed = {},
}

local function combine(func1, func2)
	return if func1
		then function(...)
			func1(...)
			func2(...)
		end
		else func2
end

local function chain(func1, func2)
	return if func1
		then function(...)
			return func2(func1(...))
		end
		else func2
end

local function initEntityPackets(entityPackets)
	entityPackets = entityPackets or {}
	entityPackets.entities = {}
	entityPackets.packets = {}
	return entityPackets
end

local function handleReplicate(factory, factoryName, entityPackets, handlePacket)
	return function(entity, ...)
		local id = table.find(entityPackets.entities, entity)
		if not id then
			id = #entityPackets.entities + 1
			table.insert(entityPackets.entities, entity)
			entityPackets.packets[id] = {}
		end

		local packet = entityPackets.packets[id]
		packet[factoryName] = packet[factoryName] or {}
		handlePacket(entity, packet, ...)
	end
end

local function injectReplication(factoryName, factory)
	factory.added = combine(
		factory.added,
		handleReplicate(factory, factoryName, EntityPackets.added, function(entity, packet, component)
			packet[factoryName] = if typeof(factory.getAddPacket) == "function"
				then table.pack(factory.getAddPacket(entity, factory.get(entity)))
				else {}
		end)
	)

	factory.sendChangePacket = chain(
		factory.sendChangePacket,
		handleReplicate(factory, factoryName, EntityPackets.changed, function(entity, packet, ...)
			table.insert(packet[factoryName], table.pack(...))
		end)
	)

	factory.removed = combine(
		factory.removed,
		handleReplicate(factory, factoryName, EntityPackets.removed, function(entity, packet, component)
			packet[factoryName] = if typeof(factory.getRemovePacket) == "function"
				then table.pack(factory.getRemovePacket(entity, component))
				else {}
		end)
	)
end

local function onInit()
	Net:RemoteEvent("ReplicateAdd")
	Net:RemoteEvent("ReplicateChange")
	Net:RemoteEvent("ReplicateRemove")

	initEntityPackets(EntityPackets.added)
	initEntityPackets(EntityPackets.changed)
	initEntityPackets(EntityPackets.removed)

	for _, factoryName in ReplicatedComponents do
		local factory = Globals.Components[factoryName]
		if factory then
			replicatedFactoryToName[factory] = factoryName
			injectReplication(factoryName, factory)
		end
	end
end

local function onGameTick()
	Net:RemoteEvent("ReplicateAdd"):FireAllClients(EntityPackets.added)
	Net:RemoteEvent("ReplicateChange"):FireAllClients(EntityPackets.changed)
	Net:RemoteEvent("ReplicateRemove"):FireAllClients(EntityPackets.removed)

	warn("Send Add", EntityPackets.added)
	warn("Send Change", EntityPackets.changed)
	warn("Send Remove", EntityPackets.removed)

	initEntityPackets(EntityPackets.added)
	initEntityPackets(EntityPackets.changed)
	initEntityPackets(EntityPackets.removed)
end

local function getEntityPacket(entity)
	local packet = {}
	for factory, component in World.get(entity) do
		local factoryName = replicatedFactoryToName[factory]
		if not factoryName then
			continue
		end

		packet[factoryName] = if typeof(factory.getAddPacket) == "function"
			then table.pack(factory.getAddPacket(entity, component))
			else {}
	end

	return packet
end

local function onUserAdded(player)
	local addedPackets = initEntityPackets()

	for entity, components in World.query({}) do
		table.insert(addedPackets.entities, entity)
		table.insert(addedPackets.packets, getEntityPacket(entity))
	end

	Net:RemoteEvent("ReplicateAdd"):FireClient(player, addedPackets)
end

return {
	init = Schedules.init.job(onInit),
	-- userAdded = Schedules.userAdded.job(onUserAdded, UserSetup.userAdded),
	gameTick = Schedules.gameTick.job(onGameTick),
}
