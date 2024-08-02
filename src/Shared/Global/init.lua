local ReplicatedStorage = game:GetService("ReplicatedStorage")

return {
	Assets = ReplicatedStorage.Assets,
	World = require(script.World),
	Schedules = require(script.Schedules),
	Util = require(script.Util),
	DEBUG = require(script.DebugUtil),
	InjectLifecycleSignals = require(script.InjectLifecycleSignals),
}
