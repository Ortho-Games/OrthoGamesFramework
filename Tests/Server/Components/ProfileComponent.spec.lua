local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local World = require(ReplicatedStorage.Shared.Modules.World)

return function()
	local Profiles = require(Globals.Local.Modules.Profiles)
	local ProfileComponent = require(Globals.Local.Components.ProfileComponent)

	describe("add", function()
		beforeEach(function()
			for entity, _ in World.query({}) do
				World.kill(entity)
			end
		end)

		it("should error without player", function()
			local entity = World.entity()

			local template = Profiles.createProfileTemplate()

			expect(template).to.be.ok()

			expect(function()
				ProfileComponent.add(entity, nil, template)
			end).to.throw()
		end)

		it("should error without profileStore", function()
			local entity = World.entity()

			local player = Players:FindFirstChildWhichIsA("Player")

			expect(function()
				ProfileComponent.add(entity, player, nil)
			end).to.throw()
		end)

		it("should return a profile", function()
			local entity = World.entity()

			local player = Players:FindFirstChildWhichIsA("Player")
			local template = Profiles.createProfileTemplate()

			local profile = ProfileComponent.add(entity, player, template)

			expect(profile).to.be.ok()
		end)
	end)

	describe("removed", function() end)

	describe("LoadData", function() end)
end
