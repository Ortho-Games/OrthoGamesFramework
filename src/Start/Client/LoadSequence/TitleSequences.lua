local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Net = require(ReplicatedStorage.Packages.Net)
local Promise = require(ReplicatedStorage.Packages.Promise)

local TitleSequences = {}

local function WaitForInputPromise()
	return Promise.fromEvent(UserInputService.InputBegan, function(input, gpe)
		return not gpe
			and (
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			)
	end)
end

function TitleSequences.preloadPromise()
	print("preloading title")
	return Promise.delay(1):andThenCall(print, "preloaded title")
end

function TitleSequences.startPromise()
	return Promise.try(function()
		-- transition to title screen
		print("starting title")
	end)
		:andThen(WaitForInputPromise)
		:andThen(function()
			-- while not Net:Invoke("RequestStart") do
			-- 	task.wait(3)
			-- end
			return Promise.delay(3):andThenCall(print, "finished title")
		end)
end

return TitleSequences
