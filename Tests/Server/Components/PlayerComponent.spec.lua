local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local World = require(ReplicatedStorage.Shared.Modules.World)
local PlayerComponent = require(Globals.Local.Components.PlayerComponent)

return function()
	describe("add", function()
		afterEach(function()
			for entity, _ in World.query({}) do
				World.kill(entity)
			end
		end)

		it("should return a player", function()
			local player = Players:FindFirstChildWhichIsA("Player")

			local entity = World.entity()
			local ret = PlayerComponent.add(entity, player)

			expect(ret).to.be.a("userdata")
		end)

		it("should add player to _componentToEntity", function()
			local player = Players:FindFirstChildWhichIsA("Player")

			local entity = World.entity()
			local ret = PlayerComponent.add(entity, player)

			expect(PlayerComponent._componentToEntity[player]).to.be.ok()
		end)
	end)

	describe("removed", function()
		it("should remove a player on kill", function()
			FOCUS()
			local player = Players:FindFirstChildWhichIsA("Player")

			local entity = World.entity()
			local ret = PlayerComponent.add(entity, player)
			expect(PlayerComponent._componentToEntity[player]).to.be.ok()

			World.kill(entity)
			expect(PlayerComponent._componentToEntity[player]).never.to.be.ok()
		end)
	end)
end
