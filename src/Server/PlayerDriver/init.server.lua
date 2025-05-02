local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local DataRegistry = require(script.Interface.DataRegistry)
local OnPlayerAdded = require(script.OnPlayerAdded)
local ProfileComponent = require(script.Components.ProfileComponent)
local profilestore = require(ReplicatedStorage.Vendor.profilestore)
local requireDescendants = require(ReplicatedStorage.Vendor.Util.requireDescendants)
local timeIt = require(ReplicatedStorage.Vendor.Util.timeIt)

-- To see how long it will take to time this process
timeIt("PlayerDriver", function()
	-- Requires all of the modules inside of the driver
	requireDescendants(script)

	-- Run the scripts in the sequence we want it to happend
	ProfileComponent.profileStore = profilestore.New("PlayerStore", DataRegistry.registry)
	OnPlayerAdded()
end)
