local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TestEZ = require(ReplicatedStorage.TestEZ)

game:GetService("Players"):WaitForChild("Player1", 30)

-- local tests = {}
-- for _, mod in script.Parent:GetDescendants() do
-- 	if mod:IsA("ModuleScript") then
-- 		table.insert(tests, require(mod))
-- 	end
-- end

TestEZ.TestBootstrap:run({ script.Parent })
