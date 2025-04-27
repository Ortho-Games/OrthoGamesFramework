local runAsyncAwait = require(script.Parent.runAsyncAwait)
local timeIt = require(script.Parent.timeIt)
return function(parent, timeItTrue: boolean?)
	-- runAsyncAwait(parent:GetDescendants(), function(descendant)
	-- 	if not descendant:IsA("ModuleScript") then return end
	-- 	local succ, err = pcall(function()
	-- 		if timeItTrue then
	-- 			timeIt(descendant:GetFullName(), function()
	-- 				require(descendant)
	-- 			end, false, 0.0001)
	-- 		else
	-- 			require(descendant)
	-- 		end
	-- 	end)
	-- 	if not succ then warn(descendant, err) end
	-- end)

	for _, descendant in parent:GetDescendants() do
		if not descendant:IsA("ModuleScript") then continue end
		local succ, err = pcall(function()
			if timeItTrue then
				timeIt(descendant:GetFullName(), function()
					require(descendant)
				end, nil, 0.0001)
			else
				require(descendant)
			end
		end)
		if not succ then warn(descendant, err) end
	end
end
