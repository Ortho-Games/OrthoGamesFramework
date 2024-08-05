--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local Global = require(ReplicatedStorage.Shared.Global)

local Net = require(ReplicatedStorage.Packages.Net)

local ServerLoadedRE = Net:RemoteEvent("ServerLoaded")

local function callWithBenchmark(name, func, ...)
	local m = if RunService:IsServer() then "[Server]" else "[Client]"
	local s = os.clock()
	warn(`{m} Starting {name}...`)
	local r = table.pack(func(...))
	warn(`{m} Finished {name} in {os.clock() - s}s`)
	return table.unpack(r)
end

callWithBenchmark(
	"server requires",
	Global.Util.requireDescendants,
	ServerStorage.Server
)

callWithBenchmark(
	"shared requires",
	Global.Util.requireDescendants,
	ReplicatedStorage.Shared
)

callWithBenchmark("initialization", Global.Schedules.Init.start)
callWithBenchmark("boot", Global.Schedules.Boot.start)

for scheduleName, schedule in Global.Schedules :: any do
	pcall(function()
		RunService[scheduleName]:Connect(schedule.start)
	end)
end
