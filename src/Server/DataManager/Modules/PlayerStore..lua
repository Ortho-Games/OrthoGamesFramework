local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local DataRegistry = require(ServerStorage.Server.DataManager.Modules.DataRegistry)

local Schedules = require(ReplicatedStorage.Shared.Modules.Schedules)
local profilestore = require(ReplicatedStorage.Vendor.profilestore)
local store = { playerStore = nil }

-- This needs to be replaced
Schedules.Init.job(function()
	store.playerStore = profilestore.New("PlayerStore", DataRegistry.registry)
end)

local cached = nil

return function()
	if cached then return cached end
	cached = profilestore.New("PlayerStore", DataRegistry.registry)
	return cached
end
