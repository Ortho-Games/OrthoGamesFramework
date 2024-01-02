-- Schedules
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Sandwich = require(Globals.Packages.Sandwich)

local Schedules = {}

Schedules.init = Sandwich.schedule()
Schedules.boot = Sandwich.schedule()

Schedules.userAdded = Sandwich.schedule()
Schedules.heartbeat = Sandwich.schedule()
Schedules.gameTick = Sandwich.schedule()

return Schedules
