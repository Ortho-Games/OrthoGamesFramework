local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local World = require(ReplicatedStorage.Shared.Modules.World)
local PlayerComponent = require(Globals.Local.Components.PlayerComponent)

return function()
	local ModelComponent = require(Globals.Local.Components.ModelComponent)

	describe("add", function()
		beforeEach(function()
			workspace.ModelStreamingBehavior = Enum.ModelStreamingBehavior.Default

			for entity, _ in World.query({}) do
				World.kill(entity)
			end
		end)

		it("should error when streaming behavior is improved", function()
			workspace.ModelStreamingBehavior = Enum.ModelStreamingBehavior.Improved
		end)
	end)

	describe("removed", function()
		it("should destroy the model", function()
			local player = Players:FindFirstChildWhichIsA("Player")

			local model = Instance.new("Model")

			local entity = World.entity()
			local model = ModelComponent.add(entity, model)

			World.destroy(entity)

			expect(model).never.to.be.ok()
		end)
	end)
end
