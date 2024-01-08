local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Net = require(Globals.Packages.Net)
local Schedules = require(ReplicatedStorage.Shared.Modules.Schedules)
local ModelComponent = require(Globals.Local.Components.ModelComponent)
local World = require(ReplicatedStorage.Shared.Modules.World)

return Schedules.init.job(function()
	Net:RemoteEvent("EntityRemoved", function(entity) end)

	-- in this case we have no removed signal because you can detect when a model is destroyed on the client anyways.
end)
