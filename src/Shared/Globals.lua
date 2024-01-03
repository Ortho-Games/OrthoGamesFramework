local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

return {
	Packages = ReplicatedStorage.Packages,
	Vendor = ReplicatedStorage.Vendor,
	Assets = ReplicatedStorage.Assets,
	Local = if RunService:IsServer() then ServerStorage.Server else ReplicatedStorage.Client,
	Shared = ReplicatedStorage.Shared,
}
