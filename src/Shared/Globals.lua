local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

return {
	Packages = ReplicatedStorage.Packages,
	Vendor = ReplicatedStorage.Vendor,
	Assets = ReplicatedStorage.Assets,
	Local = if RunService:IsServer() then ServerScriptService.Server else ReplicatedStorage.Client,
	Shared = ReplicatedStorage.Shared,
}
