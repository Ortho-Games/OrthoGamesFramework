local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local Global = require(ReplicatedStorage.Shared.Global)

local Local = if RunService:IsServer() then "Server" else "Client"

local localFighters = if RunService:IsServer()
		and not RunService:IsClient()
	then ServerStorage.Server:WaitForChild("Fighters")
	else ReplicatedStorage.Client:WaitForChild("Fighters") :: any

local actions = {}
for _, descendant in localFighters:GetDescendants() do
	if descendant.Name ~= Local then continue end
	table.insert(actions, descendant)
end

local ActionToActionEnum = Global.Util.arrToOrderLUT(actions)
ActionToActionEnum._reverse = actions

return ActionToActionEnum
