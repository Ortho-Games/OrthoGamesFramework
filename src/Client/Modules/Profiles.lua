local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local ProfileService = require(Globals.Packages.ProfileService)

local Profiles = {
	createdProfileTemplate = false,
}

local ProfileTemplate = {}

function Profiles.addDefaultData(id: string, defaultData: { string: any })
	ProfileTemplate[id] = defaultData
end

Profiles.GetProfileStore = function(): {}
	if Profiles.createdProfileTemplate then
		error("Function Profiles.createProfileTemplate can only be called once")
	end
	Profiles.createdProfileTemplate = true

	-- print(ProfileTemplate)

	return ProfileService.GetProfileStore("PlayerData", ProfileTemplate)
end

return Profiles
