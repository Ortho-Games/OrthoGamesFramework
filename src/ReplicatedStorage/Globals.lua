local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

return {
	Server = if RunService:IsServer() then ServerScriptService.Server else nil,
	Client = if RunService:IsClient() then Players.LocalPlayer.PlayerScripts.Client else nil,

	Components = if RunService:IsServer()
		then ServerScriptService.Server.Components
		else Players.LocalPlayer.PlayerScripts.Client.Components,

	Systems = if RunService:IsServer()
		then ServerScriptService.Server.Systems
		else Players.LocalPlayer.PlayerScripts.Client.Systems,

	-- Services = if RunService:IsServer() then ServerScriptService.Server.Services else nil,
	-- Controllers = if RunService:IsClient() then Players.LocalPlayer.PlayerScripts.Client.Controllers else nil,
	Packages = ReplicatedStorage.Packages,
	Shared = ReplicatedStorage.Shared,
	Vendor = ReplicatedStorage.Vendor,
	Assets = ReplicatedStorage.Assets,
	-- Config = require(ReplicatedStorage.Shared.Config),
	-- Enums = require(ReplicatedStorage.Shared.Enums),
}
