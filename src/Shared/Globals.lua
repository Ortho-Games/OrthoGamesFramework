local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local GameFolder = if RunService:IsServer() then ServerStorage.Server else ReplicatedStorage.Client

local function lazyLoad(get)
	local t, mt = {}, {}
	function mt:__index(index)
		local output = get(index)
		if not output then
			return
		end

		if typeof(output) == "Instance" and output:IsA("ModuleScript") then
			output = require(output)
		end

		t[index] = output :: typeof(output)
		return output
	end

	return setmetatable(t, mt)
end

local function lazyLoadSystems(...: Folder)
	local gameLoadFolder, sharedLoadFolder = GameFolder.Systems, ReplicatedStorage.Shared.Systems

	local children = gameLoadFolder:GetChildren()
	local sharedChildren = sharedLoadFolder:GetChildren()
	table.move(sharedChildren, 1, #sharedChildren, #children + 1, children)

	local childrenDict = {}
	for _, child in children do
		if childrenDict[child.Name] then
			error("No system can share the same name. System: {child.Name}")
		end

		childrenDict[child.Name] = child
	end

	return lazyLoad(function(index)
		return childrenDict[index]
	end)
end

return {
	Packages = ReplicatedStorage.Packages,
	Vendor = ReplicatedStorage.Vendor,
	Assets = ReplicatedStorage.Assets,
	Game = GameFolder,
	Components = GameFolder.Components,
	Modules = GameFolder.Modules,
	Systems = lazyLoadSystems("Systems"),
}
