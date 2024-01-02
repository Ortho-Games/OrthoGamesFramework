local ReplicatedStorage = game:GetService 'ReplicatedStorage'

local TableValue = require(ReplicatedStorage.Packages.TableValue)

local Globals = require(ReplicatedStorage.Shared.Globals)
local World = Globals.Modules.World

local Money = World.factory {
	add = function(_, _, amount)
		return TableValue.new {
			amount = amount,
		}
	end,
}

function Money.change(_, component, amount)
	component.amount = amount
end

return Money
