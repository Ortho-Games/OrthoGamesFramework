local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Global = require(ReplicatedStorage.Shared.Global)

local cameraComponent = {}

function cameraComponent:add(entity, character, camera)
	-- insert constructor for component here

	return {
		character = character,

		camera = camera,

		bonk = function(self, bonkDonk)
			print("FonkaBonkDonk_", bonkDonk)
		end,
	}
end

return Global.World.factory(cameraComponent)
