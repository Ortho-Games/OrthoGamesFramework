local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Globals = require(ReplicatedStorage.Shared.Globals)
local World = require(ReplicatedStorage.Shared.Modules.World)
local TestComponent = require(ServerScriptService.Tests.TestComponent)
local Profiles = require(Globals.Local.Modules.Profiles)

return function()
	local UserEntitySetup = require(Globals.Local.Systems.UserEntitySetup)

	describe("replicateEntityComponents", function()
		beforeEach(function()
			UserEntitySetup.jan:Cleanup()

			for entity, _ in World.query({}) do
				World.kill(entity)
			end
		end)

		it("should find components", function()
			local entity = World.entity()
			TestComponent.add(entity)

			local query = World.query({ TestComponent })
			expect(query).to.be.ok()

			local testComponent = TestComponent.get(query[1])
			expect(testComponent).to.be.ok()
		end)

		it("should fire addedSignal", function()
			local player = Players:FindFirstChildOfClass("Player")

			local entity = World.entity()
			TestComponent.add(entity)

			local v0, v1, v2
			TestComponent.addedSignal:Once(function(_entity, _component, _player)
				v0, v1, v2 = _entity, _component, _player
			end)

			UserEntitySetup.replicateEntityComponents(player)
			expect(v0).to.be.ok()
			expect(v1).to.be.ok()
			expect(v2).to.be.ok()
		end)
	end)

	describe("newUser", function()
		beforeEach(function()
			UserEntitySetup.jan:Cleanup()

			for entity, _ in World.query({}) do
				World.kill(entity)
			end
		end)

		it("should return a number", function()
			UserEntitySetup.PlayerProfileStore = Profiles.createProfileTemplate()

			local player = Players:FindFirstChildWhichIsA("Player")
			expect(player).to.be.ok()

			local newUser = UserEntitySetup.newUser(player)
			expect(newUser).to.be.a("number")
		end)

		it("should be in world", function()
			UserEntitySetup.PlayerProfileStore = Profiles.createProfileTemplate()

			local player = Players:FindFirstChildWhichIsA("Player")
			expect(player).to.be.ok()

			local newUser = UserEntitySetup.newUser(player)
			expect(World.get(newUser)).to.be.a("table")
		end)
	end)

	describe("onBoot", function()
		beforeEach(function()
			UserEntitySetup.jan:Cleanup()

			for entity, _ in World.query({}) do
				World.kill(entity)
			end
		end)

		it("should populate PlayerProfileStore", function()
			UserEntitySetup.onBoot()
			expect(UserEntitySetup.PlayerProfileStore).to.be.a("table")
		end)

		it("should create PlayerAdded connection", function()
			UserEntitySetup.onBoot()
			expect(UserEntitySetup.jan:Get("PlayerAdded")).to.be.ok()
			expect(UserEntitySetup.jan:Get("PlayerAdded")).to.be.a("userdata")
		end)
	end)
end
