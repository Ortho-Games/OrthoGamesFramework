local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local World = require(Globals.Shared.Modules.World)

local PlayerComponent = {}

-- THIS COMPONENT IS UNIQUE
PlayerComponent._componentToEntity = {}

function PlayerComponent:add(entity, player: Player)
	-- insert constructor for component here
	if self._componentToEntity[player] then
		error(
			"You tried to add a PlayerComponent of the same player resulting in a violation of the UNIQUE constraint of the Component. Please double check the code for any possible double additions of the same player."
		)
	end

	self._componentToEntity[player] = entity

	return player
end

function PlayerComponent:removed(entity, player: Player)
	warn(`Removing {player.Name}`)
	self._componentToEntity[player] = nil
end

function PlayerComponent:getEntityFromComponent(player: Player)
	return self._componentToEntity[player]
end

return World.factory(PlayerComponent)

-- another script:
--[[
    ```lua
    local PlayerComponent = require(path.to.component)

    local entity = PlayerComponent.getEntityFromComponent(player)
    local components = World.get(entity)

    components[HealthComponent].health -= 10
    ```
]]
