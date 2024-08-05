local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Global = require(ReplicatedStorage.Shared.Global)
local Signal = require(ReplicatedStorage.Packages.Signal)
local TableValue = require(ReplicatedStorage.Packages.TableValue)

local InAir = {}
InAir.changed = Signal.new()

function InAir:add(entity)
	-- insert constructor for component here
	local tbl = TableValue.new {
		inAir = false,
	}

	function tbl:changed(key, new, old)
		if new == old then return end
		InAir.changed:Fire(entity, new)
	end

	return tbl
end

return Global.World.factory(InAir)
